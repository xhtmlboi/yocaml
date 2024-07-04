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

type days = Mon | Tue | Wed | Thu | Fri | Sat | Sun
type cloud_protocol = Xml_rpc | Soap | Http_post

module X = struct
  open Xml

  let title x = leaf ~name:"title" (escape x)
  let link x = leaf ~name:"link" (Some x)
  let description x = leaf ~name:"description" (cdata x)
  let url x = Attr.string ~key:"url" x
end

module Category = struct
  type t = { value : string; domain : string option }

  let make ?domain value = { value; domain }

  let to_xml { domain; value } =
    let attr =
      Option.map (fun value -> [ Xml.Attr.string ~key:"domain" value ]) domain
    in
    Xml.leaf ?attr ~name:"category" (Xml.cdata value)
end

module Email = struct
  type t = { email : string; name : string option }

  let make ?name email = { email; name }

  let to_string { name; email } =
    let n = Option.fold ~none:"" ~some:(fun x -> " (" ^ x ^ ")") name in
    email ^ n
end

module Cloud = struct
  type t = {
      domain : string
    ; port : int
    ; path : string
    ; register_procedure : string
    ; protocol : cloud_protocol
  }

  let protocol_to_string = function
    | Xml_rpc -> "xml-rpc"
    | Soap -> "soap"
    | Http_post -> "http-post"

  let make ~protocol ~domain ~port ~path ~register_procedure =
    { protocol; domain; port; path; register_procedure }

  let to_xml { protocol; domain; port; path; register_procedure } =
    Xml.node ~name:"cloud"
      ~attr:
        Xml.Attr.
          [
            string ~key:"protocol" @@ protocol_to_string protocol
          ; string ~key:"domain" domain
          ; int ~key:"port" port
          ; string ~key:"path" path
          ; string ~key:"registerProcedure" register_procedure
          ]
      []
end

module Image = struct
  type t = {
      title : string
    ; link : string
    ; url : string
    ; height : int option
    ; width : int option
    ; description : string option
  }

  let make ~title ~link ?description ?width ?height ~url () =
    let width = Option.map (fun x -> x |> Int.min 144 |> Int.max 1) width
    and height = Option.map (fun x -> x |> Int.min 400 |> Int.max 1) height in
    { title; link; url; height; width; description }

  let to_xml { title; link; url; height; width; description } =
    Xml.node ~name:"image"
      [
        Xml.leaf ~name:"url" (Some url)
      ; X.title title
      ; X.link link
      ; Xml.may_leaf ~finalize:Xml.cdata ~name:"description" Fun.id description
      ; Xml.may_leaf ~name:"width" string_of_int width
      ; Xml.may_leaf ~name:"height" string_of_int height
      ]
end

module Skip_hours = struct
  let to_xml l =
    Xml.node ~name:"skipHours"
      (List.map
         (fun x ->
           let x = x |> Int.min 23 |> Int.max 0 in
           Xml.leaf ~name:"hour" (Some (string_of_int x)))
         l)
end

module Skip_days = struct
  module S = Set.Make (struct
    type t = days

    let to_int = function
      | Mon -> 0
      | Tue -> 1
      | Wed -> 2
      | Thu -> 3
      | Fri -> 4
      | Sat -> 5
      | Sun -> 6

    let compare a b =
      let a = to_int a and b = to_int b in
      Int.compare a b
  end)

  let to_string x =
    Some
      (match x with
      | Mon -> "Monday"
      | Tue -> "Tuesday"
      | Wed -> "Wednesday"
      | Thu -> "Thursday"
      | Fri -> "Friday"
      | Sat -> "Saturday"
      | Sun -> "Sunday")

  let to_xml l =
    let s = S.of_list l |> S.to_list in
    Xml.node ~name:"skipDays"
      (List.map (fun x -> Xml.leaf ~name:"day" (to_string x)) s)
end

module Enclosure = struct
  type t = { length : int; media_type : Media_type.t; url : string }

  let make ~url ~media_type ~length =
    let length = Int.max 0 length in
    { length; media_type; url }

  let to_xml { length; media_type; url } =
    Xml.leaf ~name:"enclosure"
      ~attr:
        Xml.Attr.
          [
            X.url url
          ; int ~key:"length" length
          ; make ~key:"type" Media_type.to_string media_type
          ]
      None
end

module Guid = struct
  type t = { value : string; is_permalink : bool }
  type strategy = Given of t | From_link | From_title

  let from_link = From_link
  let from_title = From_title
  let create ~is_permalink value = { value; is_permalink }
  let make ~is_permalink value = Given (create ~is_permalink value)

  let to_xml { value; is_permalink } =
    Xml.leaf ~name:"guid"
      ~attr:Xml.Attr.[ bool ~key:"isPermaLink" is_permalink ]
      (Some value)
end

module Source = struct
  type t = { title : string; url : string }

  let make ~title ~url = { title; url }

  let to_xml { title; url } =
    Xml.leaf ~name:"source" ~attr:[ X.url url ] (Some title)
end

module Item = struct
  type t = {
      title : string
    ; link : string
    ; description : string
    ; author : Email.t option
    ; category : Category.t option
    ; comments : string option
    ; enclosure : Enclosure.t option
    ; guid : Guid.t option
    ; pub_date : Datetime.t option
    ; source : Source.t option
  }

  let make ?author ?category ?comments ?enclosure ?guid ?pub_date ?source ~title
      ~link ~description () =
    let guid =
      Option.map
        (function
          | Guid.Given g -> g
          | Guid.From_link -> Guid.create ~is_permalink:true link
          | Guid.From_title -> Guid.create ~is_permalink:false title)
        guid
    in
    {
      title
    ; link
    ; description
    ; author
    ; category
    ; comments
    ; enclosure
    ; guid
    ; pub_date
    ; source
    }

  let to_xml
      {
        title
      ; link
      ; description
      ; author
      ; category
      ; comments
      ; enclosure
      ; guid
      ; pub_date
      ; source
      } =
    Xml.node ~name:"item"
      [
        X.title title
      ; X.link link
      ; X.description description
      ; Xml.may_leaf ~name:"author" Email.to_string author
      ; Xml.may Category.to_xml category
      ; Xml.may_leaf ~name:"comments" Fun.id comments
      ; Xml.may Enclosure.to_xml enclosure
      ; Xml.may Guid.to_xml guid
      ; Xml.may_leaf ~name:"pubDate" Datetime.to_string pub_date
      ; Xml.may Source.to_xml source
      ]
end

module Channel = struct
  type 'a t = {
      title : string
    ; link : string
    ; url : string
    ; description : string
    ; language : Lang.t option
    ; copyright : string option
    ; managing_editor : Email.t option
    ; webmaster : Email.t option
    ; pub_date : Datetime.t option
    ; last_build_date : Datetime.t option
    ; category : Category.t option
    ; generator : string option
    ; cloud : Cloud.t option
    ; ttl : int option
    ; image : Image.t option
    ; text_input : Text_input.t option
    ; skip_hours : int list option
    ; skip_days : days list option
    ; items : 'a list
  }

  let make ?language ?copyright ?managing_editor ?webmaster ?pub_date
      ?last_build_date ?category ?generator ?cloud ?ttl ?image ?text_input
      ?skip_hours ?skip_days ~title ~link url ~description items =
    let image = Option.map (fun f -> f ~title ~link) image in
    {
      title
    ; link
    ; url
    ; description
    ; language
    ; copyright
    ; managing_editor
    ; webmaster
    ; pub_date
    ; last_build_date
    ; category
    ; generator
    ; cloud
    ; ttl
    ; image
    ; text_input
    ; skip_hours
    ; skip_days
    ; items
    }

  let to_xml f
      {
        title
      ; link
      ; url
      ; description
      ; language
      ; copyright
      ; managing_editor
      ; webmaster
      ; pub_date
      ; last_build_date
      ; category
      ; generator
      ; cloud
      ; ttl
      ; image
      ; text_input
      ; skip_hours
      ; skip_days
      ; items
      } =
    Xml.node ~name:"channel"
      ([
         X.title title
       ; X.link link
       ; X.description description
       ; Xml.leaf ~ns:"atom" ~name:"link"
           ~attr:
             Xml.Attr.
               [
                 string ~key:"href" url
               ; string ~key:"rel" "self"
               ; string ~key:"type" "application/rss+xml"
               ]
           None
       ; Xml.may_leaf ~name:"language" Lang.to_string language
       ; Xml.may_leaf ~name:"copyright" Fun.id copyright
       ; Xml.may_leaf ~name:"managingEditor" Email.to_string managing_editor
       ; Xml.may_leaf ~name:"webMaster" Email.to_string webmaster
       ; Xml.may_leaf ~name:"pubDate" Datetime.to_string pub_date
       ; Xml.may_leaf ~name:"lastBuildDate" Datetime.to_string last_build_date
       ; Xml.may Category.to_xml category
       ; (*Since the implementation of the current module was implemented on top
           of that documentation, it make no sense to make it parametric. *)
         Xml.leaf ~name:"docs"
           (Some "https://www.rssboard.org/rss-specification")
       ; Xml.may_leaf ~name:"generator" Fun.id generator
       ; Xml.may Cloud.to_xml cloud
       ; Xml.may_leaf ~name:"ttl" string_of_int ttl
       ; Xml.may Image.to_xml image
       ; Xml.may Text_input.to_rss2 text_input
       ; Xml.may Skip_hours.to_xml skip_hours
       ; Xml.may Skip_days.to_xml skip_days
       ]
      @ List.map (fun x -> x |> f |> Item.to_xml) items)
end

type email = Email.t
type cloud = Cloud.t
type enclosure = Enclosure.t
type guid = Guid.t
type guid_strategy = Guid.strategy
type source = Source.t
type image = Image.t
type item = Item.t
type category = Category.t

let email = Email.make
let category = Category.make
let cloud = Cloud.make
let guid_from_title = Guid.from_title
let guid_from_link = Guid.from_link
let guid = Guid.make
let source = Source.make
let image = Image.make
let enclosure = Enclosure.make
let item = Item.make

let feed ?encoding ?standalone ?language ?copyright ?managing_editor ?webmaster
    ?pub_date ?last_build_date ?category ?(generator = "YOCaml") ?cloud ?ttl
    ?image ?text_input ?skip_hours ?skip_days ~title ~link ~url ~description f
    items =
  let channel =
    Channel.make ?language ?copyright ?managing_editor ?webmaster ?pub_date
      ?last_build_date ?category ~generator ?cloud ?ttl ?image ?text_input
      ?skip_hours ?skip_days ~title ~link url ~description items
  in
  let nodes = [ Channel.to_xml f channel ] in
  Xml.document ?encoding ?standalone ~version:"1.0"
    (Xml.node ~name:"rss"
       ~attr:
         Xml.Attr.
           [
             string ~ns:"xmlns" ~key:"atom" "http://www.w3.org/2005/Atom"
           ; string ~key:"version" "2.0"
           ]
       nodes)

let from ?encoding ?standalone ?language ?copyright ?managing_editor ?webmaster
    ?pub_date ?last_build_date ?category ?(generator = "YOCaml") ?cloud ?ttl
    ?image ?text_input ?skip_hours ?skip_days ~title ~link ~url ~description f =
  Yocaml.Task.lift (fun articles ->
      let feed =
        feed ?encoding ?standalone ?language ?copyright ?managing_editor
          ?webmaster ?pub_date ?last_build_date ?category ~generator ?cloud ?ttl
          ?image ?text_input ?skip_hours ?skip_days ~title ~link ~url
          ~description f articles
      in
      Xml.to_string feed)

let from_articles ?encoding ?standalone ?language ?copyright ?managing_editor
    ?webmaster ?pub_date ?category ?(generator = "YOCaml") ?cloud ?ttl ?image
    ?text_input ?skip_hours ?skip_days ~title ~link ~url ~description () =
  Yocaml.Task.lift (fun articles ->
      let last_build_date =
        List.fold_left
          (fun acc (_, elt) ->
            let open Yocaml.Archetype in
            let b = Yocaml.Archetype.Article.date elt in
            match acc with
            | None -> Some b
            | Some a -> if Datetime.compare a b > 0 then Some a else Some b)
          None articles
        |> Option.map Datetime.make
      in

      let feed =
        feed ?encoding ?standalone ?language ?copyright ?managing_editor
          ?webmaster ?pub_date ?last_build_date ?category ~generator ?cloud ?ttl
          ?image ?text_input ?skip_hours ?skip_days ~title ~link ~url
          ~description
          (fun (path, article) ->
            let open Yocaml.Archetype.Article in
            let title = title article in
            let link = link ^ Yocaml.Path.to_string path in
            let description =
              Option.value ~default:"no description" (synopsis article)
            in
            let pub_date = Datetime.make (date article) in
            item ~title ~link ~description ~pub_date ())
          articles
      in
      Xml.to_string feed)
