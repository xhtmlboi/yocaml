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

let source_root = Path.rel [ "examples"; "d2" ]
let target_root = Path.(source_root / "_build")
let cache_path = Path.(target_root / "cache")

let invoke_d2 source target =
  let open Cmd in
  make "d2"
    [
      param ~prefix:"-" "t" (int 301)
    ; param ~suffix:"=" "layout" (string "elk")
    ; arg (w source)
    ; arg target
    ]

let target_of d2_source =
  let open Path in
  d2_source
  |> move ~into:Path.(target_root / "diagrams")
  |> change_extension "svg"

let batch_diagrams =
  Action.batch ~only:`Files ~where:(Path.has_extension "d2")
    Path.(source_root / "diagrams")
    (fun source ->
      let target = target_of source in
      Action.exec_cmd (invoke_d2 source) target)

let process_all () =
  let open Eff in
  Action.restore_cache cache_path
  >>= batch_diagrams
  >>= Action.store_cache cache_path

let () =
  match Array.to_list Sys.argv with
  | _ :: "serve" :: xs ->
      let port =
        Option.bind (List.nth_opt xs 0) int_of_string_opt
        |> Option.value ~default:8000
      in

      Yocaml_unix.serve ~level:Logs.Info ~target:target_root ~port process_all
  | _ -> Yocaml_unix.run process_all
