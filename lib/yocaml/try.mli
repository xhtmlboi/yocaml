(** A specialised version of [Result] (with {!type:Error.t} as [Error] part).
    [Try] is very useful for producing sequential validations, where as soon
    as a step produces an error, the computation sequence is interrupted.*)

(** {1 Type} *)

(** A specialised version of [Result]. *)
type 'a t = ('a, Error.t) Preface.Result.t

(** {1 Constructors}

    Production of valid ([Ok]) or invalid ([Error]) values. *)

(** Produces a valid value. *)
val ok : 'a -> 'a t

(** Produces an invalid value. *)
val error : Error.t -> 'a t

(** {1 Conversions} *)

(** Produces a [Validate] from a [Try]. *)
val to_validate
  :  'a t
  -> ('a, Error.t Preface.Nonempty_list.t) Preface.Validation.t

(** Produces a [Try] from a [Validate]. *)
val from_validate
  :  ('a, Error.t Preface.Nonempty_list.t) Preface.Validation.t
  -> 'a t

(** {1 Helpers} *)

(** Pretty-printers for [Try.t]. *)
val pp : (Format.formatter -> 'a -> unit) -> Format.formatter -> 'a t -> unit

(** Equality betweens [Try.t]. *)
val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool

(** {1 Implementations}

    Some implementations of some abstractions offered by Preface. *)

(** [Try] is a [Functor] that (logically) implements [map]. *)
module Functor : Preface.Specs.FUNCTOR with type 'a t = 'a t

(** [Try] is an [Applicative] that (logically) implements [apply] and [pure]. *)
module Applicative :
  Preface.Specs.Traversable.API_OVER_APPLICATIVE with type 'a t = 'a t

(** [Try] is also a [Monad] that (logically) implements [bind] and [return]. *)
module Monad : Preface.Specs.Traversable.API_OVER_MONAD with type 'a t = 'a t

(** {1 Infix and Syntax operators}*)

module Infix : sig
  include Preface.Specs.Applicative.INFIX with type 'a t := 'a t
  include Preface.Specs.Monad.INFIX with type 'a t := 'a t
end

module Syntax : sig
  include Preface.Specs.Applicative.SYNTAX with type 'a t := 'a t
  include Preface.Specs.Monad.SYNTAX with type 'a t := 'a t
end

include module type of Infix (** @closed *)

include module type of Syntax (** @closed *)
