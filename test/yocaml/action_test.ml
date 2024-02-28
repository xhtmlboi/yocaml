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
      let trace = Fs.create_trace ~mtime:0 base_file_system in
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
     files"
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
      let trace = Fs.create_trace ~mtime:0 base_file_system in
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
      let trace = Fs.create_trace ~mtime:0 base_file_system in
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

let cases =
  ( "Yocaml.Action"
  , [
      test_action_create_file_1
    ; test_action_create_file_2
    ; test_action_create_file_3
    ] )
