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

let iter = Action.batch_list
let fold = Action.fold_list
let iter_children = Action.batch
let fold_children = Action.fold
let iter_files = iter_children ~only:`Files
let iter_directories = iter_children ~only:`Directories
let fold_files ?where ~state = fold_children ~only:`Files ?where ~state

let fold_directories ?where ~state =
  fold_children ~only:`Directories ?where ~state
