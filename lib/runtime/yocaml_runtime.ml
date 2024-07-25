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
  | Unable_to_create_directory of Yocaml.Path.t
  | Unable_to_read_file of Yocaml.Path.t
  | Unable_to_read_directory of Yocaml.Path.t
  | Unable_to_read_mtime of Yocaml.Path.t
  | Unable_to_perform_command of string * exn

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
  | Unable_to_create_directory path ->
      Format.asprintf "%s: Unable to create directory: `%a`" heading
        Yocaml.Path.pp path
  | Unable_to_perform_command (prog, _) ->
      Format.asprintf "%s: Unable to perform command: `%s`" heading prog

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

let setup_logger ?level () =
  let header = Logs_fmt.pp_header in
  let () = Fmt_tty.setup_std_outputs () in
  let () = Logs.set_reporter Logs_fmt.(reporter ~pp_header:header ()) in
  Logs.set_level level

let hash_content value =
  value |> Digestif.SHA256.digest_string |> Digestif.SHA256.to_hex
