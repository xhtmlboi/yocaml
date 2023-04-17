open Yocaml

let to_html ~strict =
  let open Preface.Fun in
  Build.arrow $ Cmarkit_html.of_doc ~safe:false % Cmarkit.Doc.of_string ~strict
;;

let content_to_html ?(strict= true) () = Build.snd (to_html ~strict)
