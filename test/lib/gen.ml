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

let csexp =
  let open QCheck2.Gen in
  let atom = string_small |> map Yocaml.Sexp.atom in
  let node self n = list_small (self (n / 10)) |> map Yocaml.Sexp.node in
  fix (fun self -> function
    | 0 -> atom
    | n -> oneof_weighted [ (1, atom); (5, node self n) ])
  |> sized

let alphanumeric =
  let open QCheck2.Gen in
  oneof [ char_range 'a' 'z'; char_range 'A' 'Z'; char_range '0' '9' ]

let sexp =
  let open QCheck2.Gen in
  let atom =
    string_size ~gen:alphanumeric (int_range 1 100) |> map Yocaml.Sexp.atom
  in
  let node self n = list_small (self (n / 10)) |> map Yocaml.Sexp.node in
  fix (fun self -> function
    | 0 -> atom
    | n -> oneof_weighted [ (1, atom); (5, node self n) ])
  |> sized

let path =
  let open QCheck2.Gen in
  let fragment =
    string_size ~gen:(char_range 'a' 'z') (int_range 1 10) |> list_small
  in
  let rel = fragment |> map Yocaml.Path.rel in
  let abs = fragment |> map Yocaml.Path.abs in
  oneof_weighted [ (5, rel); (5, abs) ]

let deps =
  let open QCheck2.Gen in
  path |> list_size (int_range 0 20) |> map Yocaml.Deps.from_list

let cache_entry =
  let open QCheck2.Gen in
  map3
    (fun last_build_date hash deps ->
      Yocaml.Cache.entry ?last_build_date hash deps)
    (option int) string_small deps

let cache =
  let open QCheck2.Gen in
  let line =
    let* v = cache_entry in
    let+ k = path in
    (k, v)
  in
  line |> list_small |> map Yocaml.Cache.from_list
