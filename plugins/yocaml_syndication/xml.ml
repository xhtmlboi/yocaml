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

let cdata str = Some ("<![CDATA[" ^ str ^ "]]>")
let escape str = Some (escape str)

let header_to_string { version; encoding; standalone; _ } =
  let attributes =
    let base =
      Attr.[ string ~key:"version" version; string ~key:"encoding" encoding ]
    in
    if standalone then Attr.string ~key:"standalone" "yes" :: base else base
  in
  "<?xml " ^ Attr.(set_to_string @@ from_list attributes) ^ " ?>"

let rec opening = function
  | Leaf (name, attributes, _) | Node (name, attributes, _) ->
      let name = make_key name in
      let attr_str =
        let r = Attr.set_to_string attributes in
        if String.equal String.empty r then "" else " " ^ r
      in
      Some (name, "<" ^ name ^ attr_str)
  | Maybe (Some n) -> opening n
  | Maybe None -> None

let rec pp_node ppf node =
  match opening node with
  | None -> Format.fprintf ppf ""
  | Some (name, opening) ->
      Format.fprintf ppf "%s%a" opening (pp_node_tail name) node

and pp_node_tail name ppf = function
  | Leaf (_, _, None) | Node (_, _, []) -> Format.fprintf ppf "/>"
  | Leaf (_, _, Some content) -> Format.fprintf ppf ">@[%s@]</%s>" content name
  | Node (_, _, li) ->
      Format.fprintf ppf ">@[<hov 0>@ %a@]@,</%s>"
        (Format.pp_print_list pp_node)
        li name
  | Maybe (Some n) -> pp_node_tail name ppf n
  | Maybe None -> Format.fprintf ppf ""

let pp ppf ({ root; _ } as doc) =
  let header = header_to_string doc in
  Format.fprintf ppf "%s@.%a" header pp_node root
