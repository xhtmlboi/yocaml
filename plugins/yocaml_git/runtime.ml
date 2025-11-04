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

let to_kv_path x =
  let _, r = Yocaml.Path.to_pair x in
  Mirage_kv.Key.v (r |> String.concat Filename.dir_sep)

module Make
    (Source : Required.SOURCE)
    (Config : Required.CONFIG)
    (Store : Mirage_kv.RW with type t = Git_kv.t) =
struct
  module Runtime = struct
    type 'a t = 'a Lwt.t

    let bind f x = Lwt.bind x f
    let return = Lwt.return
    let log ?src level message = Source.lift @@ Source.log ?src level message

    type runtime_error =
      | Git of Yocaml_runtime.Error.common
      | Source of Source.runtime_error

    let store = Config.store

    let runtime_error_to_string = function
      | Git err -> Yocaml_runtime.Error.common_to_string err
      | Source err -> Source.runtime_error_to_string err

    let lift_result x =
      x
      |> Source.bind (function
           | Ok x -> Source.return @@ Ok x
           | Error err -> Source.return @@ Error (Source err))
      |> Source.lift

    let map_error f_err = function
      | Ok x -> Ok x
      | Error err -> Error (Git (f_err err))

    let hash_content x = Source.lift @@ Source.hash_content x
    let get_time () = Source.lift @@ Source.get_time ()

    let file_exists ~on path =
      match on with
      | `Source -> Source.lift @@ Source.file_exists ~on path
      | `Target ->
          let open Lwt.Syntax in
          let+ exists = Store.exists store (to_kv_path path) in
          exists |> Result.fold ~ok:Option.is_some ~error:(Fun.const false)

    let read_file ~on path =
      match on with
      | `Source -> lift_result @@ Source.read_file ~on path
      | `Target ->
          let open Lwt.Syntax in
          let+ content = Store.get store (to_kv_path path) in
          map_error
            (Fun.const @@ Yocaml_runtime.Error.Unable_to_read_file path)
            content

    let get_mtime ~on path =
      match on with
      | `Source -> lift_result @@ Source.get_mtime ~on path
      | `Target ->
          let open Lwt.Syntax in
          let+ mtime = Store.last_modified store (to_kv_path path) in
          mtime
          |> Result.map (fun x -> x |> Ptime.to_float_s |> Float.to_int)
          |> map_error
               (Fun.const @@ Yocaml_runtime.Error.Unable_to_read_file path)

    let create_directory ~on path =
      match on with
      | `Source -> lift_result @@ Source.create_directory ~on path
      | `Target ->
          (* Path are Keys in Git_kv so [create_dir] is useless*)
          Lwt.return @@ Ok ()

    let write_file ~on path content =
      match on with
      | `Source -> lift_result @@ Source.write_file ~on path content
      | `Target ->
          let open Lwt.Syntax in
          let+ result = Store.set store (to_kv_path path) content in
          map_error
            (Fun.const @@ Yocaml_runtime.Error.Unable_to_read_file path)
            result

    let is_directory ~on path =
      match on with
      | `Source -> Source.lift @@ Source.is_directory ~on path
      | `Target ->
          let open Lwt.Infix in
          Store.exists store (to_kv_path path)
          >|= Result.fold
                ~ok:(function Some `Dictionary -> true | _ -> false)
                ~error:(Fun.const false)

    let is_file ~on path =
      match on with
      | `Source -> Source.lift @@ Source.is_file ~on path
      | `Target ->
          let open Lwt.Infix in
          Store.exists store (to_kv_path path)
          >|= Result.fold
                ~ok:(function Some `Value -> true | _ -> false)
                ~error:(Fun.const false)

    let exec ?is_success prog args =
      lift_result @@ Source.exec ?is_success prog args

    let read_dir ~on path =
      match on with
      | `Source -> lift_result @@ Source.read_dir ~on path
      | `Target ->
          (* Should be used on the source side *)
          Lwt.return @@ Ok []
  end

  module Runner = Yocaml.Runtime.Make (Runtime)
  include Runtime
end
