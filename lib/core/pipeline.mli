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

val pipe : ('a -> 'b -> 'c) -> (unit, 'b) Task.t -> ('a, 'c) Task.t
(** [pipe f arr] will pipe an arrow applying [f previous_result result_of arr].
    For example, it can be used for piping files content :
    [pipe (fun x y -> x ^ "\n" ^ y) (read_file path)]. *)

val read_file_as_metadata :
     (module Required.DATA_PROVIDER)
  -> (module Required.DATA_READABLE with type t = 'a)
  -> Path.t
  -> (unit, 'a) Task.t
(** [read_file_as_metadata (module P) (module R) ?extraction_strategy path] is a
    task that read a file located by a [path] and validates the content as
    metadata according to a {!module-type:Yocaml.Required.DATA_PROVIDER}, [P],
    using the description provided by [R] of type
    {!module-type:Yocaml.Required.DATA_READABLE}. *)

val read_file_with_metadata :
     (module Required.DATA_PROVIDER)
  -> (module Required.DATA_READABLE with type t = 'a)
  -> ?extraction_strategy:Metadata.extraction_strategy
  -> Path.t
  -> (unit, 'a * string) Task.t
(** [read_file_with_metadata (module P) (module R) ?extraction_strategy path] is
    a task that read a file located by a [path] and uses an
    [extraction_strategy] to separate the metadata from the content and
    validates the metadata according to a
    {!module-type:Yocaml.Required.DATA_PROVIDER}, [P], using the description
    provided by [R] of type {!module-type:Yocaml.Required.DATA_READABLE}. *)

val pipe_files : ?seperator:string -> Path.t list -> (unit, string) Task.t
(** [pipe_files ?seperator list_of_path] build a task that pipe file toegether
    using [seperator] as a separator. *)

val exec_cmd : ?is_success:(int -> bool) -> Cmd.t -> (unit, unit) Task.t
(** [exec_cmd ?is_success cmd] is a task that performs a shell command
    ({!module:Yocaml.Cmd}). [watched] arguments are used to define the
    dependencies set. When [is_success] is provided, it is called with the exit
    code to determine whether it indicates success or failure. Without
    [is_success], success requires the process to return an exit code of 0. *)

val exec_cmd_with_result :
  ?is_success:(int -> bool) -> Cmd.t -> (unit, string) Task.t
(** [exec_cmd_with_result ?is_success cmd] is like {!val:exec_cmd} but the
    output of the shell command is returned. *)

val as_template :
     (module Required.DATA_TEMPLATE)
  -> (module Required.DATA_INJECTABLE with type t = 'a)
  -> ?strict:bool
  -> Path.t
  -> ('a * string, 'a * string) Task.t
(** [as_template (module T) (module M) ?strict path] is an arrow that apply a
    [path] as a template. *)
