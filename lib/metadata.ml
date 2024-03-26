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

type 'a validated = ('a, Required.provider_error) result

type extraction_strategy =
  | Regular of char
  | Custom of (string -> string option * string)

let regular char = Regular char
let jekyll = regular '-'
let custom f = Custom f

let consume content len ~until i =
  let buf = Buffer.create 1 in
  let rec aux i =
    if i >= len then None
    else
      let () = Buffer.add_char buf content.[i] in
      if content.[i] = until then Some (succ i, buf) else aux (succ i)
  in
  aux i

let extract_regular delim content =
  let len = String.length content in
  if len <= 4 then (None, content)
  else
    let consume = consume content len ~until:'\n' in
    if
      List.for_all (Char.equal delim) [ content.[0]; content.[1]; content.[2] ]
      && Char.equal '\n' content.[3]
    then
      let buf = Buffer.create 1 in
      let rec aux i =
        if i >= len then (None, content)
        else
          match content.[i] with
          | c
            when len > i + 3
                 && List.for_all (Char.equal delim)
                      [ c; content.[i + 1]; content.[i + 2] ]
                 && Char.equal '\n' content.[3] ->
              let metadata = buf |> Buffer.to_bytes |> Bytes.to_string in
              let remaining = String.sub content (i + 4) (len - (i + 4)) in
              (Some metadata, remaining)
          | _ -> (
              match consume i with
              | None -> (None, content)
              | Some (new_index, other_buf) ->
                  let () = Buffer.add_buffer buf other_buf in
                  aux new_index)
      in

      aux 4
    else (None, content)

let extract_from_content ~strategy content =
  match strategy with
  | Custom f -> f content
  | Regular delim -> extract_regular delim content

let validate (type a) (module P : Required.DATA_PROVIDER)
    (module R : Required.DATA_READABLE with type t = a) value =
  value
  |> Option.map P.from_string
  |> Option.map (Result.map P.normalize)
  |> Option.fold ~none:R.neutral ~some:(fun normalized ->
         Result.bind normalized (fun value ->
             value
             |> R.validate
             |> Result.map_error (fun error ->
                    Required.Validation_error { entity = R.entity_name; error })))

let required entity = Error (Required.Required_metadata { entity })
