(** Description of a build rule. *)

open Aliases

(** {1 Type}

    [('a, 'b) Build.t] describes a special case of a function. Indeed, it is a
    function of ['a -> b Effect.t] to which a dependency link ({!type:Deps.t})
    is attached. *)

type ('a, 'b) t

(** {1 Action on rules} *)

(** [run target build_rule] executes the [build_rule] task if the dependencies
    are not up-to-date for [target] (or [target] does not exist). *)
val run : filepath -> (unit, string) t -> unit Effect.t

(** [dependencies rule] returns the dependencies of the [rule]. *)
val dependencies : ('a, 'b) t -> Deps.t

(** [task rule] returns the task of the [rule]. *)
val task : ('a, 'b) t -> 'a -> 'b Effect.t

(** {1 Building rules}

    Combiners to build rules (increasingly complex, to infinity and beyond). *)

(** Arrow version of a file reader. *)
val read_file : filepath -> (unit, string) t

(** Pipe an arrow to an other and concat the results. *)
val concat_content : separator:string -> filepath -> (string, string) t

(** Concat two files. *)
val concat_files
  :  separator:string
  -> filepath
  -> filepath
  -> (unit, string) t

(** {1 Included Arrow combinators}

    A [build rule] respects the interface of an [Arrow Choice] (which implies
    [Category] and [Arrow], by construction), for ergonomic reasons, the
    combinators of the three classes are included in the module toplevel. *)

include Preface_specs.ARROW_CHOICE with type ('a, 'b) t := ('a, 'b) t
