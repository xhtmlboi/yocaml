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

type t = Tz.t * Yocaml.Archetype.Datetime.t

let make ?(tz = Tz.Gmt) date = (tz, date)

let to_string (tz, dt) =
  let tz = Tz.to_string tz in
  Format.asprintf "%a" (Yocaml.Archetype.Datetime.pp_rfc822 ~tz ()) dt

let to_string_rfc3339 (tz, dt) =
  let tz = Tz.to_string_rfc3339 tz in
  Format.asprintf "%a" (Yocaml.Archetype.Datetime.pp_rfc3339 ~tz ()) dt

let compare (_, a) (_, b) = Yocaml.Archetype.Datetime.compare a b
