open Wordpress

let dest = "_build"
let track_binary_update = Build.watch Sys.argv.(0)

let rule_css =
  let open Build in
  process_files [ "css/" ] (with_extension "css")
  $ fun path -> copy_file path ~into:("css" |> into dest)
;;

let rule_images =
  let open Build in
  process_files
    [ "."; "images" ]
    Preface.Predicate.(with_extension "svg" || with_extension "png")
  $ fun path -> copy_file path ~into:("img" |> into dest)
;;

let rule_pages =
  let open Build in
  process_files [ "pages/" ] (with_extension "md")
  $ fun path ->
  create_file
    (basename $ replace_extension path "html" |> into dest)
    (track_binary_update
    >>> read_file "tpl/header.html"
    >>> (pipe_content path >>> process_markdown)
    >>> pipe_content "tpl/footer.html")
;;

let () =
  debug "Let's start my website generation!"
  >> rule_css
  >> rule_images
  >> rule_pages
  >> debug "Everything is done!"
  |> execute
;;
