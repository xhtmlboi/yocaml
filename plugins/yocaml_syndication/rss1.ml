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

module X = struct
  open Xml

  let title x = leaf ~name:"title" (escape x)
  let link x = leaf ~name:"link" (Some x)
  let url x = leaf ~name:"url" (Some x)
  let description x = leaf ~name:"description" (cdata x)
  let about x = Attr.string ~ns:"rdf" ~key:"about" x
  let resource x = Attr.string ~ns:"rdf" ~key:"resource" x
end

module Image = struct
  type t = { title : string; link : string; url : string }

  let to_xml { title; link; url } =
    Xml.node ~name:"image"
      ~attr:[ X.about url ]
      [ X.title title; X.link link; X.url url ]

  let make ~title ~link ~url = { title; link; url }
end

module Item = struct
  type t = { title : string; link : string; description : string }

  let to_xml { title; link; description } =
    Xml.node ~name:"item"
      ~attr:[ X.about link ]
      [ X.title title; X.link link; X.description description ]

  let make ~title ~link ~description = { title; link; description }
end

module Channel = struct
  type t = {
      title : string
    ; url : string
    ; link : string
    ; description : string
    ; image : Image.t option
    ; textinput : Text_input.t option
    ; items : Item.t list
  }

  let make ~title ~url ~link ~description ~image ~textinput ~items =
    { title; url; link; description; image; textinput; items }

  let make_image image =
    let open Xml in
    may
      (fun image ->
        leaf ~name:"image" ~attr:[ X.resource image.Image.url ] None)
      image

  let make_textinput textinput = Xml.may Text_input.to_rss1_channel textinput

  let make_items = function
    | [] -> None
    | xs ->
        let open Xml in
        let items =
          node ~name:"items"
            [
              node ~ns:"rdf" ~name:"Seq"
              @@ List.map
                   (fun item ->
                     leaf ~ns:"rdf" ~name:"li"
                       ~attr:Attr.[ string ~key:"resource" item.Item.link ]
                       None)
                   xs
            ]
        in
        Some items

  let to_xml { title; url; link; description; image; textinput; items } =
    Xml.node ~name:"channel"
      ~attr:[ X.about url ]
      [
        X.title title
      ; X.link link
      ; X.description description
      ; make_image image
      ; make_textinput textinput
      ; Xml.opt @@ make_items items
      ]
end

type image = Image.t
type item = Item.t

let image = Image.make
let item = Item.make

let feed ?encoding ?standalone ?image ?textinput ~title ~url ~link ~description
    f items =
  let items = List.map f items in
  let channel =
    Channel.make ~title ~url ~link ~description ~image ~textinput ~items
  in
  let nodes =
    [
      Channel.to_xml channel
    ; Xml.may Image.to_xml image
    ; Xml.may Text_input.to_rss1 textinput
    ]
    @ List.map (fun x -> Item.to_xml x) items
  in
  Xml.document ?encoding ?standalone ~version:"1.0"
    (Xml.node ~ns:"rdf" ~name:"RDF"
       ~attr:
         Xml.Attr.
           [
             string ~ns:"xmlns" ~key:"rdf"
               "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
           ; string ~key:"xmlns" "http://purl.org/rss/1.0/"
           ]
       nodes)

let from ?encoding ?standalone ?image ?textinput ~title ~url ~link ~description
    f =
  Yocaml.Task.lift (fun articles ->
      let feed =
        feed ?encoding ?standalone ?image ?textinput ~title ~url ~link
          ~description f articles
      in
      Xml.to_string feed)

let from_articles ?encoding ?standalone ?image ?textinput ~title ~url ~link
    ~description () =
  from ?encoding ?standalone ?image ?textinput ~title ~url ~link ~description
    (fun (path, article) ->
      let open Yocaml.Archetype in
      let title = Article.title article in
      let link = link ^ Yocaml.Path.to_string path in
      let description =
        Option.value ~default:"no description" (Article.synopsis article)
      in
      item ~title ~link ~description)
