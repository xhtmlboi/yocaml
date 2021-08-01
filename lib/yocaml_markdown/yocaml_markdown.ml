open Yocaml

let to_html =
  let open Preface.Fun in
  Build.arrow $ Omd.to_html % Omd.of_string
;;

let content_to_html () = Build.snd to_html
