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

type t = Path.Set.t

let empty = Path.Set.empty
let add = Path.Set.add
let from_list = Path.Set.of_list
let diff ~target computed = Path.Set.diff target computed |> Path.Set.to_list

let from_directory ~on target =
  let open Eff.Syntax in
  let rec aux trace parent =
    let* children = Eff.read_directory ~on ~only:`Both parent in
    Stdlib.List.fold_left
      (fun trace child ->
        let* trace = trace in
        let* as_file = Eff.is_file ~on child in
        if as_file then Eff.return (add child trace) else aux trace child)
      (Eff.return trace) children
  in
  aux empty target

let equal = Path.Set.equal

let pp ppf trace =
  Format.fprintf ppf "Trace[@[%a@]]"
    (Format.pp_print_list (fun ppf p ->
         Format.fprintf ppf "%S" (Path.to_string p)))
    (trace |> Path.Set.to_list)
