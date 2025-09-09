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

let read_file ?snapshot file =
  Task.make (Deps.singleton file) (fun () ->
      Eff.read_file ?snapshot ~on:`Source file)

let directory_exists path =
  Task.from_effect ~has_dynamic_dependencies:false (fun () ->
      Eff.is_directory ~on:`Source path)

let file_exists path =
  Task.from_effect ~has_dynamic_dependencies:false (fun () ->
      Eff.is_file ~on:`Source path)

let read_file_with_metadata (type a) (module P : Required.DATA_PROVIDER)
    (module R : Required.DATA_READABLE with type t = a) ?extraction_strategy
    ?snapshot path =
  Task.make (Deps.singleton path) (fun () ->
      Eff.read_file_with_metadata
        (module P)
        (module R)
        ?extraction_strategy ?snapshot ~on:`Source path)

let read_file_as_metadata (type a) (module P : Required.DATA_PROVIDER)
    (module R : Required.DATA_READABLE with type t = a) ?snapshot path =
  Task.make (Deps.singleton path) (fun () ->
      Eff.read_file_as_metadata (module P) (module R) ?snapshot ~on:`Source path)

let read_template (module T : Required.DATA_TEMPLATE) ?(snapshot = true)
    ?(strict = true) template =
  let open Task in
  read_file ~snapshot template
  >>> lift ~has_dynamic_dependencies:false (fun template_content ->
          let callback (type a)
              (module I : Required.DATA_INJECTABLE with type t = a) ~metadata
              content =
            let parameters =
              ("yocaml_body", Data.string content) :: I.normalize metadata
              |> List.map (fun (k, v) -> (k, T.from v))
            in
            T.render ~strict parameters template_content
          in
          callback)

module type S = Required.DATA_INJECTABLE

let read_templates (type a) (module T : Required.DATA_TEMPLATE)
    ?(snapshot = true) ?(strict = true) (templates : Path.t list) =
  match List.map (read_template (module T) ~snapshot ~strict) templates with
  | [] ->
      Task.pure
        (fun (module I : S with type t = a) ~metadata:_ (content : string) ->
          content)
  | x :: xs ->
      List.fold_left
        (fun acc t ->
          let af f g (module I : S with type t = a) ~metadata content =
            g
              (module I : S with type t = a)
              ~metadata
              (f (module I : S with type t = a) ~metadata content)
          in
          Task.map2 af acc t)
        x xs

let as_template (type a) (module T : Required.DATA_TEMPLATE)
    (module I : Required.DATA_INJECTABLE with type t = a) ?(snapshot = true)
    ?(strict = true) template =
  let action ((meta, content), tpl_content) =
    let parameters = ("yocaml_body", Data.string content) :: I.normalize meta in
    let parameters = List.map (fun (k, v) -> (k, T.from v)) parameters in
    try
      let new_content = T.render ~strict parameters tpl_content in
      Eff.return (meta, new_content)
    with exn -> Eff.raise exn
  in
  let open Task in
  (fun x -> (x, ())) |>> second (read_file ~snapshot template) >>* action

let chain_templates (type a) (module T : Required.DATA_TEMPLATE)
    (module I : Required.DATA_INJECTABLE with type t = a) ?(snapshot = true)
    ?(strict = true) templates =
  List.fold_left
    (fun task template ->
      let open Task in
      task >>> as_template ~snapshot ~strict (module T) (module I) template)
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

let fetch_some ?(only = `Files) ?(where = fun _ -> true) ?(on = `Source)
    callback path =
  Task.rcompose (track_file path)
    (Task.from_effect (fun () ->
         let open Eff in
         let* files = read_directory ~on ~only ~where path in
         List.filter_map callback files))

let fetch ?only ?where ?on callback =
  fetch_some ?only ?where ?on (fun p ->
      let open Eff in
      let+ result = callback p in
      Some result)
