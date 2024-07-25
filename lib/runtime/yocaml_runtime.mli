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

(** Utilities common to runtimes based on Logs and Fmt. (ie: Eio and Unix) *)

(** {1 Error handling}

    Common approach to error handling from a runtime. *)

type runtime_error =
  | Unable_to_write_file of Yocaml.Path.t * string
  | Unable_to_create_directory of Yocaml.Path.t
  | Unable_to_read_file of Yocaml.Path.t
  | Unable_to_read_directory of Yocaml.Path.t
  | Unable_to_read_mtime of Yocaml.Path.t
  | Unable_to_perform_command of string * exn
      (** A type describing common runtime errors. *)

val runtime_error_to_string : runtime_error -> string
(** Serialize an error to a string. *)

(** {1 Logging} *)

val log : [ `App | `Error | `Warning | `Info | `Debug ] -> string -> unit
(** [log level message] log a [message] with a given [message]. *)

val setup_logger : ?level:Logs.level -> unit -> unit
(** Set-up a default logger. *)

(** {1 Hashing}

    Hash content using Digestif. *)

val hash_content : string -> string
(** [hash s] hash a string using [SHA256]. *)
