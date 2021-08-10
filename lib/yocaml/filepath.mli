(** As {e Wordpress} is mainly used to move files, having some functions to
    work with file names can be a very good idea! *)

(** Describing a filepath. *)
type t = string

(** [t |> into dir] describes a [t] into a [dir]. *)
val into : t -> t -> t

(** [with_extension ext path] returns [true] if [path] ends with [ext] [false]
    otherwise, ie: [with_extension "html" "index.html"] returns [true] but
    [with_extenstion "html" "foohtml"] returns [false]. *)
val with_extension : string -> t -> bool

(** Keep the filename and remove the path. *)
val basename : t -> t

(** Add an extension to a t. For example: [add_extension "index.txt" "html"]
    will produce ["index.txt.html"]. *)
val add_extension : t -> string -> t

(** Remove the extension of a path. *)
val remove_extension : t -> t

(** Replace the extension of a path. *)
val replace_extension : t -> string -> t
