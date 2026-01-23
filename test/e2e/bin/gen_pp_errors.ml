module Test_Article = Test_article

class resolver ~source ~target =
  object (self)
    val get_source : Yocaml.Path.t = source
    val get_target : Yocaml.Path.t = target
    method source = get_source
    method target = Yocaml.Path.(get_target / "_www")
    method cache = Yocaml.Path.(self#target / ".cache")
    method templates = Yocaml.Path.(self#source / "content" / "templates")
    method articles = Yocaml.Path.(self#target / "articles")

    method as_article path =
      path
      |> Yocaml.Path.move ~into:self#articles
      |> Yocaml.Path.change_extension "html"

    method as_template path = Yocaml.Path.(self#templates / path)
  end

let article (resolver : resolver) file =
  Yocaml.Action.Static.write_file_with_metadata (resolver#as_article file)
    Yocaml.Task.(
      Yocaml_yaml.Pipeline.read_file_with_metadata (module Test_Article) file
      >>> Yocaml_cmarkit.content_to_html ()
      >>> Yocaml_jingoo.Pipeline.as_template
            (module Test_Article)
            (resolver#as_template "article.html")
      >>> Yocaml_jingoo.Pipeline.as_template
            (module Test_Article)
            (resolver#as_template "layout.html"))

let program (resolver : resolver) file () =
  let open Yocaml.Eff in
  let* () = logf ~level:`Debug "Trigger in %a" Yocaml.Path.pp resolver#source in
  Yocaml.Action.with_cache ~on:`Target resolver#cache (article resolver file)

module R = Yocaml.Runtime.Make (Runtime)

let () =
  let () = Array.iter print_endline Sys.argv in
  let cwd = Yocaml.Path.rel [] in
  let file =
    match Array.to_list Sys.argv with
    | _ :: file :: _ -> Yocaml.Path.rel [ file ]
    | _ -> failwith "Usage: gen_pp_errors.exe <path-to-markdown-file>"
  in
  let resolver = new resolver ~source:cwd ~target:cwd in
  let () = Yocaml_runtime.Log.setup ~level:`Debug () in
  R.run (program resolver file)
