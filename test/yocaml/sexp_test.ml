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

let test_length_1_canonical =
  let open Alcotest in
  test_case "canonical serialized length case 1" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = 2 and computed = node [] |> Canonical.length in
      check int "should be equal" expected computed)

let test_length_2_canonical =
  let open Alcotest in
  test_case "canonical serialized length case 2" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = 2 and computed = atom "" |> Canonical.length in
      check int "should be equal" expected computed)

let test_length_3_canonical =
  let open Alcotest in
  test_case "canonical serialized length case 3" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = 7 and computed = node [ atom "foo" ] |> Canonical.length in
      check int "should be equal" expected computed)

let test_length_4_canonical =
  let open Alcotest in
  test_case "canonical serialized length case 4" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = 52
      and computed =
        node
          [
            atom "foo"
          ; atom "bar"
          ; node [ atom "Lorem Ipsum Dolor" ]
          ; node [ atom "foobar"; atom "foobaz" ]
          ]
        |> Canonical.length
      in
      check int "should be equal" expected computed)

let test_to_string_1_canonical =
  let open Alcotest in
  test_case "canonical to_string case 1" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = "0:" and computed = atom "" |> Canonical.to_string in
      check Alcotest.string "should be equal" expected computed)

let test_to_string_2_canonical =
  let open Alcotest in
  test_case "canonical to_string case 2" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = "9:foobarbaz"
      and computed = atom "foobarbaz" |> Canonical.to_string in
      check Alcotest.string "should be equal" expected computed)

let test_to_string_3_canonical =
  let open Alcotest in
  test_case "canonical to_string case 3" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = "(3:foo3:bar(17:Lorem Ipsum Dolor)(6:foobar6:foobaz))"
      and computed =
        node
          [
            atom "foo"
          ; atom "bar"
          ; node [ atom "Lorem Ipsum Dolor" ]
          ; node [ atom "foobar"; atom "foobaz" ]
          ]
        |> Canonical.to_string
      in
      check Alcotest.string "should be equal" expected computed)

let test_from_string_1_canonical =
  let open Alcotest in
  test_case "canonical from_string case 1" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Result.ok @@ node []
      and computed = "" |> Canonical.from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_2_canonical =
  let open Alcotest in
  test_case "canonical from_string case 2" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Result.ok @@ atom ""
      and computed = "0:" |> Canonical.from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_3_canonical =
  let open Alcotest in
  test_case "canonical from_string case 3" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Result.ok @@ node []
      and computed = "()" |> Canonical.from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_4_canonical =
  let open Alcotest in
  test_case "canonical from_string case 4" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Result.ok @@ node [ atom ""; atom "a"; atom "foo" ]
      and computed = "0:1:a3:foo" |> Canonical.from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_5_canonical =
  let open Alcotest in
  test_case "canonical from_string case 5" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected =
        Result.ok @@ node [ atom ""; atom "a"; node [ atom "foo" ] ]
      and computed = "(0:1:a(3:foo))" |> Canonical.from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_6_canonical =
  let open Alcotest in
  test_case "canonical from_string case 6" `Quick (fun () ->
      let open Yocaml.Sexp in
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
        "(3:foo3:bar(17:Lorem Ipsum Dolor)(6:foobar6:foobaz))"
        |> Canonical.from_string
      in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_7_canonical =
  let open Alcotest in
  test_case "canonical from_string case 7" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Result.error @@ Nonterminated_node 12
      and computed = "(0:1:a(3:foo)" |> Canonical.from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_8_canonical =
  let open Alcotest in
  test_case "canonical from_string case 8" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Result.ok @@ atom "foo"
      and computed = "3:foo" |> Canonical.from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_9_canonical =
  let open Alcotest in
  test_case "canonical from_string case 9" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Result.error @@ Premature_end_of_atom (4, 3)
      and computed = "4:foo" |> Canonical.from_string in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_to_string_from_string_roundtrip_canonical =
  QCheck2.Test.make ~name:"canonical to_string -> from_string roundtrip"
    ~count:100
    ~print:(fun x -> Format.asprintf "%a" Yocaml.Sexp.pp x)
    Gen.csexp
    (fun sexp ->
      let open Yocaml.Sexp in
      let result = sexp |> Canonical.to_string |> Canonical.from_string in
      let expected = Ok sexp in
      Alcotest.equal (Testable.csexp_result ()) expected result)
  |> QCheck_alcotest.to_alcotest ~colors:true ~verbose:true

let test_from_string_1 =
  let open Alcotest in
  test_case "from_string case 1" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Ok (node []) and computed = from_string "" in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_2 =
  let open Alcotest in
  test_case "from_string case 2" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Ok (node [])
      and computed = from_string "         \n    \t \n" in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_3 =
  let open Alcotest in
  test_case "from_string case 3" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Ok (node [])
      and computed = from_string "         \n  ()  \t \n" in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_4 =
  let open Alcotest in
  test_case "from_string case 4" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Ok (atom "foo")
      and computed = from_string "         \n  foo  \t \n" in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_5 =
  let open Alcotest in
  test_case "from_string case 5" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Ok (node [ atom "foo"; atom "bar"; atom "baz" ])
      and computed = from_string "         \n  foo bar      baz  \t \n" in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_from_string_6 =
  let open Alcotest in
  test_case "from_string case 6" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Ok (node [ atom "foo"; atom "bar"; node [ atom "baz" ] ])
      and computed = from_string "         \n  (foo bar      (baz))  \t \n" in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let test_to_string_from_string_roundtrip =
  QCheck2.Test.make ~name:"to_string -> from_string roundtrip" ~count:100
    ~print:(fun x ->
      Format.asprintf "%a\n%a" Yocaml.Sexp.pp x Yocaml.Sexp.pp_pretty x)
    Gen.sexp
    (fun sexp ->
      let open Yocaml.Sexp in
      let result = sexp |> to_string |> from_string in
      let expected = Ok sexp in
      Alcotest.equal (Testable.csexp_result ()) expected result)
  |> QCheck_alcotest.to_alcotest ~colors:true ~verbose:true

let test_provider_normalize_1 =
  let open Alcotest in
  test_case "Provider.normalize case 1" `Quick (fun () ->
      let expected =
        let open Yocaml.Data in
        list []
      and computed =
        let open Yocaml.Sexp in
        node [] |> Provider.normalize
      in
      check Testable.data "should be equal" expected computed)

let test_provider_normalize_2 =
  let open Alcotest in
  test_case "Provider.normalize case 2" `Quick (fun () ->
      let expected =
        let open Yocaml.Data in
        record
          [
            ("foo", int 12)
          ; ("bar", bool true)
          ; ("baz", float 3.14)
          ; ("foobar", string "Hello World")
          ; ( "aList"
            , list
                [
                  record [ ("a", bool false); ("b", int 42) ]
                ; int 64
                ; string "foo"
                ; string "bar"
                ] )
          ]
      and computed =
        let open Yocaml.Sexp in
        node
          [
            node [ atom "foo"; atom "12" ]
          ; node [ atom "bar"; atom "true" ]
          ; node [ atom "baz"; atom "3.14" ]
          ; node [ atom "foobar"; atom "Hello World" ]
          ; node
              [
                atom "aList"
              ; node
                  [
                    node
                      [
                        node [ atom "a"; atom "false" ]
                      ; node [ atom "b"; atom "42" ]
                      ]
                  ; atom "64"
                  ; atom "foo"
                  ; atom "bar"
                  ]
              ]
          ]
        |> Provider.normalize
      in
      check Testable.data "should be equal" expected computed)

let test_from_data_1 =
  let open Alcotest in
  test_case "From_data - 1" `Quick (fun () ->
      let expected = Yocaml.Sexp.(node [])
      and computed = Yocaml.Data.(record [] |> to_sexp) in
      check Testable.sexp "should be equal" expected computed)

let test_from_data_2 =
  let open Alcotest in
  test_case "From_data - 2" `Quick (fun () ->
      let expected =
        Yocaml.Sexp.(
          node
            [
              node [ atom "foo"; atom {|"bar"|} ]
            ; node
                [
                  atom "baz"; node [ node [ atom "foobar"; atom {|"hello"|} ] ]
                ]
            ])
      and computed =
        Yocaml.Data.(
          record
            [
              ("foo", string "bar")
            ; ("baz", record [ ("foobar", string "hello") ])
            ]
          |> to_sexp)
      in
      check Testable.sexp "should be equal" expected computed)

let test_from_string_str_1 =
  let open Alcotest in
  test_case "from_string case 1" `Quick (fun () ->
      let open Yocaml.Sexp in
      let expected = Ok (node [ string "foo bar baz"; atom "hello" ])
      and computed = from_string {|("foo bar baz" hello)|} in
      check (Testable.csexp_result ()) "should be equal" expected computed)

let cases =
  ( "Yocaml.Sexp"
  , [
      test_length_1_canonical
    ; test_length_2_canonical
    ; test_length_3_canonical
    ; test_length_4_canonical
    ; test_to_string_1_canonical
    ; test_to_string_2_canonical
    ; test_to_string_3_canonical
    ; test_from_string_1_canonical
    ; test_from_string_2_canonical
    ; test_from_string_3_canonical
    ; test_from_string_4_canonical
    ; test_from_string_5_canonical
    ; test_from_string_6_canonical
    ; test_from_string_7_canonical
    ; test_from_string_8_canonical
    ; test_from_string_9_canonical
    ; test_to_string_from_string_roundtrip_canonical
    ; test_from_string_1
    ; test_from_string_2
    ; test_from_string_3
    ; test_from_string_4
    ; test_from_string_5
    ; test_from_string_6
    ; test_to_string_from_string_roundtrip
    ; test_provider_normalize_1
    ; test_provider_normalize_2
    ; test_from_data_1
    ; test_from_data_2
    ; test_from_string_str_1
    ] )
