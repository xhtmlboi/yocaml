open Yocaml
open Util
open Common_test

let make1 =
  let open Alcotest in
  test_case "Date.make 1" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> make ~time:(12, 20, 32) 2021 Oct 3)
  and expected = valid "2021-10-03 12:20:32" in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let make2 =
  let open Alcotest in
  test_case "Date.make 2" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> make 2012 Feb 29)
  and expected = valid "2012-02-29" in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let from_string1 =
  let open Alcotest in
  test_case "Date.from_string 1" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> from_string "2012-02-29")
  and expected = valid "2012-02-29" in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let from_string2 =
  let open Alcotest in
  test_case "Date.from_string 2" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> from_string "2012-02-29 20:58:59")
  and expected = valid "2012-02-29 20:58:59" in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let make_invalid =
  let open Alcotest in
  test_case "Date.make invalid 1" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> make ~time:(34, -9, 62) 2021 Oct 3)
  and expected =
    let open Preface.Nonempty_list in
    Validate.invalid
      (Error.Invalid_range (34, 0, 24)
      :: Error.Invalid_range (-9, 0, 60)
      :: Last (Error.Invalid_range (62, 0, 60)))
  in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let cases = "Date", [ make1; make2; from_string1; from_string2; make_invalid ]
