type t = string

let target_is_up_to_date = Format.asprintf "%s\tis up to date."

let crap_there_is_an_error =
  Format.asprintf "Oh dear, there is an error [%a]" Error.pp
;;

let target_need_to_be_built = Format.asprintf "%s\t need to be built."
