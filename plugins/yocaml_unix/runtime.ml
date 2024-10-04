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

type 'a t = 'a

let bind f x = f x
let return x = x

type runtime_error = Yocaml_runtime.Error.common

let runtime_error_to_string = Yocaml_runtime.Error.common_to_string
let hash_content s = Yocaml_runtime.Hash.content s
let log = Yocaml_runtime.Log.msg
let get_time () = Unix.time () |> int_of_float

let file_exists ~on:_ path =
  let path = Yocaml.Path.to_string path in
  Sys.file_exists path

let is_directory ~on:_ path =
  let path = Yocaml.Path.to_string path in
  try Sys.is_directory path with _ -> false

let create_directory ~on:_ path =
  try
    let path = Yocaml.Path.to_string path in
    let () = Unix.mkdir path 0o755 in
    Ok ()
  with _ -> Error (Yocaml_runtime.Error.Unable_to_create_directory path)

let write_file ~on:_ path content =
  try
    let path = Yocaml.Path.to_string path in
    let () =
      Out_channel.with_open_text path (fun channel ->
          Out_channel.output_string channel content)
    in
    Ok ()
  with _ -> Error (Yocaml_runtime.Error.Unable_to_write_file (path, content))

let read_dir ~on:_ path =
  try
    let path = Yocaml.Path.to_string path in
    let children = path |> Sys.readdir |> Array.to_list in
    Ok children
  with _ -> Result.error (Yocaml_runtime.Error.Unable_to_read_directory path)

let get_mtime ~on:_ path =
  try
    let path = Yocaml.Path.to_string path in
    let stat = Unix.lstat path in
    let mtim = stat.Unix.st_mtime in
    Result.ok @@ int_of_float mtim
  with _ -> Result.error @@ Yocaml_runtime.Error.Unable_to_read_mtime path

let read_file ~on:_ path =
  try
    let path = Yocaml.Path.to_string path in
    let output = In_channel.with_open_text path In_channel.input_all in
    Result.ok output
  with _ -> Result.error @@ Yocaml_runtime.Error.Unable_to_read_file path

let exec ?(is_success = Int.equal 0) exec_name args =
  let command = String.concat " " (exec_name :: args) in
  try
    let temporary = Filename.temp_file "yocaml_" "_unix_cmd" in
    let full_cmd = command ^ " > " ^ temporary in
    let exit_code =
      match Unix.system full_cmd with
      | Unix.WEXITED x | Unix.WSIGNALED x | Unix.WSTOPPED x -> x
    in
    let () = if not (is_success exit_code) then raise (Failure command) in
    let output = In_channel.with_open_bin temporary In_channel.input_all in
    let () = Unix.unlink temporary in
    Result.ok output
  with exn ->
    Result.error @@ Yocaml_runtime.Error.Unable_to_perform_command (command, exn)
