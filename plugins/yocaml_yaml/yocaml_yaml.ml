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

module Data_provider = struct
  type t = Yaml.value

  let normalize_number x =
    (* Projecting a potential float into an integer may seem a little radical
       (especially as the function is far from trivial, from my point of view),
       but data validation has been relaxed to accept, when a float is expected,
       an integer. *)
    match Float.classify_float (fst (Float.modf x)) with
    | Float.FP_zero -> Yocaml.Data.int (int_of_float x)
    | _ -> Yocaml.Data.float x

  let rec normalize = function
    | `Null -> Yocaml.Data.null
    | `Bool b -> Yocaml.Data.bool b
    | `Float f -> normalize_number f
    | `String s -> Yocaml.Data.string s
    | `A arr -> Yocaml.Data.list @@ List.map normalize arr
    | `O fields ->
        Yocaml.Data.record @@ List.map (fun (k, v) -> (k, normalize v)) fields

  let from_string str =
    str
    |> Yaml.of_string
    |> Result.map_error (fun error ->
           let message = match error with `Msg msg -> msg in
           let given = str in
           let message = "Yaml: " ^ message in
           Yocaml.Required.Parsing_error { given; message })
end

module Eff = struct
  let read_file_with_metadata (type a)
      (module R : Yocaml.Required.DATA_READABLE with type t = a)
      ?extraction_strategy ~on path =
    Yocaml.Eff.read_file_with_metadata
      (module Data_provider)
      (module R)
      ?extraction_strategy ~on path

  let read_file_as_metadata (type a)
      (module R : Yocaml.Required.DATA_READABLE with type t = a) ~on path =
    Yocaml.Eff.read_file_as_metadata (module Data_provider) (module R) ~on path
end

module Pipeline = struct
  let read_file_with_metadata (type a)
      (module R : Yocaml.Required.DATA_READABLE with type t = a)
      ?extraction_strategy path =
    Yocaml.Pipeline.read_file_with_metadata
      (module Data_provider)
      (module R)
      ?extraction_strategy path

  let read_file_as_metadata (type a)
      (module R : Yocaml.Required.DATA_READABLE with type t = a) path =
    Yocaml.Pipeline.read_file_as_metadata (module Data_provider) (module R) path
end

include Data_provider
