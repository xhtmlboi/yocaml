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

let test_extract_from_content_1 =
  let open Alcotest in
  test_case "extract_from_content - 1" `Quick (fun () ->
      let open Yocaml.Metadata in
      let given = {||} in
      let expected = (None, "")
      and computed = extract_from_content ~strategy:jekyll given in
      check Testable.with_metadata "should be equal" expected computed)

let test_extract_from_content_2 =
  let open Alcotest in
  test_case "extract_from_content - 2" `Quick (fun () ->
      let open Yocaml.Metadata in
      let given = {|Hello World|} in
      let expected = (None, "Hello World")
      and computed = extract_from_content ~strategy:jekyll given in
      check Testable.with_metadata "should be equal" expected computed)

let test_extract_from_content_3 =
  let open Alcotest in
  test_case "extract_from_content - 3" `Quick (fun () ->
      let open Yocaml.Metadata in
      let given = {|---
---
|} in
      let expected = (Some "", "")
      and computed = extract_from_content ~strategy:jekyll given in
      check Testable.with_metadata "should be equal" expected computed)

let test_extract_from_content_4 =
  let open Alcotest in
  test_case "extract_from_content - 4" `Quick (fun () ->
      let open Yocaml.Metadata in
      let given = {|---
a
b
c
---
|} in
      let expected = (Some "a\nb\nc\n", "")
      and computed = extract_from_content ~strategy:jekyll given in
      check Testable.with_metadata "should be equal" expected computed)

let test_extract_from_content_5 =
  let open Alcotest in
  test_case "extract_from_content - 5" `Quick (fun () ->
      let open Yocaml.Metadata in
      let given = {|---
a
b
c
---
Hello World|} in
      let expected = (Some "a\nb\nc\n", "Hello World")
      and computed = extract_from_content ~strategy:jekyll given in
      check Testable.with_metadata "should be equal" expected computed)

let test_extract_from_content_6 =
  let open Alcotest in
  test_case "extract_from_content - 6" `Quick (fun () ->
      let open Yocaml.Metadata in
      let given = {|***
a
b
c
***
Hello World|} in
      let expected = (Some "a\nb\nc\n", "Hello World")
      and computed = extract_from_content ~strategy:(regular '*') given in
      check Testable.with_metadata "should be equal" expected computed)

let validate_dummy =
  Yocaml.Metadata.validate (module Yocaml.Sexp.Provider) (module Metadata.Dummy)

let test_validate_dummy_1 =
  let open Alcotest in
  test_case "validate dummy metadata - 1" `Quick (fun () ->
      let given = None in
      let expected = Metadata.Dummy.neutral
      and computed = validate_dummy given in
      check
        (Testable.validated_metadata Metadata.Dummy.testable)
        "should be equal" expected computed)

let test_validate_dummy_2 =
  let open Alcotest in
  test_case "validate dummy metadata - 2" `Quick (fun () ->
      let given = Some "(foo" in
      let expected =
        Error
          (Yocaml.Required.Parsing_error
             { given = "(foo"; message = "non-terminated node on [4]" })
      and computed = validate_dummy given in
      check
        (Testable.validated_metadata Metadata.Dummy.testable)
        "should be equal" expected computed)

let test_validate_dummy_3 =
  let open Alcotest in
  test_case "validate dummy metadata - 3" `Quick (fun () ->
      let given = Some {|((name John)(age 42))|} in
      let expected =
        Ok Metadata.Dummy.{ name = "John"; age = 42; nouns = []; is_fun = None }
      and computed = validate_dummy given in
      check
        (Testable.validated_metadata Metadata.Dummy.testable)
        "should be equal" expected computed)

let test_validate_dummy_4 =
  let open Alcotest in
  test_case "validate dummy metadata - 4" `Quick (fun () ->
      let given =
        Some {|((name John)(age 42)
(funny true)   (nouns (a b c d))
)|}
      in
      let expected =
        Ok
          Metadata.Dummy.
            {
              name = "John"
            ; age = 42
            ; nouns = [ "a"; "b"; "c"; "d" ]
            ; is_fun = Some true
            }
      and computed = validate_dummy given in
      check
        (Testable.validated_metadata Metadata.Dummy.testable)
        "should be equal" expected computed)

let test_validate_dummy_5 =
  let open Alcotest in
  test_case "validate dummy metadata - 5" `Quick (fun () ->
      let given = Some {|((name 42)
(funny no-funny)   (nouns (a b c d))
)|} in
      let expected =
        Error
          (Yocaml.Required.Validation_error
             {
               entity = "dummy"
             ; error =
                 Yocaml.Data.(
                   Validation.Invalid_record
                     {
                       given =
                         [
                           ("name", int 42)
                         ; ("funny", string "no-funny")
                         ; ("nouns", list_of string [ "a"; "b"; "c"; "d" ])
                         ]
                     ; errors =
                         Yocaml.Nel.from_list
                           [
                             Validation.Invalid_field
                               {
                                 field = "name"
                               ; error =
                                   Validation.Invalid_shape
                                     {
                                       expected = "strict-string"
                                     ; given = int 42
                                     }
                               ; given = int 42
                               }
                           ; Validation.Missing_field { field = "age" }
                           ; Validation.Invalid_field
                               {
                                 field = "funny"
                               ; error =
                                   Validation.Invalid_shape
                                     {
                                       expected = "bool"
                                     ; given = string "no-funny"
                                     }
                               ; given = string "no-funny"
                               }
                           ]
                         |> Option.get
                     })
             })
      and computed = validate_dummy given in
      check
        (Testable.validated_metadata Metadata.Dummy.testable)
        "should be equal" expected computed)

let cases =
  ( "Yocaml.Metadata"
  , [
      test_extract_from_content_1
    ; test_extract_from_content_2
    ; test_extract_from_content_3
    ; test_extract_from_content_4
    ; test_extract_from_content_5
    ; test_extract_from_content_6
    ; test_validate_dummy_1
    ; test_validate_dummy_2
    ; test_validate_dummy_3
    ; test_validate_dummy_4
    ; test_validate_dummy_5
    ] )
