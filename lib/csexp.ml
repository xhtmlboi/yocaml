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

type t = Atom of string | Node of t list

let atom x = Atom x
let node x = Node x

let rec equal a b =
  match (a, b) with
  | Atom a, Atom b -> String.equal a b
  | Node a, Node b -> List.equal equal a b
  | _ -> false

let rec pp ppf = function
  | Atom x -> Format.fprintf ppf {|Atom "%s"|} x
  | Node x -> Format.fprintf ppf {|Node [ %a ]|} (Format.pp_print_list pp) x

let length csexp =
  let rec aux acc = function
    | Node x -> 2 + List.fold_left aux acc x
    | Atom x ->
        let len = String.length x in
        let ilen = String.length (Int.to_string len) in
        acc + ilen + 1 + len
  in
  aux 0 csexp

let to_buffer buf csexp =
  let rec aux = function
    | Atom x ->
        let len = String.length x |> Int.to_string in
        let () = Buffer.add_string buf len in
        let () = Buffer.add_char buf ':' in
        Buffer.add_string buf x
    | Node x ->
        let () = Buffer.add_char buf '(' in
        let () = List.iter aux x in
        Buffer.add_char buf ')'
  in
  aux csexp

let to_string csexp =
  let len = length csexp in
  let buf = Buffer.create len in
  let () = to_buffer buf csexp in
  Buffer.contents buf
