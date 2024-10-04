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

(** Utilities for working with the {{:https://erratique.ch/software/logs} Logs}
    library in a given runtime. *)

(** {1 Types} *)

type level = [ `App | `Error | `Warning | `Info | `Debug ]
(** Describe a log-level.*)

(** {1 Helpers} *)

val msg : level -> string -> unit
(** [msg level message] log a [message] with a given [message]. *)

val setup : ?level:level -> unit -> unit
(** Set-up a default logger. *)
