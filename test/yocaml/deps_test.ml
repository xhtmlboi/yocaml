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

let test_need_update_1 =
  let open Alcotest in
  test_case "need_update case 1" `Quick (fun () ->
      let mtrace =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "_build" []
              ; dir "content" [ file ~mtime:1 "foo.md" "Hello" ]
              ]
          ]
        |> create_trace
      in
      let open Path in
      let deps = Deps.from_list [ ~/[ "content"; "foo.md" ] ] in
      let program () = Deps.need_update deps ~/[ "_build"; "foo.html" ] in
      let mtrace, computed_action = Fs.run ~trace:mtrace program () in
      let computed_trace = Fs.execution_trace mtrace in
      let () =
        check Testable.required_action "should be equal" Deps.Create
          computed_action
      in
      let () =
        check (list string) "should be equal"
          [ "[FILE_EXISTS][Target]./_build/foo.html" ]
          computed_trace
      in
      ())

let test_need_update_2 =
  let open Alcotest in
  test_case "need_update case 2" `Quick (fun () ->
      let mtrace =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "_build" [ file ~mtime:2 "foo.html" "Hello" ]
              ; dir "content" [ file ~mtime:1 "foo.md" "Hello" ]
              ]
          ]
        |> create_trace
      in
      let open Path in
      let deps = Deps.from_list [ ~/[ "content"; "foo.md" ] ] in
      let program () = Deps.need_update deps ~/[ "_build"; "foo.html" ] in
      let mtrace, computed_action = Fs.run ~trace:mtrace program () in
      let computed_trace = Fs.execution_trace mtrace in
      let () =
        check Testable.required_action "should be equal" Deps.Nothing
          computed_action
      in
      let () =
        check (list string) "should be equal"
          [
            "[FILE_EXISTS][Target]./_build/foo.html"
          ; "[FILE_EXISTS][Target]./_build/foo.html"
          ; "[MTIME][Target]./_build/foo.html"
          ; "[FILE_EXISTS][Source]./content/foo.md"
          ; "[MTIME][Source]./content/foo.md"
          ]
          computed_trace
      in
      ())

let test_need_update_3 =
  let open Alcotest in
  test_case "need_update case 3" `Quick (fun () ->
      let mtrace =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "_build" [ file ~mtime:2 "foo.html" "Hello" ]
              ; dir "content" [ file ~mtime:3 "foo.md" "Hello" ]
              ]
          ]
        |> create_trace
      in
      let open Path in
      let deps = Deps.from_list [ ~/[ "content"; "foo.md" ] ] in
      let program () = Deps.need_update deps ~/[ "_build"; "foo.html" ] in
      let mtrace, computed_action = Fs.run ~trace:mtrace program () in
      let computed_trace = Fs.execution_trace mtrace in
      let () =
        check Testable.required_action "should be equal" Deps.Update
          computed_action
      in
      let () =
        check (list string) "should be equal"
          [
            "[FILE_EXISTS][Target]./_build/foo.html"
          ; "[FILE_EXISTS][Target]./_build/foo.html"
          ; "[MTIME][Target]./_build/foo.html"
          ; "[FILE_EXISTS][Source]./content/foo.md"
          ; "[MTIME][Source]./content/foo.md"
          ]
          computed_trace
      in
      ())

let cases =
  ("Yocaml.Deps", [ test_need_update_1; test_need_update_2; test_need_update_3 ])
