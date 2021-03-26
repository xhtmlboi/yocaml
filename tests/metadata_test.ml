open Wordpress

let opt_validate_testable upp ueq =
  let open Validate in
  Alcotest.testable
    (pp $ Preface.Option.pp upp)
    (equal $ Preface.Option.equal ueq)
;;

let validate_testable upp ueq =
  let open Validate in
  Alcotest.testable (pp upp) (equal ueq)
;;

let capture_base_metadata_valid1 =
  let open Alcotest in
  test_case "capture base metadata 1 without values" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|My article|}
    |> Metadata.Base.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Base.page_title)
  $ Validate.valid None
;;

let capture_base_metadata_valid2 =
  let open Alcotest in
  test_case "capture base metadata 2 without values" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|---
other_deps: foo
---My article|}
    |> Metadata.Base.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Base.page_title)
  $ Validate.valid None
;;

let capture_base_metadata_valid3 =
  let open Alcotest in
  test_case "capture base metadata 3 without values" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|---
other_deps: foo bar
---My article|}
    |> Metadata.Base.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Base.page_title)
  $ Validate.valid None
;;

let capture_base_metadata_valid4 =
  let open Alcotest in
  test_case "capture base metadata 4 with only a title" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|---
My superb article
---My article|}
    |> Metadata.Base.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Base.page_title)
  $ Validate.valid (Some "My superb article")
;;

let capture_base_metadata_valid5 =
  let open Alcotest in
  test_case "capture base metadata 5 with an indexed title" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|---
page_title: My superb article  
---My article|}
    |> Metadata.Base.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Base.page_title)
  $ Validate.valid (Some "My superb article")
;;

let capture_article_metadata_invalid1 =
  let open Alcotest in
  test_case "capture article metadata 1 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|My article|}
    |> Metadata.Article.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.page_title)
  $ Error.(to_validate $ Required_metadata Metadata.Article.repr)
;;

let capture_article_metadata_invalid2 =
  let open Alcotest in
  test_case "capture article metadata 2 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|---
My article|}
    |> Metadata.Article.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.page_title)
  $ Error.(to_validate $ Required_metadata Metadata.Article.repr)
;;

let capture_article_metadata_invalid3 =
  let open Alcotest in
  test_case "capture article metadata 3 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|---
---My article|}
    |> Metadata.Article.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.page_title)
  $ Error.(to_validate $ Required_metadata Metadata.Article.repr)
;;

let capture_article_metadata_invalid4 =
  let open Alcotest in
  test_case "capture article metadata 4 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata {|---
article_title: My First Article
---My article|}
    |> Metadata.Article.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.page_title)
  $ Validate.invalid
      Preface.Nonempty_list.(
        Error.Missing_field "date"
        :: Last (Error.Missing_field "article_synopsis"))
;;

let capture_article_metadata_invalid5 =
  let open Alcotest in
  test_case "capture article metadata 5 invalid" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata
        {|---
article_title: My First Article
article_synopsis:
  Hello, this is my first article, I guess that it is 
  interesting, but I don't think so!
date: 2021-12
---My article|}
    |> Metadata.Article.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.page_title)
  $ Validate.invalid Preface.Nonempty_list.(Last (Error.Invalid_field "date"))
;;

let capture_article_metadata_valid1 =
  let open Alcotest in
  test_case "capture article metadata 1 valid" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata
        {|---
page_title: Blog - an article
article_title: My First Article  
article_synopsis:
  Hello, this is my first article, I guess that it is 
  interesting, but I don't think so!    
date: 2021-12-03
---My article|}
    |> Metadata.Article.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.page_title)
  $ Validate.valid (Some "Blog - an article");
  check
  $ validate_testable
      (Preface.List.pp Format.pp_print_string)
      (Preface.List.equal String.equal)
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.tags)
  $ Validate.valid [];
  check
  $ validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(
      obj
      >|= Metadata.Article.date
      >|= fun (x, y, z) -> Format.asprintf "%d-%d-%d" x y z)
  $ Validate.valid "2021-12-3";
  check
  $ validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.article_title)
  $ Validate.valid "My First Article";
  check
  $ validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.article_synopsis)
  $ Validate.valid
      "Hello, this is my first article, I guess that it is interesting, but \
       I don't think so!"
;;

let capture_article_metadata_valid2 =
  let open Alcotest in
  test_case "capture article metadata 2 valid" `Quick
  $ fun () ->
  let obj =
    Preface.Tuple.fst
    $ split_metadata
        {|---
page_title: Blog - an article
article_title: My First Article  
tags:
  - Bohr
  - Church  
  - McLane         
article_synopsis:
  Hello, this is my first article, I guess that it is 
  interesting, but I don't think so!    
date: 2021-12-03
---My article|}
    |> Metadata.Article.from_string
  in
  check
  $ opt_validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.page_title)
  $ Validate.valid (Some "Blog - an article");
  check
  $ validate_testable
      (Preface.List.pp Format.pp_print_string)
      (Preface.List.equal String.equal)
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.tags)
  $ Validate.valid [ "bohr"; "church"; "mclane" ];
  check
  $ validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(
      obj
      >|= Metadata.Article.date
      >|= fun (x, y, z) -> Format.asprintf "%d-%d-%d" x y z)
  $ Validate.valid "2021-12-3";
  check
  $ validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.article_title)
  $ Validate.valid "My First Article";
  check
  $ validate_testable Format.pp_print_string String.equal
  $ "should be equal"
  $ Validate.Monad.(obj >|= Metadata.Article.article_synopsis)
  $ Validate.valid
      "Hello, this is my first article, I guess that it is interesting, but \
       I don't think so!"
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
