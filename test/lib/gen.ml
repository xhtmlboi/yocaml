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
  let atom = small_string ~gen:printable |> map Yocaml.Csexp.atom in
  let node self n = small_list (self (n / 10)) |> map Yocaml.Csexp.node in
  fix (fun self -> function
    | 0 -> atom | n -> frequency [ (1, atom); (5, node self n) ])
  |> sized

let path =
  let open QCheck2.Gen in
  let fragment =
    string_size ~gen:(char_range 'a' 'z') (int_range 1 10) |> small_list
  in
  let rel = fragment |> map Yocaml.Path.rel in
  let abs = fragment |> map Yocaml.Path.abs in
  frequency [ (5, rel); (5, abs) ]

let deps =
  let open QCheck2.Gen in
  path |> list_size (int_range 0 20) |> map Yocaml.Deps.from_list

let cache_entry =
  let open QCheck2.Gen in
  map2 Yocaml.Cache.entry (small_string ~gen:printable) deps

let cache =
  let open QCheck2.Gen in
  let line =
    let* v = cache_entry in
    let+ k = path in
    (k, v)
  in
  line |> small_list |> map Yocaml.Cache.from_list
