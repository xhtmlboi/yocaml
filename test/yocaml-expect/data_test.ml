(* YOCaml a static blog generator.
   Copyright (C) 2026 The Funkyworkers and The YOCaml's developers

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

open Yocaml

let my_record ?(title = "title") ?(kind = "kind") ?(description = "description")
    ?(url = "url") () =
  let open Data in
  record
    [
      (title, string "My title")
    ; (kind, string "My Kind")
    ; (description, string "A description")
    ; (url, string "https://yocaml.github.io")
    ]

let dump = function
  | Ok x -> print_endline x
  | Error err ->
      Format.asprintf "%a" (Diagnostic.pp_validation_error (fun _ _ -> ())) err
      |> print_endline

let validate_my_record input =
  let open Data.Validation in
  record
    (fun obj ->
      let+ title = req obj ~alt:[ "name"; "main_title" ] "title" string
      and+ kind = opt obj ~alt:[ "k"; "sort" ] "kind" string
      and+ desc = req obj ~alt:[ "desc"; "synopsis" ] "description" string
      and+ url = opt obj ~alt:[ "link"; "site" ] "url" string in
      let open Format in
      asprintf "%a\n\ntitle:%s\nkind:%a\ndesc:%s\nurl:%a" Data.pp input title
        (pp_print_option pp_print_string)
        kind desc
        (pp_print_option pp_print_string)
        url)
    input

let%expect_test "Validate a regular record" =
  my_record () |> validate_my_record |> dump;
  [%expect
    {|
    {"title": "My title", "kind": "My Kind", "description": "A description",
    "url": "https://yocaml.github.io"}

    title:My title
    kind:My Kind
    desc:A description
    url:https://yocaml.github.io
    |}]

let%expect_test "Validate a regular record with alternative names" =
  my_record ~title:"main_title" ~kind:"sort" ~description:"synopsis" ~url:"site"
    ()
  |> validate_my_record
  |> dump;
  [%expect
    {|
    {"main_title": "My title", "sort": "My Kind", "synopsis": "A description",
    "site": "https://yocaml.github.io"}

    title:My title
    kind:My Kind
    desc:A description
    url:https://yocaml.github.io
    |}]

let%expect_test "Validate a regular record with missing name - 1" =
  my_record ~title:"main_title" ~kind:"invalidfieldname" ~description:"synopsis"
    ~url:"site" ()
  |> validate_my_record
  |> dump;
  [%expect
    {|
    {"main_title": "My title", "invalidfieldname": "My Kind", "synopsis":
     "A description", "site": "https://yocaml.github.io"}

    title:My title
    kind:
    desc:A description
    url:https://yocaml.github.io
    |}]

let%expect_test "Validate a regular record with missing name - 2" =
  my_record ~title:"an_invalid_title_name" ~kind:"invalidfieldname"
    ~description:"fail_because_required" ~url:"site" ()
  |> validate_my_record
  |> dump;
  [%expect
    {|
    Invalid record:
      Errors (2):
      1) Missing field `title or [name, main_title]`

      2) Missing field `description or [desc, synopsis]`

      Given record:
        an_invalid_title_name = `"My title"`
        invalidfieldname = `"My Kind"`
        fail_because_required = `"A description"`
        site = `"https://yocaml.github.io"`
    |}]

let%expect_test "Validate a regular record with invalid fields" =
  Data.(
    record
      [
        ("title", list_of string [])
      ; ("sort", string "My Kind")
      ; ("desc", string "A description")
      ; ("link", int 42)
      ])
  |> validate_my_record
  |> dump;
  [%expect
    {|
    Invalid record:
      Errors (2):
      1) Invalid field `title`:
           Invalid shape:
             Expected: strict-string
             Given: `[]`

      2) Invalid field `link`:
           Invalid shape:
             Expected: strict-string
             Given: `42`

      Given record:
        title = `[]`
        sort = `"My Kind"`
        desc = `"A description"`
        link = `42`
    |}]
