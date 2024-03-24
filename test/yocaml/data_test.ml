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

let test_option_1 =
  let open Alcotest in
  test_case "option - validate a null value" `Quick (fun () ->
      let expected = Ok None and computed = V.option V.string D.null in
      check
        (Testable.validated_value @@ option string)
        "should be equal" expected computed)

let test_option_2 =
  let open Alcotest in
  test_case "option - validate a filled value" `Quick (fun () ->
      let expected = Ok (Some "foo")
      and computed = V.option V.string (D.string "foo") in
      check
        (Testable.validated_value @@ option string)
        "should be equal" expected computed)

let test_option_3 =
  let open Alcotest in
  test_case "option - validate with an invalid value" `Quick (fun () ->
      let expected =
        Error V.(Invalid_shape { expected = "strict-string"; given = D.int 12 })
      and computed = V.option V.string (D.int 12) in
      check
        (Testable.validated_value @@ option string)
        "should be equal" expected computed)

let test_pair_1 =
  let open Alcotest in
  test_case "pair - validate a generated value" `Quick (fun () ->
      let given = D.pair D.int D.string (42, "foo") in
      let expected = Ok (42, "foo")
      and computed = V.pair V.int V.string given in
      check
        (Testable.validated_value @@ pair int string)
        "should be equal" expected computed)

let test_pair_2 =
  let open Alcotest in
  test_case "pair - validate an invalid value" `Quick (fun () ->
      let given = D.int 42 in
      let expected = Error V.(Invalid_shape { expected = "pair"; given })
      and computed = V.pair V.int V.string given in
      check
        (Testable.validated_value @@ pair int string)
        "should be equal" expected computed)

let test_pair_3 =
  let open Alcotest in
  test_case "pair - validate an invalid on fst member" `Quick (fun () ->
      let given = D.pair D.string D.string ("foo", "bar") in
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
                          field = "fst"
                        ; error =
                            Invalid_shape
                              { expected = "int"; given = D.string "foo" }
                        ; given = D.string "foo"
                        }
                    ]
              ; given = [ ("fst", D.string "foo"); ("snd", D.string "bar") ]
              })
      and computed = V.pair V.int V.string given in
      check
        (Testable.validated_value @@ pair int string)
        "should be equal" expected computed)

let test_pair_4 =
  let open Alcotest in
  test_case "pair - validate an invalid on snd member" `Quick (fun () ->
      let given = D.pair D.int D.int (42, 43) in
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
                          field = "snd"
                        ; error =
                            Invalid_shape
                              { expected = "strict-string"; given = D.int 43 }
                        ; given = D.int 43
                        }
                    ]
              ; given = [ ("fst", D.int 42); ("snd", D.int 43) ]
              })
      and computed = V.pair V.int V.string given in
      check
        (Testable.validated_value @@ pair int string)
        "should be equal" expected computed)

let test_pair_5 =
  let open Alcotest in
  test_case "pair - validate an invalid on snd member" `Quick (fun () ->
      let given = D.pair D.string D.int ("42", 43) in
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
                          field = "fst"
                        ; error =
                            Invalid_shape
                              { expected = "int"; given = D.string "42" }
                        ; given = D.string "42"
                        }
                    ; Invalid_field
                        {
                          field = "snd"
                        ; error =
                            Invalid_shape
                              { expected = "strict-string"; given = D.int 43 }
                        ; given = D.int 43
                        }
                    ]
              ; given = [ ("fst", D.string "42"); ("snd", D.int 43) ]
              })
      and computed = V.pair V.int V.string given in
      check
        (Testable.validated_value @@ pair int string)
        "should be equal" expected computed)

let test_triple_1 =
  let open Alcotest in
  test_case "triple - validate a generated value" `Quick (fun () ->
      let given = D.triple D.int D.string D.bool (42, "foo", false) in
      let expected = Ok (42, "foo", false)
      and computed = V.triple V.int V.string V.bool given in
      check
        (Testable.validated_value @@ triple int string bool)
        "should be equal" expected computed)

let test_quad_1 =
  let open Alcotest in
  test_case "quad - validate a generated value" `Quick (fun () ->
      let given =
        D.quad D.int D.string D.bool D.float (42, "foo", false, 12.7)
      in
      let expected = Ok ((42, "foo", false), 12.7)
      and computed =
        given
        |> V.quad V.int V.string V.bool V.float
        |> Result.map (fun (a, b, c, d) -> ((a, b, c), d))
      in
      check
        (Testable.validated_value @@ pair (triple int string bool) (float 2.0))
        "should be equal" expected computed)

(* We do not test errors on triple and quad since it's relaying on pair. *)

let test_sum_1 =
  let open Alcotest in
  test_case "sum - validate sums" `Quick (fun () ->
      let sum =
        D.sum (function
          | `A s -> ("a", D.string s)
          | `B i -> ("b", D.int i)
          | `C b -> ("c", D.bool b)
          | `D -> ("d", D.null))
      in
      let v_sum =
        V.(
          sum
            [
              ("a", string $ fun x -> `A x)
            ; ("b", int $ fun x -> `B x)
            ; ("c", bool $ fun x -> `C x)
            ; ("d", null $ fun () -> `D)
            ])
      in
      let testable =
        Alcotest.testable
          (fun ppf -> function
            | `A x -> Format.fprintf ppf "`A %s" x
            | `B x -> Format.fprintf ppf "`B %d" x
            | `C x -> Format.fprintf ppf "`C %b" x
            | `D -> Format.fprintf ppf "`D")
          (fun a b ->
            match (a, b) with
            | `A a, `A b -> String.equal a b
            | `B a, `B b -> Int.equal a b
            | `C a, `C b -> Bool.equal a b
            | `D, `D -> true
            | _ -> false)
      in
      let () =
        check
          (Testable.validated_value testable)
          "`A foo: should be equal"
          (Ok (`A "foo"))
          (v_sum (sum @@ `A "foo"))
      in
      let () =
        check
          (Testable.validated_value testable)
          "`B 42: should be equal"
          (Ok (`B 42))
          (v_sum (sum @@ `B 42))
      in
      let () =
        check
          (Testable.validated_value testable)
          "`C false: should be equal"
          (Ok (`C false))
          (v_sum (sum @@ `C false))
      in
      let () =
        check
          (Testable.validated_value testable)
          "`D: should be equal" (Ok `D)
          (v_sum (sum @@ `D))
      in
      let () =
        check
          (Testable.validated_value testable)
          "Invalid shape"
          (Error
             V.(
               Invalid_shape
                 {
                   expected = "A <abstr> | B <abstr> | C <abstr> | D <abstr>"
                 ; given = D.int 45
                 }))
          (v_sum (D.int 45))
      in
      let () =
        check
          (Testable.validated_value testable)
          "Invalid constructor"
          (Error
             V.(
               Invalid_shape
                 {
                   expected = "A <abstr> | B <abstr> | C <abstr> | D <abstr>"
                 ; given =
                     D.record [ ("constr", D.string "e"); ("value", D.int 10) ]
                 }))
          (v_sum (D.sum (function `E x -> ("e", D.int x)) (`E 10)))
      in
      let () =
        check
          (Testable.validated_value testable)
          "Invalid validation"
          (Error
             V.(
               Invalid_shape
                 { expected = "strict-string"; given = D.float 32.0 }))
          (v_sum
             (D.record [ ("constr", D.string "a"); ("value", D.float 32.0) ]))
      in
      ())

let test_positive =
  let open Alcotest in
  test_case "positive - validate positive" `Quick (fun () ->
      let v = V.(int & positive) in
      let () =
        check
          (Testable.validated_value int)
          "should be equal" (Ok 10)
          (v @@ D.int 10)
      in
      let () =
        check
          (Testable.validated_value int)
          "should be equal"
          (Error
             V.(With_message { given = "-35"; message = "should be positive" }))
          (v @@ D.int (-35))
      in
      ())

let test_positive_f =
  let open Alcotest in
  test_case "positive' - validate positive" `Quick (fun () ->
      let v = V.(float & positive') in
      let () =
        check
          (Testable.validated_value @@ float 2.0)
          "should be equal" (Ok 10.65)
          (v @@ D.float 10.65)
      in
      let () =
        check
          (Testable.validated_value @@ float 2.0)
          "should be equal"
          (Error
             V.(
               With_message { given = "-35.3"; message = "should be positive" }))
          (v @@ D.float (-35.3))
      in
      ())

let test_bounded =
  let open Alcotest in
  test_case "bounded - validate bounded" `Quick (fun () ->
      let v = V.(int & bounded ~min:2 ~max:8) in
      let () =
        check
          (Testable.validated_value int)
          "should be equal" (Ok 7)
          (v @@ D.int 7)
      in
      let () =
        check
          (Testable.validated_value int)
          "should be equal"
          (Error
             V.(
               With_message
                 { given = "-35"; message = "not included into [2; 8]" }))
          (v @@ D.int (-35))
      in
      let () =
        check
          (Testable.validated_value int)
          "should be equal"
          (Error
             V.(
               With_message
                 { given = "35"; message = "not included into [2; 8]" }))
          (v @@ D.int 35)
      in
      ())

let test_bounded_f =
  let open Alcotest in
  test_case "bounded' - validate bounded" `Quick (fun () ->
      let v = V.(float & bounded' ~min:2.1 ~max:8.1) in
      let () =
        check
          (Testable.validated_value @@ float 2.0)
          "should be equal" (Ok 8.01)
          (v @@ D.float 8.01)
      in
      let () =
        check
          (Testable.validated_value @@ float 2.0)
          "should be equal"
          (Error
             V.(
               With_message
                 {
                   given = "-35."
                 ; message = "not included into [2.100000; 8.100000]"
                 }))
          (v @@ D.float (-35.0))
      in
      let () =
        check
          (Testable.validated_value @@ float 2.0)
          "should be equal"
          (Error
             V.(
               With_message
                 {
                   given = "8.2"
                 ; message = "not included into [2.100000; 8.100000]"
                 }))
          (v @@ D.float 8.2)
      in
      ())

let test_non_empty =
  let open Alcotest in
  test_case "non_empty - validate non_empty" `Quick (fun () ->
      let check =
        check (Testable.validated_value @@ list int) "should be equal"
      in
      let v = V.(list_of int & non_empty) in
      let () = check (Ok [ 1; 2 ]) (v @@ D.list_of D.int [ 1; 2 ]) in
      let () =
        check
          (Error
             V.(
               With_message
                 { given = "[]"; message = "list should not be empty" }))
          (v @@ D.list_of D.int [])
      in
      ())

let test_equal =
  let open Alcotest in
  test_case "equal - validate equal" `Quick (fun () ->
      let check = check (Testable.validated_value int) "should be equal" in
      let v = V.(int & equal ~pp:Format.pp_print_int ~equal:Int.equal 10) in
      let () = check (Ok 10) (v @@ D.int 10) in
      let () =
        check
          (Error
             V.(
               With_message { given = "11"; message = "should be equal to 10" }))
          (v @@ D.int 11)
      in
      ())

let test_not_equal =
  let open Alcotest in
  test_case "not_equal - validate not_equal" `Quick (fun () ->
      let check = check (Testable.validated_value int) "should be equal" in
      let v = V.(int & not_equal ~pp:Format.pp_print_int ~equal:Int.equal 10) in
      let () = check (Ok 11) (v @@ D.int 11) in
      let () =
        check
          (Error
             V.(
               With_message
                 { given = "10"; message = "should not be equal to 10" }))
          (v @@ D.int 10)
      in
      ())

let test_gt =
  let open Alcotest in
  test_case "gt - validate gt" `Quick (fun () ->
      let check = check (Testable.validated_value int) "should be equal" in
      let v = V.(int & gt ~pp:Format.pp_print_int ~compare:Int.compare 10) in
      let () = check (Ok 11) (v @@ D.int 11) in
      let () =
        check
          (Error
             V.(
               With_message
                 { given = "10"; message = "should be greater than 10" }))
          (v @@ D.int 10)
      in
      ())

let test_ge =
  let open Alcotest in
  test_case "ge - validate ge" `Quick (fun () ->
      let check = check (Testable.validated_value int) "should be equal" in
      let v = V.(int & ge ~pp:Format.pp_print_int ~compare:Int.compare 10) in
      let () = check (Ok 11) (v @@ D.int 11) in
      let () = check (Ok 10) (v @@ D.int 10) in
      let () =
        check
          (Error
             V.(
               With_message
                 { given = "7"; message = "should be greater or equal to 10" }))
          (v @@ D.int 7)
      in
      ())

let test_lt =
  let open Alcotest in
  test_case "lt - validate lt" `Quick (fun () ->
      let check = check (Testable.validated_value int) "should be equal" in
      let v = V.(int & lt ~pp:Format.pp_print_int ~compare:Int.compare 10) in
      let () = check (Ok 9) (v @@ D.int 9) in
      let () =
        check
          (Error
             V.(
               With_message
                 { given = "10"; message = "should be lesser than 10" }))
          (v @@ D.int 10)
      in
      ())

let test_le =
  let open Alcotest in
  test_case "le - validate le" `Quick (fun () ->
      let check = check (Testable.validated_value int) "should be equal" in
      let v = V.(int & le ~pp:Format.pp_print_int ~compare:Int.compare 10) in
      let () = check (Ok 9) (v @@ D.int 9) in
      let () = check (Ok 10) (v @@ D.int 10) in
      let () =
        check
          (Error
             V.(
               With_message
                 { given = "11"; message = "should be lesser or equal to 10" }))
          (v @@ D.int 11)
      in
      ())

let test_one_of =
  let open Alcotest in
  test_case "one_of - validate one_of" `Quick (fun () ->
      let check = check (Testable.validated_value string) "should be equal" in
      let v = V.(string & one_of' [ "foo"; "bar"; "baz" ]) in
      let () = check (Ok "foo") (v @@ D.string "foo") in
      let () = check (Ok "bar") (v @@ D.string "bar") in
      let () = check (Ok "baz") (v @@ D.string "baz") in
      let () =
        check
          (Error
             V.(
               With_message
                 {
                   given = "foobar"
                 ; message = "not included in [foo; bar; baz]"
                 }))
          (v @@ D.string "foobar")
      in
      ())

let test_where_or_const =
  let open Alcotest in
  test_case "multi-combinators tests" `Quick (fun () ->
      let check = check (Testable.validated_value string) "should be equal" in
      let v =
        let open V in
        (string & one_of' [ "foo"; "bar" ])
        / ((int & where ~pp:Format.pp_print_int (fun x -> x mod 2 = 0))
          $ string_of_int)
        / ((float
           & where ~pp:Format.pp_print_float (fun x -> Float.floor x >= 3.0))
          & const "a float")
      in
      let () = check (Ok "foo") (v @@ D.string "foo") in
      let () = check (Ok "bar") (v @@ D.string "bar") in
      let () = check (Ok "4") (v @@ D.int 4) in
      let () = check (Ok "a float") (v @@ D.float 3.65) in
      let () =
        check
          (Error
             V.(Invalid_shape { expected = "float"; given = D.string "baz" }))
          (v @@ D.string "baz")
      in
      let () =
        check
          (Error V.(Invalid_shape { expected = "float"; given = D.int 5 }))
          (v @@ D.int 5)
      in
      let () =
        check
          (Error
             V.(
               With_message { given = "1.6"; message = "unsatisfied predicate" }))
          (v @@ D.float 1.6)
      in
      ())

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
    ; test_option_1
    ; test_option_2
    ; test_option_3
    ; test_pair_1
    ; test_pair_2
    ; test_pair_3
    ; test_pair_4
    ; test_pair_5
    ; test_triple_1
    ; test_quad_1
    ; test_sum_1
    ; test_positive
    ; test_positive_f
    ; test_bounded
    ; test_bounded_f
    ; test_non_empty
    ; test_equal
    ; test_not_equal
    ; test_gt
    ; test_ge
    ; test_lt
    ; test_le
    ; test_one_of
    ; test_where_or_const
    ] )
