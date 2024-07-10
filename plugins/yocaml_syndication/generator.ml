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

type t = { name : string; uri : string option; version : string option }

let make ?uri ?version name = { name; uri; version }

let to_atom { name; uri; version } =
  let attr =
    let open Xml.Attr in
    let uri = Option.(uri |> map (string ~key:"uri") |> to_list) in
    let version = Option.(version |> map (escaped ~key:"version") |> to_list) in
    uri @ version
  in
  Xml.leaf ~name:"generator" ~attr (Xml.escape name)

let to_rss2 { name; _ } = Xml.leaf ~name:"generator" (Some name)

let yocaml =
  make ~uri:"https://github.com/xhtmlboi/yocaml" ~version:"2" "YOCaml"
