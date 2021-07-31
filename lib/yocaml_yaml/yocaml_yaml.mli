(** {1 Build additions} *)

(** Read a file and parse metadata in the header. If the metadata is invalid,
    the arrow will throw an error. The Arrow uses
    {{:https://github.com/avsm/ocaml-yaml} ocaml-yaml}. *)
val read_file_with_metadata
  :  (module Yocaml.Metadata.PARSABLE with type t = 'a)
  -> Yocaml.Aliases.filepath
  -> (unit, 'a * string) Yocaml.Build.t

(** {1 Types} *)

(** An alias for [Yaml.value]. *)
type t

(** {1 Conversion function} *)

(** Produces a Yaml representation from a string.*)
val from_string : string -> t Yocaml.Validate.t

(** {1 Validators} *)

include Yocaml.Key_value.KEY_VALUE_VALIDATOR with type t := t (** @inline *)
