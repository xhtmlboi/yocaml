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

let test_command_exec_1 =
  let open Alcotest in
  test_case "some command execution" `Quick (fun () ->
      let open Yocaml in
      let base_fs =
        Fs.(from_list [ dir ~mtime:0 "." [ dir ~mtime:0 "_build" [] ] ])
      in
      let program cache =
        let open Eff.Infix in
        Eff.return cache
        >>= Fs.increase_time_with 1
        >>= Action.write_static_file
              (Path.rel [ "_build"; "test.txt" ])
              (Task.from_effect (fun () ->
                   Eff.exec "echo" ~args:[ "yocaml"; "ocaml" ]))
      in
      let trace = Fs.create_trace ~time:0 base_fs in
      let trace, cache = Fs.run ~trace program Cache.empty in
      let computed_fs = Fs.trace_system trace in
      let expected_fs =
        Fs.(
          from_list
            [
              dir ~mtime:1 "."
                [
                  dir ~mtime:1 "_build"
                    [ file ~mtime:1 "test.txt" "yocaml ocaml" ]
                ]
            ])
      in
      let () =
        check Testable.fs "test.txt should be created" expected_fs computed_fs
      in
      let trace, _cache = Fs.run ~trace program cache in
      let computed_fs = Fs.trace_system trace in
      let () = check int "time should be 2" 2 (Fs.trace_time trace) in
      let () =
        check Testable.fs "test.txt should be not changed" expected_fs
          computed_fs
      in
      ())

let test_action_command_exec_1 =
  let open Alcotest in
  test_case "Some command execution through the Action module" `Quick (fun () ->
      let open Yocaml in
      let base_fs =
        Fs.(
          from_list
            [
              dir ~mtime:0 "."
                [ dir ~mtime:0 "_build" []; file ~mtime:0 "test.txt" "foo bar" ]
            ])
      in
      let program cache =
        let open Eff.Infix in
        let target = Path.(rel [ "_build"; "test.txt" ]) in
        Eff.return cache
        >>= Fs.increase_time_with 1
        >>= Action.exec_cmd
              Cmd.(
                fun target ->
                  make "a-cmd"
                    [
                      flag ~prefix:"--" "input"
                    ; arg @@ w (Path.rel [ "test.txt" ])
                    ; flag ~prefix:"--" "output"
                    ; arg @@ target
                    ])
              target
      in
      let trace = Fs.create_trace ~time:0 base_fs in
      let trace, cache = Fs.run ~trace program Cache.empty in
      let computed_fs = Fs.trace_system trace in
      let expected_fs =
        Fs.(
          from_list
            [
              dir ~mtime:1 "."
                [
                  dir ~mtime:1 "_build" [ file ~mtime:1 "test.txt" "FOO BAR" ]
                ; file ~mtime:0 "test.txt" "foo bar"
                ]
            ])
      in
      let () = check int "time should be 1" 1 (Fs.trace_time trace) in
      let () =
        check Testable.fs "test.txt should be created" expected_fs computed_fs
      in
      let trace, _cache = Fs.run ~trace program cache in
      let computed_fs = Fs.trace_system trace in
      let () = check int "time should be 2" 2 (Fs.trace_time trace) in
      let () =
        check Testable.fs "test.txt should be not changed" expected_fs
          computed_fs
      in
      ())

let cases =
  ("Yocaml.Exec_command", [ test_command_exec_1; test_action_command_exec_1 ])
