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

(** An extension of {!type:Yocaml.Archetype.Datetime.t} with Timezone support.
*)

(** {1 Types} *)

type t

(** {1 Helpers} *)

val compare : t -> t -> int
(** [compare dt1 dt2] a dummy comparison function that does not care about the
    Timezone (because we expect that every RSS/Atom elements are published on
    the same Timezone). *)

val make : ?tz:Tz.t -> Yocaml.Datetime.t -> t
(** [make ?tz datetime] build a [datetime] associated with a Timezone. *)

val to_string : t -> string
(** [to_string date] converts a [date] into a string. *)

val to_string_rfc3339 : t -> string
(** [to_string_rfc3339 date] converts a [date] into a string according to the
    rfc 3339. *)
