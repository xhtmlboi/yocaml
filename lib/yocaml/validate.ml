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
  include Selective.Infix
  include Alt.Infix
  include Monad.Infix
end

module Syntax = struct
  include Selective.Syntax
  include Monad.Syntax
end

include Infix
include Syntax
