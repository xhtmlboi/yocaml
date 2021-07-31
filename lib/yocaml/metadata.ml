open Util

module type INJECTABLE = sig
  type t

  val to_mustache : t -> (string * Mustache.Json.value) list
end

module type PROVIDER = sig
  type t

  val from_string : string -> t Validate.t

  include Key_value.KEY_VALUE_VALIDATOR with type t := t
end

module type PARSABLE = sig
  type t

  val from_string : (module PROVIDER) -> string option -> t Validate.t
end

module Date = struct
  type t = int * int * int

  let make y m d = y, m, d
  let pp ppf (y, m, d) = Format.fprintf ppf "%04d-%02d-%02d" y m d
  let to_string d = Format.asprintf "%a" pp d

  let equal (y, m, d) (yy, mm, dd) =
    Preface.List.equal Int.equal [ y; m; d ] [ yy; mm; dd ]
  ;;

  let compare (a, b, c) (x, y, z) =
    let f a b c = (a * 10000) + (b * 100) + c in
    Int.compare (f a b c) (f x y z)
  ;;

  let from_string str =
    let open Try.Monad in
    try Scanf.sscanf str "%04d-%02d-%02d" (fun y m d -> return (y, m, d)) with
    | _ -> Error.(to_try $ Invalid_date str)
  ;;

  let from (type a) (module V : PROVIDER with type t = a) obj =
    let open Validate.Monad in
    let open Preface.Fun.Infix in
    V.string obj >>= Try.to_validate % from_string
  ;;

  let to_mustache = function
    | (y, m, d) as date ->
      [ "canonical", `String (to_string date)
      ; "year", `String (string_of_int y)
      ; "month", `String (string_of_int m)
      ; "day", `String (string_of_int d)
      ]
  ;;
end

module Page = struct
  type t =
    { title : string option
    ; description : string option
    }

  let make title description = { title; description }

  let to_mustache { title; description } =
    [ "title", Option.fold ~none:`Null ~some:(fun x -> `String x) title
    ; ( "description"
      , Option.fold ~none:`Null ~some:(fun x -> `String x) description )
    ]
  ;;

  let from_string (module V : PROVIDER) = function
    | None -> Validate.valid $ make None None
    | Some str ->
      let open Validate.Monad in
      V.from_string str
      >>= V.object_and (fun assoc ->
              let open Validate.Applicative in
              make
              <$> V.(optional_assoc string) "title" assoc
              <*> V.(optional_assoc string) "description" assoc)
      |> (function
      | Preface.Validation.Invalid _ -> Validate.valid $ make None None
      | x -> x)
  ;;

  let equal a b =
    Option.equal String.equal a.title b.title
    && Option.equal String.equal a.description b.description
  ;;

  let pp ppf { title; description } =
    let p_opt = Preface.Option.pp Format.pp_print_string in
    Format.fprintf
      ppf
      "{title = %a; description = %a}"
      p_opt
      title
      p_opt
      description
  ;;

  let title p = p.title
  let description p = p.description
  let set_title new_title p = { p with title = new_title }
  let set_description new_desc p = { p with description = new_desc }
end

module Article = struct
  type t =
    { article_title : string
    ; article_description : string
    ; tags : string list
    ; date : Date.t
    ; title : string option
    ; description : string option
    }

  let make article_title article_description tags date title description =
    { article_title
    ; article_description
    ; tags = List.map String.lowercase_ascii tags
    ; date
    ; title
    ; description
    }
  ;;

  let from_string (module V : PROVIDER) = function
    | None -> Validate.error $ Error.Invalid_metadata "Article"
    | Some str ->
      let open Validate.Monad in
      V.from_string str
      >>= V.object_and (fun assoc ->
              let open Validate.Applicative in
              make
              <$> V.(required_assoc string) "article_title" assoc
              <*> V.(required_assoc string) "article_description" assoc
              <*> V.(optional_assoc_or ~default:[] (list_of string))
                    "tags"
                    assoc
              <*> V.required_assoc (Date.from (module V)) "date" assoc
              <*> V.(optional_assoc string) "title" assoc
              <*> V.(optional_assoc string) "description" assoc)
  ;;

  let to_mustache
      { article_title; article_description; tags; date; title; description }
    =
    [ "article_title", `String article_title
    ; "article_description", `String article_description
    ; "tags", `A (List.map (fun x -> `String x) tags)
    ; "date", `O (Date.to_mustache date)
    ; "title", Option.fold ~none:`Null ~some:(fun x -> `String x) title
    ; ( "description"
      , Option.fold ~none:`Null ~some:(fun x -> `String x) description )
    ]
  ;;

  let pp
      ppf
      { article_title; article_description; tags; date; title; description }
    =
    let p_opt = Preface.Option.pp Format.pp_print_string in
    Format.fprintf
      ppf
      "{article_title = %s; article_description = %s; date = %a; tags = %a; \
       title = %a; description = %a}"
      article_title
      article_description
      Date.pp
      date
      (Preface.List.pp Format.pp_print_string)
      tags
      p_opt
      title
      p_opt
      description
  ;;

  let equal a b =
    String.equal a.article_title b.article_title
    && String.equal a.article_description b.article_description
    && Date.equal a.date b.date
    && Preface.List.equal String.equal a.tags b.tags
    && Preface.Option.equal String.equal a.title b.title
    && Preface.Option.equal String.equal a.description b.description
  ;;

  let article_title p = p.article_title
  let article_description p = p.article_description
  let tags p = p.tags
  let date p = p.date
  let title p = p.title
  let description p = p.description
  let set_article_title new_title p = { p with article_title = new_title }

  let set_article_description new_desc p =
    { p with article_description = new_desc }
  ;;

  let set_date new_date p = { p with date = new_date }
  let set_tags new_tags p = { p with tags = new_tags }
  let set_title new_title p = { p with title = new_title }
  let set_description new_desc p = { p with description = new_desc }
  let compare_by_date a b = Date.compare a.date b.date
end

module Articles = struct
  type t =
    { articles : (Article.t * string) list
    ; title : string option
    ; description : string option
    }

  let make ?title ?description articles = { articles; title; description }
  let title p = p.title
  let description p = p.description
  let articles p = p.articles
  let set_articles new_articles p = { p with articles = new_articles }
  let set_title new_title p = { p with title = new_title }
  let set_description new_desc p = { p with description = new_desc }

  let sort_articles_by_date ?(decreasing = true) p =
    set_articles
      (List.sort
         (fun (a, _) (b, _) ->
           let r = Article.compare_by_date a b in
           if decreasing then ~-r else r)
         p.articles)
      p
  ;;

  let to_mustache { articles; title; description } =
    ( "articles"
    , `A
        (List.map
           (fun (article, url) ->
             `O (("url", `String url) :: Article.to_mustache article))
           articles) )
    :: (Page.to_mustache $ Page.make title description)
  ;;
end
