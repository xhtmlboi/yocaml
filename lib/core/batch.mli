(* YOCaml a static blog generator.
   Copyright (C) 2025 The Funkyworkers and The YOCaml's developers

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

(** Allows you to run batches of actions (on lists, directories, etc.) *)

val iter : 'a list -> ('a -> Action.t) -> Action.t
(** [iter list action cache] Executes the given action on all element of the
    given list. The cache is passed from call to call. {b see:}
    {!val:Action.batch_list} *)

val fold :
     state:'a
  -> 'b list
  -> ('b -> 'a -> Cache.t -> (Cache.t * 'a) Eff.t)
  -> Cache.t
  -> (Cache.t * 'a) Eff.t
(** [fold ~state list action cache] Executes the given action on all element of
    the given list. The cache is passed from call to call and instead of
    {!val:iter}, you can maintain your own additional state. {b see:}
    {!val:Action.fold_list} *)

val iter_children :
     ?only:[ `Both | `Directories | `Files ]
  -> ?where:(Path.t -> bool)
  -> Path.t
  -> (Path.t -> Action.t)
  -> Action.t
(** [iter_children ?only ?where path action cache] Executes the given action on
    all child files of the given path. The cache is passed from call to call.
    {b see:} {!val:Action.batch} *)

val fold_children :
     ?only:[ `Both | `Directories | `Files ]
  -> ?where:(Path.t -> bool)
  -> state:'a
  -> Path.t
  -> (Path.t -> 'a -> Cache.t -> (Cache.t * 'a) Eff.t)
  -> Cache.t
  -> (Cache.t * 'a) Eff.t
(** [fold_children ?only ?where ~state path action cache] Executes the given
    action on all child files of the given path. The cache is passed from call
    to call and instead of {!val:iter_children}, you can maintain your own
    additional state. {b see:} {!val:Action.fold} *)

val iter_files :
  ?where:(Path.t -> bool) -> Path.t -> (Path.t -> Action.t) -> Action.t
(** [iter_files] is [iter_children ~only:`Files]. *)

val fold_files :
     ?where:(Path.t -> bool)
  -> state:'a
  -> Path.t
  -> (Path.t -> 'a -> Cache.t -> (Cache.t * 'a) Eff.t)
  -> Cache.t
  -> (Cache.t * 'a) Eff.t
(** [fold_files] is [fold_children ~only:`Files]. *)

val iter_directories :
  ?where:(Path.t -> bool) -> Path.t -> (Path.t -> Action.t) -> Action.t
(** [iter_directories] is [iter_children ~only:`Directories]. *)

val fold_directories :
     ?where:(Path.t -> bool)
  -> state:'a
  -> Path.t
  -> (Path.t -> 'a -> Cache.t -> (Cache.t * 'a) Eff.t)
  -> Cache.t
  -> (Cache.t * 'a) Eff.t
(** [fold_directories] is [fold_children ~only:`Directories]. *)
