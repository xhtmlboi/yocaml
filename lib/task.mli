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

(** Task is the main abstraction used to describe an action (a task that
    produces an effect) associated with dependencies and a DSL for composing
    tasks together. *)

(** {1 Types} *)

type ('a, 'b) t
(** A task is a particular type of function, which produces an effect,
    associated with a set of dependencies. That's why it's a type parameterised
    by an input and an output. *)

(** {1 Building tasks} *)

val make : Deps.t -> ('a -> 'b Eff.t) -> ('a, 'b) t
(** [make deps eff] Builds a task with a fixed set of dependencies and an
    action.*)

val lift : ('a -> 'b) -> ('a, 'b) t
(** [lift f] lift the function [f] into a task with an empty set of
    dependencies. Useful for transforming regular functions into tasks. *)

val id : ('a, 'a) t
(** Task is in fact a Strong Profonctor, and therefore an Arrow, hence the
    presence of an identity morphism, associated with an empty dependency set. *)

(** {1 Composing tasks}

    Building a construction pipeline involves composing tasks and merging their
    set of dependencies. *)

val compose : ('b, 'c) t -> ('a, 'b) t -> ('a, 'c) t
(** [compose t2 t1] merges dependencies from [t1] and [t2] and produce a new
    action that sequentially performs [t1] following by [t2]. *)

val rcompose : ('a, 'b) t -> ('b, 'c) t -> ('a, 'c) t
(** [rcompose t1 t2] merges dependencies from [t1] and [t2] and produce a new
    action that sequentially performs [t1] following by [t2]. *)

val pre_compose : ('b -> 'c) -> ('a, 'b) t -> ('a, 'c) t
(** [pre_compose f t] is [compose (lift f) t]. It allows to composition between
    Task and regular function. *)

val post_compose : ('b, 'c) t -> ('a -> 'b) -> ('a, 'c) t
(** [post_compose t f] is [compose t (lift f)]. It allows to composition between
    Task and regular function. *)

val pre_rcompose : ('a -> 'b) -> ('b, 'c) t -> ('a, 'c) t
(** [pre_recompose f t] is [rcompose (lift f) t] It allows to composition
    between Task and regular function. *)

val post_rcompose : ('a, 'b) t -> ('b -> 'c) -> ('a, 'c) t
(** [post_recompose t f] is [rcompose t (lift f)] It allows to composition
    between Task and regular function. *)

(** {1 Profunctors operation}

    Since in {!type:t}, ['a] is contravariant and ['b] is covariant, we can
    imagine its profunctorial nature. *)

val dimap : ('a -> 'b) -> ('c -> 'd) -> ('b, 'c) t -> ('a, 'd) t
(** [dimap f g t] contramap [f] on [t] and map [g] on [t]. *)

val lmap : ('a -> 'b) -> ('b, 'c) t -> ('a, 'c) t
(** [lmap f t] contramap [f] on [t]. *)

val rmap : ('b -> 'c) -> ('a, 'b) t -> ('a, 'c) t
(** [rmap f t] map [f] on [t]. *)

(** {2 Choice operations}

    Profunctors with choice, to act on sum-types (using [Either] to describe
    generic sums). *)

val left : ('a, 'b) t -> (('a, 'c) Either.t, ('b, 'c) Either.t) t
(** [left t] expand the arrow to act only on the [Left] part of the sum. *)

val right : ('a, 'b) t -> (('c, 'a) Either.t, ('c, 'b) Either.t) t
(** [right t] expand the arrow to act only on the [Right] part of the sum. *)

val choose :
  ('a, 'b) t -> ('c, 'd) t -> (('a, 'c) Either.t, ('b, 'd) Either.t) t
(** Split the input between the two argument arrows, re-tagging and merging
    their outputs. *)

val fan_in : ('a, 'c) t -> ('b, 'c) t -> (('a, 'b) Either.t, 'c) t
(** Split the input between the two argument arrows, merging their outputs. *)

(** {2 Strong operations}

    Profunctors with strength, to act on product-types (using [('a * 'b)] to
    describe generic products). *)

val first : ('a, 'b) t -> ('a * 'c, 'b * 'c) t
(** [first t] expand the arrow to act only on the first part of the product. *)

val second : ('a, 'b) t -> ('c * 'a, 'c * 'b) t
(** [second t] expand the arrow to act only on the second part of the product. *)

val uncurry : ('a, 'b -> 'c) t -> ('a * 'b, 'c) t
(** Uncurry an arrow. *)

val split : ('a, 'b) t -> ('c, 'd) t -> ('a * 'c, 'b * 'd) t
(** Split the input between the two argument arrows and combine their output. *)

val fan_out : ('a, 'b) t -> ('a, 'c) t -> ('a, 'b * 'c) t
(** Send the input to both argument arrows and combine their output.*)

(** {1 Infix operators} *)

module Infix : sig
  val ( <<< ) : ('b, 'c) t -> ('a, 'b) t -> ('a, 'c) t
  (** [t2 <<< t1] is [compose t2 t1]. *)

  val ( >>> ) : ('a, 'b) t -> ('b, 'c) t -> ('a, 'c) t
  (** [t1 >>> t2] is [rcompose t1 t2]. *)

  val ( |<< ) : ('b -> 'c) -> ('a, 'b) t -> ('a, 'c) t
  (** [f ^<< t1] is [pre_compose f t1]. *)

  val ( <<| ) : ('b, 'c) t -> ('a -> 'b) -> ('a, 'c) t
  (** [t1 <<^ f] is [post_compose t1 f]. *)

  val ( |>> ) : ('a -> 'b) -> ('b, 'c) t -> ('a, 'c) t
  (** [f |>> t1] is [pre_rcompose f t1]. *)

  val ( >>| ) : ('a, 'b) t -> ('b -> 'c) -> ('a, 'c) t
  (** [t1 >>| f] is [post_rcompose t1 f]. *)

  val ( +++ ) :
    ('a, 'b) t -> ('c, 'd) t -> (('a, 'c) Either.t, ('b, 'd) Either.t) t
  (** [t1 +++ t2] is [choose t1 t2]. *)

  val ( ||| ) : ('a, 'c) t -> ('b, 'c) t -> (('a, 'b) Either.t, 'c) t
  (** [t1 ||| t2] is [fan_in t1 t2]. *)

  val ( *** ) : ('a, 'b) t -> ('c, 'd) t -> ('a * 'c, 'b * 'd) t
  (** [t1 *** t2] is [split t1 t2]. *)

  val ( &&& ) : ('a, 'b) t -> ('a, 'c) t -> ('a, 'b * 'c) t
  (** [t1 &&& t2] is [fan_out t1 t2]. *)
end

include module type of Infix
(** @inline *)
