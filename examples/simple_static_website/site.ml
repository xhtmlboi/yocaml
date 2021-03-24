open Wordpress

let dest = "_build"

let () =
  let program =
    let* () = debug "Let's start my website generation!" in
    let* () =
      process_files [ "pages/" ] (with_extension "html")
      $ fun path ->
      Build.(
        create_file (basename path |> into dest)
        $ read_file "tpl/header.html"
          %> pipe_content path
          %> pipe_content "tpl/footer.html")
    in
    debug "Everything is done!"
  in
  execute program
;;
