open Util

type date = int * int * int

let date_to_string (y, m, d) = Format.asprintf "%04d-%02d-%02d" y m d

let date_eq (y, m, d) (yy, mm, dd) =
  Preface.List.equal Int.equal [ y; m; d ] [ yy; mm; dd ]
;;

module type INJECTABLE = sig
  type obj

  val to_mustache : obj -> (string * Mustache.Json.value) list
end

module type PARSABLE = sig
  (** The container of the metadata. *)
  type obj

  (** Try to produces an [obj] from an optional value. *)
  val from_string : string option -> obj Validate.t
end

module type METADATA = sig
  include INJECTABLE
  include PARSABLE with type obj := obj

  val equal : obj -> obj -> bool
  val pp : Format.formatter -> obj -> unit
  val repr : string list
end

class virtual mustacheable =
  object
    method virtual to_mustache : (string * Mustache.Json.value) list
  end

let forgettable_string key xs =
  List.find_map
    (fun (k, v) ->
      if String.equal k key
      then (
        match v with
        | `String res -> Some res
        | _ -> None)
      else None)
    xs
  |> Validate.valid
;;

let required_string key xs =
  let open Validate.Monad in
  forgettable_string key xs
  >>= function
  | None -> Error.(to_validate $ Missing_field key)
  | Some x -> Validate.valid x
;;

let required_date key xs =
  let open Validate.Monad in
  required_string key xs
  >>= fun x ->
  try Scanf.sscanf x "%04d-%02d-%02d" (fun y m d -> return (y, m, d)) with
  | _ -> Error.(to_validate $ Invalid_field key)
;;

let is_string = function
  | `String _ -> true
  | _ -> false
;;

let forgettable_string_list key xs =
  List.find_map
    (fun (k, v) ->
      if String.equal k key
      then (
        match v with
        | `A res when List.for_all is_string res -> Some res
        | _ -> None)
      else None)
    xs
  |> (function
       | None -> []
       | Some x ->
         List.filter_map
           (function
             | `String k -> Some k
             | _ -> None)
           x)
  |> Validate.valid
;;

module Base = struct
  class obj ?page_title () =
    object
      inherit mustacheable

      val page_title : string option = page_title

      method get_page_title = page_title

      method to_mustache =
        match page_title with
        | None -> []
        | Some title -> [ "page_title", `String title ]
    end

  let to_mustache x = x#to_mustache

  let from_yaml = function
    | `String title -> Validate.valid (new obj ~page_title:title ())
    | `O xs ->
      List.find_map
        (fun (x, xs) ->
          let key = String.lowercase_ascii x in
          if List.mem key [ "title"; "page_title" ]
          then (
            match xs with
            | `String title -> Some title
            | _ -> None)
          else None)
        xs
      |> (function
      | page_title -> Validate.valid (new obj ?page_title ()))
    | _ -> Validate.valid (new obj ())
  ;;

  let from_string str =
    match str with
    | None -> Validate.valid (new obj ())
    | Some x ->
      Result.fold ~ok:from_yaml ~error:(function `Msg e ->
          Error.(to_validate $ Yaml e))
      $ Yaml.of_string x
  ;;

  let equal a b = Option.equal String.equal a#get_page_title b#get_page_title
  let repr = [ "page_title?" ]

  let pp ppf x =
    Format.fprintf ppf "Metadata.base (title = %a)"
    $ Preface.Option.pp Format.pp_print_string
    $ x#get_page_title
  ;;

  let page_title obj = obj#get_page_title
end

module Article = struct
  class obj ?page_title ?(tags = []) date article_title article_synopsis =
    object
      inherit
        Base.obj
          ~page_title:(Option.value ~default:article_title page_title)
          () as super

      val tags : string list = List.map String.lowercase_ascii tags

      val date : date = date

      val article_title = article_title

      val article_synopsis = article_synopsis

      method get_tags = tags

      method get_date = date

      method get_article_title = article_title

      method get_article_synopsis = article_synopsis

      method! to_mustache =
        let base = super#to_mustache in
        let tags = "tags", `A (List.map (fun x -> `String x) tags)
        and date = "date", `String (date_to_string date)
        and article_title = "article_title", `String article_title
        and article_synopsis = "article_synopsis", `String article_synopsis in
        tags :: date :: article_title :: article_synopsis :: base
    end

  let mk page_title tags date article_title article_synopsis =
    new obj ?page_title ~tags date article_title article_synopsis
  ;;

  let equal a b =
    Base.equal a b
    && Preface.List.equal String.equal a#get_tags b#get_tags
    && date_eq a#get_date b#get_date
    && String.equal a#get_article_title b#get_article_title
    && String.equal a#get_article_synopsis b#get_article_synopsis
  ;;

  let pp ppf x =
    let title =
      Format.asprintf "page_title = %a"
      $ Preface.Option.pp Format.pp_print_string
      $ x#get_page_title
    in
    let tags =
      Format.asprintf "tags = %a"
      $ Preface.List.pp Format.pp_print_string
      $ x#get_tags
    in
    let date = "date = " ^ date_to_string x#get_date in
    let article_title = "article_title =" ^ x#get_article_title in
    let article_synopsis = "article_synopsis =" ^ x#get_article_synopsis in
    Format.fprintf
      ppf
      "Metadata.article (%s;%s;%s;%s;%s)"
      title
      tags
      date
      article_title
      article_synopsis
  ;;

  let to_mustache x = x#to_mustache

  let repr =
    [ "page_title?"; "tags?"; "date"; "article_title"; "article_synopsis" ]
  ;;

  let from_yaml = function
    | `O xs ->
      let open Validate.Applicative in
      let obj = List.map (fun (x, y) -> String.lowercase_ascii x, y) xs in
      mk
      <$> forgettable_string "page_title" obj
      <*> forgettable_string_list "tags" obj
      <*> required_date "date" obj
      <*> required_string "article_title" obj
      <*> required_string "article_synopsis" obj
    | _ -> Error.(to_validate $ Required_metadata repr)
  ;;

  let from_string str =
    match str with
    | None -> Error.(to_validate $ Required_metadata repr)
    | Some x ->
      Result.fold ~ok:from_yaml ~error:(function `Msg e ->
          Error.(to_validate $ Yaml e))
      $ Yaml.of_string x
  ;;

  let page_title = Base.page_title
  let tags obj = obj#get_tags
  let date obj = obj#get_date
  let article_title obj = obj#get_article_title
  let article_synopsis obj = obj#get_article_synopsis
end

module Articles = struct
  type obj = (Article.obj * string) list

  let make o = o

  let cmp dec (a, b, c) (x, y, z) =
    let f a b c = (a * 10000) + (b * 100) + c in
    let res = Int.compare (f a b c) (f x y z) in
    if dec then ~-res else res
  ;;

  let sort_by_date ?(decreasing = true) obj =
    List.sort
      (fun (l, _) (r, _) -> cmp decreasing (Article.date l) (Article.date r))
      obj
  ;;

  let to_mustache obj =
    [ ( "articles"
      , `A
          (List.map
             (fun (m, url) ->
               `O (("url", `String url) :: Article.to_mustache m))
             obj) )
    ]
  ;;
end
