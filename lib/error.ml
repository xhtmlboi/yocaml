type t =
  | List of t Preface.Nonempty_list.t
  | Unix of Unix.error * string * string
  | Unreadable_file of string
  | Unknown of string

exception Error of t

let rec pp formater error =
  let ppf x = Format.fprintf formater x in
  match error with
  | Unknown message -> ppf "Unknown (%s)" message
  | Unix (error, fname, arg) ->
    ppf "Unix (%s, %s, %s)" (Unix.error_message error) fname arg
  | Unreadable_file filename -> ppf "Unreadable_file (%s)" filename
  | List nonempty_list ->
    ppf "List (%a)" (Preface.Nonempty_list.pp pp) nonempty_list
;;

let to_string = Format.asprintf "%a" pp
let to_exn error = Error error
let to_try error = Preface.Result.Error error

let to_validate error =
  let open Preface in
  Validation.Invalid (Nonempty_list.create error)
;;

let raise' error = raise (to_exn error)

let rec equal x y =
  match x, y with
  | Unknown a, Unknown b -> String.equal a b
  | Unix (a, b, c), Unix (x, y, z) ->
    a = x && String.equal b y && String.equal c z
  | Unreadable_file a, Unreadable_file b -> String.equal a b
  | List a, List b -> Preface.Nonempty_list.equal equal a b
  | _ -> false
;;
