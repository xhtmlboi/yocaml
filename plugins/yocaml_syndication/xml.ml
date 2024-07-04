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

let clean_string str = String.trim str

let make_key (ns, key) =
  let ns = Option.fold ~none:"" ~some:(fun x -> x ^ ":") ns in
  clean_string ns ^ clean_string key

let escape =
  String.fold_left
    (fun res -> function
      | '<' -> res ^ "&lt;"
      | '>' -> res ^ "&gt;"
      | '&' -> res ^ "&amp;"
      | '\'' -> res ^ "&apos;"
      | '"' -> res ^ "&quot;"
      | c -> res ^ String.make 1 c)
    ""

module Attr = struct
  type key = string option * string
  type t = key * string

  module M = Stdlib.Map.Make (struct
    type t = key

    let compare k1 k2 =
      let k1 = make_key k1 and k2 = make_key k2 in
      Stdlib.String.compare k1 k2
  end)

  type set = string M.t

  let make f ?ns ~key value = ((ns, key), f value)
  let string = make (fun x -> x)
  let int = make string_of_int
  let float = make string_of_float
  let bool = make string_of_bool
  let char = make (String.make 1)
  let escaped = make escape
  let from_list = M.of_list
  let to_string (key, value) = make_key key ^ "=" ^ Format.asprintf "%S" value

  let set_to_string set =
    set |> M.to_list |> List.map to_string |> String.concat " "
end

type node =
  | Node of (string option * string) * Attr.set * node list
  | Leaf of (string option * string) * Attr.set * string option
  | Maybe of node option

type t = { version : string; encoding : string; standalone : bool; root : node }

let document ?(version = "1.0") ?(encoding = "utf-8") ?(standalone = false) root
    =
  { version; encoding; standalone; root }

let opt n = Maybe n

let node ?ns ~name ?(attr = []) body =
  Node ((ns, name), Attr.from_list attr, body)

let leaf ?ns ~name ?(attr = []) body =
  Leaf ((ns, name), Attr.from_list attr, body)

let may f x = opt (Option.map f x)

let may_leaf ?(finalize = fun x -> Some x) ~name f v =
  opt @@ Option.map (fun x -> leaf ~name (finalize (f x))) v

let cdata str = Some ("<![CDATA[" ^ str ^ "]]>")
let escape str = Some (escape str)

let header_to_string { version; encoding; standalone; _ } =
  let attributes =
    let base =
      Attr.[ string ~key:"version" version; string ~key:"encoding" encoding ]
    in
    if standalone then Attr.string ~key:"standalone" "yes" :: base else base
  in
  "<?xml " ^ (attributes |> List.map Attr.to_string |> String.concat " ") ^ "?>"

let close_tag = "/>"
let close_name name = "</" ^ name ^ ">"
let make_indent i = String.make (i * 2) ' '

let node_to_string node =
  let rec aux t = function
    | Maybe (Some node) -> aux t node
    | Maybe None -> ""
    | (Node (key, attr, _) | Leaf (key, attr, _)) as node ->
        let indent = make_indent t in
        let name = make_key key in
        let attr = Attr.set_to_string attr in
        let attr = if String.(equal empty attr) then "" else " " ^ attr in
        let opening = indent ^ "<" ^ name ^ attr in
        let closing = closing t indent name node in
        opening ^ closing
  and closing t indent name = function
    | Maybe _ -> assert false (* Unreacheable *)
    | Leaf (_, _, None) | Node (_, _, []) -> close_tag
    | Leaf (_, _, Some str) ->
        if String.length str > 80 then
          let indent_ctn = make_indent (succ t) in
          ">\n" ^ indent_ctn ^ str ^ "\n" ^ indent ^ close_name name
        else ">" ^ str ^ close_name name
    | Node (_, _, li) ->
        ">\n"
        ^ (List.filter_map
             (function Maybe None -> None | x -> Some (aux (succ t) x))
             li
          |> String.concat "\n")
        ^ "\n"
        ^ indent
        ^ close_name name
  in

  aux 0 node

let to_string ({ root; _ } as doc) =
  let header = header_to_string doc in
  header ^ "\n" ^ node_to_string root
