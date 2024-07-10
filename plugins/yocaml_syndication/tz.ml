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

type t =
  | Ut
  | Gmt
  | Est
  | Edt
  | Cst
  | Cdt
  | Mst
  | Mdt
  | Pst
  | Pdt
  | Plus of int
  | Minus of int

let plus x = Plus x
let minus x = Minus x

let to_string = function
  | Ut -> "UT"
  | Gmt -> "GMT"
  | Est -> "EST"
  | Edt -> "EDT"
  | Cst -> "CST"
  | Cdt -> "CDT"
  | Mst -> "MST"
  | Mdt -> "MDT"
  | Pst -> "PST"
  | Pdt -> "PSDT"
  | Plus x -> Format.asprintf "+%04d" x
  | Minus x -> Format.asprintf "-%04d" x

let nb r =
  let s = Format.asprintf "%04d" r in
  Format.asprintf "%c%c:%c%c" s.[0] s.[1] s.[2] s.[3]

let to_string_rfc3339 = function
  | Ut | Gmt -> "Z"
  | Est -> "-05:00"
  | Edt -> "-04:00"
  | Cst -> "-06:00"
  | Cdt -> "-05:00"
  | Mst -> "-07:00"
  | Mdt -> "-06:00"
  | Pst -> "-08:00"
  | Pdt -> "-07:00"
  | Plus x -> "+" ^ nb x
  | Minus x -> "-" ^ nb x
