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

let fold_headers doc =
  let open Cmarkit in
  let block _ acc = function
    | Block.Heading (heading, _) ->
        let level = Block.Heading.level heading in
        let inline = Block.Heading.inline heading in
        let text =
          inline
          |> Inline.to_plain_text ~break_on_soft:false
          |> List.map (String.concat "")
          |> String.concat "\n"
        in
        let id = Inline.id inline in
        Folder.ret @@ ((level, (id, text)) :: acc)
    | _ -> Folder.default
  in
  let folder = Folder.make ~block () in
  let headers = Folder.fold_doc folder [] doc in
  List.rev headers

let extract_toc doc =
  doc
  |> fold_headers
  |> Yocaml.Markup.Toc.from_list
  |> Yocaml.Markup.Toc.to_html (fun x -> x)

let to_doc ?(strict = true) () =
  Yocaml.Task.lift (fun content ->
      content |> Cmarkit.Doc.of_string ~heading_auto_ids:true ~strict)

let table_of_contents = Yocaml.Task.lift (fun doc -> (extract_toc doc, doc))

let from_doc_to_html ?(safe = false) () =
  Yocaml.Task.lift (fun content -> content |> Cmarkit_html.of_doc ~safe)

let to_html_with_toc ?(strict = true) ?(safe = false) () =
  let open Yocaml.Task in
  lift (fun content ->
      let doc = Cmarkit.Doc.of_string ~heading_auto_ids:true ~strict content in
      let headers = fold_headers doc in
      (headers, doc))
  >>> first
        (lift Yocaml.Markup.Toc.from_list
        >>| Yocaml.Markup.Toc.to_html (fun x -> x))
  >>> second (lift @@ Cmarkit_html.of_doc ~safe)

let to_html ?(strict = true) ?(safe = false) () =
  Yocaml.Task.lift (fun content ->
      content
      |> Cmarkit.Doc.of_string ~heading_auto_ids:true ~strict
      |> Cmarkit_html.of_doc ~safe)

let content_to_html ?strict ?safe () =
  Yocaml.Task.second (to_html ?strict ?safe ())

let content_to_html_with_toc ?strict ?safe f =
  let open Yocaml.Task in
  second (to_html_with_toc ?strict ?safe ()) >>| fun (m, (toc, doc)) ->
  (f m toc, doc)
