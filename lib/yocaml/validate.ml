type 'a t = ('a, Error.t Preface.Nonempty_list.t) Preface.Validation.t

let valid x = Preface.Validation.Valid x
let invalid x = Preface.Validation.Invalid x
let error x = invalid (Preface.Nonempty_list.create x)
let pp inner_pp = Preface.(Validation.pp inner_pp (Nonempty_list.pp Error.pp))

let equal inner_eq =
  Preface.(Validation.equal inner_eq (Nonempty_list.equal Error.equal))
;;

let to_try = function
  | Preface.Validation.Valid x -> Ok x
  | Preface.Validation.Invalid errs -> Error (Error.List errs)
;;

let from_try = function
  | Ok x -> Preface.Validation.Valid x
  | Error err -> Preface.(Validation.Invalid (Nonempty_list.create err))
;;

module Error_list =
  Preface.Make.Semigroup.From_alt (Preface.Nonempty_list.Alt) (Error)

module Functor = Preface.Validation.Functor (Error_list)
module Applicative = Preface.Validation.Applicative (Error_list)
module Selective = Preface.Validation.Selective (Error_list)
module Monad = Preface.Validation.Monad (Error_list)
module Alt = Preface.Validation.Alt (Error_list)

module Infix = struct
  type nonrec 'a t = 'a t

  include (Alt.Infix : Preface.Specs.Alt.INFIX with type 'a t := 'a t)

  include (
    Selective.Infix : Preface.Specs.Selective.INFIX with type 'a t := 'a t)

  include (Monad.Infix : Preface.Specs.Monad.INFIX with type 'a t := 'a t)
end

module Syntax = struct
  type nonrec 'a t = 'a t

  include (
    Applicative.Syntax :
      Preface.Specs.Applicative.SYNTAX with type 'a t := 'a t)

  include (Monad.Syntax : Preface.Specs.Monad.SYNTAX with type 'a t := 'a t)
end

include (Infix : module type of Infix with type 'a t := 'a t)
include (Syntax : module type of Syntax with type 'a t := 'a t)
