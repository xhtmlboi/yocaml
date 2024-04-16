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
    point for a {b construction rule}. In general, a chain of actions maitizes a
    cache and is used in this way:

    {[
      let open Eff.Infix in
      restore_cache ~on path_of_cache
      >>= action_a
      >>= action_b
      >>= action_c
      >>= store_cache ~on path_of_cache
    ]} *)

type t = Cache.t -> Cache.t Eff.t
(** As it is necessary to maintain the cache during the various artifact
    production phases, an action is a function that takes a cache and returns
    the modified cache, wrapped in an effect. *)

val restore_cache : on:Eff.filesystem -> Path.t -> Cache.t Eff.t
(** [restore_cache path] Reads or initiates the cache in a given [path]. *)

val store_cache : on:Eff.filesystem -> Path.t -> Cache.t -> unit Eff.t
(** [store_cache path cache] saves the [cache] in a given [path]. *)

val write_file : Path.t -> (unit, string * Deps.t) Task.t -> t
(** [write_file target task cache] Writes [target] file with content generated
    by [task] if necessary. Returns the modified cache once the action has been
    performed.

    The task passed as an argument returns the contents of the file to be built
    and the dynamic dependencies produced by the task (which will be cached). *)

val copy_file : ?new_name:Path.fragment -> into:Path.t -> Path.t -> t
(** [copy_file ?new_name ~into:target source cache] Copies the [source] file to
    the [target] directory (potentially giving it a new name), taking account of
    dependencies. *)

val batch :
     ?only:[ `Files | `Directories | `Both ]
  -> ?where:(Path.t -> bool)
  -> Path.t
  -> (Path.t -> t)
  -> t
(** [batch ?only ?where path action cache] Executes the given action on all
    child files of the given path. The cache is passed from call to call. *)
