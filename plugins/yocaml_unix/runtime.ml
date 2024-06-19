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

include Yocaml.Reader.Over (struct
  type env = Eio_unix.Stdenv.base
  type 'a monad = 'a

  let return x = x
  let bind f = f
end)

type runtime_error =
  | Unable_to_write_file of Yocaml.Path.t * string
  | Unable_to_read_file of Yocaml.Path.t
  | Unable_to_read_directory of Yocaml.Path.t
  | Unable_to_read_mtime of Yocaml.Path.t

let to_eio_path env p =
  let k, fragments = Yocaml.Path.to_pair p in
  let root =
    match k with
    | `Rel -> Eio.Stdenv.cwd env
    | `Root -> Eio.Path.(Eio.Stdenv.fs env / "/")
  in
  List.fold_left Eio.Path.( / ) root fragments

let log level message _env =
  let level =
    match level with
    | `App -> Logs.App
    | `Error -> Logs.Error
    | `Warning -> Logs.Warning
    | `Info -> Logs.Info
    | `Debug -> Logs.Debug
  in
  Logs.msg level (fun print -> print "%s" message)

let file_exists ~on:_ path env =
  let path = to_eio_path env path in
  match Eio.Path.kind ~follow:true path with `Not_found -> false | _ -> true

let is_directory ~on:_ path env =
  let path = to_eio_path env path in
  Eio.Path.is_directory path

let rec create_directory path env =
  if not (file_exists ~on:`Source path env) then
    let parent = Yocaml.Path.dirname path in
    let () = create_directory parent env in
    try
      let path = to_eio_path env path in
      Eio.Path.mkdir ~perm:0o755 path
    with _ -> ()

let write_file ~on:_ path content env =
  let () = create_directory (Yocaml.Path.dirname path) env in
  try
    let path = to_eio_path env path in
    let () =
      Eio.Path.save ~append:false ~create:(`Or_truncate 0o755) path content
    in
    Ok ()
  with _ -> Error (Unable_to_write_file (path, content))

let runtime_error_to_string runtime_error =
  let heading = "Runtime error:" in
  match runtime_error with
  | Unable_to_write_file (path, _) ->
      Format.asprintf "%s Unable to write file: `%a`" heading Yocaml.Path.pp
        path
  | Unable_to_read_directory path ->
      Format.asprintf "%s: Unable to read directory: `%a`" heading
        Yocaml.Path.pp path
  | Unable_to_read_mtime path ->
      Format.asprintf "%s: Unable to read mtime: `%a`" heading Yocaml.Path.pp
        path
  | Unable_to_read_file path ->
      Format.asprintf "%s: Unable to read file: `%a`" heading Yocaml.Path.pp
        path

let read_dir ~on:_ path env =
  try path |> to_eio_path env |> Eio.Path.read_dir |> Result.ok
  with _ -> Result.error (Unable_to_read_directory path)

let get_mtime ~on:_ path env =
  try
    let path = to_eio_path env path in
    let stat = Eio.Path.stat ~follow:true path in
    let mtim = stat.Eio.File.Stat.mtime in
    Result.ok @@ int_of_float mtim
  with _ -> Result.error @@ Unable_to_read_mtime path

let hash_content value _env =
  value |> Digestif.SHA256.digest_string |> Digestif.SHA256.to_hex

let read_file ~on:_ path env =
  try
    let path = to_eio_path env path in
    let output = Eio.Path.load path in
    Result.ok output
  with _ -> Result.error @@ Unable_to_read_file path
