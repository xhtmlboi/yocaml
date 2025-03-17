(* YOCaml a static blog generator.
   Copyright (C) 2024 The Funkyworkers and The YOCaml's developers

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

(** A Sexp is a fairly loose implementation of
    {{:https://en.wikipedia.org/wiki/S-expression} S-expression} that support
    serialization to
    {{:https://en.wikipedia.org/wiki/Canonical_S-expressions} Canonical
     S-Expressions} used to serialise (and persist to disk) arbitrary OCaml data
    structures.

    As the heart of YOCaml is designed to be as small as possible. This is a
    manual reimplementation.*)

(** {1 Definition}

    An S-Expression is a data structure with an extremely simple recursive
    syntax tree. It is made up of [atoms] (character strings) and [nodes] (also
    S-Expressions). *)

(** S-Expression AST. *)
type t = Atom of string | Node of t list

(** Errors that can occur when parsing S-expressions. *)
type parsing_error =
  | Nonterminated_node of int
  | Nonterminated_atom of int
  | Expected_number_or_colon of char * int
  | Expected_number of char * int
  | Unexepected_character of char * int
  | Premature_end_of_atom of int * int

(** Used to describe an invalid S-expression (correctly parsed but does not
    respect a schema). *)
type invalid = Invalid_sexp of t * string

val atom : string -> t
(** [atom x] lift a given string, [x], into a {!type:t}. *)

val node : t list -> t
(** [nod x] lift a given list of {!type:t}, [x], into a {!type:t}. *)

(** {1 Serialization}

    Tools for serializing a Sexp. *)

val to_string : t -> string
(** convert a [S-expression] to a string (with indent). *)

(** {1 Deserialization} *)

val from_string : string -> (t, parsing_error) result
(** [from_string str] Try deserializing a string in Sexp. *)

val from_seq : char Seq.t -> (t, parsing_error) result
(** [from_string str] Try deserializing a string in Sexp. *)

module Canonical : sig
  (** S-Canonical expression used to describe compressed data sources. *)

  (** {1 Deserialization} *)

  val from_string : string -> (t, parsing_error) result
  (** [from_string str] Try deserializing a string in Csexp. *)

  val from_seq : char Seq.t -> (t, parsing_error) result
  (** [from_seq s] Try deserializing a sequence of characters in Csexp. The use
      of a sequence can serve as a basis for easily constructing other sources
      ([string] or [in_channel] for example). *)

  (** {1 Serialization} *)

  val to_buffer : Buffer.t -> t -> unit
  (** [to_buffer buf sexp] outputs [csexp] into the given buffer, [buf]. *)

  val to_string : t -> string
  (** [to_string sexp] converts a [csexp] to a string. *)

  val length : t -> int
  (** [length sexp] gives the length of [csexp] after serialization. *)
end

(** {1 Utils} *)

val equal : t -> t -> bool
(** Equality between {!type:t}. *)

val pp : Format.formatter -> t -> unit
(** Pretty-printer for {!type:t} (mostly used for debugging issue). *)

val pp_pretty : Format.formatter -> t -> unit
(** Pretty-printer for {!type:t} with indentation. *)
