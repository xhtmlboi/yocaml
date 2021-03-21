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

(** {1 Included Arrow combinators}

    A [build rule] respects the interface of an [Arrow Choice] (which implies
    [Category] and [Arrow], by construction), for ergonomic reasons, the
    combinators of the three classes are included in the module toplevel. *)

include Preface_specs.ARROW_CHOICE with type ('a, 'b) t := ('a, 'b) t
