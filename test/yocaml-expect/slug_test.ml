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

open Yocaml

let%expect_test "slugify - just 3 words" =
  let title = "foo bar baz" in
  print_endline @@ Slug.from title;
  [%expect {| foo-bar-baz |}]

let%expect_test "slugify - with spaces" =
  let title = "foo   ba   r    baz" in
  print_endline @@ Slug.from title;
  [%expect {| foo-ba-r-baz |}]

let%expect_test "slugify - with unknown characters" =
  let title = "foo   ba   r    baz ''**^% r" in
  print_endline @@ Slug.from title;
  [%expect {| foo-ba-r-baz-percent-r |}]

let%expect_test "slugify - with punctuation" =
  let title =
    "They knew that life was complicated. And yet he carried on; SAPRISTI "
  in
  print_endline @@ Slug.from title;
  [%expect
    {| they-knew-that-life-was-complicated-and-yet-he-carried-on-sapristi |}]

let%expect_test "slugify - with punctuation" =
  let title =
    "They knew that life was complicated & foo. And <> yet % he carried + on | \
     ; SAPRISTI "
  in
  print_endline @@ Slug.from title;
  [%expect
    {| they-knew-that-life-was-complicated-and-foo-and-less-greater-yet-percent-he-carried-plus-on-or-sapristi |}]

let%expect_test "slugify - with punctuation 2" =
  let title =
    "They knew that life ^ was complicated & foo. And <> yet % he carried + on \
     | ; SAPRISTI "
  in
  print_endline @@ Slug.from ~separator:'~' ~unknown_char:'@' title;
  [%expect
    {| they~knew~that~life~@~was~complicated~and~foo~and~less~greater~yet~percent~he~carried~plus~on~or~sapristi |}]

let%expect_test "slugify - with trim" =
  let title = " (  ^@  foo bar baz  )- " in
  print_endline @@ Slug.from title;
  [%expect {| at-foo-bar-baz |}]

let%expect_test "slug validation - 1" =
  let slug = "at-foo-bar-baz" in
  Slug.validate ~unknown_char:'-' ~separator:'-' (Data.string slug)
  |> Result.fold ~ok:(fun x -> x) ~error:(fun _ -> "<error>")
  |> print_endline;
  [%expect {| at-foo-bar-baz |}]

let%expect_test "slug validation - 2" =
  let slug =
    "they~knew~that~life~@~was~complicated~and~foo~and~less~greater~yet~percent~he~carried~plus~on~or~sapristi"
  in
  Slug.validate ~unknown_char:'@' ~separator:'~' (Data.string slug)
  |> Result.fold ~ok:(fun x -> x) ~error:(fun _ -> "<error>")
  |> print_endline;
  [%expect
    {| they~knew~that~life~@~was~complicated~and~foo~and~less~greater~yet~percent~he~carried~plus~on~or~sapristi |}]

let%expect_test "slug validation - 3" =
  let slug =
    "they~knew~th:at~life~@~was~complicated~and~foo~and~less~greater~yet~percent~he~carried~plus~on~or~sapristi"
  in
  Slug.validate ~unknown_char:'@' ~separator:'~' (Data.string slug)
  |> Result.fold ~ok:(fun x -> x) ~error:(fun _ -> "<error>")
  |> print_endline;
  [%expect
    {| <error> |}]
