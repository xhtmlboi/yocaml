open Yocaml
module Store = Irmin_unix.Git.FS.KV (Irmin.Contents.String)

let destination = "_build"
let css_destination = "css"
let images_destination = "images"
let config = Irmin_git.config ~bare:true destination

let may_process_markdown file =
  let open Build in
  if with_extension "md" file
  then Yocaml_markdown.content_to_html ()
  else arrow Fun.id
;;

let pages =
  process_files
    [ "pages/" ]
    (fun f -> with_extension "html" f || with_extension "md" f)
    (fun file ->
      let fname = basename file in
      let target = replace_extension fname "html" in
      let open Build in
      create_file
        target
        (Yocaml_yaml.read_file_with_metadata (module Metadata.Page) file
        >>> may_process_markdown file
        >>> Yocaml_jingoo.apply_as_template
              (module Metadata.Page)
              "templates/layout.html"
        >>^ Stdlib.snd))
;;

let article_destination file =
  let fname = basename file |> into "articles" in
  replace_extension fname "html"
;;

let articles =
  process_files [ "articles/" ] (with_extension "md") (fun file ->
      let open Build in
      let target = article_destination file in
      create_file
        target
        (Yocaml_yaml.read_file_with_metadata (module Metadata.Article) file
        >>> Yocaml_markdown.content_to_html ()
        >>> Yocaml_jingoo.apply_as_template
              (module Metadata.Article)
              "templates/article.html"
        >>> Yocaml_jingoo.apply_as_template
              (module Metadata.Article)
              "templates/layout.html"
        >>^ Stdlib.snd))
;;

let css =
  process_files [ "css/" ] (with_extension "css") (fun file ->
      Build.copy_file file ~into:css_destination)
;;

let images =
  let open Preface.Predicate in
  process_files
    [ "../04_first_blog/images" ]
    (with_extension "svg" || with_extension "png" || with_extension "gif")
    (fun file -> Build.copy_file file ~into:images_destination)
;;

let index =
  let open Build in
  let* articles =
    collection
      (read_child_files "articles/" (with_extension "md"))
      (fun source ->
        Yocaml_yaml.read_file_with_metadata (module Metadata.Article) source
        >>^ fun (x, _) -> x, article_destination source)
      (fun x meta content ->
        x
        |> Metadata.Articles.make
             ?title:(Metadata.Page.title meta)
             ?description:(Metadata.Page.description meta)
        |> Metadata.Articles.sort_articles_by_date
        |> fun x -> x, content)
  in
  create_file
    "index.html"
    (Yocaml_yaml.read_file_with_metadata (module Metadata.Page) "index.md"
    >>> Yocaml_markdown.content_to_html ()
    >>> articles
    >>> Yocaml_jingoo.apply_as_template
          (module Metadata.Articles)
          "templates/list.html"
    >>> Yocaml_jingoo.apply_as_template
          (module Metadata.Articles)
          "templates/layout.html"
    >>^ Stdlib.snd)
;;

let () =
  Yocaml_irmin.execute
    (module Yocaml_unix)
    (module Store)
    (module Lwt_main)
    ~author:"xvw"
    ~author_email:"xaviervdw@gmail.com"
    config
    (pages >> css >> images >> articles >> index)
;;
