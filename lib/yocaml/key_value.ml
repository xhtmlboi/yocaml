open Util

type ('a, 'b, 'c) visitor = ('b -> 'c) -> (unit -> 'c) -> 'a -> 'c

let find_assoc ?(case_sensitive = false) key list =
  let f = if case_sensitive then Fun.id else String.lowercase_ascii in
  let requested_key = f key in
  List.find_map
    (fun (key, value) ->
      let current_key = f key in
      if String.equal requested_key current_key then Some value else None)
    list
;;

let hook_on_invalid_field kind key =
  let open Preface.Validation in
  let open Preface.Nonempty_list in
  function
  | Invalid (Last (Error.Invalid_field msg)) ->
    Error.(
      to_validate (Invalid_field (Format.asprintf "%s[%s]: %s" kind key msg)))
  | x -> x
;;

let hook_on_invalid_mono_list =
  let open Preface.Validation in
  function
  | Invalid nel ->
    Error.(to_validate (Labelled_list ("list is not mono", nel)))
  | x -> x
;;

module L = Preface.List.Applicative.Traversable (Validate.Applicative)

module type VALIDABLE = sig
  type t

  val as_object : (t, (string * t) list, 'a) visitor
  val as_list : (t, t list, 'a) visitor
  val as_atom : (t, string, 'a) visitor
  val as_string : (t, string, 'a) visitor
  val as_boolean : (t, bool, 'a) visitor
  val as_integer : (t, int, 'a) visitor
  val as_float : (t, float, 'a) visitor
end

module type VALIDATOR = sig
  type t

  val object_ : t -> (string * t) list Validate.t
  val list : t -> t list Validate.t
  val atom : t -> string Validate.t
  val string : t -> string Validate.t
  val boolean : t -> bool Validate.t
  val integer : t -> int Validate.t
  val float : t -> float Validate.t
  val text : t -> string Validate.t
  val object_and : ((string * t) list -> 'a Validate.t) -> t -> 'a Validate.t
  val list_and : (t list -> 'a Validate.t) -> t -> 'a Validate.t
  val list_of : (t -> 'a Validate.t) -> t -> 'a list Validate.t
  val atom_and : (string -> 'a Validate.t) -> t -> 'a Validate.t
  val string_and : (string -> 'a Validate.t) -> t -> 'a Validate.t
  val boolean_and : (bool -> 'a Validate.t) -> t -> 'a Validate.t
  val integer_and : (int -> 'a Validate.t) -> t -> 'a Validate.t
  val float_and : (float -> 'a Validate.t) -> t -> 'a Validate.t
  val text_and : (string -> 'a Validate.t) -> t -> 'a Validate.t

  val optional_field
    :  ?case_sensitive:bool
    -> (t -> 'a Validate.t)
    -> string
    -> t
    -> 'a option Validate.t

  val optional_field_or
    :  ?case_sensitive:bool
    -> default:'a
    -> (t -> 'a Validate.t)
    -> string
    -> t
    -> 'a Validate.t

  val required_field
    :  ?case_sensitive:bool
    -> (t -> 'a Validate.t)
    -> string
    -> t
    -> 'a Validate.t

  val optional_assoc
    :  ?case_sensitive:bool
    -> (t -> 'a Validate.t)
    -> string
    -> (string * t) list
    -> 'a option Validate.t

  val optional_assoc_or
    :  ?case_sensitive:bool
    -> default:'a
    -> (t -> 'a Validate.t)
    -> string
    -> (string * t) list
    -> 'a Validate.t

  val required_assoc
    :  ?case_sensitive:bool
    -> (t -> 'a Validate.t)
    -> string
    -> (string * t) list
    -> 'a Validate.t
end

module Make_validator (KV : VALIDABLE) = struct
  type t = KV.t

  let object_and additional_validator =
    KV.as_object additional_validator (fun () ->
        Validate.error $ Error.Invalid_field "Object expected")
  ;;

  let list_and additional_validator =
    KV.as_list additional_validator (fun () ->
        Validate.error $ Error.Invalid_field "List expected")
  ;;

  let list_of inner_validator subject =
    let open Preface.Fun.Infix in
    list_and (L.sequence % List.map inner_validator) subject
    |> hook_on_invalid_mono_list
  ;;

  let atom_and additional_validator =
    KV.as_atom additional_validator (fun () ->
        Validate.error $ Error.Invalid_field "Atom expected")
  ;;

  let string_and additional_validator =
    KV.as_string additional_validator (fun () ->
        Validate.error $ Error.Invalid_field "String expected")
  ;;

  let boolean_and additional_validator =
    KV.as_boolean additional_validator (fun () ->
        Validate.error $ Error.Invalid_field "Boolean expected")
  ;;

  let integer_and additional_validator =
    KV.as_integer additional_validator (fun () ->
        Validate.error $ Error.Invalid_field "Integer expected")
  ;;

  let float_and additional_validator =
    KV.as_float additional_validator (fun () ->
        Validate.error $ Error.Invalid_field "Float expected")
  ;;

  let text_and additional_validator subject =
    let error () = Validate.error $ Error.Invalid_field "Text expected" in
    let open Validate.Monad in
    let open Validate.Alt in
    KV.as_string Validate.valid error subject
    <|> KV.as_atom Validate.valid error subject
    <|> (KV.as_boolean Validate.valid error subject >|= string_of_bool)
    <|> (KV.as_integer Validate.valid error subject >|= string_of_int)
    <|> (KV.as_float Validate.valid error subject >|= string_of_float)
    >>= additional_validator
  ;;

  let object_ = object_and Validate.valid
  let list = list_and Validate.valid
  let atom = atom_and Validate.valid
  let string = string_and Validate.valid
  let boolean = boolean_and Validate.valid
  let integer = integer_and Validate.valid
  let float = float_and Validate.valid
  let text = text_and Validate.valid

  let optional_aux kind case_sensitive validator key subject =
    Option.fold
      ~none:(Validate.valid None)
      ~some:validator
      (find_assoc ~case_sensitive key subject)
    |> hook_on_invalid_field kind key
  ;;

  let optional_field ?(case_sensitive = false) validator key subject =
    let open Preface.Fun.Infix in
    let open Validate.Monad in
    object_ subject
    >>= optional_aux "field" case_sensitive (map Option.some % validator) key
  ;;

  let optional_field_or
      ?(case_sensitive = false)
      ~default
      validator
      key
      subject
    =
    let open Validate.Monad in
    optional_field ~case_sensitive validator key subject
    >|= Option.value ~default
  ;;

  let required_field ?(case_sensitive = false) validator key subject =
    let open Validate.Monad in
    optional_field ~case_sensitive validator key subject
    >>= Option.fold
          ~none:Error.(to_validate (Missing_field key))
          ~some:Validate.valid
  ;;

  let optional_assoc ?(case_sensitive = false) validator key =
    let open Preface.Fun.Infix in
    let open Validate.Monad in
    optional_aux "assoc" case_sensitive (map Option.some % validator) key
  ;;

  let optional_assoc_or
      ?(case_sensitive = false)
      ~default
      validator
      key
      subject
    =
    let open Validate.Monad in
    optional_assoc ~case_sensitive validator key subject
    >|= Option.value ~default
  ;;

  let required_assoc ?(case_sensitive = false) validator key subject =
    let open Validate.Monad in
    optional_assoc ~case_sensitive validator key subject
    >>= Option.fold
          ~none:Error.(to_validate (Missing_field key))
          ~some:Validate.valid
  ;;
end

module Jsonm_object = struct
  type t =
    [ `Null
    | `Bool of bool
    | `Float of float
    | `String of string
    | `A of t list
    | `O of (string * t) list
    ]

  let as_object valid invalid = function
    | `O kv -> valid kv
    | _ -> invalid ()
  ;;

  let as_list valid invalid = function
    | `A v -> valid v
    | _ -> invalid ()
  ;;

  (* Atoms are not supported for JSONM*)
  let as_atom _valid invalid _ = invalid ()

  let as_string valid invalid = function
    | `String s -> valid s
    | _ -> invalid ()
  ;;

  let as_boolean valid invalid = function
    | `Bool b -> valid b
    | _ -> invalid ()
  ;;

  let as_integer valid invalid = function
    | `Float f -> valid $ int_of_float f
    | _ -> invalid ()
  ;;

  let as_float valid invalid = function
    | `Float f -> valid f
    | _ -> invalid ()
  ;;
end

module Jsonm_validator = Make_validator (Jsonm_object)
