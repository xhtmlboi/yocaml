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

open Test_lib

let to_csexp_from_csexp_roundtrip =
  QCheck2.Test.make ~name:"to_csexp -> from_csexp roundtrip" ~count:100
    ~print:(fun x -> Format.asprintf "%a" Yocaml.Cache.pp x)
    Gen.cache
    (fun p ->
      let open Yocaml.Cache in
      let expected = Ok p and computed = p |> to_csexp |> from_csexp in
      Alcotest.equal Testable.(from_csexp cache) expected computed)
  |> QCheck_alcotest.to_alcotest ~colors:true ~verbose:true

let cases = ("Yocaml.Cache", [ to_csexp_from_csexp_roundtrip ])
