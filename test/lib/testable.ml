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

let fs = Fs.testable
let fs_item = Fs.testable_item
let csexp = Alcotest.testable Yocaml.Csexp.pp Yocaml.Csexp.equal

let csexp_error_equal a b =
  match (a, b) with
  | `Nonterminated_atom a, `Nonterminated_atom b
  | `Nonterminated_node a, `Nonterminated_node b ->
      Int.equal a b
  | `Expected_number_or_colon (ca, la), `Expected_number_or_colon (cb, lb)
  | `Expected_number (ca, la), `Expected_number (cb, lb)
  | `Unexepected_character (ca, la), `Unexepected_character (cb, lb) ->
      Char.equal ca cb && Int.equal la lb
  | `Premature_end_of_atom (la, ia), `Premature_end_of_atom (lb, ib) ->
      Int.equal la lb && Int.equal ia ib
  | _ -> false

let csexp_error_pp ppf = function
  | `Nonterminated_atom a -> Format.fprintf ppf "`Nonterminated_atom %d" a
  | `Nonterminated_node a -> Format.fprintf ppf "`Nonterminated_node %d" a
  | `Expected_number_or_colon (c, i) ->
      Format.fprintf ppf "`Expected_number_or_colon (%c, %d)" c i
  | `Expected_number (c, i) ->
      Format.fprintf ppf "`Expected_number (%c, %d)" c i
  | `Unexepected_character (c, i) ->
      Format.fprintf ppf "`Unexepected_character (%c, %d)" c i
  | `Premature_end_of_atom (a, b) ->
      Format.fprintf ppf "`Premature_end_of_atom (%d, %d)" a b
  | _ -> Format.fprintf ppf "Unknown error"

let csexp_error () = Alcotest.testable csexp_error_pp csexp_error_equal
let csexp_result () = Alcotest.result csexp (csexp_error ())
