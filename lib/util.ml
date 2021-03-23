let into = Filename.concat
let ( $ ) = ( @@ )

let with_extension ext path =
  let e = Filename.extension path in
  String.equal e $ "." ^ ext
;;

let basename = Filename.basename
let add_extension f extension = f ^ "." ^ extension
let remove_extension = Filename.remove_extension

let replace_extension f =
  let p = remove_extension f in
  add_extension p
;;
