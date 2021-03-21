type t = string

let target_is_up_to_date = Format.asprintf "[%s] is up to date."

let crap_there_is_an_error =
  Format.asprintf "Oh dear, there is an error [%a]" Error.pp
;;
