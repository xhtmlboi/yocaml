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

let execute = Generator.run

let sequence lists handler first =
  let open Effect in
  lists >>= List.fold_left (fun t x -> t >>= fun _ -> handler x) first
;;

let process_files path predicate effect =
  sequence (Effect.read_child_files path predicate) effect (Effect.return ())
;;

include Util
include Effect
