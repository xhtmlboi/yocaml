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

type t = Cache.t -> Cache.t Eff.t

let perform_writing target cache fc hc dynamic_deps =
  let open Eff.Syntax in
  let* () = Lexicon.target_is_written target in
  let* () = Eff.write_file ~on:`Target target fc in
  let+ () = Lexicon.target_was_written target in
  Cache.update ~deps:dynamic_deps cache target hc

let perform_update target cache eff =
  let open Eff.Syntax in
  let* () = Lexicon.target_exists target in
  let* fc, dynamic_deps = eff () in
  let* hc = Eff.hash fc in
  match Cache.get cache target with
  | Some (pred_h, _) when String.equal hc pred_h ->
      let+ () = Lexicon.target_hash_is_unchanged target in
      Cache.update ~deps:dynamic_deps cache target pred_h
  | _ ->
      let* () = Lexicon.target_hash_is_changed target in
      perform_writing target cache fc hc dynamic_deps

let write_file target task cache =
  let rec aux dynamic_deps replay =
    let open Eff.Syntax in
    let deps, eff = Task.destruct task in
    let* interaction =
      Deps.need_update (Deps.concat deps dynamic_deps) target
    in
    match interaction with
    | Deps.Nothing -> (
        (* If there is nothing to do and that this is the first time we've
           visited this case, inspect the cached dynamic dependencies.
           From my understanding, this is the only "complicated" case of dynamic
           dependencies. But it may change over time... sorry, I'm not very
           professional. *)
        match (Cache.get cache target, replay) with
        | Some (_, dynamic_deps), false when not (Deps.is_empty dynamic_deps) ->
            (* If an entry exists in the cache and the target is attached to
               dynamic dependencies, try to rebuild the file taking into account
               the dynamic dependencies. *)
            let* () = Lexicon.found_dynamic_dependencies target in
            aux dynamic_deps true
        | None, false ->
            (* If there's no information in the cache, it's annoying and dynamic
               dependencies will probably have to be rechecked, right? In some
               cases, a file will be rebuilt, which is a bit of a shame, but it
               allows you to be less rigorous about cache maintenance, in the
               event of corruption or concurrent access. So it's a loss that's
               considered acceptable... sorry about that, but I'm not sure
               there's a "panacea". *)
            let* () = Lexicon.target_not_in_cache target in
            perform_update target cache eff
        | _ ->
            (* As a generic case, it would seem that there's nothing to be
               done. *)
            let+ () = Lexicon.target_already_up_to_date target in
            cache)
    | Deps.Create ->
        (* The file doesn't exist, so no matter what has been cached, all
           effects must be performed. *)
        let* () = Lexicon.target_need_to_be_built target in
        let* fc, dynamic_deps = eff () in
        let* hc = Eff.hash fc in
        perform_writing target cache fc hc dynamic_deps
    | Deps.Update ->
        (* Whatever happens, we must perform the effect to recover the dynamic
           dependencies. *)
        perform_update target cache eff
  in
  aux Deps.empty false

let copy_file ?new_name ~into path cache =
  match Path.basename path with
  | None -> Eff.raise @@ Eff.Invalid_path path
  | Some fragment ->
      let name = Option.value ~default:fragment new_name in
      let dest = Path.(into / name) in
      write_file dest Task.(Pipeline.(no_dynamic_deps <$> read_file path)) cache
