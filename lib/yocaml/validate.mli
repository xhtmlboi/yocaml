(** A specialised version of [Validation] (with a nonempty list of
    {!type:Error.t} as [Invalid] part). [Validate] is very useful to produce
    parallel validations, where each error is accumulated, as opposed to [Try]
    which stops the computation at the first error.*)

(** {1 Type} *)

(** A specialised version of [Validation]. *)
type 'a t = ('a, Error.t Preface.Nonempty_list.t) Preface.Validation.t

(** {1 Constructors}

    Production of valid ([Valid]) or invalid ([Inavlid]) values. *)

(** Produces a valid value. *)
val valid : 'a -> 'a t

(** Produces an invalid value. *)
val invalid : Error.t Preface.Nonempty_list.t -> 'a t

(** Produces an invalid value using an [Error]. *)
val error : Error.t -> 'a t

(** {1 Conversions} *)

(** Produces a [Try] from a [Validate]. *)
val to_try : 'a t -> ('a, Error.t) Preface.Result.t

(** Produces a [Validate] from a [Try]. *)
val from_try : ('a, Error.t) Preface.Result.t -> 'a t

(** {1 Helpers} *)

(** Pretty-printers for [Validate.t]. *)
val pp : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit

(** Equality betweens [Validate.t]. *)
val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool

(** {1 Implementation}

    Some implementations of some abstractions offered by Preface. *)

(** [Validate] is a [Functor] that (logically) implements [map]. *)
module Functor : Preface_specs.FUNCTOR with type 'a t = 'a t

(** [Validate] is an [Applicative] that (logically) implements [apply] and
    [pure]. *)
module Applicative :
  Preface_specs.Traversable.API_OVER_APPLICATIVE with type 'a t = 'a t

(** [Validate] is an [Alt] that (logically) implements [combine]. *)
module Alt : Preface_specs.Alt.API with type 'a t = 'a t

(** [Validate] is a [Selective] that (logically) implements [select] and
    [branch]. *)
module Selective : Preface_specs.SELECTIVE with type 'a t = 'a t

(** [Validate] is also a [Monad] that (logically) implements [bind] and
    [return]. *)
module Monad : Preface_specs.Traversable.API_OVER_MONAD with type 'a t = 'a t

(** {1 Validators} *)

(** {2 Yaml} *)

module Yaml : sig
  (** [as_object yaml valid invalid] If [yaml] is an object, applies the
      [valid] function to the key value list, otherwise returns the value
      [invalid]. *)
  val as_object
    :  [> `O of (string * 'a) list ]
    -> ((string * 'a) list -> 'b)
    -> 'b
    -> 'b

  (** [fetch_field key list] Retrieves the value attached to [key] in [list].

      This function is quite suitable for use with [as_object]:

      {[
        as_object
          my_object
          (Validate.valid % fetch_field "Hello")
          Error.(to_validate $ Invalid_metadata "object")
        (* Returns an option with the field *)
      ]} *)
  val fetch_field : string -> (string * 'a) list -> 'a option

  (** Finds an optional field and applies a validation to it. The validator
      can return None. The function works well with [as_object]. *)
  val optional'
    :  (string -> 'a -> 'b option t)
    -> string
    -> (string * 'a) list
    -> 'b option t

  (** Same of [optional'] except that the validator can never returns an empty
      value.*)
  val optional
    :  (string -> 'a -> 'b t)
    -> string
    -> (string * 'a) list
    -> 'b option t

  (** Same of [optional] but handle a default case. *)
  val with_default
    :  default:'b
    -> (string -> 'a -> 'b t)
    -> string
    -> (string * 'a) list
    -> 'b t

  (** Same of [optional] but the field must be present. *)
  val required
    :  (string -> 'a -> 'b t)
    -> string
    -> (string * 'a) list
    -> 'b t

  (** A validator for a String. *)
  val string : string -> [> `String of string ] -> string t

  (** A validator for a String which can handle [bool], [float] and [int] as
      String. *)
  val as_string
    :  string
    -> [> `String of string | `Bool of bool | `Float of float ]
    -> string t

  (** A validator for a Boolean. *)
  val bool : string -> [> `String of string | `Bool of bool ] -> bool t

  (** A validator for an Int. *)
  val int : string -> [> `Float of float ] -> int t

  (** A validator for a Float. *)
  val float : string -> [> `Float of float ] -> float t

  (** A validator for List. *)
  val list
    :  (string -> 'a -> 'b t)
    -> string
    -> [> `A of 'a list ]
    -> 'b list t
end
