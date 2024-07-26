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

type t = string
type step = Fresh | Separator | Unknown

let regular_case ~separator ~unknown_char buf chars (f, state) =
  let () =
    match state with
    | Fresh -> ()
    | Separator -> if f then Buffer.add_char buf separator
    | Unknown -> if f then Buffer.add_char buf unknown_char
  in
  let () = List.iter (Buffer.add_char buf) chars in
  (true, Fresh)

let handle_space ~same ~unknown_char buf (f, state) =
  match state with
  | Fresh -> (f, Separator)
  | Separator -> (f, Separator)
  | Unknown ->
      let () = if not same then Buffer.add_char buf unknown_char in
      (f, Separator)

let handle_unknown ~same ~separator buf (f, state) =
  match state with
  | Fresh -> (f, Unknown)
  | Unknown -> (f, Unknown)
  | Separator ->
      let () = if not same then Buffer.add_char buf separator in
      (f, Unknown)

module M = Map.Make (Char)

let default_mapping =
  [
    ('+', "plus")
  ; ('&', "and")
  ; ('$', "dollar")
  ; ('%', "percent")
  ; ('&', "and")
  ; ('<', "less")
  ; ('>', "greater")
  ; ('|', "or")
  ; ('@', "at")
  ; ('#', "hash")
  ; ('*', "")
  ; ('(', "")
  ; (')', "")
  ; ('[', "")
  ; (']', "")
  ; ('}', "")
  ; ('{', "")
  ; ('`', "")
  ]

let s x = x |> String.to_seq |> List.of_seq

let from ?(mapping = default_mapping) ?(separator = '-') ?(unknown_char = '-')
    fragment =
  let mapping = M.of_list mapping in
  let same = Char.equal separator unknown_char in
  let reg = regular_case ~separator ~unknown_char in
  let space = handle_space ~same ~unknown_char in
  let unkn = handle_unknown ~same ~separator in
  let fragment = fragment |> String.trim |> String.lowercase_ascii in
  let buf = Buffer.create @@ String.length fragment in

  let _ =
    fragment
    |> String.fold_left
         (fun state -> function
           | ('0' .. '9' | 'a' .. 'z') as l -> reg buf [ l ] state
           | ' ' | '\t' | '\n' | '-' | '_' | '.' | ',' | ';' -> space buf state
           | c -> (
               match M.find_opt c mapping with
               | None -> unkn buf state
               | Some "" -> state
               | Some r -> state |> space buf |> reg buf (s r) |> space buf))
         (false, Fresh)
  in
  buf |> Buffer.contents

let validate_from_str separator unknown_char =
  String.for_all (function
    | '0' .. '9' | 'a' .. 'z' -> true
    | chr -> Char.equal chr separator || Char.equal chr unknown_char)

let validate ?(separator = '-') ?(unknown_char = '-') =
  let open Data.Validation in
  string
  & where ~pp:Format.pp_print_string
      ~message:(fun x -> x ^ " is not a valid slug")
      (validate_from_str separator unknown_char)
