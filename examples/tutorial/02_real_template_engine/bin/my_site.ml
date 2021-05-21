open Wordpress

let destination = "_build"
let track_binary_update = Build.watch Sys.argv.(0)

let task =
  process_files [ "pages/" ] (with_extension "html") (fun file ->
      let target = basename file |> into destination in
      let open Build in
      create_file
        target
        (track_binary_update
        >>> read_file_with_metadata (module Metadata.Page) file
        >>> apply_as_template (module Metadata.Page) "templates/layout.html"
        >>^ Stdlib.snd))
;;

let () = execute task
