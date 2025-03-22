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

type (-'a, 'b) t
(** A task is a particular type of function, which produces an effect,
    associated with a set of dependencies. That's why it's a type parameterised
    by an input and an output. *)

(** {1 Building tasks} *)

val make :
  ?has_dynamic_dependencies:bool -> Deps.t -> ('a -> 'b Eff.t) -> ('a, 'b) t
(** [make deps eff] Builds a task with a fixed set of dependencies and an
    action.*)

val from_effect :
  ?has_dynamic_dependencies:bool -> ('a -> 'b Eff.t) -> ('a, 'b) t
(** [from_effect] is [make Deps.empty]. *)

val lift : ?has_dynamic_dependencies:bool -> ('a -> 'b) -> ('a, 'b) t
(** [lift f] lift the function [f] into a task with an empty set of
    dependencies. Useful for transforming regular functions into tasks. *)

val id : ('a, 'a) t
(** Task is in fact a Strong Profonctor, and therefore an Arrow, hence the
    presence of an identity morphism, associated with an empty dependency set.
*)

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
(** [second t] expand the arrow to act only on the second part of the product.
*)

val uncurry : ('a, 'b -> 'c) t -> ('a * 'b, 'c) t
(** Uncurry an arrow. *)

val split : ('a, 'b) t -> ('c, 'd) t -> ('a * 'c, 'b * 'd) t
(** Split the input between the two argument arrows and combine their output. *)

val fan_out : ('a, 'b) t -> ('a, 'c) t -> ('a, 'b * 'c) t
(** Send the input to both argument arrows and combine their output.*)

(** {2 Application operations}

    Implement function application capabilities using Arrow Apply. *)

val apply : (('a, 'b) t * 'a, 'b) t
(** Application of a task to a given input. *)

(** {1 Covariant API}

    Removing the contravariant component of the profunctor, we have a covariant
    component that can be treated as a regular Functor. This makes it possible
    to have linking operators and to make the API potentially less conflicting.*)

type 'a ct = (unit, 'a) t
(** Just a type alias for reducing signatures verbosity *)

val map : ('a -> 'b) -> 'a ct -> 'b ct
(** Regular mapping on a task. Since {!type:t} is also a Functor. *)

val pure : 'a -> 'a ct
(** Lift a regular value into a task.*)

val ap : ('a -> 'b) ct -> 'a ct -> 'b ct
(** Regular apply on a task. Since {!type:t} is also an Applicative. *)

val zip : 'a ct -> 'b ct -> ('a * 'b) ct
(** Monoidal product between two applicatives. *)

val replace : 'a -> 'b ct -> 'a ct
(** [replace x e] replace the value of [e] by [x]. *)

val void : 'a ct -> unit ct
(** [void e] replace the value of [e] by [unit]. *)

val select : ('a, 'b) Either.t ct -> ('a -> 'b) ct -> 'b ct
(** [select e f] apply [f] if [e] is [Left]. It allow to skip effect using
    [Right]. *)

val branch : ('a, 'b) Either.t ct -> ('a -> 'c) ct -> ('b -> 'c) ct -> 'c ct
(** [branch x f g ] if [x] is [Left], it performs [f], otherwise it performs
    [g]. *)

val map2 : ('a -> 'b -> 'c) -> 'a ct -> 'b ct -> 'c ct
(** Lift a 2-ary function. *)

val map3 : ('a -> 'b -> 'c -> 'd) -> 'a ct -> 'b ct -> 'c ct -> 'd ct
(** Lift a 3-ary function. *)

val map4 :
  ('a -> 'b -> 'c -> 'd -> 'e) -> 'a ct -> 'b ct -> 'c ct -> 'd ct -> 'e ct
(** Lift a 4-ary function. *)

val map5 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f)
  -> 'a ct
  -> 'b ct
  -> 'c ct
  -> 'd ct
  -> 'e ct
  -> 'f ct
(** Lift a 5-ary function. *)

val map6 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g)
  -> 'a ct
  -> 'b ct
  -> 'c ct
  -> 'd ct
  -> 'e ct
  -> 'f ct
  -> 'g ct
(** Lift a 6-ary function. *)

val map7 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'h)
  -> 'a ct
  -> 'b ct
  -> 'c ct
  -> 'd ct
  -> 'e ct
  -> 'f ct
  -> 'g ct
  -> 'h ct
(** Lift a 7-ary function. *)

val map8 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'h -> 'i)
  -> 'a ct
  -> 'b ct
  -> 'c ct
  -> 'd ct
  -> 'e ct
  -> 'f ct
  -> 'g ct
  -> 'h ct
  -> 'i ct
(** Lift a 8-ary function. *)

(** {1 Infix operators} *)

module Infix : sig
  val ( ||> ) : 'a -> ('a -> 'b) -> 'b
  (** [x ||> f] is [f x]. *)

  val ( <<< ) : ('b, 'c) t -> ('a, 'b) t -> ('a, 'c) t
  (** [t2 <<< t1] is [compose t2 t1]. *)

  val ( >>> ) : ('a, 'b) t -> ('b, 'c) t -> ('a, 'c) t
  (** [t1 >>> t2] is [rcompose t1 t2]. *)

  val ( <+< ) :
    ('b, 'c * Deps.t) t -> ('a, 'b * Deps.t) t -> ('a, 'c * Deps.t) t
  (** [a <+< b] compose [b] and [a] and concat dynamic dependencies set. *)

  val ( >+> ) :
    ('a, 'b * Deps.t) t -> ('b, 'c * Deps.t) t -> ('a, 'c * Deps.t) t
  (** [a >+> b] compose [a] and [b] and concat dynamic dependencies set. *)

  val ( |<< ) : ('b -> 'c) -> ('a, 'b) t -> ('a, 'c) t
  (** [f ^<< t1] is [pre_compose f t1]. *)

  val ( <<| ) : ('b, 'c) t -> ('a -> 'b) -> ('a, 'c) t
  (** [t1 <<| f] is [post_compose t1 f]. *)

  val ( *<< ) : ('b -> 'c Eff.t) -> ('a, 'b) t -> ('a, 'c) t
  (** [f *<< t1] is [compose (make Deps.empty f) t1]. *)

  val ( <<* ) : ('b, 'c) t -> ('a -> 'b Eff.t) -> ('a, 'c) t
  (** [t1 <<* f] is [compose t1 (make Deps.empty f)]. *)

  val ( |>> ) : ('a -> 'b) -> ('b, 'c) t -> ('a, 'c) t
  (** [f |>> t1] is [pre_rcompose f t1]. *)

  val ( >>| ) : ('a, 'b) t -> ('b -> 'c) -> ('a, 'c) t
  (** [t1 >>| f] is [post_rcompose t1 f]. *)

  val ( *>> ) : ('a -> 'b Eff.t) -> ('b, 'c) t -> ('a, 'c) t
  (** [f *>> t1] is [compose (make Deps.empty f) t1]. *)

  val ( >>* ) : ('a, 'b) t -> ('b -> 'c Eff.t) -> ('a, 'c) t
  (** [t1 >>* f] is [compose t1 (make Deps.empty f)]. *)

  val ( +++ ) :
    ('a, 'b) t -> ('c, 'd) t -> (('a, 'c) Either.t, ('b, 'd) Either.t) t
  (** [t1 +++ t2] is [choose t1 t2]. *)

  val ( ||| ) : ('a, 'c) t -> ('b, 'c) t -> (('a, 'b) Either.t, 'c) t
  (** [t1 ||| t2] is [fan_in t1 t2]. *)

  val ( *** ) : ('a, 'b) t -> ('c, 'd) t -> ('a * 'c, 'b * 'd) t
  (** [t1 *** t2] is [split t1 t2]. *)

  val ( &&& ) : ('a, 'b) t -> ('a, 'c) t -> ('a, 'b * 'c) t
  (** [t1 &&& t2] is [fan_out t1 t2]. *)

  val ( <$> ) : ('a -> 'b) -> 'a ct -> 'b ct
  (** [f <$> t] is [map f t]. *)

  val ( <*> ) : ('a -> 'b) ct -> 'a ct -> 'b ct
  (** [ft <*> t] is [apply ft t]. *)

  val ( <*? ) : ('a, 'b) Either.t ct -> ('a -> 'b) ct -> 'b ct
  (** [c <*? f] is [select c f]*)
end

include module type of Infix
(** @inline *)

(** {1 Binding operators} *)

module Syntax : sig
  val ( let+ ) : 'a ct -> ('a -> 'b) -> 'b ct
  (** [let+ x = t in f x] is [f <$> f]. *)

  val ( and+ ) : 'a ct -> 'b ct -> ('a * 'b) ct
  (** [let+ x = t1 and+ y = t2 in f x y] is [f <$> t1 <*> t2]. *)
end

include module type of Syntax
(** @inline *)

(** {1 Utils} *)

val has_dynamic_dependencies : (_, _) t -> bool
(** [has_dynamic_dependencies t] returns [true] if task has dynamic
    dependencies, [false] otherwise. *)

val dependencies_of : (_, _) t -> Deps.t
(** [dependencies_of t] returns the dependencies set of a task. *)

val action_of : ('a, 'b) t -> 'a -> 'b Eff.t
(** [action_of t] returns the effectful function of a task. *)

val destruct : ('a, 'b) t -> Deps.t * ('a -> 'b Eff.t) * bool
(** [destruct t] returns the triple of a dependencies set and an effectful
    callback and if the task is associated to dynamic dependencies. [destruct]
    is [dependencies_of t, action_of t, has_dynamic_dependencies t]*)

val no_dynamic_deps : ('a, 'b) t -> ('a, 'b * Deps.t) t
(** [no_dynamic_deps] makes an arrow static (does not attach it to any dynamic
    dependency set). *)

val drop_first : unit -> ('a * 'b, 'b) t
(** [drop_first t] discards the first element returned by a task. *)

val drop_second : unit -> ('a * 'b, 'a) t
(** [drop_second t] discards the second element returned by a task. *)

val empty_body : unit -> ('a, 'a * string) t
(** An arrow that attach an empty body *)

val const : 'a -> ('b, 'a) t
(** [const x] is an arrow that discard the previous output to replace-it by [k].
*)

val with_dynamic_dependencies : Path.t list -> ('a, 'a * Deps.t) t
(** [with_dynamic_dependencies dependenices_list] allows to add a set of dynamic
    dependencies to a task. Even the set of dependencies looks static, it is
    mostly used for attaching dependencies like folders. *)

(** {1 Helpers for dealing with static and dynamic dependencies}

    The API can change considerably when processing tasks with or without
    dynamic dependencies, so we are exposing two modules to simplify this
    processing. *)

module Static : sig
  (** Utilities for dealing with tasks without dynamic dependencies. *)

  val on_content :
       ('content_in, 'content_out) t
    -> ('meta * 'content_in, 'meta * 'content_out) t
  (** [on_content arr] lift an arrow to deal only with the content of a task. *)

  val on_metadata :
    ('meta_in, 'meta_out) t -> ('meta_in * 'content, 'meta_out * 'content) t
  (** [on_metadata arr] lift an arrow to deal only with the associated metadata
      of a task. *)

  val keep_content : unit -> ('meta * 'content, 'content) t
  (** [keep_content ()] drop the metadata part of the computed task. *)

  val empty_body : unit -> ('meta, 'meta * string) t
  (** [empty_body ()] attach an empty body (an empty string) to a task. *)
end

module Dynamic : sig
  (** Utilities for dealing with tasks with dynamic dependencies. *)

  val on_content :
       ('content_in, 'content_out) t
    -> (('meta * 'content_in) * Deps.t, ('meta * 'content_out) * Deps.t) t
  (** [on_content arr] lift an arrow to deal only with the content of a task. *)

  val on_metadata :
       ('meta_in, 'meta_out) t
    -> (('meta_in * 'content) * Deps.t, ('meta_out * 'content) * Deps.t) t
  (** [on_metadata arr] lift an arrow to deal only with the associated metadata
      of a task. *)

  val on_static :
       ('meta_in * 'content_in, 'meta_out * 'content_out) t
    -> ( ('meta_in * 'content_in) * Deps.t
       , ('meta_out * 'content_out) * Deps.t )
       t
  (** [on_static arr] lift an arrow to deal only with the static part (the
      couple [meta/content]). *)

  val on_dependencies :
       (Deps.t, Deps.t) t
    -> (('meta * 'content) * Deps.t, ('meta * 'content) * Deps.t) t
  (** [on_dependencies arr] lift an arrow to deal only with the associated
      dynamic deps set of a task. *)

  val keep_content : unit -> (('meta * 'content) * Deps.t, 'content * Deps.t) t
  (** [keep_content ()] drop the metadata part of the computed task. *)

  val empty_body : unit -> ('meta * Deps.t, ('meta * string) * Deps.t) t
  (** [empty_body ()] attach an empty body (an empty string) to a task. *)
end
