(* YOCaml a static blog generator.
   Copyright (C) 2024 The Funkyworkers and The YOCaml's developers

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

module Required = Required

let run (module Source : Required.SOURCE) (module Clock : Mirage_clock.PCLOCK)
    ~context ?author ?email ?message ~remote ?level ?custom_error_handler
    program =
  let open Lwt.Syntax in
  let () = Mirage_crypto_rng_unix.use_default () in
  let* context = match context with `SSH -> Ssh.context () in
  let* store = Git_kv.connect context remote in
  let module Store = Git_kv.Make (Clock) in
  let module Store = struct
    include Store

    (* last_modified and change_and_push have a weird interaction;
       so we show the old last_modified *)
    let last_modified new_store key =
      let* r = last_modified store key in
      match r with
      | Error (`Not_found _) -> last_modified new_store key
      | _ -> Lwt.return r
  end in
  Store.change_and_push ?author ?author_email:email ?message store (fun store ->
      let module Config = struct
        let store = store
      end in
      let module Runtime = Runtime.Make (Source) (Config) (Store) in
      let () = Yocaml_runtime.Log.setup ?level () in
      Runtime.Runner.run ?custom_error_handler program)

module From_identity (Source : Yocaml.Required.RUNTIME with type 'a t = 'a) =
struct
  include Source

  let lift x = Lwt.return x
end
