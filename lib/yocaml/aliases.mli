(** Some type aliases to clarify the signatures of some functions. *)

(** At the moment, I don't have an efficient abstraction to describe a file
    path. It's a bit sad but that's life... *)
type filepath = string

(** At the moment, I don't have an efficient abstraction to describe a
    directory path. It's a bit sad but that's life... *)
type directory = string

(** [e] is a type that only serves to mark the ghost type of the effects
    definition. This is a bit shorter than writing [unit]. *)
type e

(** Description of a log level... which will probably be useful one day... *)
type log_level =
  | Trace
  | Debug
  | Info
  | Warning
  | Alert
