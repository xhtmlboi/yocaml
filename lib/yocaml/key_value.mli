(** To attach additional content to documents, [YOCaml] uses a Metadata
    mechanism. Generally, the formats used for this kind of metadata ([Yaml],
    [JSON] or even [TOML]) can be abstractly represented as abstract objects,
    like a key-value table.

    This module abstracts the validation logic for key-value structured data. *)

(** {1 Description of a format}

    To be able to validate structured data, one must first provide visitors
    for each data type supported by the metadata description logic. *)

(** A visitor takes a structured data structure and if it respects the
    expected schema, applies a function with the extracted data, otherwise it
    applies another function. In a slightly less generic way, the function
    that acts on the extracted data can act as a validation and the one that
    is applied in case of non respect of the structure is the failure
    function.*)
type ('a, 'b, 'c) visitor = ('b -> 'c) -> (unit -> 'c) -> 'a -> 'c

(** {2 The set of visitors for a key-value structurable object} *)

(** Creating a set of validators for a key-value structure only involves
    implementing the {!module-type:KEY_VALUE_OBJECT} module. *)
module type KEY_VALUE_OBJECT = sig
  (** {2 Types} *)

  (** The type describing the key-value data structure. *)
  type t

  (** {2 Visitors}

      A visitor is quite simple and can be summarised as follows:

      {[
        let as_xxxx valid invalid observed_value =
          if is_xxx observed_value
          then valid (extract_xxx observed_value)
          else invalid ()
        ;;
      ]} *)

  (** Visitor for Objects. For example, in
      {{:https://github.com/mirage/ezjsonm/blob/master/lib/ezjsonm.ml#L18}
      Ezjsonm} (which is a simpler wrapper for the
      {{:https://erratique.ch/software/jsonm/doc/index.html} Jsonm library}),
      The AST is described in this way:

      {[
        type value =
          [ `Null
          | `Bool of bool
          | `Float of float
          | `String of string
          | `A of value list
          | `O of (string * value) list
          ]
      ]}

      Implementing [as_object] would be like writing this:

      {[
        let as_object valid invalid = function
          | `O kv -> valid kv
          | _ -> invalid ()
        ;;
      ]} *)
  val as_object : (t, (string * t) list, 'a) visitor

  (** Visitor for List.*)
  val as_list : (t, t list, 'a) visitor

  (** Visitor for Atoms.*)
  val as_atom : (t, string, 'a) visitor

  (** Visitor for String.*)
  val as_string : (t, string, 'a) visitor

  (** Visitor for Boolean.*)
  val as_boolean : (t, bool, 'a) visitor

  (** Visitor for Integer.*)
  val as_integer : (t, int, 'a) visitor

  (** Visitor for Float.*)
  val as_float : (t, float, 'a) visitor
end

(** {1 Description of a set of validation rules}

    If we have a representation of a key-value object
    ({!module-type:KEY_VALUE_OBJECT}) we can derive the API of its validator. *)

(** The full API derived by operating a representation. *)
module type KEY_VALUE_VALIDATOR = sig
  type t

  (** {2 Simple validator}

      Each simple validator checks that the element of type [t] given as an
      argument respects the expected form. *)

  (** [object_ term] checks that [term] is an [object] and extract the object
      as a list of [string * t]. *)
  val object_ : t -> (string * t) list Validate.t

  (** [list term] checks that [term] is a [list] (and extract it). *)
  val list : t -> t list Validate.t

  (** [atom term] checks that [term] is an [atom], like atoms in [SEXP] (and
      extract it as [string]). *)
  val atom : t -> string Validate.t

  (** [string term] checks that [term] is a [string] (and extract it). *)
  val string : t -> string Validate.t

  (** [boolean term] checks that [term] is a [boolean] (and extract it). *)
  val boolean : t -> bool Validate.t

  (** [list term] checks that [term] is an [integer] (and extract it). *)
  val integer : t -> int Validate.t

  (** [float term] checks that [term] is a [float] (and extract it). *)
  val float : t -> float Validate.t

  (** [text term] checks that [term] is not an [objet] nor a [list] (and
      extract the value as a [string]). *)
  val text : t -> string Validate.t

  (** {2 Composable validator}

      In addition to validating that an element of type [t] has the expected
      form, a compound validator also applies an additional validation. For
      example [string_and string_has_length 3] to validate that the element is
      a string and has a size of 3 (assuming the [string_has_length x]
      function exists). *)

  (** [object_and validator term] checks that [term] is an [object] and valid
      it using [validator]. *)
  val object_and : ((string * t) list -> 'a Validate.t) -> t -> 'a Validate.t

  (** [list_and validator term] checks that [term] is a [list] and valid it
      using [validator]. *)
  val list_and : (t list -> 'a Validate.t) -> t -> 'a Validate.t

  (** [list_of validator term], ie: [list_of int] checks if [term] is a list
      that contains only values that satisfies the given validator. *)
  val list_of : (t -> 'a Validate.t) -> t -> 'a list Validate.t

  (** [atom_and validator term] checks that [term] is an [atom] and valid it
      using [validator]. *)
  val atom_and : (string -> 'a Validate.t) -> t -> 'a Validate.t

  (** [string_and validator term] checks that [term] is a [string] and valid
      it using [validator]. *)
  val string_and : (string -> 'a Validate.t) -> t -> 'a Validate.t

  (** [boolean_and validator term] checks that [term] is a [boolean] and valid
      it using [validator]. *)
  val boolean_and : (bool -> 'a Validate.t) -> t -> 'a Validate.t

  (** [interger_and validator term] checks that [term] is an [integer] and
      valid it using [validator]. *)
  val integer_and : (int -> 'a Validate.t) -> t -> 'a Validate.t

  (** [float_and validator term] checks that [term] is a [float] and valid it
      using [validator]. *)
  val float_and : (float -> 'a Validate.t) -> t -> 'a Validate.t

  (** [text_and validator term] checks that [term] is a [text] and valid it
      using [validator]. *)
  val text_and : (string -> 'a Validate.t) -> t -> 'a Validate.t

  (** {2 Queries over objects}

      As [object_] returns an associative list, you have to manipulate
      associative list functions over and over again to validate an object
      correctly, fortunately there are combinators to help with object
      validation. *)

  (** [optional_field ?case_sensitive validator key term] try to reach the
      value at the [key] position in [term], if the key is not associated the
      function will apply the validation and wrap it into an option, if the
      association is not present the function will returns [None].
      ([case_sensitive] act on the [key] and is [false] by default) *)
  val optional_field
    :  ?case_sensitive:bool
    -> (t -> 'a Validate.t)
    -> string
    -> t
    -> 'a option Validate.t

  (** [optional_field_or ?case_sensitive ~default validator key term] same of
      [optional_field] but instead of wrapping the result into an option, it
      will apply [default] if the association does not exists.
      ([case_sensitive] act on the [key] and is [false] by default) *)
  val optional_field_or
    :  ?case_sensitive:bool
    -> default:'a
    -> (t -> 'a Validate.t)
    -> string
    -> t
    -> 'a Validate.t

  (** [required_field] is like [optional_field] except that the association
      must exist, otherwise the check fails.*)
  val required_field
    :  ?case_sensitive:bool
    -> (t -> 'a Validate.t)
    -> string
    -> t
    -> 'a Validate.t

  (** {3 Example}

      Let's imagine this type of data:

      {[
        type user =
          { firstname : string
          ; lastname : string
          ; age : int
          ; activated : bool
          ; email : string option
          }

        let make_user firstname lastname age activated email =
          { firstname; lastname; age; activated; email }
        ;;
      ]}

      We could validate it in this way (using the standard
      {{:https://github.com/xvw/preface/blob/master/guides/error_handling.md}
      Applicative validation}:

      {[
        let validate obj =
          let open Validate.Applicative in
          make_user
          <$> required_field string "firstname" obj
          <*> required_field string "lastname" obj
          <*> required_field integer "age" obj
          <*> optional_field_or ~default:false boolean "activated" obj
          <*> optional_field string "email" obj
        ;;
      ]} *)

  (** {2 Queries over associatives lists}

      In our previous example, we saw how to use queries on objects. Although
      this approach works, each validation requires the object to be
      deconstructed at each stage. Fortunately, it is possible, using
      associative lists, to deconstruct only once.

      let's take our previous type and function ([user] and [make_user]):

      {[
        let validate_with_assoc =
          object_and (fun assoc ->
              let open Validate.Applicative in
              make_user
              <$> required_assoc string "firstname" assoc
              <*> required_assoc string "lastname" assoc
              <*> required_assoc integer "age" assoc
              <*> optional_assoc_or ~default:false boolean "activated" assoc
              <*> optional_assoc string "email" assoc)
        ;;
      ]}

      The result is identical to the previous one except that this time the
      object is only deconstructed once. *)

  (** Same of [optional_field] but acting on associatives lists. *)
  val optional_assoc
    :  ?case_sensitive:bool
    -> (t -> 'a Validate.t)
    -> string
    -> (string * t) list
    -> 'a option Validate.t

  (** Same of [optional_field_or] but acting on associatives lists. *)
  val optional_assoc_or
    :  ?case_sensitive:bool
    -> default:'a
    -> (t -> 'a Validate.t)
    -> string
    -> (string * t) list
    -> 'a Validate.t

  (** Same of [required_field] but acting on associatives lists. *)
  val required_assoc
    :  ?case_sensitive:bool
    -> (t -> 'a Validate.t)
    -> string
    -> (string * t) list
    -> 'a Validate.t
end

(** {2 Producing a concrete module of validation rules}

    Produces a module from a module with type {!module-type:KEY_VALUE_OBJECT}
    to a module with type {!module-type:KEY_VALUE_VALIDATOR}. *)

module Make_key_value_validator (KV : KEY_VALUE_OBJECT) :
  KEY_VALUE_VALIDATOR with type t = KV.t

(** {1 Jsonm}

    The representation proposed by the
    {{:https://erratique.ch/software/jsonm/doc/index.html} Jsonm} library has
    become so popular that it is the representation used for
    {{:https://github.com/rgrinberg/ocaml-mustache} ocaml-mustache} and
    {{:https://github.com/avsm/ocaml-yaml} ocaml-yaml}. As the AST is
    described by means of polymorphic variants, it is possible to provide
    validators without the need to depend on the library. *)

(** {2 Structure description} *)

module Jsonm_object : sig
  type t =
    [ `Null
    | `Bool of bool
    | `Float of float
    | `String of string
    | `A of t list
    | `O of (string * t) list
    ]

  include KEY_VALUE_OBJECT with type t := t
end

(** {2 Validators} *)

module Jsonm_validator : KEY_VALUE_VALIDATOR with type t = Jsonm_object.t
