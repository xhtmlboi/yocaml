class resolver ~source ~target =
  object (self)
    val get_source : Yocaml.Path.t = source
    val get_target : Yocaml.Path.t = target
    method source = get_source
    method target = Yocaml.Path.(get_target / "_www")
    method cache = Yocaml.Path.(self#target / ".cache")
    method content = Yocaml.Path.(self#source / "content")
    method templates = Yocaml.Path.(self#content / "templates")
    method liquid_articles = Yocaml.Path.(self#target / "liquid-articles")

    method as_liquid_article path =
      path
      |> Yocaml.Path.move ~into:self#liquid_articles
      |> Yocaml.Path.change_extension "html"

    method as_template path = Yocaml.Path.(self#templates / path)
  end

let liquid_article (resolver : resolver) file =
  Yocaml.Action.Static.write_file_with_metadata
    (resolver#as_liquid_article file)
    Yocaml.Task.(
      Yocaml_yaml.Pipeline.read_file_with_metadata
        (module Yocaml.Archetype.Article)
        file
      >>> Yocaml_cmarkit.content_to_html ()
      >>> Yocaml_liquid.Pipeline.as_template
            (module Yocaml.Archetype.Article)
            (resolver#as_template "article.liquid")
      >>> Yocaml_liquid.Pipeline.as_template
            (module Yocaml.Archetype.Article)
            (resolver#as_template "layout.liquid"))

let liquid_articles (resolver : resolver) =
  Yocaml.Batch.iter_files
    ~where:(Yocaml.Path.has_extension "md")
    resolver#content (liquid_article resolver)

let program (resolver : resolver) () =
  let open Yocaml.Eff in
  let* () = logf ~level:`Debug "Trigger in %a" Yocaml.Path.pp resolver#source in
  Yocaml.Action.with_cache ~on:`Target resolver#cache (liquid_articles resolver)

module R = Yocaml.Runtime.Make (Runtime)

let () =
  let () = Array.iter print_endline Sys.argv in
  let cwd = Yocaml.Path.rel [] in
  let resolver = new resolver ~source:cwd ~target:cwd in
  let () = Yocaml_runtime.Log.setup ~level:`Debug () in
  R.run (program resolver)
