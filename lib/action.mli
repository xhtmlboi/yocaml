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

(** Actions consume {!module:Pipeline} to produce artifacts. This is the entry
    point for a {b construction rule}. *)

val write_file : Cache.t -> Path.t -> (unit, string) Task.t -> Cache.t Eff.t
(** [write_file cache target task] Writes [target] file with content generated
    by [task] if necessary. Returns the modified cache once the action has been
    performed. *)

val copy_file :
  ?new_name:Path.fragment -> into:Path.t -> Cache.t -> Path.t -> Cache.t Eff.t
(** [copy_file ?new_name ~into:target cache source] Copies the [source] file to
    the [target] directory (potentially giving it a new name), taking account of
    dependencies. *)
