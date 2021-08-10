(** A Wrapper around {{:https://github.com/rgrinberg/ocaml-mustache}
    ocaml-mustache}.

    This module can act as a provider to inject metadata in a template written
    in Mustache. *)

(** {1 Build additions} *)

(** Applies a file as a template. (and replacing the metadata). Once the
    content has been transformed, the arrow returns a pair containing the
    metadata and the file content injected into the template. *)
val apply_as_template
  :  (module Yocaml.Metadata.INJECTABLE with type t = 'a)
  -> ?strict:bool
  -> Yocaml.Filepath.t
  -> ('a * string, 'a * string) Yocaml.Build.t

(** {1 Types} *)

(** An alias for [Mustache.Json.value]. *)
type t = Yocaml.Key_value.Jsonm_object.t

(** {1 Conversion function} *)

(** [to_string variables templates] produces a string where [variables] have
    been applied.*)
val to_string : ?strict:bool -> (string * t) list -> string -> string

(** {1 Descriptor} *)

include Yocaml.Key_value.DESCRIBABLE with type t := t (** @inline *)
