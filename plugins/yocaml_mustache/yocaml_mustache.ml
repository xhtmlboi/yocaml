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

module Tpl = struct
  type t = Mustache.Json.value

  let rec from = function
    | Yocaml.Data.Null -> `Null
    | Yocaml.Data.Bool b -> `Bool b
    | Yocaml.Data.Int i -> `Float (float_of_int i)
    | Yocaml.Data.Float f -> `Float f
    | Yocaml.Data.String s -> `String s
    | Yocaml.Data.List l -> `A (List.map from l)
    | Yocaml.Data.Record r -> `O (List.map (fun (k, v) -> (k, from v)) r)

  let render ?(strict = true) parameters content =
    let layout = Mustache.of_string content in
    Mustache.render ~strict layout (`O parameters)
end

module Pipeline = struct
  let as_template (type a)
      (module I : Yocaml.Required.DATA_INJECTABLE with type t = a) ?strict
      template =
    Yocaml.Pipeline.as_template (module Tpl) (module I) ?strict template
end

include Tpl
