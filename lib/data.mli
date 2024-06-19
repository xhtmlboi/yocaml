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

(** Describes an mostly compatible
    {{:https://github.com/mirage/ezjsonm/blob/master/lib/ezjsonm.ml#L18}
      Ezjsonm} AST that acts as a generic AST for describing metadata that can
    be exchanged between source documents and templates. To summarise, source
    metadata is ultimately projected into a value of type {!type:Yocaml.Data.t}
    and data injected into templates is projected from values of type
    {!type:Yocaml.Data.t}.

    To be generic, you need to provide a module capable of transforming the AST
    of arbitrary metadata (for example, [Yaml]) into a value of type
    {!type:Yocaml.Data.t} to be used generically. *)

(** {1 Types} *)

type t = private
  | Null
  | Bool of bool
  | Int of int
  | Float of float
  | String of string
  | List of t list
  | Record of (string * t) list
      (** Describes the set of possible values for the Data AST. *)

type ezjsonm =
  [ `Null
  | `Bool of bool
  | `Float of float
  | `String of string
  | `A of ezjsonm list
  | `O of (string * ezjsonm) list ]
(** Describes type [ezjsonm] (to be compatible with historical libraries, such
    as {{:https://ocaml.org/p/yaml/3.1.0/doc/Yaml/index.html} ocaml_yaml}). *)

(** {1 Creating Data values} *)

val null : t
(** [null] returns the {!type:t} for [null].*)

val bool : bool -> t
(** [bool b] converts a Boolean into a {!type:t}. *)

val int : int -> t
(** [int i] converts an integer into a {!type:t}. *)

val float : float -> t
(** [float f] converts a float into a {!type:t}. *)

val string : string -> t
(** [string s] converts a string into a {!type:t}. *)

val list : t list -> t
(** [list v] converts a list of {!type:t} into a {!type:t}. *)

(** {2 Generic Data values}

    Building generic Data values. *)

val list_of : ('a -> t) -> 'a list -> t
(** [list f v] converts a list of arbitrary values into a {!type:t}. *)

val record : (string * t) list -> t
(** [record fields] converts a list of {!type:t} into a {!type:t}. *)

val option : ('a -> t) -> 'a option -> t
(** [option opt] converts an option into a {!type:t} or {!val:null}. *)

val sum : ('a -> string * t) -> 'a -> t
(** [sum f x] convert sum into a {!type:t}. *)

val pair : ('a -> t) -> ('b -> t) -> 'a * 'b -> t
(** [pair f g (x, y)] construct a pair as a {!type:t}. A pair has the structure
    [{"fst": a, "snd": b}]. *)

val triple : ('a -> t) -> ('b -> t) -> ('c -> t) -> 'a * 'b * 'c -> t
(** [triple f g h (x, y, z)] is [pair f (pair g h) (x, (y, z))]. It use [pair]
    to define [triple]. *)

val quad :
  ('a -> t) -> ('b -> t) -> ('c -> t) -> ('d -> t) -> 'a * 'b * 'c * 'd -> t
(** [quad f g h i (w, x, y, z)] is [pair f (triple g h) (w, (x, y, z))] *)

val either : ('a -> t) -> ('b -> t) -> ('a, 'b) Either.t -> t
(** [either f g x] construct either as a {!type:t}. Either has the structure
    [{"constr": "left | right", "value": e}]. *)

(** {1 Validating Data values} *)

module Validation : sig
  (** Used to validate data described by type {!type:Yocaml.Data.t} to build
      validation pipelines. The aim of this module is to produce combinators for
      building validation pipelines that support nesting and that can transform
      any value described by the AST in [Data] into arbitrary OCaml values. *)

  (** {1 Types} *)

  type custom_error = ..
  (** An extensible type dedicated to extending potential validation errors. *)

  (** Type used to describe when a value does not have the expected form (for
      example when a float is given whereas a character string is expected). The
      [With_message] is only parametrized by string in order to allow to write
      custom error messages.*)
  type value_error =
    | Invalid_shape of { expected : string; given : t }
    | Invalid_list of { errors : (int * value_error) Nel.t; given : t list }
    | Invalid_record of {
          errors : record_error Nel.t
        ; given : (string * t) list
      }
    | With_message of { given : string; message : string }
    | Custom of custom_error

  (** Errors at the field level, for validating records. *)
  and record_error =
    | Missing_field of { field : string }
    | Invalid_field of { given : t; field : string; error : value_error }

  type 'a validated_value = ('a, value_error) result
  (** Used to validate data described by type {!type:t} to build validation
      pipelines. *)

  type 'a validated_record = ('a, record_error Nel.t) result
  (** Used to validate records described by type {!type:t} to build validation
      pipelines. *)

  (** {2 Types helpers}

      Helpers for creating errors. *)

  val fail_with : given:string -> string -> 'a validated_value
  (** [fail_with ~given message] returns a validation error associated to a
      message. *)

  val fail_with_custom : custom_error -> 'a validated_value
  (** [fail_with_custom err] returns a custonm validation error. *)

  (** {1 Validators}

      Validators act on classic AST values. They are used to validate the fields
      of a record (or the inhabitants of a list). They are often used as
      arguments to the {!val:optional}, {!val:optional_or} and {!val:required}
      functions. *)

  val null : t -> unit validated_value
  (** ensure that a value is [null].*)

  val bool : t -> bool validated_value
  (** ensure that a value is a boolean. *)

  val int : t -> int validated_value
  (** ensure that a value is an int (or a float). *)

  val float : t -> float validated_value
  (** ensure that a value is an float. *)

  val string : ?strict:bool -> t -> string validated_value
  (** ensure that a value is a string, if [strict] is [false] it will consider
      [bool], [int], [float] also as strings. *)

  val list_of : (t -> 'a validated_value) -> t -> 'a list validated_value
  (** [list_of v x] ensure that [x] is a list that satisfy [v] (all errors are
      collected). *)

  val record :
    ((string * t) list -> 'a validated_record) -> t -> 'a validated_value
  (** [record v x] ensure that [x] has the shape validated by [v] (all errors
      are collected). *)

  val option : (t -> 'a validated_value) -> t -> 'a option validated_value
  (** [option v x] validate a value using [v] that can be [null] wrapped into an
      option. *)

  val pair :
       (t -> 'a validated_value)
    -> (t -> 'b validated_value)
    -> t
    -> ('a * 'b) validated_value
  (** [pair fst snd x] validated a pair (described as {!val:Yocaml.Data.pair},
      [{"fst": a, "snd": b}]). *)

  val triple :
       (t -> 'a validated_value)
    -> (t -> 'b validated_value)
    -> (t -> 'c validated_value)
    -> t
    -> ('a * 'b * 'c) validated_value
  (** [triple f g h v] define a triple validator built on top of {!val:pair}.
      (Under the hood, it treat value like that [(x, (y, z))]. )*)

  val quad :
       (t -> 'a validated_value)
    -> (t -> 'b validated_value)
    -> (t -> 'c validated_value)
    -> (t -> 'd validated_value)
    -> t
    -> ('a * 'b * 'c * 'd) validated_value
  (** [quad f g h i v] define a quad validator built on top of {!val:triple}.
      (Under the hood, it treat value like that [(w, (x, (y, z)))]. )*)

  val sum : (string * (t -> 'a validated_value)) list -> t -> 'a validated_value
  (** [sum [(k, v)] value] validated a sum value using the representation
      described in {!val:Yocaml.Data.sum}:
      [{"constr": const_value, "value": e}]. *)

  val either :
       (t -> 'a validated_value)
    -> (t -> 'b validated_value)
    -> t
    -> ('a, 'b) Either.t validated_value
  (** [either left right v] validated a [either] value. *)

  (** {2 Validators on parsed data}

      Validators to use when data is already parsed. *)

  val positive : int -> int validated_value
  (** [positive x] ensure that [x] is positive. *)

  val positive' : float -> float validated_value
  (** [positive x] ensure that [x] is positive. *)

  val bounded : min:int -> max:int -> int -> int validated_value
  (** [bounded ~min ~max x] ensure that [x] is included in the range [[min;max]]
      (both included). *)

  val bounded' : min:float -> max:float -> float -> float validated_value
  (** [bounded ~min ~max x] ensure that [x] is included in the range [[min;max]]
      (both included). *)

  val non_empty : 'a list -> 'a list validated_value
  (** [non_empty l] ensure that [l] is non-empty. *)

  val equal :
       ?pp:(Format.formatter -> 'a -> unit)
    -> ?equal:('a -> 'a -> bool)
    -> 'a
    -> 'a
    -> 'a validated_value
  (** [equal ?pp ?equal x y] ensure that [y] is equal to [x]. [pp] is used for
      error-reporting. *)

  val not_equal :
       ?pp:(Format.formatter -> 'a -> unit)
    -> ?equal:('a -> 'a -> bool)
    -> 'a
    -> 'a
    -> 'a validated_value
  (** [not_equal ?pp ?equal x y] ensure that [y] is different of [x]. [pp] is
      used for error-reporting. *)

  val gt :
       ?pp:(Format.formatter -> 'a -> unit)
    -> ?compare:('a -> 'a -> int)
    -> 'a
    -> 'a
    -> 'a validated_value
  (** [gt ?pp ?equal x y] ensure that [x] is greater than [y]. [pp] is used for
      error-reporting. *)

  val ge :
       ?pp:(Format.formatter -> 'a -> unit)
    -> ?compare:('a -> 'a -> int)
    -> 'a
    -> 'a
    -> 'a validated_value
  (** [ge ?pp ?equal x y] ensure that [x] is greater or equal to [y]. [pp] is
      used for error-reporting. *)

  val lt :
       ?pp:(Format.formatter -> 'a -> unit)
    -> ?compare:('a -> 'a -> int)
    -> 'a
    -> 'a
    -> 'a validated_value
  (** [lt ?pp ?equal x y] ensure that [x] is lesser than [y]. [pp] is used for
      error-reporting. *)

  val le :
       ?pp:(Format.formatter -> 'a -> unit)
    -> ?compare:('a -> 'a -> int)
    -> 'a
    -> 'a
    -> 'a validated_value
  (** [le ?pp ?equal x y] ensure that [x] is lesser or equal to [y]. [pp] is
      used for error-reporting. *)

  val one_of :
       ?pp:(Format.formatter -> 'a -> unit)
    -> ?equal:('a -> 'a -> bool)
    -> 'a list
    -> 'a
    -> 'a validated_value
  (** [one_of ?pp ?equal li x] ensure that [x] is include in [li]. [pp] is used
      for error-reporting. *)

  val where :
       ?pp:(Format.formatter -> 'a -> unit)
    -> ?message:('a -> string)
    -> ('a -> bool)
    -> 'a
    -> 'a validated_value
  (** [where ?pp predicate x] ensure that [x] is satisfying [predicate]. [pp] is
      used for error-reporting.*)

  val const : 'a -> 'b -> ('a, 'c) result
  (** [const k r] wrap [k] as valid and discard [r]. *)

  (** {2 Infix operators} *)

  module Infix : sig
    (** Infix operators are essentially used to compose data validators (unlike
        binding operators, which are used to compose record validation
        fragments).

        Infix operators are used to trivially compose validators. If you have a
        complicated set of validation rules, it is advisable to build a
        dedicated function to avoid making the validation rule complex to read. *)

    val ( & ) :
         ('a -> 'b validated_value)
      -> ('b -> 'c validated_value)
      -> 'a
      -> 'c validated_value
    (** [(v1 & v2) x] sequentially compose [v2 (v1 x)], so [v1] following by
        [v2]. For example : [int &> positive &> c]. *)

    val ( / ) :
         ('a -> 'b validated_value)
      -> ('a -> 'b validated_value)
      -> 'a
      -> 'b validated_value
    (** [(v1 / v2) x] perform [v1 x] and if it fail, performs [v2 x]. *)

    val ( $ ) :
      ('a -> 'b validated_value) -> ('b -> 'c) -> 'a -> 'c validated_value
    (** [(v1 $ f) x] perform [f] on the result of [v1 x]. *)
  end

  include module type of Infix
  (** @inline *)

  (** {1 Fields validators}

      Field validators are used to describe parallel validation strategies for
      each field in a {!val:record} and collect errors by field. Usually, a
      field validator takes as arguments the associative list of keys/values in
      a record, the name of the field to be observed and a regular validator. *)

  val required :
       (string * t) list
    -> string
    -> (t -> 'a validated_value)
    -> 'a validated_record
  (** [required assoc field validator] required [field] of [assoc], validated by
      [validator]. *)

  val optional :
       (string * t) list
    -> string
    -> (t -> 'a validated_value)
    -> 'a option validated_record
  (** [optional assoc field validator] optional [field] of [assoc], validated by
      [validator]. *)

  val optional_or :
       (string * t) list
    -> string
    -> default:'a
    -> (t -> 'a validated_value)
    -> 'a validated_record
  (** [optional_or ~default assoc field validator] optional [field] of [assoc],
      validated by [validator]. If the field does not exists, it return default.
      ([default] is not validated) *)

  (** {2 Bindings operators} *)

  module Syntax : sig
    (** Binding operators are used to link fields together to build a complete
        validation.

        A typical usage is:

        {eof@ocaml skip[
          record (fun assoc ->
              let+ field_a = required assoc "fieldA" validator_a
              and+ field_b = optional assoc "fieldB" validator_b
              and+ field_c = required associ "fieldB" validator_c in
              { field_a, field_b, field_c })
        ]eof} *)

    val ( let+ ) : 'a validated_record -> ('a -> 'b) -> 'b validated_record
    (** [let+ x = v in  k x] is [map (fun x -> k x) v]. *)

    val ( and+ ) :
      'a validated_record -> 'b validated_record -> ('a * 'b) validated_record
    (** [let+ x = v and+ y = w in k x y] is [map2 (fun x y -> k x y) v w]. *)
  end

  include module type of Syntax
  (** @inline *)
end

(** {1 Utils} *)

val equal : t -> t -> bool
(** Equality between {!type:t}. *)

val pp : Format.formatter -> t -> unit
(** Pretty-printer for {!type:t} (mostly used for debugging issue). *)

val to_ezjsonm : t -> ezjsonm
(** [to_ezjsonm v] converts a {!type:t} into a {!type:ezjsonm}. *)

val from_ezjsonm : ezjsonm -> t
(** [from_ezjsonm v] converts a {!type:ezjsonm} into a {!type:t}. *)
