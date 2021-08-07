open Util

type kind = File of Filepath.t

module Deps_set = Set.Make (struct
  type t = kind

  (* ATM: Simple use of [String.compare] but will have to change as soon
     as multiple kinds will appear! *)
  let compare (File a) (File b) = String.compare a b
end)

include Deps_set

let to_list deps = elements deps
let file path = File path
let to_filepath (File x) = x

module Monoid = Preface.Make.Monoid.Via_combine_and_neutral (struct
  type nonrec t = t

  let neutral = Deps_set.empty
  let combine = Deps_set.union
end)

let get_modification_time = function
  | File path -> Effect.get_modification_time path
;;

let kind_exists = function
  | File path -> Effect.file_exists path
;;

module Nonempty_list_effects = Preface.Nonempty_list.Monad.Traversable (Effect)
module Nonempty_list_try = Preface.Nonempty_list.Monad.Traversable (Try.Monad)

let get_max_modification_time deps =
  let open Preface.Fun.Infix in
  let open Effect.Monad in
  match deps |> to_list |> Preface.Nonempty_list.from_list with
  | None -> Effect.return $ Try.ok None
  | Some deps_list ->
    Nonempty_list_effects.traverse get_modification_time deps_list
    >|= Try.Functor.map
          (Preface.Nonempty_list.fold_left
             (fun acc x ->
               Option.(fold ~none:(Some x) ~some:(some % max x)) acc)
             None)
        % Nonempty_list_try.sequence
;;

let nel_for_one f =
  let open Preface.Nonempty_list in
  let rec loop = function
    | Last x -> f x
    | x :: xs -> if f x then true else loop xs
  in
  loop
;;

let need_update deps target =
  let open Preface.Fun.Infix in
  let open Effect.Monad in
  Effect.target_exists target
  >>= function
  | false -> return $ Try.ok true
  | true ->
    Effect.target_modification_time target
    >>= (function
    | Error err -> return $ Try.error err
    | Ok mtime ->
      (match deps |> to_list |> Preface.Nonempty_list.from_list with
      | None -> return $ Try.ok false
      | Some deps_list ->
        Nonempty_list_effects.traverse get_modification_time deps_list
        >|= Try.Functor.map (nel_for_one (fun x -> x >= mtime))
            % Nonempty_list_try.sequence))
;;
