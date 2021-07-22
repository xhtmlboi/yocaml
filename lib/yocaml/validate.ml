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
module L = Preface.List.Applicative.Traversable (Applicative)

module Alt =
  Preface.Make.Alt.Over_functor
    (Functor)
    (struct
      type nonrec 'a t = 'a t

      let combine a b =
        match a, b with
        | Preface.Validation.Invalid _, result -> result
        | Preface.Validation.Valid x, _ -> Preface.Validation.Valid x
      ;;
    end)

module Yaml = struct
  let as_object yaml is_object is_not_object =
    match yaml with
    | `O obj -> is_object obj
    | _ -> is_not_object
  ;;

  let fetch_field field obj =
    let key = String.lowercase_ascii field in
    List.find_map
      (fun (k, value) ->
        let aux_key = String.lowercase_ascii k in
        if String.equal key aux_key then Some value else None)
      obj
  ;;

  let optional' validator field obj =
    Option.fold
      ~none:(valid None)
      ~some:(validator field)
      (fetch_field field obj)
  ;;

  let optional validator field obj =
    optional'
      (fun field x -> validator field x |> Functor.map Option.some)
      field
      obj
  ;;

  let with_default ~default validator field obj =
    Functor.map
      (Option.fold ~none:default ~some:Fun.id)
      (optional validator field obj)
  ;;

  let required validator field obj =
    let open Monad in
    optional validator field obj
    >>= Option.fold
          ~none:Error.(to_validate (Missing_field field))
          ~some:valid
  ;;

  let string field = function
    | `String value -> valid value
    | _ -> Error.(to_validate (Invalid_field field))
  ;;

  let as_string field = function
    | `String value -> valid value
    | `Bool value -> valid (string_of_bool value)
    | `Float value -> valid (string_of_float value)
    | _ -> Error.(to_validate (Invalid_field field))
  ;;

  let bool field = function
    | `Bool value -> valid value
    | `String value ->
      let b = String.(lowercase_ascii value |> trim) in
      if b = "true"
      then valid true
      else if b = "false"
      then valid false
      else Error.(to_validate (Invalid_field field))
    | _ -> Error.(to_validate (Invalid_field field))
  ;;

  let int field = function
    | `Float value -> valid (int_of_float value)
    | _ -> Error.(to_validate (Invalid_field field))
  ;;

  let float field = function
    | `Float value -> valid value
    | _ -> Error.(to_validate (Invalid_field field))
  ;;

  let list f field = function
    | `A list -> List.map (f field) list |> L.sequence
    | _ -> Error.(to_validate (Invalid_field field))
  ;;
end
