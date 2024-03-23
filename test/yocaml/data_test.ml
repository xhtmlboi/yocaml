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

let one_of' =
  Data.Validation.one_of ~pp:Format.pp_print_string ~equal:String.equal

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
        let open Data.Validation in
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
        let open Data.Validation in
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
        Data.Validation.(
          Invalid_shape { expected = "record"; given = Data.int 0 })
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
        let open Data in
        record [ ("baz", string "olleh") ]
      in
      let validate =
        let open Data.Validation in
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
        Data.Validation.(
          Invalid_record
            {
              errors =
                Yocaml.Nel.from_list
                @@ [
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
                                 Format.asprintf
                                   "not included in [hello; world]"
                             }
                       }
                   ; Missing_field { field = "bar" }
                   ]
                |> Option.get
            ; given = [ ("baz", Data.string "olleh") ]
            })
        |> Result.error
      and computed = validate source in

      check testable "should be invalid" expected computed)

let cases =
  ("Yocaml.Data.Validation", [ test_sample_1; test_sample_2; test_sample_3 ])
