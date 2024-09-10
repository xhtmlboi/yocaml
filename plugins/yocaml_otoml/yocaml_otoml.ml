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
  type t = Otoml.t

  let rec normalize = function
    | Otoml.TomlBoolean b -> Yocaml.Data.bool b
    | TomlString str -> Yocaml.Data.string str
    | TomlInteger i -> Yocaml.Data.int i
    | TomlFloat fl -> Yocaml.Data.float fl
    | TomlArray arr | TomlTableArray arr ->
        arr |> List.map normalize |> Yocaml.Data.list
    | TomlTable fields | TomlInlineTable fields ->
        fields
        |> List.map (fun (k, v) -> (k, normalize v))
        |> Yocaml.Data.record
    (* Treat datetime related fields as regular strings. *)
    | TomlOffsetDateTime str
    | TomlLocalDateTime str
    | TomlLocalDate str
    | TomlLocalTime str ->
        Yocaml.Data.string str

  let from_string str =
    str
    |> Otoml.Parser.from_string_result
    |> Result.map_error (fun error ->
           let given = str and message = "Toml: " ^ error in
           Yocaml.Required.Parsing_error { given; message })
end

include Yocaml.Make.Data_reader (Data_provider)
