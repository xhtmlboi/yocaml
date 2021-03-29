open Wordpress

let dest = "_build"
let articles_repository = [ "articles" ]
let is_markdown = with_extension "md"
let is_css = with_extension "css"
let apply f = f ()

let is_image =
  Preface.Predicate.(with_extension "svg" || with_extension "png")
;;

let track_binary_update = Build.watch Sys.argv.(0)

let process_css =
  let open Build in
  process_files [ "../simple_static_website_using_omd/css/" ] is_css
  $ fun path -> copy_file path ~into:("css" |> into dest)
;;

let process_images =
  let open Build in
  process_files
    [ "../simple_static_website_using_omd"
    ; "../simple_static_website_using_omd/images"
    ]
    is_image
  $ fun path -> copy_file path ~into:("img" |> into dest)
;;

let get_articles = process_files articles_repository is_markdown

let article_url src =
  let base_name = basename $ replace_extension src "html" in
  into "articles" base_name
;;

let article src =
  let open Build in
  track_binary_update
  >>> read_file_with_metadata (module Metadata.Article) src
  >>> snd process_markdown
  >>> apply_as_template (module Metadata.Article) "article.html"
  >>> apply_as_template (module Metadata.Article) "layout.html"
;;

let process_articles =
  get_articles
  $ fun src ->
  Build.(
    create_file
      (into dest $ article_url src)
      (article src >>^ Preface.Tuple.snd))
;;

let index =
  let page_title = "Index" in
  let open Build in
  let* deps = read_child_files "articles" is_markdown in
  let task, effects =
    fold_dependencies
      (List.map (fun p -> article p >>^ fun (m, _) -> m, article_url p) deps)
  in
  create_file
    (into dest "index.html")
    (task (fun () ->
         let+ metadata = Traverse.sequence $ List.map apply effects in
         let articles =
           Metadata.Articles.(
             make ~title:page_title metadata |> sort_articles_by_date)
         in
         without_body articles)
    >>> apply_as_template (module Metadata.Articles) "index.html"
    >>> apply_as_template (module Metadata.Articles) "layout.html"
    >>^ Preface.Tuple.snd)
;;

let () =
  let program =
    let* () = process_css in
    let* () = process_images in
    let* () = process_articles in
    index
  in
  execute program
;;
