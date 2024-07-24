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

type value = Path of { watched : bool; path : Path.t } | String of string

type arg =
  | Flag of { prefix : string; name : string }
  | Param of {
        prefix : string
      ; suffix : string option
      ; name : string
      ; value : value
    }
  | Plain of value

type t = { command : string; args : arg list }

let param_to_string = function
  | String s -> s
  | Path { path; _ } -> Path.to_string path

let arg_to_string = function
  | Flag { prefix; name } -> [ prefix ^ name ]
  | Param { prefix; suffix = Some suffix; name; value } ->
      [ prefix ^ name ^ suffix ^ param_to_string value ]
  | Param { prefix; suffix = None; name; value } ->
      [ prefix ^ name; param_to_string value ]
  | Plain value -> [ param_to_string value ]

let args_to_string args = args |> List.concat_map arg_to_string
let flag ?(prefix = "-") name = Flag { prefix; name }

let param ?(prefix = "--") ?suffix name value =
  Param { prefix; suffix; name; value }

let arg x = Plain x
let string value = String value
let int value = string (string_of_int value)
let char value = string (String.make 1 value)
let float value = string (string_of_float value)
let bool value = string (string_of_bool value)
let list ?(sep = " ") xs = xs |> String.concat sep |> string
let path ?(watched = false) path = Path { watched; path }
let watched x = path ~watched:true x
let make command args = { command; args }
let s = string
let i = int
let c = char
let f = float
let p = path
let w = watched

let to_string { command; args } =
  command ^ " " ^ (args_to_string args |> String.concat " ")

let pp ppf cmd = Format.fprintf ppf "%s" (to_string cmd)

let pp_arg ppf arg =
  Format.fprintf ppf "%a"
    (Format.pp_print_list
       ~pp_sep:(fun ppf () -> Format.fprintf ppf " ")
       Format.pp_print_string)
    (arg_to_string arg)

let deps_of { args; _ } =
  List.filter_map
    (function
      | Plain (Path { watched = true; path })
      | Param { value = Path { watched = true; path }; _ } ->
          Some path
      | _ -> None)
    args

let normalize { command; args } = (command, args_to_string args)
