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
    method pages = Yocaml.Path.(self#target / "articles-with-applicative-read")

    method as_article path =
      path
      |> Yocaml.Path.move ~into:self#articles
      |> Yocaml.Path.change_extension "html"

    method as_page path =
      path
      |> Yocaml.Path.move ~into:self#pages
      |> Yocaml.Path.change_extension "html"

    method as_template path = Yocaml.Path.(self#templates / path)
  end

let css (resolver : resolver) =
  Yocaml.Action.Static.write_file
    Yocaml.Path.(resolver#target / "style.css")
    (Yocaml.Pipeline.pipe_files ~separator:"\n"
       Yocaml.Path.
         [ resolver#content / "global.css"; resolver#content / "specific.css" ])

let page (resolver : resolver) file =
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
  Yocaml.Action.Static.write_file (resolver#as_page file) pipeline

let pages resolver =
  Yocaml.Batch.iter_files
    ~where:(Yocaml.Path.has_extension "md")
    resolver#content (page resolver)

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
  >>= pages resolver
  >>= Yocaml.Action.store_cache ~on:`Target resolver#cache

let () =
  let () = Array.iter print_endline Sys.argv in
  let cwd = Yocaml.Path.rel [] in
  let resolver = new resolver ~source:cwd ~target:cwd in
  Yocaml_unix.run ~level:`Debug (program resolver)
