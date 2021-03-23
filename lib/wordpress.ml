module Build = Build
module Deps = Deps
module Generator = Generator
module Effect = Effect
module Error = Error
module Try = Try
module Validate = Validate
module Lexicon = Lexicon
module Aliases = Aliases
module Util = Util

let run = Generator.run

let sequence first lists handler =
  let open Effect in
  lists >>= List.fold_left (fun t x -> t >>= fun _ -> handler x) first
;;

include Util
