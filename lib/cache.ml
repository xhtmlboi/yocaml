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

module Cache_map = Map.Make (Path)

type entry = { hashed_content : string; dynamic_dependencies : Deps.t }
type t = entry Cache_map.t

let entry hashed_content dynamic_dependencies =
  { hashed_content; dynamic_dependencies }

let empty = Cache_map.empty
let from_list = Cache_map.of_list

let update cache path ?(deps = Deps.empty) content =
  let entry = entry content deps in
  Cache_map.add path entry cache

let get cache path =
  Option.map
    (fun { hashed_content; dynamic_dependencies } ->
      (hashed_content, dynamic_dependencies))
    (Cache_map.find_opt path cache)

let entry_to_csexp { hashed_content; dynamic_dependencies } =
  let open Csexp in
  node [ atom hashed_content; Deps.to_csexp dynamic_dependencies ]

let entry_from_csexp csexp =
  match csexp with
  | Csexp.(Node [ Atom hashed_content; potential_deps ]) ->
      let entry = entry hashed_content in
      potential_deps
      |> Deps.from_csexp
      |> Result.map_error (fun _ -> `Invalid_csexp (csexp, `Cache))
      |> Result.map entry
  | _ -> Error (`Invalid_csexp (csexp, `Cache))

let to_csexp cache =
  Cache_map.fold
    (fun key entry acc ->
      let k = Path.to_csexp key in
      let v = entry_to_csexp entry in
      Csexp.node [ k; v ] :: acc)
    cache []
  |> Csexp.node

let key_value_from_csexp csexp =
  match csexp with
  | Csexp.(Node [ key; value ]) ->
      Result.bind (Path.from_csexp key) (fun key ->
          value |> entry_from_csexp |> Result.map (fun value -> (key, value)))
      |> Result.map_error (fun _ -> `Invalid_csexp (csexp, `Cache))
  | _ -> Error (`Invalid_csexp (csexp, `Cache))

let from_csexp csexp =
  match csexp with
  | Csexp.(Node entries) ->
      List.fold_left
        (fun acc line ->
          Result.bind acc (fun acc ->
              line |> key_value_from_csexp |> Result.map (fun x -> x :: acc)))
        (Ok []) entries
      |> Result.map Cache_map.of_list
  | _ -> Error (`Invalid_csexp (csexp, `Cache))

let entry_equal { hashed_content = hashed_a; dynamic_dependencies = deps_a }
    { hashed_content = hashed_b; dynamic_dependencies = deps_b } =
  String.equal hashed_a hashed_b && Deps.equal deps_a deps_b

let equal = Cache_map.equal entry_equal

let pp_kv ppf (key, { hashed_content; dynamic_dependencies }) =
  Format.fprintf ppf "%a => deps: @[<v 0>%a@]@hash:%s" Path.pp key Deps.pp
    dynamic_dependencies hashed_content

let pp ppf cache =
  Format.fprintf ppf "Cache [@[<v 0>%a@]]"
    (Format.pp_print_list
       ~pp_sep:(fun ppf () -> Format.fprintf ppf ";@ ")
       pp_kv)
    (Cache_map.to_list cache)
