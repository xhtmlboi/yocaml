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

let test_to_string_rel =
  let open Alcotest in
  test_case "to_string for relative path should behaves correctly" `Quick
    (fun () ->
      let expected = "./foo/bar/baz"
      and computed = Yocaml.Path.(rel [ "foo"; "bar"; "baz" ] |> to_string) in
      check string "should be equal" expected computed)

let test_to_string_abs =
  let open Alcotest in
  test_case "to_string for absolute path should behaves correctly" `Quick
    (fun () ->
      let expected = "/foo/bar/baz"
      and computed = Yocaml.Path.(abs [ "foo"; "bar"; "baz" ] |> to_string) in
      check string "should be equal" expected computed)

let test_to_string_rel_slash =
  let open Alcotest in
  test_case "to_string for relative path using [/] should behaves correctly"
    `Quick (fun () ->
      let expected = "./foo/bar/baz/main.ml"
      and computed =
        Yocaml.Path.(rel [ "foo" ] / "bar" / "baz" / "main.ml" |> to_string)
      in
      check string "should be equal" expected computed)

let test_to_string_abs_plus =
  let open Alcotest in
  test_case "to_string for absolute path using [++] should behaves correctly"
    `Quick (fun () ->
      let expected = "./foo/bar/baz/main.ml"
      and computed =
        Yocaml.Path.(
          rel [ "foo" ] ++ [ "bar"; "baz" ] ++ [ "main.ml" ] |> to_string)
      in
      check string "should be equal" expected computed)

let test_to_string_root =
  let open Alcotest in
  test_case "to_string for root should returns an empty path" `Quick (fun () ->
      let expected = "/" and computed = Yocaml.Path.(root |> to_string) in
      check string "should be equal" expected computed)

let test_to_string_pwd =
  let open Alcotest in
  test_case "to_string for pwd should returns an empty path" `Quick (fun () ->
      let expected = "./" and computed = Yocaml.Path.(pwd |> to_string) in
      check string "should be equal" expected computed)

let test_extension_with_extension =
  let open Alcotest in
  test_case "extension when path has an extension" `Quick (fun () ->
      let expected = ".ml"
      and computed =
        Yocaml.Path.(rel [ "foo"; "bar"; "baz.ml" ] |> extension)
      in
      check string "should be equal" expected computed)

let test_extension_without_extension =
  let open Alcotest in
  test_case "extension when path has no extension" `Quick (fun () ->
      let expected = ""
      and computed = Yocaml.Path.(rel [ "foo"; "bar"; "baz" ] |> extension) in
      check string "should be equal" expected computed)

let test_extension_opt_with_extension =
  let open Alcotest in
  test_case "extension_opt when path has an extension" `Quick (fun () ->
      let expected = Some ".ml"
      and computed =
        Yocaml.Path.(rel [ "foo"; "bar"; "baz.ml" ] |> extension_opt)
      in
      check (option string) "should be equal" expected computed)

let test_extension_opt_without_extension =
  let open Alcotest in
  test_case "extension_opt when path has no extension" `Quick (fun () ->
      let expected = None
      and computed =
        Yocaml.Path.(rel [ "foo"; "bar"; "baz" ] |> extension_opt)
      in
      check (option string) "should be equal" expected computed)

let test_extension_and_opt_on_root_and_pwd =
  let open Alcotest in
  test_case "extension and extension_opt on root and pwd" `Quick (fun () ->
      let () =
        check string "should be equal" "" Yocaml.Path.(root |> extension)
      in
      let () =
        check string "should be equal" "" Yocaml.Path.(pwd |> extension)
      in
      let () =
        check (option string) "should be equal" None
          Yocaml.Path.(root |> extension_opt)
      in
      let () =
        check (option string) "should be equal" None
          Yocaml.Path.(pwd |> extension_opt)
      in
      ())

let test_remove_extension_on_path_with_extension =
  let open Alcotest in
  test_case
    "remove_extension with extension on last fragment should remove the \
     extension"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz" ]
      and computed = rel [ "foo"; "bar"; "baz.ml" ] |> remove_extension in
      check Testable.path "should be equal" expected computed)

let test_remove_extension_on_path_without_extension =
  let open Alcotest in
  test_case
    "remove_extension with no extension on last fragment it should keep the \
     path unchanged"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz" ] in
      let computed = expected |> remove_extension in
      check Testable.path "should be equal" expected computed)

let test_add_extension_without_dot =
  let open Alcotest in
  test_case
    "add_extension with a regular extension without dot should append the \
     extension on the last fragment"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz.ml" ]
      and computed = rel [ "foo"; "bar"; "baz" ] |> add_extension "ml" in
      check Testable.path "should be equal" expected computed)

let test_add_extension_with_dot =
  let open Alcotest in
  test_case
    "add_extension with a regular extension with dot should append the \
     extension on the last fragment"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz.ml" ]
      and computed = rel [ "foo"; "bar"; "baz" ] |> add_extension ".ml" in
      check Testable.path "should be equal" expected computed)

let test_add_extension_with_empty_extension =
  let open Alcotest in
  test_case
    "add_extension with an empty extension with dot should not append the \
     extension on the last fragment"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz" ]
      and computed = rel [ "foo"; "bar"; "baz" ] |> add_extension "" in
      check Testable.path "should be equal" expected computed)

let test_add_extension_with_dot_extension =
  let open Alcotest in
  test_case
    "add_extension with a dot extension with dot should not append the \
     extension on the last fragment"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz" ]
      and computed = rel [ "foo"; "bar"; "baz" ] |> add_extension "." in
      check Testable.path "should be equal" expected computed)

let test_add_extension_on_root_or_pwd =
  let open Alcotest in
  test_case "add_extension on root or pwd should do nothing" `Quick (fun () ->
      let open Yocaml.Path in
      let () =
        check Testable.path "should be equal" pwd (pwd |> add_extension ".ml")
      in
      let () =
        check Testable.path "should be equal" root (root |> add_extension ".ml")
      in
      ())

let test_change_extension_valid_case_no_dot =
  let open Alcotest in
  test_case
    "change_extension with valid path and extension (no-dot) should behaves \
     correctly"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz.ml" ]
      and computed =
        rel [ "foo"; "bar"; "baz.html" ] |> change_extension "ml"
      in
      check Testable.path "should be equal" expected computed)

let test_change_extension_valid_case_dot =
  let open Alcotest in
  test_case
    "change_extension with valid path and extension (dot) should behaves \
     correctly"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz.ml" ]
      and computed =
        rel [ "foo"; "bar"; "baz.html" ] |> change_extension ".ml"
      in
      check Testable.path "should be equal" expected computed)

let test_basename1 =
  let open Alcotest in
  test_case "basename test 1" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = Some "index.png"
      and computed = ~/[ "foo"; "bar"; "baz"; "index.png" ] |> basename in
      check (option string) "should be equal" expected computed)

let test_basename2 =
  let open Alcotest in
  test_case "basename test 2" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = None and computed = ~/[] |> basename in
      check (option string) "should be equal" expected computed)

let test_basename3 =
  let open Alcotest in
  test_case "basename test 1" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = Some "index.png"
      and computed = ~/[ "index.png" ] |> basename in
      check (option string) "should be equal" expected computed)

let test_dirname1 =
  let open Alcotest in
  test_case "dirname test 1" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = ~/[ "foo"; "bar"; "baz" ]
      and computed = ~/[ "foo"; "bar"; "baz"; "index.png" ] |> dirname in
      check Testable.path "should be equal" expected computed)

let test_dirname2 =
  let open Alcotest in
  test_case "dirname test 2" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = ~/[] and computed = ~/[ "foo" ] |> dirname in
      check Testable.path "should be equal" expected computed)

let test_dirname3 =
  let open Alcotest in
  test_case "dirname test 2" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = ~/[] and computed = ~/[] |> dirname in
      check Testable.path "should be equal" expected computed)

let test_move1 =
  let open Alcotest in
  test_case "move test 1" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = ~/[ "oof"; "rab"; "zab"; "index.png" ]
      and computed =
        ~/[ "foo"; "bar"; "baz"; "index.png" ]
        |> move ~into:~/[ "oof"; "rab"; "zab" ]
      in
      check Testable.path "should be equal" expected computed)

let test_move2 =
  let open Alcotest in
  test_case "move test 2" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = ~/[ "oof"; "rab"; "zab" ]
      and computed = ~/[] |> move ~into:~/[ "oof"; "rab"; "zab" ] in
      check Testable.path "should be equal" expected computed)

let test_relocate1 =
  let open Alcotest in
  test_case "relocate when both path are relative without common suffixes"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = ~/[ "foo"; "bar"; "baz"; "index.html" ]
      and computed =
        relocate ~into:~/[ "foo"; "bar" ] ~/[ "baz"; "index.html" ]
      in
      check Testable.path "should be equal" expected computed)

let test_relocate2 =
  let open Alcotest in
  test_case "relocate when both path are absolute without common suffixes"
    `Quick (fun () ->
      let open Yocaml.Path in
      let expected = abs [ "foo"; "bar"; "baz"; "index.html" ]
      and computed =
        relocate ~into:(abs [ "foo"; "bar" ]) (abs [ "baz"; "index.html" ])
      in
      check Testable.path "should be equal" expected computed)

let test_relocate3 =
  let open Alcotest in
  test_case "relocate when one path is absolute without common suffixes" `Quick
    (fun () ->
      let open Yocaml.Path in
      let expected = abs [ "foo"; "bar"; "baz"; "index.html" ]
      and computed =
        relocate ~into:(abs [ "foo"; "bar" ]) (rel [ "baz"; "index.html" ])
      in
      check Testable.path "should be equal" expected computed)

let test_relocate4 =
  let open Alcotest in
  test_case "relocate when one path is relative without common suffixes" `Quick
    (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz"; "index.html" ]
      and computed =
        relocate ~into:(rel [ "foo"; "bar" ]) (abs [ "baz"; "index.html" ])
      in
      check Testable.path "should be equal" expected computed)

let test_relocate5 =
  let open Alcotest in
  test_case "relocate when common suffixes 1" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "index.html" ]
      and computed =
        relocate
          ~into:(rel [ "foo"; "bar" ])
          (rel [ "foo"; "bar"; "index.html" ])
      in
      check Testable.path "should be equal" expected computed)

let test_relocate6 =
  let open Alcotest in
  test_case "relocate when common suffixes 2" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "foo"; "bar"; "baz"; "index.html" ]
      and computed =
        relocate
          ~into:(rel [ "foo"; "bar" ])
          (rel [ "foo"; "bar"; "baz"; "index.html" ])
      in
      check Testable.path "should be equal" expected computed)

let test_from_string1 =
  let open Alcotest in
  test_case "from_string 1" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = ~/[ "oof"; "rab"; "zab" ]
      and computed = from_string "./oof/rab/zab" in
      check Testable.path "should be equal" expected computed)

let test_from_string2 =
  let open Alcotest in
  test_case "from_string 2" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = abs [ "oof"; "rab"; "zab" ]
      and computed = from_string "/oof/rab/zab" in
      check Testable.path "should be equal" expected computed)

let test_from_string3 =
  let open Alcotest in
  test_case "from_string 2" `Quick (fun () ->
      let open Yocaml.Path in
      let expected = rel [ "oof"; "rab"; "zab" ]
      and computed = from_string "oof/rab/zab" in
      check Testable.path "should be equal" expected computed)

let to_csexp_from_csexp_roundtrip =
  QCheck2.Test.make ~name:"to_csexp -> from_csexp roundtrip" ~count:100
    ~print:(fun x -> Format.asprintf "%a" Yocaml.Path.pp x)
    Gen.path
    (fun p ->
      let open Yocaml.Path in
      let expected = Ok p and computed = p |> to_sexp |> from_sexp in
      Alcotest.equal Testable.(from_sexp path) expected computed)
  |> QCheck_alcotest.to_alcotest ~colors:true ~verbose:true

let to_string_from_string_roundtrip =
  QCheck2.Test.make ~name:"to_string -> from_string roundtrip" ~count:100
    ~print:(fun x -> Format.asprintf "%a" Yocaml.Path.pp x)
    Gen.path
    (fun p ->
      let open Yocaml.Path in
      let expected = p and computed = p |> to_string |> from_string in
      Alcotest.equal Testable.path expected computed)
  |> QCheck_alcotest.to_alcotest ~colors:true ~verbose:true

let cases =
  ( "Yocaml.Path"
  , [
      test_to_string_rel
    ; test_to_string_abs
    ; test_to_string_rel_slash
    ; test_to_string_abs_plus
    ; test_to_string_root
    ; test_to_string_pwd
    ; test_extension_with_extension
    ; test_extension_opt_with_extension
    ; test_extension_without_extension
    ; test_extension_opt_without_extension
    ; test_extension_and_opt_on_root_and_pwd
    ; test_remove_extension_on_path_with_extension
    ; test_remove_extension_on_path_without_extension
    ; test_add_extension_without_dot
    ; test_add_extension_with_dot
    ; test_add_extension_with_empty_extension
    ; test_add_extension_with_dot_extension
    ; test_add_extension_on_root_or_pwd
    ; test_change_extension_valid_case_no_dot
    ; test_change_extension_valid_case_dot
    ; test_basename1
    ; test_basename2
    ; test_basename3
    ; test_dirname1
    ; test_dirname2
    ; test_dirname3
    ; test_move1
    ; test_move2
    ; test_relocate1
    ; test_relocate2
    ; test_relocate3
    ; test_relocate4
    ; test_relocate5
    ; test_relocate6
    ; test_from_string1
    ; test_from_string2
    ; test_from_string3
    ; to_string_from_string_roundtrip
    ; to_csexp_from_csexp_roundtrip
    ] )
