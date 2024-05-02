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

(** An internal module to centralize logs propagated by the application. And to
    centralise the 'vocabulary' used in the code. *)

(** {1 Logs} *)

val target_already_up_to_date : Path.t -> unit Eff.t
val target_exists : Path.t -> unit Eff.t
val target_need_to_be_built : Path.t -> unit Eff.t
val target_is_written : Path.t -> unit Eff.t
val target_was_written : Path.t -> unit Eff.t
val target_hash_is_unchanged : Path.t -> unit Eff.t
val target_hash_is_changed : Path.t -> unit Eff.t
val found_dynamic_dependencies : Path.t -> unit Eff.t
val target_not_in_cache : Path.t -> unit Eff.t
val cache_invalid_csexp : Path.t -> unit Eff.t
val cache_invalid_repr : Path.t -> unit Eff.t
val cache_restored : Path.t -> unit Eff.t
val cache_stored : Path.t -> unit Eff.t

(** {1 Vocabulary} *)

val backtrace_not_available : string
val there_is_an_error : Format.formatter -> unit -> unit
val unknown_error : Format.formatter -> exn -> unit

val file_not_exists :
  Eff.filesystem -> Path.t -> Format.formatter -> unit -> unit

val invalid_path : Eff.filesystem -> Path.t -> Format.formatter -> unit -> unit

val file_is_a_directory :
  Eff.filesystem -> Path.t -> Format.formatter -> unit -> unit

val directory_not_exists :
  Eff.filesystem -> Path.t -> Format.formatter -> unit -> unit
