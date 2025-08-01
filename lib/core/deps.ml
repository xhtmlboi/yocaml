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

type t = Path.Set.t

let concat = Path.Set.union
let empty = Path.Set.empty
let reduce = List.fold_left concat empty
let singleton = Path.Set.singleton
let from_list = Path.Set.of_list
let equal = Path.Set.equal
let is_empty = Path.Set.is_empty
let add = Path.Set.add

let get_mtimes deps =
  deps |> Path.Set.elements |> Eff.(List.traverse @@ mtime ~on:`Source)

let to_sexp deps =
  deps |> Path.Set.to_list |> List.map Path.to_sexp |> Sexp.node

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
  Format.fprintf ppf "Deps [@[%a@]]"
    (Format.pp_print_list
       ~pp_sep:(fun ppf () -> Format.fprintf ppf ";@ ")
       Path.pp)
    (Path.Set.elements deps)
