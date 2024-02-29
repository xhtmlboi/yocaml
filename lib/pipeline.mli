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

(** A pipeline is a succession of {!module:Task} that enable concrete elements
    to be built. Building a construction system generally consists of composing
    pipelines together. *)

val track_file : Path.t -> (unit, unit) Task.t
(** [track_file filepath] is a dummy task that just add a file to a dependcies
    set and do nothing.

    It useful to watch file modification, like binaries just, for example, to
    replay a task if the binary was recompiled. *)

val track_files : Path.t list -> (unit, unit) Task.t
(** [track_files list_of_filepath] is like {!val:track_file} but for multiple
    files. *)

val read_file : Path.t -> (unit, string) Task.t
(** [read_file path] is a task that read the content of a file. *)

val no_dynamic_deps : unit -> ('a, 'a * Deps.t) Task.t
(** [t >>> no_dynamic_deps] lift [t] do not produce any dynamic deps. *)
