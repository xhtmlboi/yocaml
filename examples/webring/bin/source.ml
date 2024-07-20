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

open Yocaml

let root = Path.rel [ "examples"; "webring" ]
let source_root = root
let css = Path.(source_root / "css")
let index = Path.(source_root / "index.md")
let members = Path.(source_root / "members.yml")
let templates = Path.(source_root / "templates")
let template file = Path.(templates / file)
let binary = Path.rel [ Sys.argv.(0) ]
