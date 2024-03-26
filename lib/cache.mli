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

(** The cache is an artifact of the previous build that tracks information about
    build targets, including dynamic dependencies, and maintains a hashed
    version of the targets. *)

(** {1 Types} *)

type t
(** A representation of the cache (a map indexed by {!type:Path.t}). *)

type entry
(** An entry of the cache. *)

(** {1 Building} *)

val entry : string -> Deps.t -> entry
(** [entry hashed_content deps] creates an entry.*)

val empty : t
(** [empty] returns an empty cache. *)

val from_list : (Path.t * entry) list -> t
(** [from_list l] creates a cache from a list. *)

(** {1 Cache interaction} *)

val update : t -> Path.t -> ?deps:Deps.t -> string -> t
(** [update cache path ?deps content] updates the cache for the [path] entry. If
    an entry already existed at the given key, it will be deleted. *)

val get : t -> Path.t -> (string * Deps.t) option
(** [get cache path] returns the associated hash content and deps set for a
    given path. *)

(** {1 Serialization/Deserialization}

    Supports serialization and deserialization of cache. *)

val to_sexp : t -> Sexp.t
(** [to_sexp cache] Converts a [cache] into a {!module:Sexp}. *)

val from_sexp : Sexp.t -> (t, [> `Invalid_sexp of Sexp.t * [> `Cache ] ]) result
(** [from_sexp sexp] try to converts a {!module:Sexp} into a [cache]. *)

(** {1 Utils} *)

val pp : Format.formatter -> t -> unit
(** Pretty printer for caches. *)

val equal : t -> t -> bool
(** Equality between caches. *)
