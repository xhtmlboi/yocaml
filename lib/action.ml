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

let perform_writing cache target fc hc =
  let open Eff.Syntax in
  let* () = Lexicon.target_is_written target in
  let* () = Eff.write_file ~on:`Target target fc in
  let+ () = Lexicon.target_was_written target in
  Cache.update cache target hc

let write_file cache target task =
  let open Eff.Syntax in
  let deps, eff = Task.destruct task in
  let* interaction = Deps.need_update deps target in
  match interaction with
  | Deps.Nothing ->
      let+ () = Lexicon.target_already_up_to_date target in
      cache
  | Deps.Create ->
      let* () = Lexicon.target_need_to_be_built target in
      let* fc = eff () in
      let* hc = Eff.hash fc in
      perform_writing cache target fc hc
  | Deps.Update -> (
      let* () = Lexicon.target_exists target in
      let* fc = eff () in
      let* hc = Eff.hash fc in
      match Cache.get cache target with
      | Some (pred_h, _) when String.equal hc pred_h ->
          let+ () = Lexicon.target_hash_is_unchanged target in
          cache
      | _ ->
          let* () = Lexicon.target_hash_is_changed target in
          perform_writing cache target fc hc)

let copy_file ?new_name ~into cache path =
  match Path.basename path with
  | None -> Eff.raise @@ Eff.Invalid_path path
  | Some fragment ->
      let name = Option.value ~default:fragment new_name in
      let dest = Path.(into / name) in
      write_file cache dest (Pipeline.read_file path)
