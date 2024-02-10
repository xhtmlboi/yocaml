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

(** A dependency set describes all the files required to build an artifact. *)

(** {1 Types} *)

type t
(** The representation of a set of dependencies, containing {!type:Path.t}.
    Under the bonnet, dependencies are defined by a [Set]. *)

(** {1 Monoid}

    A dependency set is a monoid with the union of two sets as the internal
    composition operator and the empty set as the neutral element. *)

val concat : t -> t -> t
(** [concat a b] constructs the union of two sets of dependencies.
    [concat a b = concat b a]. *)

val empty : t
(** [empty] returns the neutral element of the monoid. It the {b empty set} and
    [concat neutral a = concat a neutral = a]. *)

val reduce : t list -> t
(** [reduce sets] merge many sets in one. *)

(** {1 Utils} *)

val pp : Format.formatter -> t -> unit
(** Pretty-printer for {!type:t}. *)

val equal : t -> t -> bool
(** Equality between {!type:t}. *)
