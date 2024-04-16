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

let read_file_with_metadata (type a) (module P : Required.DATA_PROVIDER)
    (module R : Required.DATA_READABLE with type t = a) ?extraction_strategy
    path =
  Task.make (Deps.singleton path) (fun () ->
      Eff.read_file_with_metadata
        (module P)
        (module R)
        ?extraction_strategy ~on:`Source path)

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
