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

let ( % ) f g x = f (g x)

module Make (S : sig
  val source : Yocaml.Path.t
end) =
struct
  module Source = struct
    let root = S.source
    let source_root = root
    let index = Path.(source_root / "index.md")
    let members = Path.(source_root / "members.yml")
    let templates = Path.(source_root / "templates")
    let template file = Path.(templates / file)
    let binary = Path.rel [ Sys.argv.(0) ]
  end

  module Target = struct
    let target_root = Path.(Source.root / "_build")
    let cache = Path.(target_root / "cache")
    let opml = Path.(target_root / "ring.opml")

    let as_html ?(into = target_root) file =
      file |> Path.move ~into |> Path.change_extension "html"

    let root = target_root
  end

  let target = Target.root

  module Model = struct
    module Lang = struct
      type t = Fr | En

      let validate =
        let open Yocaml.Data.Validation in
        string $ String.trim % String.lowercase_ascii & function
        | "fr" -> Ok Fr
        | "uk" | "en" | "us" -> Ok En
        | given -> fail_with ~given "Invalid Lang value"

      let to_string = function Fr -> "fr" | En -> "en"
      let normalize lang = Yocaml.Data.string @@ to_string lang
    end

    module Url = struct
      type t = string

      let starts_with prefix =
        Yocaml.Data.Validation.where (String.starts_with ~prefix)

      let validate =
        (* It's really a very poor implementation of a URL, but hey. *)
        let open Yocaml.Data.Validation in
        string & (starts_with "http://" / starts_with "https://")

      let normalize url = Yocaml.Data.string url
    end

    module Kind = struct
      type t = Blog | Wiki | Hybrid | Linktree | Other of string

      let validate =
        let open Yocaml.Data.Validation in
        string $ String.trim % String.lowercase_ascii & function
        | "blog" -> Ok Blog
        | "wiki" -> Ok Wiki
        | "hybrid" -> Ok Hybrid
        | "linktree" -> Ok Linktree
        | x -> Ok (Other x)

      let to_string = function
        | Blog -> "blog"
        | Wiki -> "wiki"
        | Hybrid -> "hybrid"
        | Linktree -> "linktree"
        | Other x -> x

      let normalize kind = Yocaml.Data.string (to_string kind)
    end

    module Member = struct
      type t = {
          id : string
        ; url : Url.t
        ; kind : Kind.t option
        ; main_lang : Lang.t
        ; feed_url : Url.t option
        ; built_with_yocaml : bool
        ; tags : string list
      }

      let id { id; _ } = id

      let minimal_length l =
        Yocaml.Data.Validation.where (fun x -> String.length x >= l)

      let validate =
        let open Yocaml.Data.Validation in
        record (fun fields ->
            let+ id = required fields "id" (string & minimal_length 2)
            and+ url = required fields "url" Url.validate
            and+ kind = optional fields "kind" Kind.validate
            and+ main_lang = required fields "main_lang" Lang.validate
            and+ built_with_yocaml =
              optional_or ~default:false fields "yocaml" bool
            and+ feed_url = optional fields "feed_url" Url.validate
            and+ tags =
              optional_or fields ~default:[] "tags" (list_of string)
            in
            { id; url; main_lang; feed_url; built_with_yocaml; tags; kind })

      let normalize
          { id; url; main_lang; feed_url; built_with_yocaml; tags; kind } =
        let open Yocaml.Data in
        [
          ("id", string id)
        ; ("url", Url.normalize url)
        ; ("main_lang", Lang.normalize main_lang)
        ; ("kind", option Kind.normalize kind)
        ; ("feed_url", option Url.normalize feed_url)
        ; ("built_with_yocaml", bool built_with_yocaml)
        ; ("has_tags", bool @@ List.is_empty tags)
        ; ("tags", list_of string tags)
        ]
    end

    module List = struct
      type t = Member.t list

      let entity_name = "List of members"
      let neutral = Yocaml.Metadata.required entity_name

      let validate =
        let open Yocaml.Data.Validation in
        (null & const []) / list_of Member.validate

      let normalize l =
        let has_members = not (List.is_empty l) in
        Yocaml.Data.
          [
            ("members", list_of (record % Member.normalize) l)
          ; ("has_members", bool has_members)
          ]

      let to_outlines l =
        List.filter_map
          (fun x ->
            match x.Member.feed_url with
            | Some feed_url ->
                let title = x.id in
                let description = "Feed of " ^ x.id in
                let language = x.main_lang |> Lang.to_string in
                let html_url = x.url in
                Some
                  (Yocaml_syndication.Opml.subscription ~title ~description
                     ~feed_url ~language ~html_url ())
            | None -> None)
          l
    end

    module Cycle = struct
      type t = {
          prev : Member.t
        ; curr : Member.t
        ; succ : Member.t
        ; select : [ `Prev | `Curr | `Succ ]
      }

      let from list =
        let select = `Curr in
        match list with
        | x :: xs ->
            let first = x in
            let rec aux second prev acc = function
              | curr :: succ :: xs ->
                  let second = Option.value ~default:curr second in
                  aux (Some second) curr
                    ({ prev; curr; succ; select } :: acc)
                    (succ :: xs)
              | [ curr ] ->
                  let latest =
                    Option.fold ~none:[]
                      ~some:(fun second ->
                        [ { prev = curr; curr = first; succ = second; select } ])
                      second
                  in
                  ({ prev; curr; succ = first; select } :: acc) @ latest
              | [] -> []
            in
            aux None first [] xs
        | [] -> []

      let curr { curr; _ } = curr

      let select_to_string = function
        | `Prev -> "prev"
        | `Curr -> "curr"
        | `Succ -> "succ"

      let select value t = { t with select = value }

      let normalize { prev; curr; succ; select } =
        let open Yocaml.Data in
        [
          ("prev", record @@ Member.normalize prev)
        ; ("curr", record @@ Member.normalize curr)
        ; ("succ", record @@ Member.normalize succ)
        ; ("redirection", string @@ select_to_string select)
        ]
    end

    include List
  end

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
end
