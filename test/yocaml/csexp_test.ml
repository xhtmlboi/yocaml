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

let test_length_1 =
  let open Alcotest in
  test_case "serialized length case 1" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = 2 and computed = node [] |> length in
      check int "should be equal" expected computed)

let test_length_2 =
  let open Alcotest in
  test_case "serialized length case 2" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = 2 and computed = atom "" |> length in
      check int "should be equal" expected computed)

let test_length_3 =
  let open Alcotest in
  test_case "serialized length case 3" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = 7 and computed = node [ atom "foo" ] |> length in
      check int "should be equal" expected computed)

let test_length_4 =
  let open Alcotest in
  test_case "serialized length case 4" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = 52
      and computed =
        node
          [
            atom "foo"
          ; atom "bar"
          ; node [ atom "Lorem Ipsum Dolor" ]
          ; node [ atom "foobar"; atom "foobaz" ]
          ]
        |> length
      in
      check int "should be equal" expected computed)

let test_to_string_1 =
  let open Alcotest in
  test_case "to_string case 1" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = "0:" and computed = atom "" |> to_string in
      check string "should be equal" expected computed)

let test_to_string_2 =
  let open Alcotest in
  test_case "to_string case 1" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = "9:foobarbaz"
      and computed = atom "foobarbaz" |> to_string in
      check string "should be equal" expected computed)

let test_to_string_3 =
  let open Alcotest in
  test_case "to_string case 1" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = "(3:foo3:bar(17:Lorem Ipsum Dolor)(6:foobar6:foobaz))"
      and computed =
        node
          [
            atom "foo"
          ; atom "bar"
          ; node [ atom "Lorem Ipsum Dolor" ]
          ; node [ atom "foobar"; atom "foobaz" ]
          ]
        |> to_string
      in
      check string "should be equal" expected computed)

let cases =
  ( "Yocaml.Csexp"
  , [
      test_length_1
    ; test_length_2
    ; test_length_3
    ; test_length_4
    ; test_to_string_1
    ; test_to_string_2
    ; test_to_string_3
    ] )
