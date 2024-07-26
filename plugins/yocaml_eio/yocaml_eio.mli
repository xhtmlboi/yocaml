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

(** Eio runtime for YOCaml.

    Allows you to run YOCaml on a Unix system based on Eio (or source service
    for more complex runtimes). *)

val run :
     ?level:Yocaml_runtime.Log.level
  -> ?custom_error_handler:
       (Format.formatter -> Yocaml.Data.Validation.custom_error -> unit)
  -> (unit -> unit Yocaml.Eff.t)
  -> unit
(** [run ?level ?custom_error_handler program] Runs a Yocaml program in the Eio
    runtime. The log [level] (default: [Debug]) and a [custom_error_handler] can
    be passed as arguments to change the reporting level.*)

val serve :
     ?level:Yocaml_runtime.Log.level
  -> ?custom_error_handler:
       (Format.formatter -> Yocaml.Data.Validation.custom_error -> unit)
  -> target:Yocaml.Path.t
  -> port:int
  -> (unit -> unit Yocaml.Eff.t)
  -> 'a
(** [serve ?level ?custom_error_handler ~target ~port program] serve the
    directory [target] statically and re-run [program] on each refresh. *)

(** {1 Runtime} *)

module Runtime = Runtime
(** Rexports Runtime to be used outside of the package. *)
