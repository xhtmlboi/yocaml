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

(** A Csexp is a fairly loose implementation of
    {{:https://en.wikipedia.org/wiki/Canonical_S-expressions} Canonical
      S-Expressions} used to serialise (and persist to disk) arbitrary OCaml
    data structures.

    As the heart of YOCaml is designed to be as small as possible. This is a
    manual reimplementation.*)

(** {1 Definition}

    An S-Expression is a data structure with an extremely simple recursive
    syntax tree. It is made up of [atoms] (character strings) and [nodes] (also
    S-Expressions). *)

(** S-Expression AST. *)
type t = Atom of string | Node of t list

val atom : string -> t
(** [atom x] lift a given string, [x], into a {!type:t}. *)

val node : t list -> t
(** [nod x] lift a given list of {!type:t}, [x], into a {!type:t}. *)

(** {1 Serialization}

    Tools for serializing a Csexp. *)

val length : t -> int
(** [length csexp] gives the length of [csexp] after serialization. *)

val to_buffer : Buffer.t -> t -> unit
(** [to_buffer buf csexp] outputs [csexp] into the given buffer, [buf]. *)

val to_string : t -> string
(** [to_string csexp] converts a [csexp] to a string. *)

(** {1 Desrialization} *)

val from_seq :
     char Seq.t
  -> ( t
     , [> `Nonterminated_atom of int
       | `Expected_number_or_colon of char * int
       | `Expected_number of char * int
       | `Unexepected_character of char * int
       | `Premature_end_of_atom of int * int
       | `Nonterminated_node of int ] )
     result
(** [from_seq s] Try deserializing a sequence of characters in CSexp. The use of
    a sequence can serve as a basis for easily constructing other sources
    ([string] or [in_channel] for example). *)

val from_string :
     string
  -> ( t
     , [> `Nonterminated_atom of int
       | `Expected_number_or_colon of char * int
       | `Expected_number of char * int
       | `Unexepected_character of char * int
       | `Premature_end_of_atom of int * int
       | `Nonterminated_node of int ] )
     result
(** [from_string str] Try deserializing a string in CSexp. *)

(** {1 Utils} *)

val equal : t -> t -> bool
(** Equality between {!type:t}. *)

val pp : Format.formatter -> t -> unit
(** Pretty-printer for {!type:t} (mostly used for debugging issue). *)
