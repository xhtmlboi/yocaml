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
open Yocaml
module D = Data
module V = D.Validation

let nel l = l |> Nel.from_list |> Option.get
let one_of' = V.one_of ~pp:Format.pp_print_string ~equal:String.equal

let test_sample_1 =
  let open Alcotest in
  test_case "validation sample 1 - valid source" `Quick (fun () ->
      let testable =
        triple int
          (triple (option bool) string (list (float 1.0)))
          (option string)
        |> Testable.validated_value
      in
      let source =
        let open Data in
        record
          [
            ("foo", int 10)
          ; ( "bar"
            , record
                [
                  ("a", bool true)
                ; ("b", string "hello World")
                ; ("c", list_of float [ 1.2; 2.3; 3.4 ])
                ] )
          ; ("baz", null)
          ]
      in
      let validate =
        let open V in
        record (fun obj ->
            let+ foo = required obj "foo" (int & bounded ~min:5 ~max:10)
            and+ baz = optional obj "baz" (string & one_of' [ "hello"; "world" ])
            and+ bar =
              required obj "bar"
                (record (fun obj ->
                     let+ a = optional obj "a" (bool & where (fun x -> x))
                     and+ b = required obj "b" string
                     and+ c =
                       optional_or obj "c" ~default:[ 3.14 ]
                         (list_of float & non_empty)
                     in
                     (a, b, c)))
            in
            (foo, bar, baz))
      in
      let expected = Ok (10, (Some true, "hello World", [ 1.2; 2.3; 3.4 ]), None)
      and computed = validate source in
      check testable "should be valid" expected computed)

let test_sample_2 =
  let open Alcotest in
  test_case "validation sample 1 - invalid source (record expected)" `Quick
    (fun () ->
      let testable =
        triple int
          (triple (option bool) string (list (float 1.0)))
          (option string)
        |> Testable.validated_value
      in
      let source =
        let open Data in
        int 0
      in
      let validate =
        let open V in
        record (fun obj ->
            let+ foo = required obj "foo" (int & bounded ~min:5 ~max:10)
            and+ baz = optional obj "baz" (string & one_of' [ "hello"; "world" ])
            and+ bar =
              required obj "bar"
                (record (fun obj ->
                     let+ a = optional obj "a" (bool & where (fun x -> x))
                     and+ b = required obj "b" string
                     and+ c =
                       optional_or obj "c" ~default:[ 3.14 ]
                         (list_of float & non_empty)
                     in
                     (a, b, c)))
            in
            (foo, bar, baz))
      in
      let expected =
        V.(Invalid_shape { expected = "record"; given = Data.int 0 })
        |> Result.error
      and computed = validate source in
      check testable "should be invalid" expected computed)

let test_sample_3 =
  let open Alcotest in
  test_case "validation sample 1 - invalid source (missing fields)" `Quick
    (fun () ->
      let testable =
        triple int
          (triple (option bool) string (list (float 1.0)))
          (option string)
        |> Testable.validated_value
      in
      let source =
        let open D in
        record [ ("baz", string "olleh") ]
      in
      let validate =
        let open V in
        record (fun obj ->
            let+ foo = required obj "foo" (int & bounded ~min:5 ~max:10)
            and+ baz = optional obj "baz" (string & one_of' [ "hello"; "world" ])
            and+ bar =
              required obj "bar"
                (record (fun obj ->
                     let+ a = optional obj "a" (bool & where (fun x -> x))
                     and+ b = required obj "b" string
                     and+ c =
                       optional_or obj "c" ~default:[ 3.14 ]
                         (list_of float & non_empty)
                     in
                     (a, b, c)))
            in

            (foo, bar, baz))
      in
      let expected =
        V.(
          Invalid_record
            {
              errors =
                nel
                  [
                    Missing_field { field = "foo" }
                  ; Invalid_field
                      {
                        given = Data.string "olleh"
                      ; field = "baz"
                      ; error =
                          With_message
                            {
                              given = "olleh"
                            ; message =
                                Format.asprintf "not included in [hello; world]"
                            }
                      }
                  ; Missing_field { field = "bar" }
                  ]
            ; given = [ ("baz", Data.string "olleh") ]
            })
        |> Result.error
      and computed = validate source in

      check testable "should be invalid" expected computed)

let test_null_1 =
  let open Alcotest in
  test_case "validate null - validate generated null" `Quick (fun () ->
      let expected = Ok () and computed = V.null D.null in
      check (Testable.validated_value unit) "should equal" expected computed)

let test_null_2 =
  let open Alcotest in
  test_case "validate null - validate from option" `Quick (fun () ->
      let expected = Ok () and computed = V.null @@ D.option D.string None in
      check (Testable.validated_value unit) "should equal" expected computed)

let test_null_3 =
  let open Alcotest in
  test_case "validate null - validate from other value" `Quick (fun () ->
      let given = D.option D.string (Some "foo") in
      let expected = Error V.(Invalid_shape { expected = "null"; given })
      and computed = V.null given in
      check (Testable.validated_value unit) "should equal" expected computed)

let test_bool_1 =
  let open Alcotest in
  test_case "validate bool - validate from bool" `Quick (fun () ->
      let given = D.bool true in
      let expected = Ok true and computed = V.bool given in
      check (Testable.validated_value bool) "should equal" expected computed)

let test_bool_2 =
  let open Alcotest in
  test_case "validate bool - validate from other value" `Quick (fun () ->
      let given = D.string "foo" in
      let expected = Error V.(Invalid_shape { expected = "bool"; given })
      and computed = V.bool given in
      check (Testable.validated_value bool) "should equal" expected computed)

let test_int_1 =
  let open Alcotest in
  test_case "validate int - validate from int" `Quick (fun () ->
      let given = D.int 42 in
      let expected = Ok 42 and computed = V.int given in
      check (Testable.validated_value int) "should equal" expected computed)

let test_int_2 =
  let open Alcotest in
  test_case "validate int - validate from float" `Quick (fun () ->
      let given = D.float 42.72 in
      let expected = Ok 42 and computed = V.int given in
      check (Testable.validated_value int) "should equal" expected computed)

let test_int_3 =
  let open Alcotest in
  test_case "validate int - validate from other value" `Quick (fun () ->
      let given = D.string "foo" in
      let expected = Error V.(Invalid_shape { expected = "int"; given })
      and computed = V.int given in
      check (Testable.validated_value int) "should equal" expected computed)

let test_float_1 =
  let open Alcotest in
  test_case "validate float - validate from float" `Quick (fun () ->
      let given = D.float 42.87 in
      let expected = Ok 42.87 and computed = V.float given in
      check
        (Testable.validated_value (float 2.0))
        "should equal" expected computed)

let test_float_2 =
  let open Alcotest in
  test_case "validate float - validate from other value" `Quick (fun () ->
      let given = D.string "foo" in
      let expected = Error V.(Invalid_shape { expected = "float"; given })
      and computed = V.float given in
      check
        (Testable.validated_value (float 2.0))
        "should equal" expected computed)

let test_strict_string_1 =
  let open Alcotest in
  test_case "validate strict string - validate from string" `Quick (fun () ->
      let given = D.string "foo" in
      let expected = Ok "foo" and computed = V.string given in
      check (Testable.validated_value string) "should equal" expected computed)

let test_strict_string_2 =
  let open Alcotest in
  test_case "validate strict string - validate from other value" `Quick
    (fun () ->
      let given = D.float 23.4 in
      let expected =
        Error V.(Invalid_shape { expected = "strict-string"; given })
      and computed = V.string given in
      check (Testable.validated_value string) "should equal" expected computed)

let test_non_strict_string_1 =
  let open Alcotest in
  test_case "validate non-strict string - validate from string" `Quick
    (fun () ->
      let given = D.string "foo" in
      let expected = Ok "foo" and computed = V.string ~strict:false given in
      check (Testable.validated_value string) "should equal" expected computed)

let test_non_strict_string_2 =
  let open Alcotest in
  test_case "validate non-strict string - validate from bool" `Quick (fun () ->
      let given = D.bool true in
      let expected = Ok "true" and computed = V.string ~strict:false given in
      check (Testable.validated_value string) "should equal" expected computed)

let test_non_strict_string_3 =
  let open Alcotest in
  test_case "validate non-strict string - validate from int" `Quick (fun () ->
      let given = D.int 42 in
      let expected = Ok "42" and computed = V.string ~strict:false given in
      check (Testable.validated_value string) "should equal" expected computed)

let test_non_strict_string_4 =
  let open Alcotest in
  test_case "validate non-strict string - validate from float" `Quick (fun () ->
      let given = D.float 42.6 in
      let expected = Ok "42.6" and computed = V.string ~strict:false given in
      check (Testable.validated_value string) "should equal" expected computed)

let test_non_strict_string_5 =
  let open Alcotest in
  test_case "validate non-strict string - validate from other value" `Quick
    (fun () ->
      let given = D.list_of D.float [] in
      let expected =
        Error V.(Invalid_shape { expected = "non-strict-string"; given })
      and computed = V.string ~strict:false given in
      check (Testable.validated_value string) "should equal" expected computed)

let test_list_of_1 =
  let open Alcotest in
  test_case "validate list - validate a generated list" `Quick (fun () ->
      let given = D.list_of D.string [ "foo"; "bar"; "baz" ] in
      let expected = Ok [ "foo"; "bar"; "baz" ]
      and computed = V.list_of V.string given in
      check
        (Testable.validated_value @@ list string)
        "should be equal" expected computed)

let test_list_of_2 =
  let open Alcotest in
  test_case "validate list - validate an other value" `Quick (fun () ->
      let given = D.string "foo" in
      let expected = Error V.(Invalid_shape { expected = "list"; given })
      and computed = V.list_of V.string given in
      check
        (Testable.validated_value @@ list string)
        "should be equal" expected computed)

let test_list_of_3 =
  let open Alcotest in
  test_case "validate list - validate some value are not valid" `Quick
    (fun () ->
      let given_list =
        [
          D.string "foo"
        ; D.int 1
        ; D.string "bar"
        ; D.bool true
        ; D.string "baz"
        ; D.int 32
        ]
      in
      let given = D.list given_list in
      let expected =
        Error
          V.(
            Invalid_list
              {
                errors =
                  nel
                    [
                      ( 5
                      , Invalid_shape
                          { expected = "strict-string"; given = D.int 32 } )
                    ; ( 3
                      , Invalid_shape
                          { expected = "strict-string"; given = D.bool true } )
                    ; ( 1
                      , Invalid_shape
                          { expected = "strict-string"; given = D.int 1 } )
                    ]
              ; given = given_list
              })
      and computed = V.list_of V.string given in
      check
        (Testable.validated_value @@ list string)
        "should be equal" expected computed)

let test_record_1 =
  let open Alcotest in
  test_case "validate record - validate a valid generated record" `Quick
    (fun () ->
      let given =
        D.record
          [
            ("a", D.string "foo")
          ; ("b", D.option D.int (Some 10))
          ; ("c", D.option D.bool None)
          ; ("d", D.list_of D.int [ 1; 2; 3 ])
          ]
      in
      let expected = Ok (("foo", Some 10), (None, [ 1; 2; 3 ]))
      and computed =
        let open V in
        record
          (fun assoc ->
            let+ a = required assoc "a" string
            and+ b = optional assoc "b" int
            and+ c = optional assoc "c" bool
            and+ d = optional_or assoc "d" ~default:[] (list_of int) in
            ((a, b), (c, d)))
          given
      in
      check
        (Testable.validated_value
        @@ pair (pair string (option int)) (pair (option bool) (list int)))
        "should be equal" expected computed)

let test_record_2 =
  let open Alcotest in
  test_case
    "validate record - validate a valid generated record and other optional \
     values"
    `Quick (fun () ->
      let given = D.record [ ("a", D.string "foo"); ("c", D.bool true) ] in
      let expected = Ok (("foo", None), (Some true, []))
      and computed =
        let open V in
        record
          (fun assoc ->
            let+ a = required assoc "a" string
            and+ b = optional assoc "b" int
            and+ c = optional assoc "c" bool
            and+ d = optional_or assoc "d" ~default:[] (list_of int) in
            ((a, b), (c, d)))
          given
      in
      check
        (Testable.validated_value
        @@ pair (pair string (option int)) (pair (option bool) (list int)))
        "should be equal" expected computed)

let test_record_3 =
  let open Alcotest in
  test_case "validate record - validate an invalid input" `Quick (fun () ->
      let given = D.int 45 in
      let expected = Error V.(Invalid_shape { expected = "record"; given })
      and computed =
        let open V in
        record
          (fun assoc ->
            let+ a = required assoc "a" string
            and+ b = optional assoc "b" int
            and+ c = optional assoc "c" bool
            and+ d = optional_or assoc "d" ~default:[] (list_of int) in
            ((a, b), (c, d)))
          given
      in
      check
        (Testable.validated_value
        @@ pair (pair string (option int)) (pair (option bool) (list int)))
        "should be equal" expected computed)

let test_record_4 =
  let open Alcotest in
  test_case "validate record - validate an invalid record" `Quick (fun () ->
      let given = D.record [ ("c", D.bool true) ] in
      let expected =
        Error
          V.(
            Invalid_record
              {
                errors = nel [ Missing_field { field = "a" } ]
              ; given = [ ("c", D.bool true) ]
              })
      and computed =
        let open V in
        record
          (fun assoc ->
            let+ a = required assoc "a" string
            and+ b = optional assoc "b" int
            and+ c = optional assoc "c" bool
            and+ d = optional_or assoc "d" ~default:[] (list_of int) in
            ((a, b), (c, d)))
          given
      in
      check
        (Testable.validated_value
        @@ pair (pair string (option int)) (pair (option bool) (list int)))
        "should be equal" expected computed)

let test_record_5 =
  let open Alcotest in
  test_case "validate record - validate an invalid record" `Quick (fun () ->
      let given =
        D.record
          [
            ("a", D.string "foo")
          ; ("c", D.int 22)
          ; ("d", D.list [ D.string "1"; D.bool true ])
          ]
      in
      let expected =
        Error
          V.(
            Invalid_record
              {
                errors =
                  nel
                    [
                      Invalid_field
                        {
                          field = "c"
                        ; error =
                            Invalid_shape
                              { expected = "bool"; given = D.int 22 }
                        ; given = D.int 22
                        }
                    ; Invalid_field
                        {
                          field = "d"
                        ; error =
                            Invalid_list
                              {
                                errors =
                                  nel
                                    [
                                      ( 1
                                      , Invalid_shape
                                          {
                                            expected = "int"
                                          ; given = D.bool true
                                          } )
                                    ; ( 0
                                      , Invalid_shape
                                          {
                                            expected = "int"
                                          ; given = D.string "1"
                                          } )
                                    ]
                              ; given = [ D.string "1"; D.bool true ]
                              }
                        ; given = D.list [ D.string "1"; D.bool true ]
                        }
                    ]
              ; given =
                  [
                    ("a", D.string "foo")
                  ; ("c", D.int 22)
                  ; ("d", D.list [ D.string "1"; D.bool true ])
                  ]
              })
      and computed =
        let open V in
        record
          (fun assoc ->
            let+ a = required assoc "a" string
            and+ b = optional assoc "b" int
            and+ c = optional assoc "c" bool
            and+ d = optional_or assoc "d" ~default:[] (list_of int) in
            ((a, b), (c, d)))
          given
      in
      check
        (Testable.validated_value
        @@ pair (pair string (option int)) (pair (option bool) (list int)))
        "should be equal" expected computed)

let cases =
  ( "Yocaml.Data"
  , [
      test_sample_1
    ; test_sample_2
    ; test_sample_3
    ; test_null_1
    ; test_null_2
    ; test_null_3
    ; test_bool_1
    ; test_bool_2
    ; test_int_1
    ; test_int_2
    ; test_int_3
    ; test_float_1
    ; test_float_2
    ; test_strict_string_1
    ; test_strict_string_2
    ; test_non_strict_string_1
    ; test_non_strict_string_2
    ; test_non_strict_string_3
    ; test_non_strict_string_4
    ; test_non_strict_string_5
    ; test_list_of_1
    ; test_list_of_2
    ; test_list_of_3
    ; test_record_1
    ; test_record_2
    ; test_record_3
    ; test_record_4
    ; test_record_5
    ] )
