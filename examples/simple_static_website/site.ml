open Wordpress

let dest = "_build"

let () =
  let open Preface.Fun.Infix in
  run
  $ sequence
      (Effect.return ())
      (Effect.read_child_files "pages" (( = ) ".html" % Filename.extension))
      (fun path ->
        let open Build in
        create_file (Filename.basename path |> into dest)
        $ read_file "tpl/header.html"
          %> concat_content path
          %> concat_content "tpl/footer.html")
;;
