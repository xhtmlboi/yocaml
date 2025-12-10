(* YOCaml a static blog generator.
   Copyright (C) 2025 The Funkyworkers and The YOCaml's developers

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

type t = {
    page : Yocaml.Archetype.Page.t
  ; category : string option
  ; authors : string list
}

let normalize_t { page; category; authors } =
  let open Yocaml.Data in
  record
    (Yocaml.Archetype.Page.normalize page
    @ [
        ("category", option string category)
      ; ("authors", (list_of string) authors)
      ])

let testable_t =
  let pp ppf x = Format.fprintf ppf "%a" Yocaml.Data.pp (normalize_t x)
  and equal a b = Yocaml.Data.equal (normalize_t a) (normalize_t b) in
  Alcotest.testable pp equal

let validate_t =
  let open Yocaml.Data.Validation in
  record (fun fields ->
      let+ page = sub_record fields Yocaml.Archetype.Page.validate
      and+ category = optional fields "category" string
      and+ authors =
        optional_or ~default:[] fields "authors" (list_of string)
      in
      { page; category; authors })

let test_validate_with_subpage_1 =
  let open Alcotest in
  test_case "Validate using a page inside a different value - 1" `Quick
    (fun () ->
      let input =
        let open Yocaml.Data in
        record []
      and input_page =
        let open Yocaml.Data in
        record []
      and category = None
      and authors = [] in
      let expected =
        Result.map
          (fun page -> { page; category; authors })
          (Yocaml.Archetype.Page.validate input_page)
      and computed = validate_t input in
      check
        Test_lib.Testable.(validated_value testable_t)
        "shoudl be equal" expected computed)

let test_validate_with_subpage_2 =
  let open Alcotest in
  test_case "Validate using a page inside a different value - 2" `Quick
    (fun () ->
      let input =
        let open Yocaml.Data in
        record [ ("page_title", string "foo") ]
      and input_page =
        let open Yocaml.Data in
        record [ ("page_title", string "foo") ]
      and category = None
      and authors = [] in
      let expected =
        Result.map
          (fun page -> { page; category; authors })
          (Yocaml.Archetype.Page.validate input_page)
      and computed = validate_t input in
      check
        Test_lib.Testable.(validated_value testable_t)
        "shoudl be equal" expected computed)

let test_validate_with_subpage_3 =
  let open Alcotest in
  test_case "Validate using a page inside a different value - 3" `Quick
    (fun () ->
      let input =
        let open Yocaml.Data in
        record
          [
            ("page_title", string "foo")
          ; ("category", string "article")
          ; ("authors", list_of string [ "xvw"; "xhtmlboi"; "msp"; "grm" ])
          ]
      and input_page =
        let open Yocaml.Data in
        record [ ("page_title", string "foo") ]
      and category = Some "article"
      and authors = [ "xvw"; "xhtmlboi"; "msp"; "grm" ] in
      let expected =
        Result.map
          (fun page -> { page; category; authors })
          (Yocaml.Archetype.Page.validate input_page)
      and computed = validate_t input in
      check
        Test_lib.Testable.(validated_value testable_t)
        "shoudl be equal" expected computed)

let cases =
  ( "Yocaml.Archetype.Path"
  , [
      test_validate_with_subpage_1
    ; test_validate_with_subpage_2
    ; test_validate_with_subpage_3
    ] )
