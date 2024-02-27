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

type fragment = string
type t = Relative of fragment list | Absolute of fragment list

let rel x = Relative x
let abs x = Absolute x
let root = abs []
let pwd = rel []
let equal_fragment = String.equal
let pp_fragment ppf = Format.fprintf ppf "%s"
let get_fragments = function Relative f | Absolute f -> f

let get_ctor_and_fragments = function
  | Relative f -> (rel, f)
  | Absolute f -> (abs, f)

let equal a b =
  match (a, b) with
  | Relative a, Relative b | Absolute a, Absolute b ->
      List.equal equal_fragment a b
  | _ -> false

let pp ppf path =
  let prefix, fragments, start =
    match path with
    | Relative f -> (Filename.current_dir_name, f, 1)
    | Absolute f -> ("", f, 0)
  in
  let seperator = Filename.dir_sep in
  match fragments with
  | [] -> Format.fprintf ppf "%s" (prefix ^ seperator)
  | _ ->
      let sep_len = String.length seperator in
      let len =
        List.fold_left
          (fun acc fragment -> sep_len + acc + String.length fragment)
          start fragments
      in
      let buf = Buffer.create len in
      let () = Buffer.add_string buf prefix in
      let () =
        List.iter
          (fun fragment ->
            let () = Buffer.add_string buf seperator in
            Buffer.add_string buf fragment)
          fragments
      in
      Format.fprintf ppf "%s" (Buffer.contents buf)

let to_string = Format.asprintf "%a" pp
let to_list = function Absolute xs -> "/" :: xs | Relative xs -> "." :: xs

let append path fragments =
  match path with
  | Relative f -> Relative (f @ fragments)
  | Absolute f -> Absolute (f @ fragments)

let extension path =
  let fragments = get_fragments path in
  let rec aux = function
    | [] -> ""
    | [ x ] -> Filename.extension x
    | _ :: xs -> aux xs
  in
  aux fragments

let extension_opt path =
  match extension path with "" -> None | ext -> Some ext

let update_last_fragment callback path =
  let f, fragments = get_ctor_and_fragments path in
  let rec aux acc = function
    | [] -> path
    | [ x ] -> f @@ List.rev (callback x :: acc)
    | x :: xs -> aux (x :: acc) xs
  in
  aux [] fragments

let remove_extension = update_last_fragment Filename.remove_extension

let fragment_add_extension extension fragment =
  let len = String.length extension in
  let ext =
    if len = 0 then ""
    else if len = 1 && String.equal extension "." then ""
    else if len > 1 && extension.[0] = '.' then extension
    else "." ^ extension
  in
  fragment ^ ext

let add_extension extension =
  update_last_fragment (fragment_add_extension extension)

let change_extension extension =
  update_last_fragment (fun fragment ->
      fragment |> Filename.remove_extension |> fragment_add_extension extension)

let compare a b =
  match (a, b) with
  | Absolute _, Relative _ -> -1
  | Relative _, Absolute _ -> 1
  | Absolute a, Absolute b | Relative a, Relative b ->
      List.compare String.compare a b

let to_csexp path =
  let ctor, fragments =
    match path with Relative x -> ("rel", x) | Absolute x -> ("abs", x)
  in
  Csexp.(node [ atom ctor; node @@ List.map atom fragments ])

let all_are_nodes csexp node =
  List.fold_left
    (fun acc value ->
      Result.bind acc (fun acc ->
          match value with
          | Csexp.Atom x -> Ok (x :: acc)
          | _ -> Error (`Invalid_csexp (csexp, `Path))))
    (Ok []) node
  |> Result.map List.rev

let from_csexp csexp =
  match csexp with
  | Csexp.(Node [ Atom "rel"; Node fragments ]) ->
      Result.map rel (all_are_nodes csexp fragments)
  | Csexp.(Node [ Atom "abs"; Node fragments ]) ->
      Result.map abs (all_are_nodes csexp fragments)
  | _ -> Error (`Invalid_csexp (csexp, `Path))

module Infix = struct
  let ( ++ ) = append
  let ( / ) path fragment = append path [ fragment ]
  let ( ~/ ) = rel
end

include Infix
