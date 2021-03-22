open Wordpress

let run_for page =
  let open Build in
  run
    (page ^ ".html")
    (read_file "tpl/header.html"
    >>> concat_content ~separator:"\n" ("pages/" ^ page ^ ".html")
    >>> concat_content ~separator:"\n" "tpl/footer.html")
;;

let generator =
  let open Effect.Monad in
  let* () = run_for "index" in
  let* () = run_for "about" in
  run_for "lipsum"
;;

let () = Generator.run generator
