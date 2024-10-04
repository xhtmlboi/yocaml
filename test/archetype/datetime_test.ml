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

let ( let+ ) x f = Result.map f x
let ( let* ) = Result.bind

let test_datetime_make_1 =
  let open Alcotest in
  test_case "make a valid datetime - 1" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok "2023-11-12 00:00:00"
      and computed =
        let+ a = Datetime.make ~year:2023 ~month:11 ~day:12 () in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_make_2 =
  let open Alcotest in
  test_case "make a valid datetime - 2" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok "2023-11-12 11:07:58"
      and computed =
        let+ a =
          Datetime.make ~time:(11, 7, 58) ~year:2023 ~month:11 ~day:12 ()
        in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_make_3 =
  let open Alcotest in
  test_case "make a valid datetime - 3" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Data.Validation.fail_with ~given:"29" "Invalid hour value"
      and computed =
        let+ a =
          Datetime.make ~time:(29, 7, 55) ~year:2023 ~month:11 ~day:12 ()
        in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_make_4 =
  let open Alcotest in
  test_case "make a valid datetime - 4" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Data.Validation.fail_with ~given:"-9" "Invalid year value"
      and computed =
        let+ a =
          Datetime.make ~time:(22, 7, 55) ~year:(-9) ~month:11 ~day:12 ()
        in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_make_5 =
  let open Alcotest in
  test_case "make a valid datetime - 5" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Data.Validation.fail_with ~given:"13" "Invalid month value"
      and computed =
        let+ a = Datetime.make ~time:(22, 7, 55) ~year:9 ~month:13 ~day:12 () in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_make_6 =
  let open Alcotest in
  test_case "make a valid datetime - 6" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Data.Validation.fail_with ~given:"34" "Invalid day value"
      and computed =
        let+ a = Datetime.make ~time:(22, 7, 55) ~year:9 ~month:12 ~day:34 () in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_make_7 =
  let open Alcotest in
  test_case "make a valid datetime - 7" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Data.Validation.fail_with ~given:"60" "Invalid min value"
      and computed =
        let+ a =
          Datetime.make ~time:(22, 60, 55) ~year:9 ~month:12 ~day:30 ()
        in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_make_8 =
  let open Alcotest in
  test_case "make a valid datetime - 8" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Data.Validation.fail_with ~given:"155" "Invalid sec value"
      and computed =
        let+ a =
          Datetime.make ~time:(22, 40, 155) ~year:9 ~month:12 ~day:30 ()
        in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_validate_1 =
  let open Alcotest in
  test_case "validate datetime - 1" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok "2023-11-12 00:00:00"
      and computed =
        let+ a = Datetime.validate @@ Data.string "2023-11-12 00:00:00" in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_validate_2 =
  let open Alcotest in
  test_case "validate datetime - 2" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok "2023-11-12 00:00:00"
      and computed =
        let+ a = Datetime.validate @@ Data.string "2023/11/12" in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_validate_3 =
  let open Alcotest in
  test_case "validate datetime - 3" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok "2023-11-12 22:18:45"
      and computed =
        let+ a = Datetime.validate @@ Data.string "2023/11/12 22:18:45" in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_validate_4 =
  let open Alcotest in
  test_case "validate datetime - 4" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok "2024-02-29 22:18:45"
      and computed =
        let+ a = Datetime.validate @@ Data.string "2024/02/29 22:18:45" in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_validate_5 =
  let open Alcotest in
  test_case "validate datetime - 5" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Data.Validation.fail_with ~given:"29" "Invalid day value"
      and computed =
        let+ a = Datetime.validate @@ Data.string "2023/02/29 22:18:45" in
        Format.asprintf "%a" Datetime.pp a
      in
      check
        Testable.(validated_value string)
        "should be equal" expected computed)

let test_datetime_validate_normalize_1 =
  let open Alcotest in
  test_case "validate and normalize datetime - 1" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected =
        Ok
          Data.(
            record
              [
                ("year", int 2023)
              ; ("month", int 2)
              ; ("day", int 28)
              ; ("hour", int 22)
              ; ("min", int 18)
              ; ("sec", int 45)
              ; ("has_time", bool true)
              ; ("day_of_week", int 1)
              ; ( "repr"
                , record
                    [
                      ("month", string "feb")
                    ; ("datetime", string "2023-02-28 22:18:45")
                    ; ("date", string "2023-02-28")
                    ; ("time", string "22:18:45")
                    ; ("day_of_week", string "tue")
                    ] )
              ])
      and computed =
        let+ a = Datetime.validate @@ Data.string "2023/02/28 22:18:45" in
        Datetime.normalize a
      in
      check Testable.(validated_value data) "should be equal" expected computed)

let test_datetime_validate_normalize_2 =
  let open Alcotest in
  test_case "validate and normalize datetime - 2" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected =
        Ok
          Data.(
            record
              [
                ("year", int 1813)
              ; ("month", int 8)
              ; ("day", int 15)
              ; ("hour", int 0)
              ; ("min", int 0)
              ; ("sec", int 0)
              ; ("has_time", bool false)
              ; ("day_of_week", int 6)
              ; ( "repr"
                , record
                    [
                      ("month", string "aug")
                    ; ("datetime", string "1813-08-15 00:00:00")
                    ; ("date", string "1813-08-15")
                    ; ("time", string "00:00:00")
                    ; ("day_of_week", string "sun")
                    ] )
              ])
      and computed =
        let+ a = Datetime.validate @@ Data.string "1813:08:15" in
        Datetime.normalize a
      in
      check Testable.(validated_value data) "should be equal" expected computed)

let test_datetime_comparison_1 =
  let open Alcotest in
  test_case "comparison between datetime - 1" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok true
      and computed =
        let* a = Datetime.validate @@ Data.string "2023/11/12" in
        let* b = Datetime.validate @@ Data.string "2022/11/12" in
        Result.ok Datetime.(a > b)
      in
      check Testable.(validated_value bool) "should be equal" expected computed)

let test_datetime_comparison_2 =
  let open Alcotest in
  test_case "comparison between datetime - 2" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok true
      and computed =
        let* a = Datetime.validate @@ Data.string "2023/11/12" in
        let* b = Datetime.validate @@ Data.string "2022/11/12" in
        Result.ok Datetime.(a >= b)
      in
      check Testable.(validated_value bool) "should be equal" expected computed)

let test_datetime_comparison_3 =
  let open Alcotest in
  test_case "comparison between datetime - 3" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok false
      and computed =
        let* a = Datetime.validate @@ Data.string "2023/11/12" in
        let* b = Datetime.validate @@ Data.string "2022/11/12" in
        Result.ok Datetime.(a < b)
      in
      check Testable.(validated_value bool) "should be equal" expected computed)

let test_datetime_comparison_4 =
  let open Alcotest in
  test_case "comparison between datetime - 4" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok false
      and computed =
        let* a = Datetime.validate @@ Data.string "2023/11/12" in
        let* b = Datetime.validate @@ Data.string "2022/11/12" in
        Result.ok Datetime.(a <= b)
      in
      check Testable.(validated_value bool) "should be equal" expected computed)

let test_datetime_comparison_5 =
  let open Alcotest in
  test_case "comparison between datetime - 5" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok false
      and computed =
        let* a = Datetime.validate @@ Data.string "2023/11/12" in
        let* b = Datetime.validate @@ Data.string "2022/11/12" in
        Result.ok Datetime.(a = b)
      in
      check Testable.(validated_value bool) "should be equal" expected computed)

let test_datetime_comparison_6 =
  let open Alcotest in
  test_case "comparison between datetime - 6" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok true
      and computed =
        let* a = Datetime.validate @@ Data.string "2023/11/12" in
        let* b = Datetime.validate @@ Data.string "2022/11/12" in
        Result.ok Datetime.(a <> b)
      in
      check Testable.(validated_value bool) "should be equal" expected computed)

let test_datetime_comparison_7 =
  let open Alcotest in
  test_case "comparison between datetime - 7" `Quick (fun () ->
      let open Yocaml in
      let open Archetype in
      let expected = Ok true
      and computed =
        let* a = Datetime.validate @@ Data.string "2023/11/12" in
        let* b = Datetime.validate @@ Data.string "2023/11/12" in
        Result.ok Datetime.(a = b)
      in
      check Testable.(validated_value bool) "should be equal" expected computed)

let test_datetime_pp_rfc822_1 =
  let open Alcotest in
  test_case "pretty-print a date according rfc822 specification 1" `Quick
    (fun () ->
      let open Yocaml.Archetype in
      let expected = Ok "Wed, 02 Oct 2002 00:00:00 GMT"
      and computed =
        Result.map
          (Format.asprintf "%a" (Datetime.pp_rfc822 ()))
          (Datetime.validate @@ Yocaml.Data.string "2002/10/02")
      in
      check
        (Testable.validated_value string)
        "should be equal" expected computed)

let test_datetime_pp_rfc3339_1 =
  let open Alcotest in
  test_case "pretty-print a date according rfc3339 specification 1" `Quick
    (fun () ->
      let open Yocaml.Archetype in
      let expected = Ok "2002-10-02T21:13:54Z"
      and computed =
        Result.map
          (Format.asprintf "%a" (Datetime.pp_rfc3339 ()))
          (Datetime.validate @@ Yocaml.Data.string "2002/10/02 21:13:54")
      in
      check
        (Testable.validated_value string)
        "should be equal" expected computed)

let cases =
  ( "Yocaml.Archetype.Date"
  , [
      test_datetime_make_1
    ; test_datetime_make_2
    ; test_datetime_make_3
    ; test_datetime_make_4
    ; test_datetime_make_5
    ; test_datetime_make_6
    ; test_datetime_make_7
    ; test_datetime_make_8
    ; test_datetime_validate_1
    ; test_datetime_validate_2
    ; test_datetime_validate_3
    ; test_datetime_validate_4
    ; test_datetime_validate_5
    ; test_datetime_validate_normalize_1
    ; test_datetime_validate_normalize_2
    ; test_datetime_comparison_1
    ; test_datetime_comparison_2
    ; test_datetime_comparison_3
    ; test_datetime_comparison_4
    ; test_datetime_comparison_5
    ; test_datetime_comparison_6
    ; test_datetime_comparison_7
    ; test_datetime_pp_rfc822_1
    ; test_datetime_pp_rfc3339_1
    ] )
