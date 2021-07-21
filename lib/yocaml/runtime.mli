(** Describes a dedicated runtime for varying the execution context of YOCaml. *)

(** Although much of YOCaml is already abstracted by means of a rudimentary
    effect handler (based on a Freer Monad), it is assumed that the management
    of the control flow does not have to be handled by an end user or someone
    concerned with building a dedicated runtime (for Windows for example). So
    it is sufficient to provide a module that implements the necessary
    primitives that will be invoked in the effect manager.

    One might ask why not just use modules as an effect abstraction. Mainly
    because a Freer Monad is also a (logical) monad, so you can easily
    traverse them which makes the implementation of the engine much simpler. *)

open Aliases

(** {1 Runtime definition} *)

module type RUNTIME = sig
  val file_exists : filepath -> bool
  val is_directory : filepath -> bool
  val get_modification_time : filepath -> int Try.t
  val read_file : filepath -> string Try.t
  val write_file : filepath -> string -> unit Try.t
  val read_dir : filepath -> filepath list
  val create_dir : ?file_perm:int -> filepath -> unit
  val log : Aliases.log_level -> string -> unit
end

(** {1 Helpers} *)

(** Runs a YOCaml program with a specific runtime. *)
val execute : (module RUNTIME) -> 'a Effect.t -> 'a
