(* YOCaml a static blog generator.
   Copyright (C) 2025 The Funkyworkers and The YOCaml's developers

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

let test_trace_empty_dir =
  let open Alcotest in
  test_case "Compute trace from an empty target" `Quick (fun () ->
      let fs =
        let open Fs in
        from_list [ dir "." [] ]
      in
      let program () =
        Yocaml.Trace.from_directory ~on:`Source Yocaml.Path.cwd
      in
      let expected = Yocaml.Trace.empty in
      let _, computed = Fs.run ~trace:(Fs.create_trace fs) program () in
      check Testable.trace "should be equal" expected computed)

let test_trace_empty_dir_with_subdir =
  let open Alcotest in
  test_case "Compute trace from an empty target (with only dir)" `Quick
    (fun () ->
      let fs =
        let open Fs in
        from_list [ dir "." [ dir "foo" []; dir "bar" [ dir "foobar" [] ] ] ]
      in
      let program () =
        Yocaml.Trace.from_directory ~on:`Source Yocaml.Path.cwd
      in
      let expected = Yocaml.Trace.empty in
      let _, computed = Fs.run ~trace:(Fs.create_trace fs) program () in
      check Testable.trace "should be equal" expected computed)

let test_trace_1 =
  let open Alcotest in
  test_case "Compute trace from a target 1" `Quick (fun () ->
      let fs =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "foo" []; dir "bar" [ dir "foobar" [ file "test.txt" "" ] ]
              ]
          ]
      in
      let program () =
        Yocaml.Trace.from_directory ~on:`Source Yocaml.Path.cwd
      in
      let expected =
        Yocaml.Trace.from_list
          Yocaml.Path.[ rel [ "bar"; "foobar"; "test.txt" ] ]
      in
      let _, computed = Fs.run ~trace:(Fs.create_trace fs) program () in
      check Testable.trace "should be equal" expected computed)

let test_trace_2 =
  let open Alcotest in
  test_case "Compute trace from a target 2" `Quick (fun () ->
      let fs =
        let open Fs in
        from_list
          [
            dir "."
              [
                file ".config" ""
              ; dir "foo" [ file "test-3.txt" "" ]
              ; dir "bar"
                  [
                    file "hello.md" ""
                  ; dir "foobar" [ file "test.txt" ""; file "test-2.txt" "" ]
                  ]
              ]
          ]
      in
      let program () =
        Yocaml.Trace.from_directory ~on:`Source Yocaml.Path.cwd
      in
      let expected =
        Yocaml.Trace.from_list
          Yocaml.Path.
            [
              rel [ "bar"; "foobar"; "test.txt" ]
            ; rel [ "bar"; "foobar"; "test-2.txt" ]
            ; rel [ "bar"; "hello.md" ]
            ; rel [ "foo"; "test-3.txt" ]
            ; rel [ ".config" ]
            ]
      in
      let _, computed = Fs.run ~trace:(Fs.create_trace fs) program () in
      check Testable.trace "should be equal" expected computed)

let cases =
  ( "Yocaml.Trace"
  , [
      test_trace_empty_dir
    ; test_trace_empty_dir_with_subdir
    ; test_trace_1
    ; test_trace_2
    ] )
