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

(** Description of common errors in the various runtimes (at least shared by
    Unix and Eio). *)

(** {1 Types} *)

(** Describes common errors that can occur during the execution of a program in
    a specific runtime. *)
type common =
  | Unable_to_write_file of Yocaml.Path.t * string
  | Unable_to_create_directory of Yocaml.Path.t
  | Unable_to_read_file of Yocaml.Path.t
  | Unable_to_read_directory of Yocaml.Path.t
  | Unable_to_read_mtime of Yocaml.Path.t
  | Unable_to_perform_command of string * exn

(** {1 Utils} *)

val common_to_string : common -> string
(** String representation of a {!type:common}. *)
