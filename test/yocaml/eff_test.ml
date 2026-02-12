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

(** Having tests for effects may seem strange, as they rely on the effects
    interpreter described in {!module:Test_lib.Fs} which will probably never be
    used outside of testing.

    However, some functions defined in the Eff module embed more logic that is
    independent of the effects interpretation. *)

let d t n l = Fs.dir ~mtime:t n l
let f t n c = Fs.file ~mtime:t n c

let base_file_system =
  let open Fs in
  from_list
    [
      d 20 "."
        [
          d 10 "images"
            [
              d 5 "photos"
                [
                  f 2 "antoine.jpg" "antoine-picture"
                ; f 3 "xavier.jpg" "xavier-picture"
                ; f 3 "pierre.png" "pierre-picture"
                ; f 3 "mickael.jpeg" "mickael-picture"
                ]
            ; f 4 "logo.svg" "a logo"
            ; f 4 "ocaml.svg" "ocaml logo"
            ; f 4 "yocaml.png" "yocaml logo"
            ]
        ; d 11 "articles"
            [
              f 7 "hello.md" "Hello world"
            ; f 8 "release-1.md" "A 2nd release of YOCaml"
            ; f 9 "release-nightmare.md" "A new release of Nightmare"
            ]
        ; f 15 "index.md" "Index of my site"
        ; f 16 "about.md" "Welcome on my dummy file system!"
        ]
    ]

let test_file_exists =
  let open Alcotest in
  test_case "file_exists should return true if the file exists" `Quick
    (fun () ->
      let open Yocaml in
      let open Path.Infix in
      let trace = Fs.create_trace base_file_system in
      let perform_exists expected path =
        let exists =
          snd @@ Fs.run ~trace (fun () -> Eff.file_exists ~on:`Source path) ()
        in
        check bool
          (Format.asprintf "%a should %sexists" Path.pp path
             (if expected then "" else "not "))
          expected exists
      in
      let should_exists = perform_exists true
      and should_not_exists = perform_exists false in
      should_exists ~/[];
      should_exists ~/[ "images" ];
      should_exists ~/[ "articles"; "release-1.md" ];
      should_exists ~/[ "about.md" ];
      should_not_exists ~/[ "foo"; "bar" ])

let test_read_file =
  let open Alcotest in
  test_case "read_file should read the content of a file" `Quick (fun () ->
      let open Yocaml in
      let open Path.Infix in
      let trace = Fs.create_trace base_file_system in
      let expect_content path expected =
        let computed =
          snd @@ Fs.run ~trace (fun () -> Eff.read_file ~on:`Source path) ()
        in
        check string
          (Format.asprintf "%a should contains `%s`" Path.pp path expected)
          expected computed
      in
      expect_content ~/[ "images"; "photos"; "antoine.jpg" ] "antoine-picture";
      expect_content ~/[ "index.md" ] "Index of my site")

let test_mtime =
  let open Alcotest in
  test_case "mtime should return the modification of time of a file" `Quick
    (fun () ->
      let open Yocaml in
      let open Path.Infix in
      let trace = Fs.create_trace base_file_system in
      let expect_mtime path expected =
        let computed =
          snd @@ Fs.run ~trace (fun () -> Eff.mtime ~on:`Source path) ()
        in
        check (float 1.0)
          (Format.asprintf "%a should has mtime `%f`" Path.pp path expected)
          expected computed
      in
      expect_mtime ~/[] 20.0;
      expect_mtime ~/[ "about.md" ] 16.0;
      expect_mtime ~/[ "images"; "logo.svg" ] 4.0)

let test_is_directory =
  let open Alcotest in
  test_case "is_directory should returns true if the given path is a directory"
    `Quick (fun () ->
      let open Yocaml in
      let open Path.Infix in
      let trace = Fs.create_trace base_file_system in
      let perform_is_dir expected path =
        let is_dir =
          snd @@ Fs.run ~trace (fun () -> Eff.is_directory ~on:`Source path) ()
        in
        check bool
          (Format.asprintf "%a should %sbe a directory" Path.pp path
             (if expected then "" else "not "))
          expected is_dir
      in
      let a_directory = perform_is_dir true in
      let not_a_directory = perform_is_dir false in
      a_directory ~/[];
      a_directory ~/[ "images" ];
      a_directory ~/[ "images"; "photos" ];
      not_a_directory ~/[ "index.md" ];
      not_a_directory ~/[ "images"; "logo.svg" ])

let test_read_directory =
  let open Alcotest in
  test_case "read_directory should return the list of directory's children"
    `Quick (fun () ->
      let open Yocaml in
      let open Path.Infix in
      let trace = Fs.create_trace base_file_system in
      let check_children ?only ?where path expected =
        let sort = List.sort Path.compare in
        let expected = sort expected in
        let computed =
          snd
          @@ Fs.run ~trace
               (fun () -> Eff.read_directory ~on:`Source ?only ?where path)
               ()
          |> sort
        in
        check (list Testable.path)
          (Format.asprintf "%a has not the expected children" Path.pp path)
          expected computed
      in
      check_children ~/[]
        [ ~/[ "images" ]; ~/[ "articles" ]; ~/[ "index.md" ]; ~/[ "about.md" ] ];
      check_children ~only:`Files ~/[] [ ~/[ "index.md" ]; ~/[ "about.md" ] ];
      check_children ~only:`Directories ~/[]
        [ ~/[ "images" ]; ~/[ "articles" ] ];
      check_children ~/[] ~where:(Path.has_extension "md")
        [ ~/[ "index.md" ]; ~/[ "about.md" ] ];
      check_children
        ~/[ "images"; "photos" ]
        ~where:(fun x ->
          Path.has_extension "jpg" x || Path.has_extension "jpeg" x)
        [
          ~/[ "images"; "photos"; "antoine.jpg" ]
        ; ~/[ "images"; "photos"; "xavier.jpg" ]
        ; ~/[ "images"; "photos"; "mickael.jpeg" ]
        ])

let test_mtime_recursive =
  let open Alcotest in
  test_case "mtime on directory should return the greatest mtime of children"
    `Quick (fun () ->
      let open Yocaml in
      let fs =
        let open Fs in
        from_list
          [
            d 1 "."
              [
                f 1 "foo" "bar"
              ; d 1 "www"
                  [
                    d 1 "x" [ f 10 "test" "test"; f 2 "aaa" "bbb" ]
                  ; f 13 "tttt" "tttt"
                  ]
              ]
          ]
      in
      let trace = Fs.create_trace fs in
      let expect_mtime path expected =
        let computed =
          snd @@ Fs.run ~trace (fun () -> Eff.mtime ~on:`Source path) ()
        in
        check (float 1.0)
          (Format.asprintf "%a should has mtime `%f`" Path.pp path expected)
          expected computed
      in
      let open Path in
      expect_mtime ~/[] 13.0;
      expect_mtime ~/[ "www" ] 13.0;
      expect_mtime ~/[ "www"; "x" ] 10.0;
      expect_mtime ~/[ "foo" ] 1.0)

let test_list_fold_left_1 =
  let open Alcotest in
  test_case "List.fold_left on empty list should return an empty string" `Quick
    (fun () ->
      let trace = Fs.create_trace base_file_system in
      let expected = ""
      and _, computed =
        Fs.run ~trace
          (fun () ->
            Yocaml.Eff.(
              List.fold_left (fun acc x -> acc >|= String.cat x) (return "") []))
          ()
      in
      check string "should be equal" expected computed)

let test_list_fold_left_2 =
  let open Alcotest in
  test_case "List.fold_left on list should concat into one string" `Quick
    (fun () ->
      let trace = Fs.create_trace base_file_system in
      let expected = "abcd"
      and _, computed =
        Fs.run ~trace
          (fun () ->
            Yocaml.Eff.(
              List.fold_left
                (fun acc x -> acc >|= (Fun.flip String.cat) x)
                (return "")
                [ return "a"; return "b"; return "c"; return "d" ]))
          ()
      in
      check string "should be equal" expected computed)

let cases =
  ( "Yocaml.Eff"
  , [
      test_file_exists
    ; test_read_file
    ; test_mtime
    ; test_is_directory
    ; test_read_directory
    ; test_mtime_recursive
    ; test_list_fold_left_1
    ; test_list_fold_left_2
    ] )
