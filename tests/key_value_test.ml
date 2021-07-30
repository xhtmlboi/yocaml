open Yocaml
open Common_test
module J = Key_value.Jsonm_validator

let with_length min max s =
  let l = String.length s in
  if l > max
  then Error.(to_validate $ Unknown "max")
  else if l < min
  then Error.(to_validate $ Unknown "min")
  else Validate.valid s
;;

let jsonm_string_valid_test =
  let open Alcotest in
  test_case
    "string | when a string is valid it should wrap it into a success"
    `Quick
  $ fun () ->
  let meta = `String "Foo" in
  let expected = Validate.valid "Foo"
  and computed = J.string meta in
  check
    (validate_testable pstring estring)
    "should be equal"
    expected
    computed
;;

let jsonm_string_and_valid_test =
  let open Alcotest in
  test_case
    "string_and | when a string is valid it should wrap it into a success"
    `Quick
  $ fun () ->
  let meta = `String "Foo" in
  let expected = Validate.valid "Foo"
  and computed = J.string_and (with_length 1 4) meta in
  check
    (validate_testable pstring estring)
    "should be equal"
    expected
    computed
;;

let jsonm_string_invalid_test =
  let open Alcotest in
  test_case
    "string | when a string is valid it should wrap it into a success"
    `Quick
  $ fun () ->
  let meta = `Float 4.0 in
  let expected = Error.(to_validate $ Invalid_field "String expected")
  and computed = J.string meta in
  check
    (validate_testable pstring estring)
    "should be equal"
    expected
    computed
;;

type user =
  { firstname : string
  ; lastname : string
  ; age : int
  ; activated : bool
  ; email : string option
  }

let pp_user ppf x =
  Format.fprintf
    ppf
    "%s, %s, %d, %s, %a"
    x.firstname
    x.lastname
    x.age
    (if x.activated then "a" else "u")
    (Preface.Option.pp pstring)
    x.email
;;

let eq_user a b =
  String.equal a.firstname b.firstname
  && String.equal a.lastname b.lastname
  && Option.equal String.equal a.email b.email
  && Int.equal a.age b.age
  && Bool.equal a.activated b.activated
;;

let user_testable = validate_testable pp_user eq_user

let make_user firstname lastname age activated email =
  { firstname; lastname; age; activated; email }
;;

let validate obj =
  let open Validate.Applicative in
  make_user
  <$> J.(required_field string "firstname" obj)
  <*> J.(required_field string "lastname" obj)
  <*> J.(required_field integer "age" obj)
  <*> J.(optional_field_or ~default:false boolean "activated" obj)
  <*> J.(optional_field string "email" obj)
;;

let validate_with_assoc =
  J.object_and (fun assoc ->
      let open Validate.Applicative in
      let open J in
      make_user
      <$> required_assoc string "firstname" assoc
      <*> required_assoc string "lastname" assoc
      <*> required_assoc integer "age" assoc
      <*> optional_assoc_or ~default:false boolean "activated" assoc
      <*> optional_assoc string "email" assoc)
;;

let jsonm_validate_user_valid_with_only_requirement =
  let open Alcotest in
  test_case "validate partial user using field description" `Quick
  $ fun () ->
  let meta =
    `O
      [ "firstname", `String "Pierre"
      ; "lastname", `String "Grim"
      ; "age", `Float 25.0
      ]
  in
  let expected = Validate.valid $ make_user "Pierre" "Grim" 25 false None
  and computed = validate meta in
  check user_testable "should be equal" expected computed
;;

let jsonm_validate_user_invalid =
  let open Alcotest in
  test_case "validate partial invalid user using field description" `Quick
  $ fun () ->
  let meta =
    `O
      [ "name", `String "Pierre"
      ; "lastname", `String "Grim"
      ; "age", `String "25.0"
      ]
  in
  let expected =
    let open Preface.Nonempty_list in
    Validate.invalid
      (Error.Missing_field "firstname"
      :: Last (Error.Invalid_field "field[age]: Integer expected"))
  and computed = validate meta in
  check user_testable "should be equal" expected computed
;;

let jsonm_validate_user_valid =
  let open Alcotest in
  test_case "validate filled user using field description" `Quick
  $ fun () ->
  let meta =
    `O
      [ "firstname", `String "Pierre"
      ; "lastname", `String "Grim"
      ; "age", `Float 25.0
      ; "activated", `Bool true
      ; "email", `String "grimfw@gmail.com"
      ]
  in
  let expected =
    Validate.valid
    $ make_user "Pierre" "Grim" 25 true (Some "grimfw@gmail.com")
  and computed = validate meta in
  check user_testable "should be equal" expected computed
;;

let jsonm_validate_user_valid_with_only_requirement_assoc =
  let open Alcotest in
  test_case "validate partial user using assoc description" `Quick
  $ fun () ->
  let meta =
    `O
      [ "firstname", `String "Pierre"
      ; "lastname", `String "Grim"
      ; "age", `Float 25.0
      ]
  in
  let expected = Validate.valid $ make_user "Pierre" "Grim" 25 false None
  and computed = validate_with_assoc meta in
  check user_testable "should be equal" expected computed
;;

let jsonm_validate_user_valid_assoc =
  let open Alcotest in
  test_case "validate filled user using assoc description" `Quick
  $ fun () ->
  let meta =
    `O
      [ "firstname", `String "Pierre"
      ; "lastname", `String "Grim"
      ; "age", `Float 25.0
      ; "activated", `Bool true
      ; "email", `String "grimfw@gmail.com"
      ]
  in
  let expected =
    Validate.valid
    $ make_user "Pierre" "Grim" 25 true (Some "grimfw@gmail.com")
  and computed = validate_with_assoc meta in
  check user_testable "should be equal" expected computed
;;

let jsonm_validate_user_invalid_assoc =
  let open Alcotest in
  test_case "validate partial invalid user using field description" `Quick
  $ fun () ->
  let meta =
    `O
      [ "name", `String "Pierre"
      ; "lastname", `String "Grim"
      ; "age", `String "25.0"
      ]
  in
  let expected =
    let open Preface.Nonempty_list in
    Validate.invalid
      (Error.Missing_field "firstname"
      :: Last (Error.Invalid_field "assoc[age]: Integer expected"))
  and computed = validate_with_assoc meta in
  check user_testable "should be equal" expected computed
;;

let cases =
  ( "Key_value"
  , [ jsonm_string_valid_test
    ; jsonm_string_and_valid_test
    ; jsonm_string_invalid_test
    ; jsonm_validate_user_valid_with_only_requirement
    ; jsonm_validate_user_valid
    ; jsonm_validate_user_invalid
    ; jsonm_validate_user_valid_with_only_requirement_assoc
    ; jsonm_validate_user_valid_assoc
    ; jsonm_validate_user_invalid_assoc
    ] )
;;
