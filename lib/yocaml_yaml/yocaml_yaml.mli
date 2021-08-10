(** A Wrapper around {{:https://github.com/avsm/ocaml-yaml} ocaml-yaml}.

    This module can act as a provider to read the metadata of a file being
    written in Yaml. *)

(** {1 Build additions} *)

(** Read a file and parse metadata desribed in Yaml in the header. If the
    metadata is invalid, the arrow will throw an error. *)
val read_file_with_metadata
  :  (module Yocaml.Metadata.READABLE with type t = 'a)
  -> Yocaml.Filepath.t
  -> (unit, 'a * string) Yocaml.Build.t

(** {1 Types} *)

(** An alias for [Yaml.value]. *)
type t = Yocaml.Key_value.Jsonm_object.t

(** {1 Conversion function} *)

(** Produces a Yaml representation from a string.*)
val from_string : string -> t Yocaml.Validate.t

(** {1 Validators} *)

include Yocaml.Key_value.VALIDATOR with type t := t (** @inline *)
