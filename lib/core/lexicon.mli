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

val target_already_up_to_date : Path.t -> string
val target_need_to_be_built : Path.t -> string
val target_is_written : Path.t -> string
val target_was_written : Path.t -> string
val target_hash_is_unchanged : Path.t -> string
val target_hash_is_changed : Path.t -> string
val found_dynamic_dependencies : Path.t -> string
val cache_invalid_csexp : Path.t -> string
val cache_invalid_repr : Path.t -> string
val cache_restored : Path.t -> string
val cache_stored : Path.t -> string
val copy_file : ?new_name:Path.fragment -> into:Path.t -> Path.t -> string
val copy_directory : ?new_name:Path.fragment -> into:Path.t -> Path.t -> string

(** {1 Vocabulary} *)

val backtrace_not_available : string
val there_is_an_error : Format.formatter -> unit -> unit
val unknown_error : Format.formatter -> exn -> unit

val file_not_exists :
  [ `Source | `Target ] -> Path.t -> Format.formatter -> unit -> unit

val invalid_path :
  [ `Source | `Target ] -> Path.t -> Format.formatter -> unit -> unit

val file_is_a_directory :
  [ `Source | `Target ] -> Path.t -> Format.formatter -> unit -> unit

val directory_is_a_file :
  [ `Source | `Target ] -> Path.t -> Format.formatter -> unit -> unit

val directory_not_exists :
  [ `Source | `Target ] -> Path.t -> Format.formatter -> unit -> unit
