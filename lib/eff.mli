(* YOCaml a static blog generator.
   Copyright (C) 2024 The Funkyworkers and The YOCaml's developers

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

(** An overlay on expression and effect performance.

    Currently ([OCaml 5.1.1]), the definition and interpretation of effects is a
    feature dedicated to implementing concurrent primitives for OCaml, for
    example: {{:https://v2.ocaml.org/api/Domain.html} the Domain API}. However,
    the effects type system has not yet been implemented, so the use of effects
    and handlers is still experimental.

    In YOCaml 1.0.0, effects were abstracted using a
    {{:https://okmij.org/ftp/Computation/free-monad.html} Freer Monad},
    described in the {{:https://github.com/xvw/preface} Preface}. However, since
    OCaml 5, it has been possible to describe effects, in order to be able to
    {i colour} the functions which propagate effects, we use an IO Monad. This
    allows us to distinguish pure functions from impure functions, while
    allowing the interpretation, a posteriori of effects, allowing
    specialisation via a Runtime to ensure the versatility of YOCaml. The
    trade-off is that you can't really take advantage of the direct style, but
    the presence of
    {{:https://v2.ocaml.org/manual/bindingops.html} binding operators} makes
    this loss fairly slight. *)

(** {1 The Eff Monad}

    The Eff Monad is an implementation of IO, which produces functions that
    propagate effects. It is used to distinguish between pure and impure
    functions. *)

type 'a t
(** A type describing an impure normal form. A function from ['a -> 'b] should
    be pure, and a function of ['a -> 'b Eff.t] should be impure and, in
    retrospect, be interpreted by an effect handler.*)

val return : 'a -> 'a t
(** [return x] lift [x] into an {i impure} context. *)

val bind : ('a -> 'b t) -> 'a t -> 'b t
(** [bind f x] gives the result of the computation [x] to the function [f]. *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** [map f x] mapping from ['a t] to ['b t]. *)

val join : 'a t t -> 'a t
(** [join x] remove one level of monadic structure, projecting its bound
    argument into the outer level. *)

val compose : ('a -> 'b t) -> ('b -> 'c t) -> 'a -> 'c t
(** [compose f g] is left to right composition of Kleisli Arrows of [f . g]. *)

val rcompose : ('b -> 'c t) -> ('a -> 'b t) -> 'a -> 'c t
(** [rcompose f g] is the right to left composition of Kleisli Arrows of
    [g . f]. *)

val apply : ('a -> 'b) t -> 'a t -> 'b t
(** [apply f x] apply f to x. *)

val zip : 'a t -> 'b t -> ('a * 'b) t
(** [zip x y] is the monoidal product of [x] and [y]. *)

val replace : 'a -> 'b t -> 'a t
(** [replace x e] replace the value of [e] by [x]. *)

val void : 'a t -> unit t
(** [void e] replace the value of [e] by [unit]. *)

val select : ('a, 'b) Either.t t -> ('a -> 'b) t -> 'b t
(** [select e f] apply [f] if [e] is [Left]. It allow to skip effect using
    [Right]. *)

val branch : ('a, 'b) Either.t t -> ('a -> 'c) t -> ('b -> 'c) t -> 'c t
(** [branch x f g ] if [x] is [Left], it performs [f], otherwise it performs
    [g]. *)

val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
(** Lift a 2-ary function. *)

val map3 : ('a -> 'b -> 'c -> 'd) -> 'a t -> 'b t -> 'c t -> 'd t
(** Lift a 3-ary function. *)

val map4 : ('a -> 'b -> 'c -> 'd -> 'e) -> 'a t -> 'b t -> 'c t -> 'd t -> 'e t
(** Lift a 4-ary function. *)

val map5 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f)
  -> 'a t
  -> 'b t
  -> 'c t
  -> 'd t
  -> 'e t
  -> 'f t
(** Lift a 5-ary function. *)

val map6 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g)
  -> 'a t
  -> 'b t
  -> 'c t
  -> 'd t
  -> 'e t
  -> 'f t
  -> 'g t
(** Lift a 6-ary function. *)

val map7 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'h)
  -> 'a t
  -> 'b t
  -> 'c t
  -> 'd t
  -> 'e t
  -> 'f t
  -> 'g t
  -> 'h t
(** Lift a 7-ary function. *)

val map8 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'h -> 'i)
  -> 'a t
  -> 'b t
  -> 'c t
  -> 'd t
  -> 'e t
  -> 'f t
  -> 'g t
  -> 'h t
  -> 'i t
(** Lift a 8-ary function. *)

(** {2 Traversable}

    Enables traversable structures to be traversed on effects. *)

module List : sig
  val traverse : ('a -> 'b t) -> 'a list -> 'b list t
  (** Map each element of a structure to an action, evaluate these actions from
      left to right, and collect the results. *)

  val sequence : 'a t list -> 'a list t
  (** Evaluate each action in the structure from left to right, and collect the
      results *)
end

(** {2 Infix operators}

    Comfort infix operators for composing programmes that produce effects. *)

module Infix : sig
  val ( <$> ) : ('a -> 'b) -> 'a t -> 'b t
  (** [f <$> x] is [map f x]. *)

  val ( <*> ) : ('a -> 'b) t -> 'a t -> 'b t
  (** [f <*> x] is [apply f x]. *)

  val ( <*? ) : ('a, 'b) Either.t t -> ('a -> 'b) t -> 'b t
  (** [c <*? f] is [select c f]*)

  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
  (** [m >>= f] is [bind f m]. *)

  val ( =<< ) : ('a -> 'b t) -> 'a t -> 'b t
  (** [f =<< m] is [bind f m]. *)

  val ( >|= ) : 'a t -> ('a -> 'b) -> 'b t
  (** [m >|= f] is [map f m]. *)

  val ( =|< ) : ('a -> 'b) -> 'a t -> 'b t
  (** [f =|< x] is [map f x]. *)

  val ( >=> ) : ('a -> 'b t) -> ('b -> 'c t) -> 'a -> 'c t
  (** [f >=> g] is [compose f g]. *)

  val ( <=< ) : ('b -> 'c t) -> ('a -> 'b t) -> 'a -> 'c t
  (** [f <=< g] is [rcompose f g]. *)
end

include module type of Infix
(** @inline *)

(** {2 Bindings operators}

    Comfort bindings operators for composing programmes that produce effects and
    get closer to the direct style. *)

module Syntax : sig
  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
  (** [let+ x = e in f x] is [f <$> x]*)

  val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t
  (** [let+ x = e and+ y = f in g x y] is [g <$> e <*> f]. *)

  val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
  (** [let* x = e in f x] is [e >>= f]. *)
end

include module type of Syntax
(** @inline *)

(** {1 User defined effects}

    Description of the effects that can be propagated by a YOCaml program. All
    effects are prefixed with [Yocaml_] to avoid conflicts with another program
    propagating different effects.

    Some effects are common (for example those used to log or propagate errors),
    some are used to act on the original filesystem and uses a parameter
    [`Source] and others act on the target and uses a parameter [`Target]. This
    makes it possible, for example, to generate in a target different from the
    source. This is useful, for example, when generating a site in a git
    repository, which uses a Unix file system as its source and a git repo as
    its target. *)

type _ Effect.t +=
  | Yocaml_log :
      ([ `App | `Error | `Warning | `Info | `Debug ] * string)
      -> unit Effect.t
        (** Effect describing the logging of a message attached to a log level.
            The log level uses the various conventional levels offered, in
            particular, by the {{:https://erratique.ch/software/logs} Logs}
            library. *)
  | Yocaml_failwith : exn -> 'a Effect.t
        (** Effect that propagates an error. *)
  | Yocaml_file_exists : [ `Target | `Source ] * Path.t -> bool Effect.t
        (** Effect that check if a file exists. *)
  | Yocaml_read_file : [ `Target | `Source ] * Path.t -> string Effect.t
        (** Effect that read a file from a given filepath on the source*)
  | Yocaml_get_mtime : [ `Target | `Source ] * Path.t -> int Effect.t
        (** Effect that get the modification time of a source filepath. *)

val perform : 'a Effect.t -> 'a t
(** [perform effect] colours an effect performance as impure. Replaces
    [Stdlib.Effect.perform x].*)

val run : ('b, 'c) Effect.Deep.handler -> ('a -> 'b t) -> 'a -> 'c
(** [run handler kleisli_arrow input] interprets a Kleisli Arrow
    ([kleisli_arrow]) for an effect handler ([effect_handler]) given as an
    argument ([input]). *)

(** {2 Exceptions}

    Exception that can be propagated by the performance of effects. *)

exception File_not_exists of Path.t
(** Exception raised when a file does not exists. *)

(** {2 Helpers for performing effects}

    Functions producing defined effects. *)

val log :
  ?level:[ `App | `Error | `Warning | `Info | `Debug ] -> string -> unit t
(** [log ~level message] performs the effect [Yocaml_log] with a given [level]
    and a [message]. *)

val raise : exn -> 'a t
(** [raise exn] performs the effect [Yocaml_failwith] with a given [exn]. *)

val failwith : string -> 'a t
(** [failwith message] perform the effect [Yocaml_failwith] with a message that
    produces an error wrapped into a [Failure] exception. *)

val file_exists : on:[ `Target | `Source ] -> Path.t -> bool t
(** [file_exists path] perform the effect [Yocaml_file_exists] with a given
    [path] return [true] if the file exists, [false] if not. *)

val read_file : on:[ `Target | `Source ] -> Path.t -> string t
(** [source_read_file path] perform the effect [Yocaml_read_file] with a given
    [path] and try to read it. Perform [Yocaml_failwith] with
    {!exception:File_not_exists} if the file does not exists. *)

val mtime : on:[ `Target | `Source ] -> Path.t -> int t
(** [source_mtime path] perform the effect [Yocaml_source_get_mtime] with a
    given [path] and try to get the modification time. Perform [Yocaml_failwith]
    with {!exception:File_not_exists} if the file does not exists. *)
