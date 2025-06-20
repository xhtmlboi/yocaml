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

let track_files list = Task.make (Deps.from_list list) Eff.return
let track_file file = track_files [ file ]

let read_file file =
  Task.make (Deps.singleton file) (fun () -> Eff.read_file ~on:`Source file)

let directory_exists path =
  Task.from_effect ~has_dynamic_dependencies:false (fun () ->
      Eff.is_directory ~on:`Source path)

let file_exists path =
  Task.from_effect ~has_dynamic_dependencies:false (fun () ->
      Eff.is_file ~on:`Source path)

let read_file_with_metadata (type a) (module P : Required.DATA_PROVIDER)
    (module R : Required.DATA_READABLE with type t = a) ?extraction_strategy
    path =
  Task.make (Deps.singleton path) (fun () ->
      Eff.read_file_with_metadata
        (module P)
        (module R)
        ?extraction_strategy ~on:`Source path)

let read_file_as_metadata (type a) (module P : Required.DATA_PROVIDER)
    (module R : Required.DATA_READABLE with type t = a) path =
  Task.make (Deps.singleton path) (fun () ->
      Eff.read_file_as_metadata (module P) (module R) ~on:`Source path)

let as_template (type a) (module T : Required.DATA_TEMPLATE)
    (module I : Required.DATA_INJECTABLE with type t = a) ?(strict = true)
    template =
  let action ((meta, content), tpl_content) =
    let parameters = ("yocaml_body", Data.string content) :: I.normalize meta in
    let parameters = List.map (fun (k, v) -> (k, T.from v)) parameters in
    try
      let new_content = T.render ~strict parameters tpl_content in
      Eff.return (meta, new_content)
    with exn -> Eff.raise exn
  in
  let open Task in
  (fun x -> (x, ())) |>> second (read_file template) >>* action

let chain_templates (type a) (module T : Required.DATA_TEMPLATE)
    (module I : Required.DATA_INJECTABLE with type t = a) ?(strict = true)
    templates =
  List.fold_left
    (fun task template ->
      let open Task in
      task >>> as_template ~strict (module T) (module I) template)
    Task.id templates

let exec_cmd_with_result ?is_success cmd =
  let deps = cmd |> Cmd.deps_of |> Deps.from_list in
  Task.make ~has_dynamic_dependencies:false deps (fun () ->
      Eff.exec_cmd ?is_success cmd)

let exec_cmd ?is_success cmd =
  Task.rcompose
    (exec_cmd_with_result ?is_success cmd)
    (Task.lift ~has_dynamic_dependencies:false (fun _result -> ()))

let pipe f arr =
  let open Task in
  let lift f = lift ~has_dynamic_dependencies:false f in
  lift (fun x -> (x, ())) >>> second arr >>> lift (fun (a, b) -> f a b)

let pipe_files ?(separator = "") files =
  let f x y = x ^ separator ^ y in
  List.fold_left
    (fun arr file -> Task.(arr >>> pipe f (read_file file)))
    (Task.const "") files
