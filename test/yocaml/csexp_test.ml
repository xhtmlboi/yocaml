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
  test_case "to_string case 2" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = "9:foobarbaz"
      and computed = atom "foobarbaz" |> to_string in
      check string "should be equal" expected computed)

let test_to_string_3 =
  let open Alcotest in
  test_case "to_string case 3" `Quick (fun () ->
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

let test_from_string_1 =
  let open Alcotest in
  test_case "from_string case 1" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = Result.ok @@ node [] and computed = "" |> from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_2 =
  let open Alcotest in
  test_case "from_string case 2" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = Result.ok @@ atom "" and computed = "0:" |> from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_3 =
  let open Alcotest in
  test_case "from_string case 3" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = Result.ok @@ node [] and computed = "()" |> from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_4 =
  let open Alcotest in
  test_case "from_string case 4" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = Result.ok @@ node [ atom ""; atom "a"; atom "foo" ]
      and computed = "0:1:a3:foo" |> from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_5 =
  let open Alcotest in
  test_case "from_string case 5" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected =
        Result.ok @@ node [ atom ""; atom "a"; node [ atom "foo" ] ]
      and computed = "(0:1:a(3:foo))" |> from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_6 =
  let open Alcotest in
  test_case "from_string case 6" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected =
        Result.ok
        @@ node
             [
               atom "foo"
             ; atom "bar"
             ; node [ atom "Lorem Ipsum Dolor" ]
             ; node [ atom "foobar"; atom "foobaz" ]
             ]
      and computed =
        "(3:foo3:bar(17:Lorem Ipsum Dolor)(6:foobar6:foobaz))" |> from_string
      in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_7 =
  let open Alcotest in
  test_case "from_string case 7" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = Result.error @@ `Nonterminated_node 12
      and computed = "(0:1:a(3:foo)" |> from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_8 =
  let open Alcotest in
  test_case "from_string case 8" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = Result.ok @@ atom "foo"
      and computed = "3:foo" |> from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_9 =
  let open Alcotest in
  test_case "from_string case 9" `Quick (fun () ->
      let open Yocaml.Csexp in
      let expected = Result.error @@ `Premature_end_of_atom (4, 3)
      and computed = "4:foo" |> from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_to_string_from_string_roundtrip =
  QCheck2.Test.make ~name:"to_string -> from_string roundtrip" ~count:100
    ~print:(fun x -> Format.asprintf "%a" Yocaml.Csexp.pp x)
    Gen.csexp
    (fun csexp ->
      let open Yocaml.Csexp in
      let result = csexp |> to_string |> from_string in
      let expected = Ok csexp in
      Alcotest.equal (Testable.csexp_result ()) expected result)
  |> QCheck_alcotest.to_alcotest ~colors:true ~verbose:true

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
    ; test_from_string_1
    ; test_from_string_2
    ; test_from_string_3
    ; test_from_string_4
    ; test_from_string_5
    ; test_from_string_6
    ; test_from_string_7
    ; test_from_string_8
    ; test_from_string_9
    ; test_to_string_from_string_roundtrip
    ] )
