(* YOCaml a static blog generator.
   Copyright (C) 2025 The Funkyworkers and The YOCaml's developers

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

module Doc = struct
  let from_string ?(strict = false) ?(heading_auto_ids = true) content =
    Cmarkit.Doc.of_string ~strict ~heading_auto_ids content

  let default_grammars_set =
    let t = TmLanguage.create () in
    let () =
      [
        Hilite.Grammars.ocaml
      ; Hilite.Grammars.ocaml_interface
      ; Hilite.Grammars.dune
      ; Hilite.Grammars.opam
      ; Hilite.Grammars.diff
      ]
      |> List.iter (fun g ->
          g |> TmLanguage.of_yojson_exn |> TmLanguage.add_grammar t)
    in
    t

  let table_of_contents
      ?(traverse_table = Yocaml.Markup.Toc.to_html ~ol:false Fun.id) doc =
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
    headers |> List.rev |> Yocaml.Markup.Toc.from_list |> traverse_table

  let syntax_highlighting ?(skip_unknown_languages = true)
      ?(tm = default_grammars_set) ?lookup_method () document =
    document
    |> Hilite_markdown.transform ~skip_unknown_languages ~tm ?lookup_method

  let no_highlighting x = x

  let make ?(strict = false) ?(heading_auto_ids = true)
      ?(highlight = syntax_highlighting ()) content =
    content |> from_string ~strict ~heading_auto_ids |> highlight

  let to_html ?(safe = false) content = Cmarkit_html.of_doc ~safe content
end

let from_string_to_html ?strict ?heading_auto_ids ?highlight ?safe content =
  content |> Doc.make ?strict ?heading_auto_ids ?highlight |> Doc.to_html ?safe

module Pipeline = struct
  let mk f = Yocaml.Task.lift ~has_dynamic_dependencies:false f

  let to_doc ?strict ?heading_auto_ids ?highlight () =
    mk (Doc.make ?strict ?heading_auto_ids ?highlight)

  let table_of_contents ?traverse_table () =
    mk (fun document -> Doc.table_of_contents ?traverse_table document)

  let with_table_of_contents ?traverse_table () =
    let open Yocaml.Task in
    id &&& table_of_contents ?traverse_table () >>| fun (a, b) -> (b, a)

  let table_of_contents_metadata ?traverse_table () =
    let open Yocaml.Task in
    id
    >>> second (with_table_of_contents ?traverse_table ())
    >>> mk (fun (meta, (toc, content)) -> ((meta, toc), content))

  let to_html ?safe () = mk (Doc.to_html ?safe)

  let make ?strict ?heading_auto_ids ?highlight ?safe () =
    let open Yocaml.Task in
    to_doc ?strict ?heading_auto_ids ?highlight () >>> to_html ?safe ()

  module With_metadata = struct
    let make ?strict ?heading_auto_ids ?highlight ?safe () =
      Yocaml.Task.second (make ?strict ?heading_auto_ids ?highlight ?safe ())

    let table_of_contents = table_of_contents_metadata

    let to_doc ?strict ?heading_auto_ids ?highlight () =
      Yocaml.Task.second (to_doc ?strict ?heading_auto_ids ?highlight ())

    let with_table_of_contents ?strict ?heading_auto_ids ?highlight
        ?traverse_table () =
      let open Yocaml.Task in
      to_doc ?strict ?heading_auto_ids ?highlight ()
      >>> table_of_contents_metadata ?traverse_table ()

    let to_html ?safe () = Yocaml.Task.second (to_html ?safe ())

    let make_with_table_of_contents ?strict ?heading_auto_ids ?highlight
        ?traverse_table ?safe () =
      let open Yocaml.Task in
      with_table_of_contents ?strict ?heading_auto_ids ?highlight
        ?traverse_table ()
      >>> to_html ?safe ()
  end
end
