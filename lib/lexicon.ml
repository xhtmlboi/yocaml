type t = string

let target_is_up_to_date = Format.asprintf "Updated: %s"

let crap_there_is_an_error =
  Format.asprintf "Oh dear, there is an error [%a]" Error.pp
;;

let target_need_to_be_built = Format.asprintf "Fresh: %s"
