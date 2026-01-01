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

let test_cons_1 =
  let open Alcotest in
  test_case "cons - 1" `Quick (fun () ->
      let open Yocaml in
      let expected = Nel.[ 1; 2 ] and computed = Nel.(cons 1 [ 2 ]) in
      check (Testable.nel int) "should be equal" expected computed)

let test_singleton_1 =
  let open Alcotest in
  test_case "singleton - 1" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 1 ] and computed = Yocaml.Nel.singleton 1 in
      check (Testable.nel int) "should be equal" expected computed)

let test_init_1 =
  let open Alcotest in
  test_case "init - 1" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 0; 1; 2; 3; 4 ]
      and computed = Yocaml.Nel.init 5 Fun.id in
      check (Testable.nel int) "should be equal" expected computed)

let test_from_list =
  let open Alcotest in
  test_case "from_list - when a list is not empty, it should return a Nel one"
    `Quick (fun () ->
      let expected = Some Yocaml.Nel.[ 0; 1; 2; 3; 4 ]
      and computed = List.init 5 Fun.id |> Yocaml.Nel.from_list in
      check (option @@ Testable.nel int) "should be equal" expected computed)

let test_from_empty_list =
  let open Alcotest in
  test_case "from_list - when a list is empty, it should return None" `Quick
    (fun () ->
      let expected = None and computed = [] |> Yocaml.Nel.from_list in
      check (option @@ Testable.nel int) "should be equal" expected computed)

let test_from_seq =
  let open Alcotest in
  test_case "from_seq - when a seq is not empty, it should return a Nel one"
    `Quick (fun () ->
      let expected = Some Yocaml.Nel.[ 0; 1; 2; 3; 4 ]
      and computed = List.init 5 Fun.id |> List.to_seq |> Yocaml.Nel.from_seq in
      check (option @@ Testable.nel int) "should be equal" expected computed)

let test_from_empty_seq =
  let open Alcotest in
  test_case "from_list - when a seq is empty, it should return None" `Quick
    (fun () ->
      let expected = None and computed = Seq.empty |> Yocaml.Nel.from_seq in
      check (option @@ Testable.nel int) "should be equal" expected computed)

let test_to_list_1 =
  let open Alcotest in
  test_case "to_list - from a Nel to a list" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 1; 2; 3; 4 ] |> Yocaml.Nel.to_list
      and computed = [ 1; 2; 3; 4 ] in
      check (list int) "should be equal" expected computed)

let test_to_seq_1 =
  let open Alcotest in
  test_case "to_seq - from a Nel to a seq" `Quick (fun () ->
      let expected =
        Yocaml.Nel.[ 1; 2; 3; 4 ] |> Yocaml.Nel.to_seq |> List.of_seq
      and computed = [ 1; 2; 3; 4 ] in
      check (list int) "should be equal" expected computed)

let test_length_1 =
  let open Alcotest in
  test_case "lengt - simple test on length" `Quick (fun () ->
      let expected = [ 1; 2; 3; 10 ]
      and computed =
        Yocaml.[ Nel.[ 1 ]; Nel.[ 1; 2 ]; Nel.[ 1; 2; 3 ]; Nel.init 10 Fun.id ]
        |> List.map Yocaml.Nel.length
      in
      check (list int) "should be equal" expected computed)

let test_is_singleton_1 =
  let open Alcotest in
  test_case "is_singleton - simple test on is_singleton" `Quick (fun () ->
      let expected = [ true; false; true ]
      and computed =
        Yocaml.[ Nel.[ 1 ]; Nel.[ 1; 2 ]; Nel.singleton 2000 ]
        |> List.map Yocaml.Nel.is_singleton
      in
      check (list bool) "should be equal" expected computed)

let test_hd_1 =
  let open Alcotest in
  test_case "hd - fetch the head of a Nel" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 73; 1; 2 ] |> Yocaml.Nel.hd
      and computed = 73 in
      check int "should be equal" expected computed)

let test_tl_1 =
  let open Alcotest in
  test_case "tl - fetch the tail of a Nel" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 73; 1; 2; 111 ] |> Yocaml.Nel.tl
      and computed = [ 1; 2; 111 ] in
      check (list int) "should be equal" expected computed)

let test_rev_1 =
  let open Alcotest in
  test_case "rev - simple test on rev" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 4; 3; 2; 1; 0 ]
      and computed = Yocaml.Nel.(init 5 Fun.id) |> Yocaml.Nel.rev in
      check (Testable.nel int) "should be equal" expected computed)

let test_rev_append_1 =
  let open Alcotest in
  test_case "rev_append - simple test on rev_append" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 4; 3; 2; 1; 0; 1; 2; 3; 4 ]
      and computed =
        Yocaml.Nel.([ 1; 2; 3; 4 ] |> rev_append (init 5 Fun.id))
      in
      check (Testable.nel int) "should be equal" expected computed)

let test_concat_1 =
  let open Alcotest in
  test_case "concat - simple test on concat" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 1; 2; 3; 4; 5 ]
      and computed =
        Yocaml.Nel.[ [ 1 ]; [ 2; 3 ]; [ 4; 5 ] ] |> Yocaml.Nel.concat
      in
      check (Testable.nel int) "should be equal" expected computed)

let test_iter_1 =
  let open Alcotest in
  test_case "iter - simple test on iter" `Quick (fun () ->
      let buffer = Buffer.create 8 in
      let expected = "f1f2f3f4"
      and computed =
        let () =
          Yocaml.Nel.[ 1; 2; 3; 4 ]
          |> Yocaml.Nel.iter (fun i ->
              Buffer.add_string buffer @@ "f" ^ string_of_int i)
        in
        Buffer.contents buffer
      in
      check string "should be equal" expected computed)

let test_iteri_1 =
  let open Alcotest in
  test_case "iteri - simple test on iteri" `Quick (fun () ->
      let buffer = Buffer.create 12 in
      let expected = "f01f12f23f34"
      and computed =
        let () =
          Yocaml.Nel.[ 1; 2; 3; 4 ]
          |> Yocaml.Nel.iteri (fun i x ->
              Buffer.add_string buffer
              @@ "f"
              ^ string_of_int i
              ^ string_of_int x)
        in
        Buffer.contents buffer
      in
      check string "should be equal" expected computed)

let test_map_1 =
  let open Alcotest in
  test_case "map - simple test on map" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 1; 2; 3 ]
      and computed = Yocaml.Nel.init 3 Fun.id |> Yocaml.Nel.map succ in
      check (Testable.nel int) "should be equal" expected computed)

let test_mapi_1 =
  let open Alcotest in
  test_case "mapi - simple test on mapi" `Quick (fun () ->
      let expected = Yocaml.Nel.[ (0, 1); (1, 2); (2, 3) ]
      and computed =
        Yocaml.Nel.init 3 succ |> Yocaml.Nel.mapi (fun i x -> (i, x))
      in
      check (Testable.nel @@ pair int int) "should be equal" expected computed)

let test_rev_map_1 =
  let open Alcotest in
  test_case "rev_map - simple test on rev_map" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 3; 2; 1 ]
      and computed = Yocaml.Nel.init 3 Fun.id |> Yocaml.Nel.rev_map succ in
      check (Testable.nel int) "should be equal" expected computed)

let test_rev_mapi_1 =
  let open Alcotest in
  test_case "rev_mapi - simple test on rev_mapi" `Quick (fun () ->
      let expected = Yocaml.Nel.[ (2, 3); (1, 2); (0, 1) ]
      and computed =
        Yocaml.Nel.init 3 succ |> Yocaml.Nel.rev_mapi (fun i x -> (i, x))
      in
      check (Testable.nel @@ pair int int) "should be equal" expected computed)

let test_concat_map_1 =
  let open Alcotest in
  test_case "concat_map - simple test on concat_map" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 1; 2; 2; 3 ]
      and computed =
        let open Yocaml in
        Nel.init 3 Fun.id
        |> Nel.concat_map (fun x ->
            if x = 1 then Nel.[ 2; 2 ] else Nel.singleton (succ x))
      in
      check (Testable.nel int) "should be equal" expected computed)

let test_concat_mapi_1 =
  let open Alcotest in
  test_case "concat_mapi - simple test on concat_mapi" `Quick (fun () ->
      let open Yocaml in
      let expected = Nel.[ (1, 0); (2, -2); (2, -3); (3, 2) ]
      and computed =
        Nel.init 3 Fun.id
        |> Nel.concat_mapi (fun i x ->
            if x = 1 then Nel.[ (2, -2); (2, -3) ] else Nel.singleton (succ x, i))
      in
      check (Testable.nel @@ pair int int) "should be equal" expected computed)

let test_fold_left_1 =
  let open Alcotest in
  test_case "fold_left - simple test on fold_left" `Quick (fun () ->
      let expected = [ 3; 2; 1; 0 ]
      and computed =
        Yocaml.Nel.init 4 Fun.id
        |> Yocaml.Nel.fold_left (fun xs x -> x :: xs) []
      in
      check (list int) "should be equal" expected computed)

let test_fold_right_1 =
  let open Alcotest in
  test_case "fold_right - simple test on fold_right" `Quick (fun () ->
      let expected = [ 0; 1; 2; 3 ]
      and computed =
        Yocaml.Nel.fold_right
          (fun x xs -> x :: xs)
          (Yocaml.Nel.init 4 Fun.id) []
      in
      check (list int) "should be equal" expected computed)

let test_fold_lefti_1 =
  let open Alcotest in
  test_case "fold_lefti - simple test on fold_lefti" `Quick (fun () ->
      let expected = [ (6, 3); (4, 2); (2, 1); (0, 0) ]
      and computed =
        Yocaml.Nel.init 4 Fun.id
        |> Yocaml.Nel.fold_lefti (fun i xs x -> (x * 2, i) :: xs) []
      in
      check (list @@ pair int int) "should be equal" expected computed)

let test_fold_righti_1 =
  let open Alcotest in
  test_case "fold_righti - simple test on fold_righti" `Quick (fun () ->
      let expected = [ (0, 0); (1, 2); (2, 4); (3, 6) ]
      and computed =
        Yocaml.Nel.fold_righti
          (fun i x xs -> (i, x * 2) :: xs)
          (Yocaml.Nel.init 4 Fun.id) []
      in
      check (list @@ pair int int) "should be equal" expected computed)

let test_equal_1 =
  let open Alcotest in
  test_case "equal - two equal nels" `Quick (fun () ->
      let a = Yocaml.Nel.[ 1; 2; 3 ] and b = Yocaml.Nel.[ 1; 2; 3 ] in
      check bool "should be equal" true (Yocaml.Nel.equal Int.equal a b))

let test_equal_2 =
  let open Alcotest in
  test_case "equal - two different nels" `Quick (fun () ->
      let a = Yocaml.Nel.[ 1; 2; 3 ] and b = Yocaml.Nel.[ 1; 2; 4 ] in
      check bool "should not be equal" false (Yocaml.Nel.equal Int.equal a b))

let test_append_1 =
  let open Alcotest in
  test_case "append - simple test on append" `Quick (fun () ->
      let expected = Yocaml.Nel.[ 1; 2; 3; 4; 5 ]
      and computed =
        Yocaml.Nel.append Yocaml.Nel.[ 1; 2 ] Yocaml.Nel.[ 3; 4; 5 ]
      in
      check (Testable.nel int) "should be equal" expected computed)

let cases =
  ( "Yocaml.Nel"
  , [
      test_cons_1
    ; test_singleton_1
    ; test_init_1
    ; test_from_list
    ; test_from_empty_list
    ; test_from_seq
    ; test_from_empty_seq
    ; test_to_list_1
    ; test_to_seq_1
    ; test_length_1
    ; test_is_singleton_1
    ; test_hd_1
    ; test_tl_1
    ; test_rev_1
    ; test_rev_append_1
    ; test_concat_1
    ; test_iter_1
    ; test_iteri_1
    ; test_map_1
    ; test_mapi_1
    ; test_rev_map_1
    ; test_rev_mapi_1
    ; test_concat_map_1
    ; test_concat_mapi_1
    ; test_fold_left_1
    ; test_fold_right_1
    ; test_fold_lefti_1
    ; test_fold_righti_1
    ; test_equal_1
    ; test_equal_2
    ; test_append_1
    ] )
