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

type runtime_error =
  | Unable_to_write_file of Yocaml.Path.t * string
  | Unable_to_read_file of Yocaml.Path.t
  | Unable_to_read_directory of Yocaml.Path.t
  | Unable_to_read_mtime of Yocaml.Path.t

type 'a t = 'a

let bind f x = f x
let return x = x

let log level message =
  let level =
    match level with
    | `App -> Logs.App
    | `Error -> Logs.Error
    | `Warning -> Logs.Warning
    | `Info -> Logs.Info
    | `Debug -> Logs.Debug
  in
  Logs.msg level (fun print -> print "%s" message)

let file_exists ~on:_ path = Sys.file_exists @@ Yocaml.Path.to_string path
let is_directory ~on:_ path = Sys.is_directory @@ Yocaml.Path.to_string path

let rec create_directory path =
  if not (file_exists ~on:`Source path) then
    let parent = Yocaml.Path.dirname path in
    let () = create_directory parent in
    try
      let path_str = Yocaml.Path.to_string path in
      Unix.mkdir path_str 0o755
    with _ -> ()

let write_file ~on:_ path content =
  let () = create_directory (Yocaml.Path.dirname path) in
  try
    let () =
      Out_channel.with_open_text (Yocaml.Path.to_string path) (fun channel ->
          output_string channel content)
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

let read_dir ~on:_ path =
  try Sys.readdir @@ Yocaml.Path.to_string path |> Array.to_list |> Result.ok
  with _ -> Result.error (Unable_to_read_directory path)

let get_mtime ~on:_ path =
  try
    let st = Unix.stat (Yocaml.Path.to_string path) in
    let mt = st.Unix.st_mtime in
    Result.ok (int_of_float mt)
  with _ -> Result.error @@ Unable_to_read_mtime path

let hash_content value =
  value |> Digestif.SHA256.digest_string |> Digestif.SHA256.to_hex

let read_file ~on:_ path =
  try
    let output =
      In_channel.with_open_text
        (Yocaml.Path.to_string path)
        In_channel.input_all
    in
    Result.ok output
  with _ -> Result.error @@ Unable_to_read_file path
