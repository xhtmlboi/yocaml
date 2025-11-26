(* YOCaml a static blog generator.
   Copyright (C) 2025 The Funkyworkers and The YOCaml's developers

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

(** Describes a set of (unique) files. Used to apply diffs and delete files that
    have not been created. *)

type t

val empty : t
(** Creates an empty trace. *)

val add : Path.t -> t -> t
(** Add a path to the trace. *)

val from_list : Path.t list -> t
(** Creates a trace from a list of path. *)

val diff : target:t -> t -> Path.t list
(** File diff into a list. *)

val from_directory : on:Eff.filesystem -> Path.t -> t Eff.t
(** Compute a trace from a directory. *)

val equal : t -> t -> bool
(** Equality between traces. *)

val pp : Format.formatter -> t -> unit
(** Pretty printer for traces. *)
