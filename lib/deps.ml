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

module Path_set = Set.Make (Path)

type t = Path_set.t

let concat = Path_set.union
let empty = Path_set.empty
let reduce = List.fold_left concat empty
let singleton = Path_set.singleton
let from_list = Path_set.of_list
let equal = Path_set.equal
let is_empty = Path_set.is_empty

let get_mtimes deps =
  deps |> Path_set.elements |> Eff.(List.traverse @@ mtime ~on:`Source)

let to_sexp deps =
  deps |> Path_set.to_list |> List.map Path.to_sexp |> Sexp.node

let all_path_nodes sexp node =
  List.fold_left
    (fun acc value ->
      Result.bind acc (fun acc ->
          value |> Path.from_sexp |> Result.map (fun p -> p :: acc)))
    (Ok []) node
  |> Result.map_error (fun _ -> Sexp.Invalid_sexp (sexp, "deps"))

let from_sexp sexp =
  match sexp with
  | Sexp.(Node paths) -> paths |> all_path_nodes sexp |> Result.map from_list
  | _ -> Error (Sexp.Invalid_sexp (sexp, "deps"))

let pp ppf deps =
  Format.fprintf ppf "Deps [@[<v 0>%a@]]"
    (Format.pp_print_list
       ~pp_sep:(fun ppf () -> Format.fprintf ppf ";@ ")
       Path.pp)
    (Path_set.elements deps)
