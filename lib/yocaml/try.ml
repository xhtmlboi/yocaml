type 'a t = ('a, Error.t) Preface.Result.t

let ok x = Ok x
let error e = Error e
let pp inner_pp = Preface.Result.pp inner_pp Error.pp
let equal inner_eq = Preface.Result.equal inner_eq Error.equal

let to_validate = function
  | Ok x -> Preface.Validation.Valid x
  | Error err -> Error.to_validate err
;;

let from_validate = function
  | Preface.Validation.Valid x -> Ok x
  | Preface.Validation.Invalid errs -> Error.to_try (Error.List errs)
;;

module Functor = Preface.Result.Functor (Error)
module Applicative = Preface.Result.Applicative (Error)
module Monad = Preface.Result.Monad (Error)

module Infix = struct
  include Applicative.Infix
  include Monad.Infix
end

module Syntax = struct
  include Applicative.Syntax
  include Monad.Syntax
end

include Infix
include Syntax
