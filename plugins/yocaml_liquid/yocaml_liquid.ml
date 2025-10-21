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

open Liquid_ml.Exports

module Tpl = struct
  type t = value

  let rec from = function
    | Yocaml.Data.Null -> Nil
    | Yocaml.Data.Bool b -> Bool b
    | Yocaml.Data.Int i -> Number (float_of_int i)
    | Yocaml.Data.Float f -> Number f
    | Yocaml.Data.String s -> String s
    | Yocaml.Data.List l -> List (List.map from l)
    | Yocaml.Data.Record r ->
        let obj =
          List.fold_left
            (fun acc (k, v) -> Object.add k (from v) acc)
            Object.empty r
        in
        Object obj

  let render ?(strict = true) parameters content =
    let context =
      List.fold_left (fun acc (k, v) -> Ctx.add k v acc) Ctx.empty parameters
    in
    let error_policy = if strict then Settings.Strict else Settings.Warn in
    let settings = Settings.make ~context ~error_policy () in
    Liquid_ml.Liquid.render_text ~settings content
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
