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

let track_files list = Task.make (Deps.from_list list) Eff.return
let track_file file = track_files [ file ]

let read_file file =
  Task.make (Deps.singleton file) (fun () -> Eff.read_file ~on:`Source file)

let no_dynamic_deps () = Task.lift (fun x -> (x, Deps.empty))
