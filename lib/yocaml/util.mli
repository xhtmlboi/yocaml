(** An invasive but probably useful tooling. *)

(** {1 String util}

    As I was not very serious... strings occupy a very large place in
    Wordpress... so it is necessary to be able to work correctly with them. *)

val split_metadata : string -> string option * string

(** {1 Infix operators}

    Even if sometimes, infix operators can seem unreadable... the immoderate
    use of Arrows has already made the code incomprehensible... so why deprive
    yourself? *)

(** [f $ x] is [f @@ x] which is [f x]... but I don't like [@@]. *)
val ( $ ) : ('a -> 'b) -> 'a -> 'b

(** {1 Working with file name} *)

include module type of Filepath (** @closed *)
