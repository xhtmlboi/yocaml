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

module Dummy = struct
  type t = {
      name : string
    ; age : int
    ; nouns : string list
    ; is_fun : bool option
  }

  let entity_name = "dummy"
  let neutral = Yocaml.Metadata.required entity_name

  let validate =
    let open Yocaml.Data.Validation in
    record (fun assoc ->
        let+ name = required assoc "name" string
        and+ age = required assoc "age" (int & positive)
        and+ nouns = optional_or assoc ~default:[] "nouns" (list_of string)
        and+ is_fun = optional assoc "funny" bool in
        { name; age; nouns; is_fun })

  let equal { name = name_a; age = age_a; nouns = nouns_a; is_fun = is_fun_a }
      { name = name_b; age = age_b; nouns = nouns_b; is_fun = is_fun_b } =
    String.equal name_a name_b
    && Int.equal age_a age_b
    && List.equal String.equal nouns_a nouns_b
    && Option.equal Bool.equal is_fun_a is_fun_b

  let pp =
    let open Fmt in
    record
      [
        field "name" (fun { name; _ } -> name) string
      ; field "age" (fun { age; _ } -> age) int
      ; field "nouns" (fun { nouns; _ } -> nouns) (list string)
      ; field "is_fun" (fun { is_fun; _ } -> is_fun) (option bool)
      ]

  let testable = Alcotest.testable pp equal
end
