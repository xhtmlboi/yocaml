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

type t = { title : string; description : string; name : string; link : string }

let make ~title ~description ~name ~link = { title; description; name; link }

module X = struct
  open Xml

  let title x = leaf ~name:"title" (escape x)
  let name x = leaf ~name:"name" (escape x)
  let link x = leaf ~name:"link" (Some x)
  let description x = leaf ~name:"description" (cdata x)
  let resource x = Attr.string ~ns:"rdf" ~key:"resource" x
end

let to_rss1_channel { link; _ } =
  Xml.leaf ~name:"textinput" ~attr:[ X.resource link ] None

let to_rss1 { title; description; name; link } =
  Xml.node ~name:"textinput"
    ~attr:[ Xml.Attr.string ~ns:"rdf" ~key:"about" link ]
    [ X.title title; X.description description; X.name name; X.link link ]

let to_rss2 { title; description; name; link } =
  Xml.node ~name:"textInput"
    [ X.title title; X.description description; X.name name; X.link link ]
