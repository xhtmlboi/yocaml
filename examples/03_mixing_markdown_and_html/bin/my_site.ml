open Yocaml

let destination = "_build"
let track_binary_update = Build.watch Sys.argv.(0)

let may_process_markdown file =
  let open Build in
  if with_extension "md" file
  then Yocaml_markdown.content_to_html ()
  else arrow Fun.id
;;

let task =
  process_files
    [ "pages/" ]
    (fun f -> with_extension "html" f || with_extension "md" f)
    (fun file ->
      let fname = basename file |> into destination in
      let target = replace_extension fname "html" in
      let open Build in
      create_file
        target
        (track_binary_update
        >>> read_file_with_metadata (module Metadata.Page) file
        >>> may_process_markdown file
        >>> apply_as_template (module Metadata.Page) "templates/layout.html"
        >>^ Stdlib.snd))
;;

let () = Yocaml_unix.execute task
