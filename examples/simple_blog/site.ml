open Wordpress

let dest = "_build"
let track_binary_update = Build.watch Sys.argv.(0)

let process_css =
  let open Build in
  process_files
    [ "../simple_static_website_using_omd/css/" ]
    (with_extension "css")
  $ fun path -> copy_file path ~into:("css" |> into dest)
;;

let process_images =
  let open Preface.Predicate in
  let open Build in
  process_files
    [ "../simple_static_website_using_omd"
    ; "../simple_static_website_using_omd/images"
    ]
    (with_extension "svg" || with_extension "png")
  $ fun path -> copy_file path ~into:("img" |> into dest)
;;

let process_articles =
  process_files [ "articles" ] (with_extension "md")
  $ fun path ->
  let open Build in
  let base_name = basename $ replace_extension path "html" in
  let dest = into dest (into "articles" base_name) in
  create_file dest
  $ (track_binary_update
    >>> read_file_with_metadata (module Metadata.Article) path
    >>> snd process_markdown
    >>> apply_as_template (module Metadata.Article) "article.html"
    >>> apply_as_template (module Metadata.Article) "layout.html"
    >>^ Preface.Tuple.snd)
;;

let () =
  let program =
    let* () = process_css in
    let* () = process_images in
    process_articles
  in
  execute program
;;
