(** An invasive but probably useful tooling. *)

open Aliases

(** {1 Working with file name}

    As {e Wordpress} is mainly used to move files, having some functions to
    work with file names can be a very good idea! *)

(** [filepath |> into dir] describes a [filepath] into a [dir]. *)
val into : filepath -> filepath -> filepath

(** [with_extension ext path] returns [true] if [path] ends with [ext] [false]
    otherwise, ie: [with_extension "html" "index.html"] returns [true] but
    [with_extenstion "html" "foohtml"] returns [false]. *)
val with_extension : string -> filepath -> bool

(** Keep the filename and remove the path. *)
val basename : filepath -> filepath

(** Add an extension to a filepath. For example:
    [add_extension "index.txt" "html"] will produce ["index.txt.html"]. *)
val add_extension : filepath -> string -> filepath

val remove_extension : filepath -> filepath
val replace_extension : filepath -> string -> filepath

(** {1 Infix operators}

    Even if sometimes, infix operators can seem unreadable... the immoderate
    use of Arrows has already made the code incomprehensible... so why deprive
    yourself? *)

(** [f $ x] is [f @@ x] which is [f x]... but I don't like [@@]. *)
val ( $ ) : ('a -> 'b) -> 'a -> 'b
