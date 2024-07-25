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

open Yocaml

module D2 = D2.Make (struct
  let source = Path.rel [ "examples"; "d2-unix" ]
end)

let () =
  match Array.to_list Sys.argv with
  | _ :: "serve" :: xs ->
      let port =
        Option.bind (List.nth_opt xs 0) int_of_string_opt
        |> Option.value ~default:8000
      in
      Yocaml_unix.serve ~level:`Info ~target:D2.target ~port D2.process_all
  | _ -> Yocaml_unix.run D2.process_all
