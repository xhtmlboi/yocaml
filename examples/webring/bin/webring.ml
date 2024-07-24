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

open Yocaml

let process_index =
  let source = Source.index in
  let target = Target.(as_html source) in
  Action.write_static_file target
    (let open Task in
     Pipeline.track_file Source.binary
     >>> (Yocaml_yaml.Pipeline.read_file_as_metadata
            (module Model)
            Source.members
         &&& Pipeline.read_file source)
     >>> Yocaml_omd.content_to_html ()
     >>> Yocaml_jingoo.Pipeline.as_template
           (module Model)
           (Source.template "index.html")
     >>> Yocaml_jingoo.Pipeline.as_template
           (module Model)
           (Source.template "layout.html")
     >>> drop_first ())

let write_chain select member =
  let path =
    match select with `Prev -> "prev" | `Curr -> "curr" | `Succ -> "succ"
  in
  let member = Model.Cycle.select select member in
  let curr = Model.Cycle.curr member in
  let target = Path.(Target.root / Model.Member.id curr) in
  Action.write_static_file
    Path.(target / path / "index.html")
    (let open Task in
     Pipeline.track_files [ Source.binary; Source.members ]
     >>> const member
     >>> empty_body ()
     >>> Yocaml_jingoo.Pipeline.as_template
           (module Model.Cycle)
           (Source.template "layout.html")
     >>> drop_first ())

let process_members members =
  let open Eff in
  Action.batch_list (Model.Cycle.from members) (fun member cache ->
      cache |> write_chain `Prev member >>= write_chain `Succ member)

let generate_opml members =
  let members = Model.to_outlines members in
  Action.write_static_file Target.opml
    (let open Task in
     Pipeline.track_files [ Source.binary; Source.members ]
     >>> const members
     >>> Yocaml_syndication.Opml.opml2_from ~title:"Webring OPML" ())

let process_all () =
  let open Eff in
  let* members =
    Yocaml_yaml.Eff.read_file_as_metadata ~on:`Source
      (module Model)
      Source.members
  in
  Action.restore_cache Target.cache
  >>= process_index
  >>= process_members members
  >>= generate_opml members
  >>= Action.store_cache Target.cache

let () =
  match Array.to_list Sys.argv with
  | _ :: "serve" :: xs ->
      let port =
        Option.bind (List.nth_opt xs 0) int_of_string_opt
        |> Option.value ~default:8000
      in
      Yocaml_eio.serve ~level:Logs.Info ~target:Target.root ~port process_all
  | _ -> Yocaml_eio.run process_all
