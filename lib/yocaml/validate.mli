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
