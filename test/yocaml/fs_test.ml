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

let test_get =
  let open Alcotest in
  test_case "Ensures that the [get] primitive behaves as expected" `Quick
    (fun () ->
      let open Test_lib.Fs in
      let root =
        dir "."
          [
            file ~mtime:2 "hello.txt" "Hello, World!"
          ; dir "posts"
              [
                file ~mtime:4 "index.md" "First post"
              ; file "second.md" "Second post"
              ; dir "images" [ file "foo.png" "An image" ]
              ]
          ]
      in
      let file_system = from_list [ root ] in
      let () =
        check (option testable_item) "should be equal" (Some root)
          file_system.%{"."}
      in
      let () =
        check (option testable_item) "should be equal"
          (Some (file ~mtime:2 "hello.txt" "Hello, World!"))
          file_system.%{"./hello.txt"}
      in
      let () =
        check (option testable_item) "should be equal"
          (Some (file ~mtime:4 "index.md" "First post"))
          file_system.%{"./posts/index.md"}
      in
      let () =
        check (option testable_item) "should be equal"
          (Some (file ~mtime:1 "second.md" "Second post"))
          file_system.%{"./posts/second.md"}
      in
      let () =
        check (option testable_item) "should be equal"
          (Some (dir "images" [ file ~mtime:1 "foo.png" "An image" ]))
          file_system.%{"./posts/images"}
      in
      let () =
        check (option testable_item) "should be equal"
          (Some (file ~mtime:1 "foo.png" "An image"))
          file_system.%{"./posts/images/foo.png"}
      in
      let () =
        check (option testable_item) "should be equal" None
          file_system.%{"./foo/bar/baz"}
      in
      ())

let test_update_file =
  let open Alcotest in
  test_case "Ensure that the [update] primitive behaves as expected" `Quick
    (fun () ->
      let open Test_lib.Fs in
      let root =
        dir "."
          [
            file ~mtime:2 "hello.txt" "Hello, World!"
          ; dir "posts"
              [
                file ~mtime:4 "index.md" "First post"
              ; file "second.md" "Second post"
              ; dir "images" [ file "foo.png" "An image" ]
              ]
          ]
      in
      let file_system = from_list [ root ] in
      let file_system =
        file_system.%{"./hello.txt"} <-
          (fun ~target ~previous_item ->
            let () = check string "should be equal" "hello.txt" target in
            let () =
              check (option testable_item) "should be equal"
                (Some (file ~mtime:2 "hello.txt" "Hello, World!"))
                previous_item
            in
            Some (file ~mtime:3 "olleh.txt" "Replaced"))
      in
      let file_system =
        file_system.%{"./posts/images"} <-
          (fun ~target ~previous_item ->
            let () = check string "should be equal" "images" target in
            Option.map (rename "pictures") previous_item)
      in
      let () =
        check testable "should be equal"
          (from_list
             [
               dir "."
                 [
                   file ~mtime:3 "olleh.txt" "Replaced"
                 ; dir "posts"
                     [
                       file ~mtime:4 "index.md" "First post"
                     ; file "second.md" "Second post"
                     ; dir "pictures" [ file "foo.png" "An image" ]
                     ]
                 ]
             ])
          file_system
      in
      ())

let cases = ("Test_lib.Fs", [ test_get; test_update_file ])
