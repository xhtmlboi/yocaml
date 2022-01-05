(** A runtime describes the set of "low-level" primitives to operate in a
    specific context. This separation allows to have a pure and platform
    agnostic kernel (the [Yocaml] module) and to define specific runtimes as
    needed. Here is the runtime for UNIXish (OSX/Linux). *)

(** {1 API} *)

(** Executes a YOCaml program using the UNIX Runtime. *)
val execute : 'a Yocaml.Effect.t -> 'a

(** [serve ~filepath ~port engine] will serve, a bit like the sad python
    server, a static directory ... in addition, the function takes an OCaml
    program and re-executes it on every HTTP request that does not point to a
    404. Very handy for continuous content development! *)
val serve : filepath:string -> port:int -> unit Yocaml.t -> unit Lwt.t

(** {1 Runtime}

    Inclusion of the runtime to be able to use [Yocaml_unix] as runtime
    directly. *)

include Yocaml.Runtime.RUNTIME (** @closed *)
