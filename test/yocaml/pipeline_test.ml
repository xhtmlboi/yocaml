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

let test_dependencies_empty =
  let open Alcotest in
  test_case
    "when there is no dependencies, dependencies_of should returns an empty set"
    `Quick (fun () ->
      let open Task in
      let expected = Deps.empty
      and computed = dependencies_of @@ lift (fun x -> x) in
      check Testable.deps "should be equal" expected computed)

let test_dependencies_with_one_file =
  let open Alcotest in
  test_case "when there is dependencies it should returns an non-empty set"
    `Quick (fun () ->
      let open Path.Infix in
      let open Task in
      let expected = Deps.singleton ~/[ "foo"; "index.html" ]
      and computed =
        dependencies_of @@ Pipeline.track_file ~/[ "foo"; "index.html" ]
      in
      check Testable.deps "should be equal" expected computed)

let test_dependencies_with_multiple_files =
  let open Alcotest in
  test_case "when there is dependencies it should returns an non-empty set"
    `Quick (fun () ->
      let open Path.Infix in
      let open Task in
      let expected =
        Deps.from_list
          [
            ~/[ "foo"; "index.html" ]
          ; ~/[ "foo"; "index.php" ]
          ; ~/[ "index.html" ]
          ; ~/[ "test.txt" ]
          ; ~/[ "foo"; "module.ml" ]
          ; ~/[ "foo"; "index.svg" ]
          ]
      and computed =
        let task =
          let+ () = Pipeline.track_file ~/[ "foo"; "index.html" ]
          and+ () =
            Pipeline.track_files
              [
                ~/[ "foo"; "index.php" ]
              ; ~/[ "index.html" ]
              ; ~/[ "foo"; "module.ml" ]
              ; ~/[ "foo"; "index.svg" ]
              ]
          and+ _ = Pipeline.read_file ~/[ "test.txt" ] in
          ()
        in
        dependencies_of task
      in
      check Testable.deps "should be equal" expected computed)

let test_dependencies_with_multiple_files_and_duplicate_file =
  let open Alcotest in
  test_case
    "when there is dependencies it should returns an non-empty set with only \
     unique file identifier"
    `Quick (fun () ->
      let open Path.Infix in
      let open Task in
      let expected =
        Deps.from_list
          [
            ~/[ "foo"; "index.html" ]
          ; ~/[ "foo"; "index.php" ]
          ; ~/[ "index.html" ]
          ; ~/[ "test.txt" ]
          ; ~/[ "foo"; "module.ml" ]
          ; ~/[ "foo"; "index.svg" ]
          ]
      and computed =
        let task =
          let+ () = Pipeline.track_file ~/[ "foo"; "index.html" ]
          and+ () = Pipeline.track_file ~/[ "foo"; "index.svg" ]
          and+ () =
            Pipeline.track_files
              [
                ~/[ "foo"; "index.php" ]
              ; ~/[ "index.html" ]
              ; ~/[ "foo"; "module.ml" ]
              ; ~/[ "foo"; "index.svg" ]
              ]
          and+ _ = Pipeline.read_file ~/[ "test.txt" ]
          and+ _ = Pipeline.read_file ~/[ "index.html" ] in
          ()
        in
        dependencies_of task
      in
      check Testable.deps "should be equal" expected computed)

module Dummy_tpl : Yocaml.Required.DATA_TEMPLATE = struct
  type t = Yocaml.Sexp.t

  let from = Yocaml.Data.to_sexp
  let render ?strict:_ _ x = x
end

let test_dependencies_with_applicative_templates =
  let open Alcotest in
  test_case
    "when there is dependencies it should returns an non-empty set with only \
     unique file identifier"
    `Quick (fun () ->
      let open Path.Infix in
      let open Task in
      let expected =
        Deps.from_list
          [
            ~/[ "foo"; "index.html" ]
          ; ~/[ "foo"; "index.php" ]
          ; ~/[ "index.html" ]
          ; ~/[ "test.txt" ]
          ; ~/[ "foo"; "module.ml" ]
          ; ~/[ "foo"; "index.svg" ]
          ; ~/[ "a_tpl.ml.tpl" ]
          ; ~/[ "b_tpl.ml.tpl" ]
          ; ~/[ "c_tpl.ml.tpl" ]
          ; ~/[ "d_tpl.ml.tpl" ]
          ]
      and computed =
        let task =
          let+ () = Pipeline.track_file ~/[ "foo"; "index.html" ]
          and+ () = Pipeline.track_file ~/[ "foo"; "index.svg" ]
          and+ () =
            Pipeline.track_files
              [
                ~/[ "foo"; "index.php" ]
              ; ~/[ "index.html" ]
              ; ~/[ "foo"; "module.ml" ]
              ; ~/[ "foo"; "index.svg" ]
              ]
          and+ _ =
            Pipeline.read_template (module Dummy_tpl) ~/[ "a_tpl.ml.tpl" ]
          and+ _ =
            Pipeline.read_templates
              (module Dummy_tpl)
              [
                ~/[ "a_tpl.ml.tpl" ]
              ; ~/[ "b_tpl.ml.tpl" ]
              ; ~/[ "c_tpl.ml.tpl" ]
              ; ~/[ "d_tpl.ml.tpl" ]
              ]
          and+ _ = Pipeline.read_file ~/[ "test.txt" ]
          and+ _ = Pipeline.read_file ~/[ "index.html" ] in
          ()
        in
        dependencies_of task
      in
      check Testable.deps "should be equal" expected computed)

let cases =
  ( "Yocaml.Pipeline"
  , [
      test_dependencies_empty
    ; test_dependencies_with_one_file
    ; test_dependencies_with_multiple_files
    ; test_dependencies_with_multiple_files_and_duplicate_file
    ; test_dependencies_with_applicative_templates
    ] )
