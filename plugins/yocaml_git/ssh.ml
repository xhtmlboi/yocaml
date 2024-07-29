(* YOCaml a static blog generator.
   Copyright (C) 2024 Romain Calascibetta

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

module Ctx = struct
  type error = Unix.error * string * string
  type write_error = [ `Closed | `Error of Unix.error * string * string ]

  let pp_error ppf (err, f, v) =
    Fmt.pf ppf "%s(%s): %s" f v (Unix.error_message err)

  let pp_write_error ppf = function
    | `Closed -> Fmt.pf ppf "Connection closed by peer"
    | `Error (err, f, v) -> Fmt.pf ppf "%s(%s): %s" f v (Unix.error_message err)

  type flow = { ic : in_channel; oc : out_channel }

  type endpoint = {
      user : string
    ; path : string
    ; host : Unix.inet_addr
    ; port : int
    ; mode : [ `Rd | `Wr ]
  }

  let pp_inet_addr ppf inet_addr =
    Fmt.string ppf (Unix.string_of_inet_addr inet_addr)

  let connect { user; path; host; port; mode } =
    let edn = Fmt.str "%s@%a" user pp_inet_addr host in
    let cmd = match mode with
      | `Wr -> Fmt.str {sh|git-receive-pack '%s'|sh} path
      | `Rd -> Fmt.str {sh|git-upload-pack '%s'|sh} path in
    let cmd = Fmt.str "ssh -p %d %s %a" port edn Fmt.(quote string) cmd in
    try
      let ic, oc = Unix.open_process cmd in
      Lwt.return_ok { ic; oc }
    with Unix.Unix_error (err, f, v) -> Lwt.return_error (`Error (err, f, v))

  let read t =
    let tmp = Bytes.create 0x1000 in
    try
      let len = input t.ic tmp 0 0x1000 in
      if len = 0 then Lwt.return_ok `Eof
      else Lwt.return_ok (`Data (Cstruct.of_bytes tmp ~off:0 ~len))
    with Unix.Unix_error (err, f, v) -> Lwt.return_error (err, f, v)

  let write t cs =
    let str = Cstruct.to_string cs in
    try
      output_string t.oc str;
      flush t.oc;
      Lwt.return_ok ()
    with Unix.Unix_error (err, f, v) -> Lwt.return_error (`Error (err, f, v))

  let writev t css =
    let rec go t = function
      | [] -> Lwt.return_ok ()
      | x :: r -> (
          let open Lwt.Infix in
          write t x >>= function
          | Ok () -> go t r
          | Error _ as err -> Lwt.return err)
    in
    go t css

  let close t =
    close_in t.ic;
    close_out t.oc;
    Lwt.return_unit

  let shutdown t = function
    | `read ->
        close_in t.ic;
        Lwt.return_unit
    | `write ->
        close_out t.oc;
        Lwt.return_unit
    | `read_write -> close t
end

let register ?priority ?(name = "ssh") () =
  Mimic.register ?priority ~name (module Ctx)

let context () =
  let ssh_edn, _ = register () in
  let k scheme user path host port mode =
    match (scheme, Unix.gethostbyname host) with
    | `SSH, { Unix.h_addr_list; _ } when Array.length h_addr_list > 0 ->
        Lwt.return_some { Ctx.user; path; host = h_addr_list.(0); port; mode }
    | _ -> Lwt.return_none
  in
  let open Lwt.Syntax in
  let+ context = Git_unix.ctx @@ Happy_eyeballs_lwt.create () in
  context
  |> Mimic.fold Smart_git.git_transmission
       Mimic.Fun.[ req Smart_git.git_scheme ]
       ~k:(function `SSH -> Lwt.return_some `Exec | _ -> Lwt.return_none)
  |> Mimic.fold ssh_edn
       Mimic.Fun.
         [
           req Smart_git.git_scheme
         ; req Smart_git.git_ssh_user
         ; req Smart_git.git_path
         ; req Smart_git.git_hostname
         ; dft Smart_git.git_port 22
         ; req Smart_git.git_capabilities
         ]
       ~k
