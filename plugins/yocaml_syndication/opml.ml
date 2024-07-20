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

module Head = struct
  type t = {
      title : string option
    ; date_created : Datetime.t option
    ; date_modified : Datetime.t option
    ; owner : Person.t option
    ; expansion_state : int list
    ; vert_scroll_state : int option
    ; window_top : int option
    ; window_left : int option
    ; window_bottom : int option
    ; window_right : int option
  }

  let make ?title ?date_created ?date_modified ?owner ?(expansion_state = [])
      ?vert_scroll_state ?window_top ?window_left ?window_bottom ?window_right
      () =
    {
      title
    ; date_created
    ; date_modified
    ; owner
    ; expansion_state
    ; vert_scroll_state
    ; window_top
    ; window_left
    ; window_right
    ; window_bottom
    }

  let expand = function [] -> None | list -> Some list

  let to_xml
      {
        title
      ; date_created
      ; date_modified
      ; owner
      ; expansion_state
      ; vert_scroll_state
      ; window_top
      ; window_left
      ; window_right
      ; window_bottom
      } =
    let open Xml in
    [
      may_leaf ~name:"title" Fun.id title
    ; may_leaf ~name:"dateCreated" Datetime.to_string date_created
    ; may_leaf ~name:"dateModified" Datetime.to_string date_modified
    ; may Person.to_owner_name owner
    ; may Person.to_owner_email owner
    ; may_leaf ~name:"expansionState"
        (fun x -> x |> List.map string_of_int |> String.concat ",")
        (expand expansion_state)
    ; may_leaf ~name:"vertScrollState" string_of_int vert_scroll_state
    ; may_leaf ~name:"windowTop" string_of_int window_top
    ; may_leaf ~name:"windowLeft" string_of_int window_left
    ; may_leaf ~name:"windowRight" string_of_int window_right
    ; may_leaf ~name:"windowBottom" string_of_int window_bottom
    ]

  let to_opml1 head = Xml.node ~name:"head" (to_xml head)

  let to_opml2 head =
    Xml.node ~name:"head"
      (to_xml head
      @ [
          Xml.leaf ~name:"docs" (Some "http://opml.org/spec2.opml")
        ; Xml.may Person.to_owner_id head.owner
        ])
end

module Outline = struct
  type t = {
      text : string
    ; typ : string option
    ; title : string option
    ; is_comment : bool option
    ; is_breakpoint : bool option
    ; xml_url : string option
    ; html_url : string option
    ; categories : string list
    ; attr : Xml.Attr.t list
    ; outlines : t list
  }

  let make ?typ ?is_comment ?is_breakpoint ?xml_url ?html_url ?(attr = [])
      ?(categories = []) ?title ~text outlines =
    {
      text
    ; typ
    ; title
    ; is_breakpoint
    ; is_comment
    ; xml_url
    ; html_url
    ; categories
    ; attr
    ; outlines
    }

  let rec to_opml
      {
        text
      ; typ
      ; title
      ; is_breakpoint
      ; is_comment
      ; xml_url
      ; html_url
      ; categories
      ; attr
      ; outlines
      } =
    let text = Xml.Attr.string ~key:"text" text in
    let is_comment =
      is_comment
      |> Option.map (Xml.Attr.bool ~key:"isComment")
      |> Option.to_list
    in
    let is_breakpoint =
      is_breakpoint
      |> Option.map (Xml.Attr.bool ~key:"isBreakpoint")
      |> Option.to_list
    in
    let typ =
      typ |> Option.map (Xml.Attr.string ~key:"type") |> Option.to_list
    in
    let title =
      title |> Option.map (Xml.Attr.string ~key:"title") |> Option.to_list
    in
    let xml_url =
      xml_url |> Option.map (Xml.Attr.string ~key:"xmlUrl") |> Option.to_list
    in
    let html_url =
      html_url |> Option.map (Xml.Attr.string ~key:"xmlUrl") |> Option.to_list
    in
    let categories =
      match categories with
      | [] -> []
      | categories ->
          [ String.concat "," categories |> Xml.Attr.string ~key:"category" ]
    in
    let attr =
      typ
      @ xml_url
      @ html_url
      @ title
      @ attr
      @ categories
      @ is_breakpoint
      @ is_comment
      @ [ text ]
    in
    Xml.node ~name:"outline" ~attr (List.map to_opml outlines)
end

module Body = struct
  type t = Outline.t list

  let to_opml l = Xml.node ~name:"body" (List.map Outline.to_opml l)
end

module Feed = struct
  type t = Head.t * Body.t

  let make ~head body = (head, body)

  let to_opml1 ?encoding ?standalone (head, body) =
    Xml.document ~version:"1.0" ?encoding ?standalone
      (Xml.node ~name:"opml"
         ~attr:Xml.Attr.[ string ~key:"version" "1.0" ]
         [ Head.to_opml1 head; Body.to_opml body ])

  let to_opml2 ?encoding ?standalone (head, body) =
    Xml.document ~version:"1.0" ?encoding ?standalone
      (Xml.node ~name:"opml"
         ~attr:Xml.Attr.[ string ~key:"version" "2.0" ]
         [ Head.to_opml2 head; Body.to_opml body ])
end

type outline = Outline.t
type t = Feed.t

let outline = Outline.make

let inclusion ~url ~text =
  outline ~typ:"link" ~attr:Xml.Attr.[ string ~key:"url" url ] ~text []

let subscription ?version ?description ?html_url ?language ~title ~feed_url () =
  let attr =
    let description =
      description
      |> Option.map (Xml.Attr.string ~key:"description")
      |> Option.to_list
    in
    let language =
      language |> Option.map (Xml.Attr.string ~key:"language") |> Option.to_list
    in
    let version =
      version |> Option.map (Xml.Attr.string ~key:"version") |> Option.to_list
    in
    description @ language @ version @ []
  in
  outline ~typ:"rss" ~xml_url:feed_url ~attr ?html_url ~text:title ~title []

let feed ?title ?date_created ?date_modified ?owner ?expansion_state
    ?vert_scroll_state ?window_top ?window_left ?window_bottom ?window_right
    outlines =
  let head =
    Head.make ?title ?date_created ?date_modified ?owner ?expansion_state
      ?vert_scroll_state ?window_top ?window_left ?window_bottom ?window_right
      ()
  in
  Feed.make ~head outlines

let to_opml1 ?encoding ?standalone feed =
  Feed.to_opml1 ?encoding ?standalone feed

let to_opml2 ?encoding ?standalone feed =
  Feed.to_opml2 ?encoding ?standalone feed
