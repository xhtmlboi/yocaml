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
  type t = Jingoo.Jg_types.tvalue

  let rec from = function
    | Yocaml.Data.Null -> Jingoo.Jg_types.Tnull
    | Yocaml.Data.Bool b -> Jingoo.Jg_types.Tbool b
    | Yocaml.Data.Int i -> Jingoo.Jg_types.Tint i
    | Yocaml.Data.Float f -> Jingoo.Jg_types.Tfloat f
    | Yocaml.Data.String s -> Jingoo.Jg_types.Tstr s
    | Yocaml.Data.List l -> Jingoo.Jg_types.Tlist (List.map from l)
    | Yocaml.Data.Record a ->
        Jingoo.Jg_types.Tobj (List.map (fun (k, v) -> (k, from v)) a)

  let render ?(strict = true) parameters content =
    let env = Jingoo.Jg_types.{ std_env with strict_mode = strict } in
    Jingoo.Jg_template.from_string ~env ~models:parameters content
end

let read_template ?snapshot ?strict template =
  Yocaml.Pipeline.read_template (module Tpl) ?snapshot ?strict template

let read_templates ?snapshot ?strict templates =
  Yocaml.Pipeline.read_templates (module Tpl) ?snapshot ?strict templates

module Pipeline = struct
  let as_template (type a)
      (module I : Yocaml.Required.DATA_INJECTABLE with type t = a) ?snapshot
      ?strict template =
    Yocaml.Pipeline.as_template
      (module Tpl)
      (module I)
      ?snapshot ?strict template
end

include Tpl
