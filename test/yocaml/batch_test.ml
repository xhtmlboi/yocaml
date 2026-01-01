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
module Batch = Yocaml.Batch
module Path = Yocaml.Path

let test_iter_tree_1 =
  let open Alcotest in
  test_case "iter_tree - without nesting" `Quick (fun () ->
      let base_fs =
        let open Fs in
        from_list
          [ dir "." [ dir "content" [ file "a.md" "a"; file "b.md" "b" ] ] ]
      in
      let trace = Fs.create_trace ~time:10 base_fs in
      let program () =
        let open Yocaml.Eff in
        return Yocaml.Cache.empty
        >>= Fs.increase_time_with 1
        >>= Batch.iter_tree (Path.rel [ "content" ]) (fun p ->
            let into =
              p
              |> Path.dirname
              |> Path.trim ~prefix:(Path.rel [ "content" ])
              |> Path.relocate ~into:(Path.rel [ "_www" ])
            in
            Yocaml.Action.copy_file ~into p)
      in
      let trace, _cache = Fs.run ~trace program () in
      let computed_file_system = Fs.trace_system trace in
      let expected_file_system =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "content" [ file "a.md" "a"; file "b.md" "b" ]
              ; dir "_www"
                  [ file ~mtime:11 "a.md" "a"; file ~mtime:11 "b.md" "b" ]
              ]
          ]
      in
      check Testable.fs "should be equal" expected_file_system
        computed_file_system)

let test_iter_tree_2 =
  let open Alcotest in
  test_case "iter_tree - with nesting" `Quick (fun () ->
      let base_fs =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "content"
                  [
                    file "a.md" "a"
                  ; file "b.md" "b"
                  ; dir "foo"
                      [
                        file "c.md" "c"
                      ; file "d.md" "d"
                      ; dir "bar" [ file "e.md" "e"; file "f.md" "f" ]
                      ; dir "foobar" [ file "g.txt" "g" ]
                      ]
                  ]
              ]
          ]
      in
      let trace = Fs.create_trace ~time:10 base_fs in
      let program () =
        let open Yocaml.Eff in
        return Yocaml.Cache.empty
        >>= Fs.increase_time_with 1
        >>= Batch.iter_tree (Path.rel [ "content" ]) (fun p ->
            let into =
              p
              |> Path.dirname
              |> Path.trim ~prefix:(Path.rel [ "content" ])
              |> Path.relocate ~into:(Path.rel [ "_www" ])
            in
            Yocaml.Action.copy_file ~into p)
      in
      let trace, _cache = Fs.run ~trace program () in
      let computed_file_system = Fs.trace_system trace in
      let expected_file_system =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "content"
                  [
                    file "a.md" "a"
                  ; file "b.md" "b"
                  ; dir "foo"
                      [
                        file "c.md" "c"
                      ; file "d.md" "d"
                      ; dir "bar" [ file "e.md" "e"; file "f.md" "f" ]
                      ; dir "foobar" [ file "g.txt" "g" ]
                      ]
                  ]
              ; dir "_www"
                  [
                    file ~mtime:11 "a.md" "a"
                  ; file ~mtime:11 "b.md" "b"
                  ; dir ~mtime:11 "foo"
                      [
                        file ~mtime:11 "c.md" "c"
                      ; file ~mtime:11 "d.md" "d"
                      ; dir "bar"
                          [
                            file ~mtime:11 "e.md" "e"; file ~mtime:11 "f.md" "f"
                          ]
                      ; dir "foobar" [ file ~mtime:11 "g.txt" "g" ]
                      ]
                  ]
              ]
          ]
      in
      check Testable.fs "should be equal" expected_file_system
        computed_file_system)

let test_fold_tree_1 =
  let open Alcotest in
  test_case "fold_tree - with nesting" `Quick (fun () ->
      let base_fs =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "content"
                  [
                    file "a.md" "a"
                  ; file "b.md" "b"
                  ; dir "foo"
                      [
                        file "c.md" "c"
                      ; file "d.md" "d"
                      ; dir "bar" [ file "e.md" "e"; file "f.md" "f" ]
                      ; dir "foobar" [ file "g.txt" "g" ]
                      ]
                  ]
              ]
          ]
      in
      let trace = Fs.create_trace ~time:10 base_fs in
      let program () =
        let open Yocaml.Eff in
        return Yocaml.Cache.empty
        >>= Fs.increase_time_with 1
        >>= Batch.fold_tree ~state:"" (Path.rel [ "content" ])
              (fun p state cache ->
                let+ ctn = read_file ~on:`Source p in
                (cache, state ^ ctn))
        >>= fun (c, s) ->
        Yocaml.Action.write_static_file (Path.rel [ "OUT" ])
          (Yocaml.Task.const s) c
      in
      let trace, _cache = Fs.run ~trace program () in
      let computed_file_system = Fs.trace_system trace in
      let expected_file_system =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "content"
                  [
                    file "a.md" "a"
                  ; file "b.md" "b"
                  ; dir "foo"
                      [
                        file "c.md" "c"
                      ; file "d.md" "d"
                      ; dir "bar" [ file "e.md" "e"; file "f.md" "f" ]
                      ; dir "foobar" [ file "g.txt" "g" ]
                      ]
                  ]
              ; file ~mtime:11 "OUT" "abcdefg"
              ]
          ]
      in
      check Testable.fs "should be equal" expected_file_system
        computed_file_system)

let test_fold_tree_2 =
  let open Alcotest in
  test_case "fold_tree - with filtering" `Quick (fun () ->
      let base_fs =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "content"
                  [
                    file "a.md" "a"
                  ; file "b.md" "b"
                  ; dir "foo"
                      [
                        file "c.md" "c"
                      ; file "d.md" "d"
                      ; dir "bar" [ file "e.md" "e"; file "f.md" "f" ]
                      ; dir "foobar" [ file "g.txt" "g" ]
                      ]
                  ]
              ]
          ]
      in
      let reject name p =
        match Path.basename p with
        | None -> true
        | Some x -> not (String.equal x name)
      in
      let trace = Fs.create_trace ~time:10 base_fs in
      let program () =
        let open Yocaml.Eff in
        return Yocaml.Cache.empty
        >>= Fs.increase_time_with 1
        >>= Batch.fold_tree
              ~where:(function
                | `Directory -> reject "foobar" | `File -> reject "d.md")
              ~state:"" (Path.rel [ "content" ])
              (fun p state cache ->
                let+ ctn = read_file ~on:`Source p in
                (cache, state ^ ctn))
        >>= fun (c, s) ->
        Yocaml.Action.write_static_file (Path.rel [ "OUT" ])
          (Yocaml.Task.const s) c
      in
      let trace, _cache = Fs.run ~trace program () in
      let computed_file_system = Fs.trace_system trace in
      let expected_file_system =
        let open Fs in
        from_list
          [
            dir "."
              [
                dir "content"
                  [
                    file "a.md" "a"
                  ; file "b.md" "b"
                  ; dir "foo"
                      [
                        file "c.md" "c"
                      ; file "d.md" "d"
                      ; dir "bar" [ file "e.md" "e"; file "f.md" "f" ]
                      ; dir "foobar" [ file "g.txt" "g" ]
                      ]
                  ]
              ; file ~mtime:11 "OUT" "abcef"
              ]
          ]
      in
      check Testable.fs "should be equal" expected_file_system
        computed_file_system)

let cases =
  ( "Yocaml.Batch"
  , [ test_iter_tree_1; test_iter_tree_2; test_fold_tree_1; test_fold_tree_2 ]
  )
