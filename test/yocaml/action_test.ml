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

let test_action_create_file_1 =
  let open Alcotest in
  test_case "test of a complete action exection - everything is fresh" `Quick
    (fun () ->
      let open Yocaml.Path.Infix in
      let base_file_system =
        Fs.(
          from_list
            [
              dir ~mtime:0 "."
                [
                  file ~mtime:0 "index.md" "an index"
                ; file ~mtime:0 "about.md" "about page"
                ; dir ~mtime:0 "articles"
                    [
                      file ~mtime:0 "hello.md" "hello world"
                    ; file ~mtime:0 "yocaml.md" "article about YOCaml"
                    ]
                ; dir ~mtime:0 "static"
                    [
                      dir ~mtime:0 "images"
                        [
                          file ~mtime:0 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:0 "yocaml.svg" "yocaml-logo"
                        ]
                    ; file ~mtime:0 "client.bc.js" "js client"
                    ; file ~mtime:0 "style.css" "stylesheet"
                    ]
                ]
            ])
      in
      let trace = Fs.create_trace ~time:0 base_file_system in
      let program () =
        let open Yocaml in
        let cache = Cache.empty in
        let open Eff in
        Eff.return cache
        >>= Fs.increase_time_with 1
        >>= Action.copy_file ~new_name:"client.js"
              ~into:~/[ "_build"; "js" ]
              ~/[ "static"; "client.bc.js" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "css" ]
              ~/[ "static"; "style.css" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "images" ]
              ~/[ "static"; "images"; "ocaml.png" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "images" ]
              ~/[ "static"; "images"; "yocaml.svg" ]
      in
      let trace, _cache = Fs.run ~trace program () in
      let computed_file_system = Fs.trace_system trace
      and expected_file_system =
        Fs.(
          from_list
            [
              dir ~mtime:1 "."
                [
                  file ~mtime:0 "index.md" "an index"
                ; file ~mtime:0 "about.md" "about page"
                ; dir ~mtime:0 "articles"
                    [
                      file ~mtime:0 "hello.md" "hello world"
                    ; file ~mtime:0 "yocaml.md" "article about YOCaml"
                    ]
                ; dir ~mtime:0 "static"
                    [
                      dir ~mtime:0 "images"
                        [
                          file ~mtime:0 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:0 "yocaml.svg" "yocaml-logo"
                        ]
                    ; file ~mtime:0 "client.bc.js" "js client"
                    ; file ~mtime:0 "style.css" "stylesheet"
                    ]
                ; dir "_build"
                    [
                      dir ~mtime:1 "js"
                        [ file ~mtime:1 "client.js" "js client" ]
                    ; dir ~mtime:1 "css"
                        [ file ~mtime:1 "style.css" "stylesheet" ]
                    ; dir ~mtime:1 "images"
                        [
                          file ~mtime:1 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:1 "yocaml.svg" "yocaml-logo"
                        ]
                    ]
                ]
            ])
      in
      check Testable.fs "should be equal" expected_file_system
        computed_file_system)

let test_action_create_file_2 =
  let open Alcotest in
  test_case
    "test of a complete action exection - updating one file and producing new \
     files. Since the cache is empty, it has to rewrite everything."
    `Quick (fun () ->
      let open Yocaml.Path.Infix in
      let base_file_system =
        Fs.(
          from_list
            [
              dir ~mtime:0 "."
                [
                  file ~mtime:0 "index.md" "an index"
                ; file ~mtime:0 "about.md" "about page"
                ; dir ~mtime:0 "articles"
                    [
                      file ~mtime:0 "hello.md" "hello world"
                    ; file ~mtime:0 "yocaml.md" "article about YOCaml"
                    ]
                ; dir ~mtime:0 "static"
                    [
                      dir ~mtime:0 "images"
                        [
                          file ~mtime:0 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:0 "yocaml.svg" "yocaml-logo"
                        ]
                    ; file ~mtime:2 "client.bc.js" "js client"
                    ; file ~mtime:0 "style.css" "stylesheet"
                    ]
                ; dir "_build"
                    [
                      dir ~mtime:1 "js"
                        [ file ~mtime:1 "client.js" "js client" ]
                    ; dir ~mtime:1 "css"
                        [ file ~mtime:1 "style.css" "stylesheet" ]
                    ; dir ~mtime:1 "images"
                        [
                          file ~mtime:1 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:1 "yocaml.svg" "yocaml-logo"
                        ]
                    ]
                ]
            ])
      in
      let trace = Fs.create_trace ~time:0 base_file_system in
      let program () =
        let open Yocaml in
        let cache = Cache.empty in
        let open Eff in
        Eff.return cache
        >>= Fs.increase_time_with 5
        >>= Action.copy_file ~new_name:"client.js"
              ~into:~/[ "_build"; "js" ]
              ~/[ "static"; "client.bc.js" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "css" ]
              ~/[ "static"; "style.css" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "images" ]
              ~/[ "static"; "images"; "ocaml.png" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "images" ]
              ~/[ "static"; "images"; "yocaml.svg" ]
        >>= Action.copy_file ~new_name:"index.html" ~into:~/[ "_build" ]
              ~/[ "index.md" ]
        >>= Action.copy_file ~new_name:"about.html" ~into:~/[ "_build" ]
              ~/[ "about.md" ]
      in
      let trace, _cache = Fs.run ~trace program () in
      let computed_file_system = Fs.trace_system trace
      and expected_file_system =
        Fs.(
          from_list
            [
              dir ~mtime:5 "."
                [
                  file ~mtime:0 "index.md" "an index"
                ; file ~mtime:0 "about.md" "about page"
                ; dir ~mtime:0 "articles"
                    [
                      file ~mtime:0 "hello.md" "hello world"
                    ; file ~mtime:0 "yocaml.md" "article about YOCaml"
                    ]
                ; dir ~mtime:0 "static"
                    [
                      dir ~mtime:0 "images"
                        [
                          file ~mtime:0 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:0 "yocaml.svg" "yocaml-logo"
                        ]
                    ; file ~mtime:2 "client.bc.js" "js client"
                    ; file ~mtime:0 "style.css" "stylesheet"
                    ]
                ; dir "_build"
                    [
                      file ~mtime:5 "index.html" "an index"
                    ; file ~mtime:5 "about.html" "about page"
                    ; dir ~mtime:5 "js"
                        [ file ~mtime:5 "client.js" "js client" ]
                    ; dir ~mtime:5 "css"
                        [ file ~mtime:5 "style.css" "stylesheet" ]
                    ; dir ~mtime:5 "images"
                        [
                          file ~mtime:5 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:5 "yocaml.svg" "yocaml-logo"
                        ]
                    ]
                ]
            ])
      in
      check Testable.fs "should be equal" expected_file_system
        computed_file_system)

let test_action_create_file_3 =
  let open Alcotest in
  test_case
    "test of a complete action exection - use cache to discard some writing"
    `Quick (fun () ->
      let open Yocaml.Path.Infix in
      let base_file_system =
        Fs.(
          from_list
            [
              dir ~mtime:0 "."
                [
                  file ~mtime:0 "index.md" "an index"
                ; file ~mtime:0 "about.md" "about page"
                ; dir ~mtime:0 "articles"
                    [
                      file ~mtime:0 "hello.md" "hello world"
                    ; file ~mtime:0 "yocaml.md" "article about YOCaml"
                    ]
                ; dir ~mtime:0 "static"
                    [
                      dir ~mtime:0 "images"
                        [
                          file ~mtime:0 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:0 "yocaml.svg" "yocaml-logo"
                        ]
                    ; file ~mtime:0 "client.bc.js" "js client"
                    ; file ~mtime:0 "style.css" "stylesheet"
                    ]
                ]
            ])
      in
      let trace = Fs.create_trace ~time:0 base_file_system in
      let program cache =
        let open Yocaml in
        let open Eff in
        Eff.return cache
        >>= Fs.increase_time_with 1
        >>= Action.copy_file ~new_name:"client.js"
              ~into:~/[ "_build"; "js" ]
              ~/[ "static"; "client.bc.js" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "css" ]
              ~/[ "static"; "style.css" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "images" ]
              ~/[ "static"; "images"; "ocaml.png" ]
        >>= Action.copy_file
              ~into:~/[ "_build"; "images" ]
              ~/[ "static"; "images"; "yocaml.svg" ]
      in
      let _, cache = Fs.run ~trace program Yocaml.Cache.empty in
      let base_file_system =
        Fs.(
          from_list
            [
              dir ~mtime:1 "."
                [
                  file ~mtime:0 "index.md" "an index"
                ; file ~mtime:0 "about.md" "about page"
                ; dir ~mtime:0 "articles"
                    [
                      file ~mtime:0 "hello.md" "hello world"
                    ; file ~mtime:0 "yocaml.md" "article about YOCaml"
                    ]
                ; dir ~mtime:0 "static"
                    [
                      dir ~mtime:0 "images"
                        [
                          file ~mtime:3 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:0 "yocaml.svg" "yocaml-logo"
                        ]
                    ; file ~mtime:0 "client.bc.js" "js client"
                    ; file ~mtime:0 "style.css" "stylesheet"
                    ]
                ; dir "_build"
                    [
                      dir ~mtime:1 "js"
                        [ file ~mtime:1 "client.js" "js client" ]
                    ; dir ~mtime:1 "css"
                        [ file ~mtime:1 "style.css" "stylesheet" ]
                    ; dir ~mtime:1 "images"
                        [
                          file ~mtime:1 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:1 "yocaml.svg" "yocaml-logo"
                        ]
                    ]
                ]
            ])
      in
      let trace = Fs.create_trace base_file_system in
      let trace, _cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      check Testable.fs "should be equal" base_file_system computed_file_system)

let test_action_with_dynamic_dependencies_1 =
  let open Alcotest in
  test_case "an example using dynamic dependencies - 1" `Quick (fun () ->
      let open Yocaml.Path.Infix in
      let base_file_system =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "includes"
                    [ file "a.txt" "a"; file "b.txt" "b"; file "c.txt" "c" ]
                ; file "index.txt" "a.txt;b.txt;c.txt"
                ]
            ])
      in
      let program cache =
        let open Yocaml in
        let open Task in
        let t =
          Pipeline.read_file ~/[ "index.txt" ] >>* fun content ->
          let open Eff in
          let files =
            content
            |> String.split_on_char ';'
            |> Stdlib.List.map (fun file -> ~/[ "includes" ] / file)
          in
          let* content = List.traverse (read_file ~on:`Source) files in
          return (content |> String.concat "", Deps.from_list files)
        in

        Eff.(
          return cache
          >>= Action.write_dynamic_file ~/[ "_build"; "index.txt" ] t)
      in
      let trace = Fs.create_trace ~time:2 base_file_system in
      let cache = Yocaml.Cache.empty in
      let trace, cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      let expected_file_system =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "_build" ~mtime:2 [ file "index.txt" ~mtime:2 "abc" ]
                ; dir "includes"
                    [ file "a.txt" "a"; file "b.txt" "b"; file "c.txt" "c" ]
                ; file "index.txt" "a.txt;b.txt;c.txt"
                ]
            ])
      in
      let () =
        check Testable.cache "should be equal"
          Yocaml.Cache.(
            from_list
              [
                ( ~/[ "_build"; "index.txt" ]
                , entry "H:abc"
                  @@ Yocaml.Deps.from_list
                       [
                         ~/[ "includes"; "a.txt" ]
                       ; ~/[ "includes"; "b.txt" ]
                       ; ~/[ "includes"; "c.txt" ]
                       ] )
              ])
          cache
      in
      let () =
        check Testable.fs "should be equal" expected_file_system
          computed_file_system
      in
      let trace = Fs.create_trace ~time:5 computed_file_system in
      let trace, cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      let () =
        check Testable.fs "should be equal" expected_file_system
          computed_file_system
      in
      let base_file_system =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "_build" ~mtime:2 [ file "index.txt" ~mtime:2 "abc" ]
                ; dir "includes"
                    [
                      file "a.txt" "a"
                    ; file "b.txt" "b"
                    ; file ~mtime:3 "c.txt" "c"
                    ]
                ; file "index.txt" "a.txt;b.txt;c.txt"
                ]
            ])
      in
      let trace = Fs.create_trace ~time:2 base_file_system in
      let trace, cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      let expected_file_system =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "_build" ~mtime:2 [ file "index.txt" ~mtime:2 "abc" ]
                ; dir "includes"
                    [
                      file "a.txt" "a"
                    ; file "b.txt" "b"
                    ; file ~mtime:3 "c.txt" "c"
                    ]
                ; file "index.txt" "a.txt;b.txt;c.txt"
                ]
            ])
      in
      let () =
        check Testable.fs "should be equal" expected_file_system
          computed_file_system
      in
      let trace = Fs.create_trace ~time:10 computed_file_system in
      let trace, cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      let () =
        check Testable.fs "should be equal" expected_file_system
          computed_file_system
      in
      let base_file_system =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "_build" ~mtime:2 [ file "index.txt" ~mtime:2 "abc" ]
                ; dir "includes"
                    [
                      file "a.txt" "a"
                    ; file "b.txt" "b"
                    ; file ~mtime:3 "c.txt" "c"
                    ]
                ; file "index.txt" "a.txt;b.txt;c.txt"
                ]
            ])
      in
      let trace = Fs.create_trace ~time:2 base_file_system in
      let trace, cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      let expected_file_system =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "_build" ~mtime:2 [ file "index.txt" ~mtime:2 "abc" ]
                ; dir "includes"
                    [
                      file "a.txt" "a"
                    ; file "b.txt" "b"
                    ; file ~mtime:3 "c.txt" "c"
                    ]
                ; file "index.txt" "a.txt;b.txt;c.txt"
                ]
            ])
      in
      let () =
        check Testable.fs "should be equal" expected_file_system
          computed_file_system
      in
      let trace = Fs.create_trace ~time:10 computed_file_system in
      let trace, cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      let () =
        check Testable.fs "should be equal" expected_file_system
          computed_file_system
      in
      let base_file_system =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "_build" ~mtime:2 [ file "index.txt" ~mtime:2 "abc" ]
                ; dir "includes"
                    [
                      file "a.txt" "a"
                    ; file "b.txt" "b"
                    ; file ~mtime:5 "c.txt" "d"
                    ]
                ; file "index.txt" "a.txt;b.txt;c.txt"
                ]
            ])
      in
      let trace = Fs.create_trace ~time:10 base_file_system in
      let trace, _cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      let expected_file_system =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "_build" ~mtime:10 [ file "index.txt" ~mtime:10 "abd" ]
                ; dir "includes"
                    [
                      file "a.txt" "a"
                    ; file "b.txt" "b"
                    ; file ~mtime:5 "c.txt" "d"
                    ]
                ; file "index.txt" "a.txt;b.txt;c.txt"
                ]
            ])
      in

      let () =
        check Testable.fs "should be equal" expected_file_system
          computed_file_system
      in

      ())

let test_batch_1 =
  let open Alcotest in
  test_case "batch should performs action on multiple files, relaying the cache"
    `Quick (fun () ->
      let open Yocaml in
      let open Path.Infix in
      let base_file_system =
        Fs.(
          from_list
            [
              dir ~mtime:0 "."
                [
                  file ~mtime:0 "index.md" "an index"
                ; file ~mtime:0 "about.md" "about page"
                ; dir ~mtime:0 "articles"
                    [
                      file ~mtime:0 "hello.md" "hello world"
                    ; file ~mtime:0 "yocaml.md" "article about YOCaml"
                    ]
                ; dir ~mtime:0 "static"
                    [
                      dir ~mtime:0 "images"
                        [
                          file ~mtime:0 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:0 "yocaml.svg" "yocaml-logo"
                        ]
                    ; file ~mtime:0 "client.bc.js" "js client"
                    ; file ~mtime:0 "style.css" "stylesheet"
                    ]
                ]
            ])
      in
      let program cache =
        let open Eff.Infix in
        Eff.return cache
        >>= Action.batch ~only:`Files ~/[] ~where:(Path.has_extension ".md")
              (Action.copy_file ~into:~/[ "_build" ])
        >>= Action.batch ~only:`Files
              ~/[ "static"; "images" ]
              (Action.copy_file ~into:~/[ "_build"; "images" ])
        >>= Action.batch ~only:`Files ~/[ "static" ]
              ~where:(Path.has_extension ".css")
              (Action.copy_file ~into:~/[ "_build"; "css" ])
        >>= Action.batch ~only:`Files ~/[ "static" ]
              ~where:(Path.has_extension ".js")
              (Action.copy_file ~into:~/[ "_build"; "js" ])
      in
      let trace = Fs.create_trace ~time:1 base_file_system in
      let trace, cache = Fs.run ~trace program Cache.empty in
      let expected_file_system =
        Fs.(
          from_list
            [
              dir ~mtime:1 "."
                [
                  file ~mtime:0 "index.md" "an index"
                ; file ~mtime:0 "about.md" "about page"
                ; dir ~mtime:1 "_build"
                    [
                      file ~mtime:1 "index.md" "an index"
                    ; file ~mtime:1 "about.md" "about page"
                    ; dir ~mtime:1 "images"
                        [
                          file ~mtime:1 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:1 "yocaml.svg" "yocaml-logo"
                        ]
                    ; dir ~mtime:1 "js"
                        [ file ~mtime:1 "client.bc.js" "js client" ]
                    ; dir ~mtime:1 "css"
                        [ file ~mtime:1 "style.css" "stylesheet" ]
                    ]
                ; dir ~mtime:0 "articles"
                    [
                      file ~mtime:0 "hello.md" "hello world"
                    ; file ~mtime:0 "yocaml.md" "article about YOCaml"
                    ]
                ; dir ~mtime:0 "static"
                    [
                      dir ~mtime:0 "images"
                        [
                          file ~mtime:0 "ocaml.png" "ocaml-logo"
                        ; file ~mtime:0 "yocaml.svg" "yocaml-logo"
                        ]
                    ; file ~mtime:0 "client.bc.js" "js client"
                    ; file ~mtime:0 "style.css" "stylesheet"
                    ]
                ]
            ])
      in
      let computed_file_system = Fs.trace_system trace in

      let () =
        check Testable.fs "everything should be copied" expected_file_system
          computed_file_system
      in
      let trace = Fs.create_trace ~time:1 base_file_system in
      let trace, _cache = Fs.run ~trace program cache in
      let computed_file_system = Fs.trace_system trace in
      check Testable.fs "Nothing should be done" expected_file_system
        computed_file_system)

let cases =
  ( "Yocaml.Action"
  , [
      test_action_create_file_1
    ; test_action_create_file_2
    ; test_action_create_file_3
    ; test_action_with_dynamic_dependencies_1
    ; test_batch_1
    ] )
