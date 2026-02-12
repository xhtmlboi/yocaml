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

type entry = {
    hashed_content : string
  ; dynamic_dependencies : Deps.t
  ; last_build_date : float option
}

type t = { entries : entry Path.Map.t; trace : Trace.t }

let entry ?last_build_date hashed_content dynamic_dependencies =
  { hashed_content; dynamic_dependencies; last_build_date }

let make ~entries ~trace = { entries; trace }
let empty = make ~entries:Path.Map.empty ~trace:Trace.empty

let from_list ?(trace = Trace.empty) entries =
  let entries = entries |> Path.Map.of_list in
  make ~entries ~trace

let update cache path ?(deps = Deps.empty) ~now content =
  let entry = entry ~last_build_date:now content deps in
  { cache with entries = Path.Map.add path entry cache.entries }

let get cache path =
  Option.map
    (fun { hashed_content; dynamic_dependencies; last_build_date } ->
      (hashed_content, dynamic_dependencies, last_build_date))
    (Path.Map.find_opt path cache.entries)

let entry_to_sexp { hashed_content; dynamic_dependencies; last_build_date } =
  let open Sexp in
  let last_build_date =
    last_build_date
    |> Option.map (fun x -> x |> string_of_float |> atom)
    |> Option.to_list
  in
  node
    ([ atom hashed_content; Deps.to_sexp dynamic_dependencies ]
    @ last_build_date)

let last_build_date_from_string lbd =
  match float_of_string_opt lbd with
  | None -> Error (Sexp.Invalid_sexp (Sexp.Atom lbd, "last_build_date"))
  | Some x -> Ok x

let entry_from_sexp sexp =
  let make hashed_content potential_deps last_build_date =
    let entry = entry ?last_build_date hashed_content in
    potential_deps
    |> Deps.from_sexp
    |> Result.map_error (fun _ -> Sexp.Invalid_sexp (sexp, "cache"))
    |> Result.map entry
  in
  match sexp with
  | Sexp.(Node [ Atom hashed_content; potential_deps ]) ->
      make hashed_content potential_deps None
  | Sexp.(Node [ Atom hashed_content; potential_deps; Atom last_build_date ]) ->
      Result.bind (last_build_date_from_string last_build_date) (fun lbd ->
          make hashed_content potential_deps (Some lbd))
  | _ -> Error (Sexp.Invalid_sexp (sexp, "cache"))

let to_sexp { entries; _ } =
  Path.Map.fold
    (fun key entry acc ->
      let k = Path.to_sexp key in
      let v = entry_to_sexp entry in
      Sexp.node [ k; v ] :: acc)
    entries []
  |> Sexp.node

let key_value_from_sexp sexp =
  match sexp with
  | Sexp.(Node [ key; value ]) ->
      Result.bind (Path.from_sexp key) (fun key ->
          value |> entry_from_sexp |> Result.map (fun value -> (key, value)))
      |> Result.map_error (fun _ -> Sexp.Invalid_sexp (sexp, "cache"))
  | _ -> Error (Sexp.Invalid_sexp (sexp, "cache"))

let from_sexp sexp =
  match sexp with
  | Sexp.(Node entries) ->
      List.fold_left
        (fun acc line ->
          Result.bind acc (fun acc ->
              line |> key_value_from_sexp |> Result.map (fun x -> x :: acc)))
        (Ok []) entries
      |> Result.map (fun e ->
          make ~entries:(Path.Map.of_list e) ~trace:Trace.empty)
  | _ -> Error (Sexp.Invalid_sexp (sexp, "cache"))

let entry_equal
    {
      hashed_content = hashed_a
    ; dynamic_dependencies = deps_a
    ; last_build_date = lbd_a
    }
    {
      hashed_content = hashed_b
    ; dynamic_dependencies = deps_b
    ; last_build_date = lbd_b
    } =
  String.equal hashed_a hashed_b
  && Deps.equal deps_a deps_b
  && Option.equal Float.equal lbd_a lbd_b

let equal { entries; trace } b =
  Path.Map.equal entry_equal entries b.entries && Trace.equal trace b.trace

let pp_kv ppf (key, { hashed_content; dynamic_dependencies; last_build_date }) =
  Format.fprintf ppf "%a => deps: @[<v 0>%a@] hash:%s (%a)" Path.pp key Deps.pp
    dynamic_dependencies hashed_content
    (Format.pp_print_option Format.pp_print_float)
    last_build_date

let trace { trace; _ } = trace
let mark cache path = { cache with trace = Trace.add path (trace cache) }

let pp ppf cache =
  Format.fprintf ppf "Cache [@[<v 0>%a@]]@ @[<v 1>%a@]"
    (Format.pp_print_list
       ~pp_sep:(fun ppf () -> Format.fprintf ppf ";@ ")
       pp_kv)
    (Path.Map.to_list cache.entries)
    Trace.pp (trace cache)
