open Wordpress

let dest = "_build"

let create_page page =
  let open Build in
  create_file (page ^ ".html" |> into dest)
  $ read_file "tpl/header.html"
    %> concat_content ("pages/" ^ page ^ ".html")
    %> concat_content "tpl/footer.html"
;;

let generator =
  let open Effect.Monad in
  let* () = create_page "index" in
  let* () = create_page "about" in
  create_page "lipsum"
;;

let () = Generator.run generator
