open Yocaml

let opt_validate_testable upp ueq =
  let open Validate in
  Alcotest.testable
    (pp $ Preface.Option.pp upp)
    (equal $ Preface.Option.equal ueq)
;;

let validate_testable upp ueq =
  let open Validate in
  Alcotest.testable (pp upp) (equal ueq)
;;

let pstring = Format.pp_print_string
let estring = String.equal
