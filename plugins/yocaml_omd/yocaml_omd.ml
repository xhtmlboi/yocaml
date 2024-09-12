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

let to_text elt =
  let rec aux acc = function
    | Omd.Text (_, value) | Omd.Code (_, value) -> acc ^ value
    | Omd.Emph (_, inline) | Omd.Strong (_, inline) -> aux acc inline
    | Omd.Link (_, { label; _ }) | Omd.Image (_, { label; _ }) -> aux acc label
    | Omd.Hard_break _ | Omd.Soft_break _ -> "\n"
    | Omd.Html _ -> acc
    | Omd.Concat (_, inlines) -> List.fold_left aux acc inlines
  in
  aux "" elt

let tag l x = Format.asprintf "<%s>%s</%s>" l x l

let inline_to_html elt =
  let rec aux acc = function
    | Omd.Text (_, value) -> acc ^ value
    | Omd.Code (_, value) -> acc ^ tag "code" value
    | Omd.Emph (_, value) -> acc ^ tag "em" (aux "" value)
    | Omd.Strong (_, value) -> acc ^ tag "strong" (aux "" value)
    | Omd.Link (_, { label; _ }) -> acc ^ aux "" label
    | Omd.Hard_break _ -> acc ^ "<br />"
    | Omd.Soft_break _ -> acc ^ "\n"
    | Omd.Html _ | Omd.Image _ -> acc
    | Omd.Concat (_, inlines) -> List.fold_left aux acc inlines
  in
  aux "" elt

let rec without_links = function
  | Omd.Concat (attr, inlines) ->
      Omd.Concat (attr, List.map without_links inlines)
  | Omd.Emph (attr, inline) -> Omd.Emph (attr, without_links inline)
  | Omd.Strong (attr, inline) -> Omd.Strong (attr, without_links inline)
  | Omd.Link (_, link) -> link.label
  | Omd.Image (attr, link) ->
      Omd.Image (attr, Omd.{ link with label = without_links link.label })
  | Omd.(Hard_break _ | Soft_break _ | Html _ | Code _ | Text _) as inline ->
      inline

let collect_headers doc =
  let headers, doc =
    List.fold_left
      (fun (headers, doc) -> function
        | Omd.Heading (attributes, level, inline) ->
            let hd_inline, id, new_attributes =
              match List.assoc_opt "id" attributes with
              | None ->
                  let id = Yocaml.Slug.from @@ to_text inline in
                  let inline = without_links inline in
                  (inline, id, ("id", id) :: attributes)
              | Some id ->
                  let inline = without_links inline in
                  (inline, id, attributes)
            in
            ( (level, (id, hd_inline)) :: headers
            , Omd.Heading (new_attributes, level, inline) :: doc )
        | x -> (headers, x :: doc))
      ([], []) doc
  in
  (List.rev headers, List.rev doc)

let to_html_with_toc =
  let open Yocaml.Task in
  lift (fun content -> content |> Omd.of_string |> collect_headers)
  >>> first
        (lift Yocaml.Markup.Toc.from_list
        >>| Yocaml.Markup.Toc.to_html inline_to_html)
  >>> second (lift Omd.to_html)

let to_html =
  Yocaml.Task.lift (fun content -> content |> Omd.of_string |> Omd.to_html)

let content_to_html () = Yocaml.Task.second to_html

let content_to_html_with_toc f =
  let open Yocaml.Task in
  second to_html_with_toc >>| fun (m, (toc, doc)) -> (f m toc, doc)
