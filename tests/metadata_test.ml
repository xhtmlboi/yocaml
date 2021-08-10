open Yocaml
open Common_test

let page_testable = Alcotest.testable Metadata.Page.pp Metadata.Page.equal

let article_testable =
  Alcotest.testable Metadata.Article.pp Metadata.Article.equal
;;

let valid_page_testable =
  validate_testable Metadata.Page.pp Metadata.Page.equal
;;

let valid_article_testable =
  validate_testable Metadata.Article.pp Metadata.Article.equal
;;

let capture_base_metadata_valid1 =
  let open Alcotest in
  test_case "capture base metadata 1 without values" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|My article|}
    |> Metadata.Page.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Page.title)
  $ Validate.valid None
;;

let capture_base_metadata_valid2 =
  let open Alcotest in
  test_case "capture base metadata 2 without values" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|---
other_deps: foo
---My article|}
    |> Metadata.Page.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Page.title)
  $ Validate.valid None
;;

let capture_base_metadata_valid3 =
  let open Alcotest in
  test_case "capture base metadata 3 without values" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|---
other_deps: foo bar
---My article|}
    |> Metadata.Page.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Page.title)
  $ Validate.valid None
;;

let capture_base_metadata_valid4 =
  let open Alcotest in
  test_case "capture base metadata 4 with only a title" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|---
My superb article
---My article|}
    |> Metadata.Page.from_string (module Yocaml_yaml)
  in
  check
    valid_page_testable
    "should be equal"
    obj
    (Validate.valid $ Metadata.Page.make None None)
;;

let capture_base_metadata_valid5 =
  let open Alcotest in
  test_case "capture base metadata 5 with an indexed title" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|---
title: My superb article
---My article|}
    |> Metadata.Page.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Page.title)
  $ Validate.valid (Some "My superb article")
;;

let capture_article_metadata_invalid1 =
  let open Alcotest in
  test_case "capture article metadata 1 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|My article|}
    |> Metadata.Article.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.title)
  $ Error.(to_validate $ Required_metadata [ "Article" ])
;;

let capture_article_metadata_invalid2 =
  let open Alcotest in
  test_case "capture article metadata 2 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|---
My article|}
    |> Metadata.Article.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.title)
  $ Error.(to_validate $ Required_metadata [ "Article" ])
;;

let capture_article_metadata_invalid3 =
  let open Alcotest in
  test_case "capture article metadata 3 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|---
---My article|}
    |> Metadata.Article.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.title)
  $ Error.(to_validate $ Invalid_field "Object expected")
;;

let capture_article_metadata_invalid4 =
  let open Alcotest in
  test_case "capture article metadata 4 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata {|---
article_title: My First Article
---My article|}
    |> Metadata.Article.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.title)
  $ Validate.invalid
      Preface.Nonempty_list.(
        Error.Missing_field "article_description"
        :: Last (Error.Missing_field "date"))
;;

let capture_article_metadata_invalid5 =
  let open Alcotest in
  test_case "capture article metadata 5 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata
        {|---
article_title: My First Article
article_description:
  Hello, this is my first article, I guess that it is
  interesting, but I don't think so!
date: 2021-12
---My article|}
    |> Metadata.Article.from_string (module Yocaml_yaml)
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.title)
  $ Validate.invalid
      Preface.Nonempty_list.(Last (Error.Invalid_date "2021-12"))
;;

let capture_article_metadata_valid1 =
  let open Alcotest in
  test_case "capture article metadata 1 valid" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata
        {|---
title: Blog - an article
article_title: My First Article
article_description:
  Hello, this is my first article, I guess that it is
  interesting, but I don't think so!
date: 2021-12-03
---My article|}
    |> Metadata.Article.from_string (module Yocaml_yaml)
  in
  let expected =
    let open Validate.Monad in
    Date.make 2021 Dec 3
    >|= fun date ->
    Metadata.Article.make
      "My First Article"
      "Hello, this is my first article, I guess that it is interesting, but \
       I don't think so!"
      []
      date
      (Some "Blog - an article")
      None
  in
  check valid_article_testable "should be equal" expected obj
;;

let capture_article_metadata_valid2 =
  let open Alcotest in
  test_case "capture article metadata 2 valid" `Quick
  $ fun () ->
  let obj =
    Preface.Pair.fst
    $ split_metadata
        {|---
title: Blog - an article
article_title: My First Article
tags:
  - Bohr
  - Church
  - McLane
article_description:
  Hello, this is my first article, I guess that it is
  interesting, but I don't think so!
date: 2021-12-03
---My article|}
    |> Metadata.Article.from_string (module Yocaml_yaml)
  in
  let expected =
    let open Validate.Monad in
    Date.make 2021 Dec 3
    >|= fun date ->
    Metadata.Article.make
      "My First Article"
      "Hello, this is my first article, I guess that it is interesting, but \
       I don't think so!"
      [ "bohr"; "church"; "mclane" ]
      date
      (Some "Blog - an article")
      None
  in
  check valid_article_testable "should be equal" expected obj
;;

let cases =
  ( "Metadata"
  , [ capture_base_metadata_valid1
    ; capture_base_metadata_valid2
    ; capture_base_metadata_valid3
    ; capture_base_metadata_valid4
    ; capture_base_metadata_valid5
    ; capture_article_metadata_invalid1
    ; capture_article_metadata_invalid2
    ; capture_article_metadata_invalid3
    ; capture_article_metadata_invalid4
    ; capture_article_metadata_invalid5
    ; capture_article_metadata_valid1
    ; capture_article_metadata_valid2
    ] )
;;
