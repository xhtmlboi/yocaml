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

let error_to_string = function
  | Sexp.Nonterminated_node x -> Format.asprintf "non-terminated node on [%d]" x
  | Nonterminated_atom x -> Format.asprintf "non-terminated atom on [%d]" x
  | Unexepected_character (c, x) ->
      Format.asprintf "unexpected character [%c] on [%d]" c x
  | Expected_number_or_colon (c, x) ->
      Format.asprintf "expected number or colon on [%d], given: [%c]" x c
  | Expected_number (c, x) ->
      Format.asprintf "expected number on [%d], given: [%c]" x c
  | Premature_end_of_atom (len, x) ->
      Format.asprintf "premature end of atom, expected length [%d] on [%d]" len
        x

module Data_provider = struct
  type t = Sexp.t

  let from_string str =
    str
    |> Sexp.from_string
    |> Result.map_error (fun error ->
           let given = str in
           let message = error_to_string error in
           Required.Parsing_error { given; message })

  let ( <|> ) a b =
    match (a, b) with Some x, _ -> Some x | None, Some y -> Some y | _ -> None

  let literal_string = function
    | {|""|} | "''" -> Some ""
    | str
      when String.starts_with ~prefix:{|"|} str
           && String.ends_with ~suffix:{|""|} str ->
        let len = String.length str in
        Some (String.sub str 1 (len - 2))
    | _ -> None

  let normalize_atom x =
    literal_string x
    |> Option.map Data.string
    <|> (bool_of_string_opt x |> Option.map Data.bool)
    <|> (int_of_string_opt x |> Option.map Data.int)
    <|> (float_of_string_opt x |> Option.map Data.float)
    |> Option.value ~default:(Data.string x)

  let is_record =
    List.for_all (function Sexp.Node [ Atom _; _ ] -> true | _ -> false)

  let rec normalize = function
    | Sexp.Atom "null" -> Data.null
    | Sexp.Atom x -> normalize_atom x
    | Node [] -> Data.list []
    | Node node when is_record node ->
        Data.record
          (List.concat_map
             (function
               | Sexp.Node [ Atom k; value ] -> [ (k, normalize value) ]
               | _ (* not reachable *) -> [])
             node)
    | Node node -> Data.list_of normalize node
end

include Make.Data_reader (Data_provider)

module Canonical = struct
  module Data_provider = struct
    type t = Sexp.t

    let from_string str =
      str
      |> Sexp.Canonical.from_string
      |> Result.map_error (fun error ->
             let given = str in
             let message = error_to_string error in
             Required.Parsing_error { given; message })

    let normalize = Data_provider.normalize
  end

  include Make.Data_reader (Data_provider)
end
