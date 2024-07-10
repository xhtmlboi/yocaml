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

type t = { term : string; scheme : string option; label : string option }

let make ?scheme ?label term = { term; scheme; label }

let to_atom { term; scheme; label } =
  let attr =
    let open Xml.Attr in
    let scheme = Option.(scheme |> map (string ~key:"scheme") |> to_list) in
    let label = Option.(label |> map (escaped ~key:"label") |> to_list) in
    escaped ~key:"term" term :: (scheme @ label)
  in
  Xml.leaf ~name:"category" ~attr None

let to_rss2 { term; scheme; _ } =
  let attr =
    Option.map (fun value -> [ Xml.Attr.string ~key:"domain" value ]) scheme
  in
  Xml.leaf ?attr ~name:"category" (Xml.cdata term)
