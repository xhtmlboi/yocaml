class resolver ~source ~target =
  object (self)
    val get_source : Yocaml.Path.t = source
    val get_target : Yocaml.Path.t = target
    method source = get_source
    method target = Yocaml.Path.(get_target / "_www")
    method cache = Yocaml.Path.(self#target / ".cache")
    method content = Yocaml.Path.(self#source / "content")
    method templates = Yocaml.Path.(self#content / "templates")
    method articles = Yocaml.Path.(self#target / "articles")

    method articles_aux_1 =
      Yocaml.Path.(self#target / "articles-with-applicative-read")

    method articles_aux_2 =
      Yocaml.Path.(self#target / "articles-with-applicative-read-2")

    method as_article path =
      path
      |> Yocaml.Path.move ~into:self#articles
      |> Yocaml.Path.change_extension "html"

    method as_articles_aux_1 path =
      path
      |> Yocaml.Path.move ~into:self#articles_aux_1
      |> Yocaml.Path.change_extension "html"

    method as_articles_aux_2 path =
      path
      |> Yocaml.Path.move ~into:self#articles_aux_2
      |> Yocaml.Path.change_extension "html"

    method as_template path = Yocaml.Path.(self#templates / path)
  end

let css (resolver : resolver) =
  Yocaml.Action.Static.write_file
    Yocaml.Path.(resolver#target / "style.css")
    (Yocaml.Pipeline.pipe_files ~separator:"\n"
       Yocaml.Path.
         [ resolver#content / "global.css"; resolver#content / "specific.css" ])

let article_aux_1 (resolver : resolver) file =
  let pipeline =
    let open Yocaml.Task in
    let+ metadata, content =
      Yocaml_yaml.Pipeline.read_file_with_metadata
        (module Yocaml.Archetype.Article)
        file
    and+ tpl_article =
      Yocaml_jingoo.read_template (resolver#as_template "article.html")
    and+ tpl_layout =
      Yocaml_jingoo.read_template (resolver#as_template "layout.html")
    in
    content
    |> Yocaml_markdown.from_string_to_html
    |> tpl_article ~metadata (module Yocaml.Archetype.Article)
    |> tpl_layout ~metadata (module Yocaml.Archetype.Article)
  in
  Yocaml.Action.Static.write_file (resolver#as_articles_aux_1 file) pipeline

let article_aux_2 (resolver : resolver) file =
  let pipeline =
    let open Yocaml.Task in
    let+ metadata, content =
      Yocaml_yaml.Pipeline.read_file_with_metadata
        (module Yocaml.Archetype.Article)
        file
    and+ templates =
      Yocaml_jingoo.read_templates
        [
          resolver#as_template "article.html"
        ; resolver#as_template "layout.html"
        ]
    in
    content
    |> Yocaml_markdown.from_string_to_html
    |> templates ~metadata (module Yocaml.Archetype.Article)
  in
  Yocaml.Action.Static.write_file (resolver#as_articles_aux_2 file) pipeline

let articles_aux_2 resolver =
  Yocaml.Batch.iter_files
    ~where:(Yocaml.Path.has_extension "md")
    resolver#content (article_aux_2 resolver)

let articles_aux_1 resolver =
  Yocaml.Batch.iter_files
    ~where:(Yocaml.Path.has_extension "md")
    resolver#content (article_aux_1 resolver)

let article (resolver : resolver) file =
  Yocaml.Action.Static.write_file_with_metadata (resolver#as_article file)
    Yocaml.Task.(
      Yocaml_yaml.Pipeline.read_file_with_metadata
        (module Yocaml.Archetype.Article)
        file
      >>> Yocaml_cmarkit.content_to_html ()
      >>> Yocaml_jingoo.Pipeline.as_template
            (module Yocaml.Archetype.Article)
            (resolver#as_template "article.html")
      >>> Yocaml_jingoo.Pipeline.as_template
            (module Yocaml.Archetype.Article)
            (resolver#as_template "layout.html"))

let articles (resolver : resolver) =
  Yocaml.Batch.iter_files
    ~where:(Yocaml.Path.has_extension "md")
    resolver#content (article resolver)

let program (resolver : resolver) () =
  let open Yocaml.Eff in
  let* () = logf ~level:`Debug "Trigger in %a" Yocaml.Path.pp resolver#source in
  Yocaml.Action.restore_cache ~on:`Target resolver#cache
  >>= css resolver
  >>= articles resolver
  >>= articles_aux_1 resolver
  >>= articles_aux_2 resolver
  >>= Yocaml.Action.store_cache ~on:`Target resolver#cache

let () =
  let () = Array.iter print_endline Sys.argv in
  let cwd = Yocaml.Path.rel [] in
  let resolver = new resolver ~source:cwd ~target:cwd in
  Yocaml_unix.run ~level:`Debug (program resolver)
