type t = string

let target_is_up_to_date = Format.asprintf "Updated: %s"

let oh_dear_there_is_an_error x =
  Format.asprintf "Oh dear, there is an error [%a]" x
;;

let crap_there_is_an_error = oh_dear_there_is_an_error Error.pp
let crap_there_is_an_exception = oh_dear_there_is_an_error Preface.Exn.pp
let target_need_to_be_built = Format.asprintf "Fresh: %s"
