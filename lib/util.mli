(** An invasive but probably useful tooling. *)

open Aliases

(** {1 Working with file name}

    As {e Wordpress} is mainly used to move files, having some functions to
    work with file names can be a very good idea! *)

(** [filepath |> into dir] describes a [filepath] into a [dir]. *)
val into : filepath -> filepath -> filepath

(** {1 Infix operators}

    Even if sometimes, infix operators can seem unreadable... the immoderate
    use of Arrows has already made the code incomprehensible... so why deprive
    yourself? *)

(** [f $ x] is [f @@ x] which is [f x]... but I don't like [@@]. *)
val ( $ ) : ('a -> 'b) -> 'a -> 'b
