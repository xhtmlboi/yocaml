open Util

module type INJECTABLE = sig
  type t

  val inject
    :  (module Key_value.DESCRIBABLE with type t = 'a)
    -> t
    -> (string * 'a) list
end

module type RENDERABLE = sig
  type t

  val to_string : ?strict:bool -> (string * t) list -> string -> string

  include Key_value.DESCRIBABLE with type t := t
end

module type VALIDABLE = sig
  type t

  val from_string : string -> t Validate.t

  include Key_value.VALIDATOR with type t := t
end

module type READABLE = sig
  type t

  val from_string : (module VALIDABLE) -> string option -> t Validate.t
end

module Date = struct
  include Date

  let from (type a) (module V : VALIDABLE with type t = a) obj =
    let open Validate.Monad in
    V.string obj >>= Date.from_string
  ;;

  let inject (type a) (module D : Key_value.DESCRIBABLE with type t = a) date =
    let (y, m, d), time = to_pair date in
    [ "canonical", D.string $ to_string date
    ; "year", D.string $ string_of_int y
    ; "month", D.string (string_of_int $ Date.month_to_int m)
    ; "day", D.string $ string_of_int d
    ; "month_repr", D.string $ month_to_string m
    ]
    @ Option.fold
        ~none:[ "hour", D.null; "min", D.null; "sec", D.null ]
        ~some:(fun (h, m, s) ->
          [ "hour", D.string $ string_of_int h
          ; "min", D.string $ string_of_int m
          ; "sec", D.string $ string_of_int s
          ])
        time
  ;;
end

module Page = struct
  type t =
    { title : string option
    ; description : string option
    }

  let make title description = { title; description }

  let inject
      (type a)
      (module D : Key_value.DESCRIBABLE with type t = a)
      { title; description }
    =
    [ "title", Option.fold ~none:D.null ~some:D.string title
    ; "description", Option.fold ~none:D.null ~some:D.string description
    ]
  ;;

  let from_string (module V : VALIDABLE) = function
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

  let from_string (module V : VALIDABLE) = function
    | None -> Validate.error $ Error.Required_metadata [ "Article" ]
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

  let inject
      (type a)
      (module D : Key_value.DESCRIBABLE with type t = a)
      { article_title; article_description; tags; date; title; description }
    =
    [ "article_title", D.string article_title
    ; "article_description", D.string article_description
    ; "tags", D.list (List.map D.string tags)
    ; "date", D.object_ $ Date.inject (module D) date
    ]
    @ Page.inject (module D) (Page.make title description)
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

  let inject
      (type a)
      (module D : Key_value.DESCRIBABLE with type t = a)
      { articles; title; description }
    =
    ( "articles"
    , D.list
        (List.map
           (fun (article, url) ->
             D.object_
               (("url", D.string url) :: Article.inject (module D) article))
           articles) )
    :: (Page.inject (module D) $ Page.make title description)
  ;;
end
