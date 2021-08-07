(** Describes the list of errors that can occur in the process of creating a
    blog. *)

(** {1 Errors list}

    The type of errors could be "open", but I find it quite comfortable to
    locate the errors in one place to easily provide conversion and
    manipulation functions. In addition, it allows me to generalize the type
    of [Result] and [Validation] without relying on exceptions. *)

type t =
  | List of t Preface.Nonempty_list.t
      (** Groups several errors into one (mainly to ensure conversions between
          [Try] and [Validate]). *)
  | Labelled_list of string * t Preface.Nonempty_list.t
  | Unix of string * string * string (** Unix related error. *)
  | Unreadable_file of string (** When a file is unreadable. *)
  | Missing_field of string
  | Invalid_field of string
  | Invalid_metadata of string
  | Required_metadata of string list
  | Yaml of string
  | Mustache of string
  | Invalid_date of string
  | Invalid_year of int
  | Invalid_day of int
  | Invalid_month of int
  | Invalid_range of int * int * int
  | Unknown of string (** An unq\ualified error (probably due to laziness). *)
  | Message of string

(** Represents an [Error.t] in [exception]. *)
exception Error of t

(** {1 Conversions} *)

(** Use {!val:pp} to convert an [Error.t] to a [string].*)
val to_string : t -> string

(** Converts an [Error.t] into an [exception]. *)
val to_exn : t -> exn

(** Converts an [Error.t] into a {!type:Preface.Result.t}. *)
val to_try : t -> ('a, t) Preface.Result.t

(** Converts an [Error.t] into a {!type:Preface.Validation.t}. *)
val to_validate : t -> ('a, t Preface.Nonempty_list.t) Preface.Validation.t

(** {1 Actions} *)

(** Raises an [Error.t] as an exception. *)
val raise' : t -> 'a

(** {1 Helpers} *)

(** Pretty-printers for [Error.t]. *)
val pp : Format.formatter -> t -> unit

(** Equality betweens [Error.t]. *)
val equal : t -> t -> bool
