(** A centralisation of feedback messages. *)

(** As I have already quietly mentioned, feedback is important to the user. So
    this module essentially exposes functions to produce strings of
    characters... for example, "{e Ah, this file was successfully created}" or
    "{e Hmm, the task failed miserably with 'the error in question'}". *)

(** {1 Types}

    At the moment it would seem (obviously) that a string is an ideal tool to
    display messages... *)

type t = string

(** {1 Messages} *)

(** Occurs when a target need to be built. *)
val target_need_to_be_built : Filepath.t -> t

(** Occurs when a target is up to date. *)
val target_is_up_to_date : Filepath.t -> t

(** Occurs when there is an error. *)
val crap_there_is_an_error : Error.t -> t

(** Occurs when there is an exception. *)
val crap_there_is_an_exception : exn -> t
