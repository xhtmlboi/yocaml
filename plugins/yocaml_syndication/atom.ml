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

module Text_construct = struct
  type t = Text of string | Html of string | Xhtml of Xml.node

  let text s = Text s
  let html s = Html s

  let xhtml ?(need_prefix = false) x =
    let x = if need_prefix then Xml.namespace ~ns:"xhtml" x else x in
    Xhtml x
end

type link_rel = Alternate | Related | Self | Enclosure | Via | Link of string

module Link = struct
  type t = {
      href : string
    ; rel : link_rel option
    ; media_type : Media_type.t option
    ; hreflang : string option
    ; title : string option
    ; length : int option
  }

  let rel_to_string = function
    | Alternate -> "alternate"
    | Related -> "related"
    | Self -> "self"
    | Enclosure -> "enclosure"
    | Via -> "via"
    | Link uri -> uri

  let rel_to_attr x = Xml.Attr.string ~key:"rel" (rel_to_string x)

  let make ?rel ?media_type ?hreflang ?length ?title href =
    { rel; media_type; hreflang; length; title; href }

  let to_xml { rel; media_type; hreflang; length; title; href } =
    let attr =
      let open Xml.Attr in
      let open Option in
      let rel = rel |> map rel_to_attr |> to_list in
      let media_type =
        media_type
        |> map (fun x -> string ~key:"type" @@ Media_type.to_string x)
        |> to_list
      in
      let hreflang = hreflang |> map (string ~key:"hreflang") |> to_list in
      let length = length |> map (int ~key:"length") |> to_list in
      let title = title |> map (escaped ~key:"title") |> to_list in
      let href = string ~key:"href" href in
      href :: (rel @ title @ media_type @ hreflang @ length)
    in
    Xml.leaf ~name:"link" ~attr None
end

let text_node ~name = function
  | Text_construct.Text t ->
      Xml.leaf ~name ~attr:Xml.Attr.[ string ~key:"type" "text" ] (Xml.escape t)
  | Text_construct.Html h ->
      Xml.leaf ~name ~attr:Xml.Attr.[ string ~key:"type" "html" ] (Xml.escape h)
  | Text_construct.Xhtml xh ->
      Xml.node ~name
        ~attr:
          Xml.Attr.
            [
              string ~key:"type" "xhtml"
            ; string ~ns:"xmlns" ~key:"xhtml" "http://www.w3.org/1999/xhtml"
            ]
        [ xh ]

module Source = struct
  type t = {
      title : Text_construct.t option
    ; subtitle : Text_construct.t option
    ; authors : Person.t list
    ; contributors : Person.t list
    ; categories : Category.t list
    ; generator : Generator.t option
    ; icon : string option
    ; logo : string option
    ; id : string option
    ; links : Link.t list
    ; rights : Text_construct.t option
    ; updated : Datetime.t option
  }

  let change_updated t updated = { t with updated = Some updated }

  let make ?subtitle ?(contributors = []) ?(categories = [])
      ?(generator = Some Generator.yocaml) ?icon ?logo ?(links = []) ?rights
      ?updated ?title ?(authors = []) ?id () =
    {
      title
    ; subtitle
    ; authors
    ; contributors
    ; categories
    ; generator
    ; icon
    ; logo
    ; id
    ; links
    ; rights
    ; updated
    }

  let to_xml
      {
        title
      ; subtitle
      ; authors
      ; contributors
      ; categories
      ; generator
      ; icon
      ; logo
      ; id
      ; links
      ; rights
      ; updated
      } =
    let authors = authors |> List.map (Person.to_atom ~name:"author") in
    let contributors =
      contributors |> List.map (Person.to_atom ~name:"contributor")
    in
    let links = links |> List.map Link.to_xml in
    let categories = categories |> List.map Category.to_atom in
    [
      Xml.may_leaf ~indent:false ~name:"id" Fun.id id
    ; Xml.may (text_node ~name:"title") title
    ; Xml.may (text_node ~name:"subtitle") subtitle
    ; Xml.may Generator.to_atom generator
    ; Xml.may_leaf ~name:"icon" Fun.id icon
    ; Xml.may_leaf ~name:"logo" Fun.id logo
    ; Xml.may (text_node ~name:"rights") rights
    ; Xml.may_leaf ~indent:false ~name:"updated" Datetime.to_string_rfc3339
        updated
    ]
    @ authors
    @ contributors
    @ categories
    @ links

  let to_source_xml x = Xml.node ~name:"source" (to_xml x)
end

module Content = struct
  type t =
    | Text_construct of Text_construct.t
    | Mime of Media_type.t option * string
    | Src of Media_type.t option * string

  let text_construct tc = Text_construct tc
  let mime ?media_type s = Mime (media_type, s)
  let src ?media_type uri = Src (media_type, uri)

  let to_xml = function
    | Src (mime, v) ->
        let attr =
          let typ =
            mime
            |> Option.map (fun x ->
                   Xml.Attr.string ~key:"type" (Media_type.to_string x))
            |> Option.to_list
          in
          let value = Xml.Attr.string ~key:"src" v in
          value :: typ
        in
        Xml.leaf ~name:"content" ~attr None
    | Mime (mime, value) ->
        let attr =
          mime
          |> Option.map (fun x ->
                 Xml.Attr.string ~key:"type" (Media_type.to_string x))
          |> Option.to_list
        in
        Xml.leaf ~name:"content" ~attr (Some value)
    | Text_construct k -> text_node ~name:"content" k
end

module Entry = struct
  type t = {
      title : Text_construct.t
    ; id : string
    ; updated : Datetime.t
    ; published : Datetime.t option
    ; authors : Person.t list
    ; contributors : Person.t list
    ; links : Link.t list
    ; categories : Category.t list
    ; rights : Text_construct.t option
    ; source : Source.t option
    ; summary : Text_construct.t option
    ; content : Content.t option
  }

  let make ?(authors = []) ?(contributors = []) ?(links = []) ?(categories = [])
      ?published ?rights ?source ?summary ?content ~title ~id ~updated () =
    {
      title
    ; id
    ; authors
    ; contributors
    ; links
    ; categories
    ; updated
    ; rights
    ; source
    ; published
    ; summary
    ; content
    }

  let to_xml
      {
        title
      ; id
      ; authors
      ; contributors
      ; links
      ; categories
      ; updated
      ; rights
      ; source
      ; published
      ; summary
      ; content
      } =
    let authors = authors |> List.map (Person.to_atom ~name:"author") in
    let contributors =
      contributors |> List.map (Person.to_atom ~name:"contributor")
    in
    let links = links |> List.map Link.to_xml in
    let categories = categories |> List.map Category.to_atom in
    Xml.node ~name:"entry"
      ([
         Xml.leaf ~indent:false ~name:"id" (Some id)
       ; text_node ~name:"title" title
       ; Xml.may (text_node ~name:"rights") rights
       ; Xml.leaf ~indent:false ~name:"updated"
           (Some (Datetime.to_string_rfc3339 updated))
       ; Xml.may_leaf ~indent:false ~name:"published" Datetime.to_string_rfc3339
           published
       ; Xml.may Source.to_source_xml source
       ; Xml.may (text_node ~name:"summary") summary
       ; Xml.may Content.to_xml content
       ]
      @ authors
      @ contributors
      @ links
      @ categories)
end

type updated_strategy = From_entries of Datetime.t | Given of Datetime.t

let updated_from_entries
    ?(default_value = Datetime.make Yocaml.Archetype.Datetime.dummy) () =
  From_entries default_value

let updated_given value = Given value
let opt_or f a = function None -> a | Some b -> f a b

module Feed = struct
  let make ?subtitle ?contributors ?categories ?generator ?icon ?logo ?links
      ?rights ~title ~authors ~id entries =
    let s =
      Source.make ?subtitle ?contributors ?categories ?generator ?icon ?logo
        ?links ?rights ~title
        ~authors:(Yocaml.Nel.to_list authors)
        ~id ()
    in
    (s, entries)

  let to_xml_with_updated f updated (source, entries) =
    let latest, entries =
      List.fold_left
        (fun (dt, acc) item ->
          let entry = item |> f in
          let latest =
            opt_or
              (fun a b ->
                let cp = Datetime.compare a b in
                if cp > 0 then a else b)
              entry.Entry.updated dt
          in
          (Some latest, Entry.to_xml entry :: acc))
        (None, []) entries
    in
    let entries = List.rev entries in
    let updated =
      match (updated, latest) with
      | Given dt, _ -> dt
      | From_entries _, Some dt -> dt
      | From_entries dt, _ -> dt
    in
    let source = Source.change_updated source updated in
    let preamble = Source.to_xml source in
    Xml.node ~name:"feed"
      ~attr:[ Xml.Attr.string ~key:"xmlns" "http://www.w3.org/2005/Atom" ]
      (preamble @ entries)
end

type text_construct = Text_construct.t
type link = Link.t
type source = Source.t
type content = Content.t
type entry = Entry.t

let text = Text_construct.text
let html = Text_construct.html
let xhtml = Text_construct.xhtml
let link = Link.make
let alternate = link ~rel:Alternate
let related = link ~rel:Related
let self = link ~rel:Self
let enclosure = link ~rel:Enclosure
let via = link ~rel:Via
let source = Source.make
let content_text s = Content.text_construct @@ text s
let content_html s = Content.text_construct @@ html s
let content_mime = Content.mime
let content_src = Content.src
let entry = Entry.make

let content_xhtml ?need_prefix n =
  Content.text_construct @@ xhtml ?need_prefix n

let feed ?encoding ?standalone ?subtitle ?contributors ?categories ?generator
    ?icon ?logo ?links ?rights ~updated ~title ~authors ~id f entries =
  let feed =
    Feed.make ?subtitle ?contributors ?categories ?generator ?icon ?logo ?links
      ?rights ~title ~authors ~id entries
  in
  Xml.document ~version:"1.0" ?encoding ?standalone
    (Feed.to_xml_with_updated f updated feed)

let from ?encoding ?standalone ?subtitle ?contributors ?categories ?generator
    ?icon ?logo ?links ?rights ~updated ~title ~authors ~id f =
  Yocaml.Task.lift (fun articles ->
      let feed =
        feed ?encoding ?standalone ?subtitle ?contributors ?categories
          ?generator ?icon ?logo ?links ?rights ~updated ~title ~authors ~id f
          articles
      in
      Xml.to_string feed)

let from_articles ?encoding ?standalone ?subtitle ?contributors ?categories
    ?generator ?icon ?logo ?(links = []) ?rights
    ?(updated = updated_from_entries ()) ?id ~site_url ~feed_url ~title ~authors
    () =
  let id = Option.value ~default:feed_url id in
  let feed_url = self feed_url in
  let base_url = link site_url in
  let links = base_url :: feed_url :: links in
  from ?encoding ?standalone ?subtitle ?contributors ?categories ?generator
    ?icon ?logo ~links ?rights ~updated ~title ~authors ~id
    (fun (path, article) ->
      let title = Yocaml.Archetype.Article.title article in
      let content_url = site_url ^ Yocaml.Path.to_string path in
      let updated = Datetime.make @@ Yocaml.Archetype.Article.date article in
      let categories =
        List.map Category.make
        @@ Yocaml.Archetype.(Page.tags @@ Article.page article)
      in
      let summary =
        Option.map text @@ Yocaml.Archetype.Article.synopsis article
      in
      let links = [ alternate content_url ~title ] in
      entry ~links ~categories ?summary ~updated ~id:content_url
        ~title:(text title) ())
