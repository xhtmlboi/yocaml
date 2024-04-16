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
type interaction = Create | Nothing | Update

let need_update cache has_dynamic_deps deps target =
  let open Eff.Syntax in
  let* exists = Eff.file_exists ~on:`Target target in
  if exists then
    let* need_shortcut, deps =
      if has_dynamic_deps then
        match Cache.get cache target with
        | None ->
            (* If there's no information in the cache, it's annoying and dynamic
               dependencies will probably have to be rechecked, right? In some
               cases, a file will be rebuilt, which is a bit of a shame, but it
               allows you to be less rigorous about cache maintenance, in the
               event of corruption or concurrent access. So it's a loss that's
               considered acceptable... sorry about that, but I'm not sure
               there's a "panacea". *)
            let+ () = Lexicon.target_not_in_cache target in
            (true, deps)
        | Some (_, dynamic_deps) when not (Deps.is_empty dynamic_deps) ->
            (* If an entry exists in the cache and the target is attached to
               dynamic dependencies, try to rebuild the file taking into account
               the dynamic dependencies. *)
            let+ () = Lexicon.found_dynamic_dependencies target in
            (false, Deps.concat deps dynamic_deps)
        | _ -> Eff.return (false, deps)
      else Eff.return (false, deps)
    in
    if need_shortcut then Eff.return Update
    else
      let+ mtime_target = Eff.mtime ~on:`Target target
      and+ mtime_deps = Deps.get_mtimes deps in
      if List.exists (fun mtime_dep -> mtime_dep >= mtime_target) mtime_deps
      then Update
      else Nothing
  else Eff.return Create

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
  let open Eff.Syntax in
  let deps, eff, has_dynamic_deps = Task.destruct task in
  let* interaction = need_update cache has_dynamic_deps deps target in
  match interaction with
  | Nothing ->
      let+ () = Lexicon.target_already_up_to_date target in
      cache
  | Create ->
      let* () = Lexicon.target_need_to_be_built target in
      let* fc, dynamic_deps = eff () in
      let* hc = Eff.hash fc in
      perform_writing target cache fc hc dynamic_deps
  | Update -> perform_update target cache eff

let copy_file ?new_name ~into path cache =
  match Path.basename path with
  | None -> Eff.raise @@ Eff.Invalid_path (`Source, path)
  | Some fragment ->
      let name = Option.value ~default:fragment new_name in
      let dest = Path.(into / name) in
      let arr = Task.(Pipeline.read_file path ||> no_dynamic_deps) in
      write_file dest arr cache

let batch ?only ?where path action cache =
  let open Eff in
  let* children = read_directory ~on:`Source ?only ?where path in
  Stdlib.List.fold_left
    (fun cache file -> cache >>= action file)
    (return cache) children

let restore_cache ~on path =
  let open Eff.Syntax in
  let* cache_content = Eff.read_file ~on path in
  let sexp = Sexp.Canonical.from_string cache_content in
  match sexp with
  | Error _ ->
      let+ () = Lexicon.cache_invalid_csexp path in
      Cache.empty
  | Ok sexp ->
      Result.fold
        ~ok:(fun cache ->
          let+ () = Lexicon.cache_restored path in
          cache)
        ~error:(fun _ ->
          let+ () = Lexicon.cache_invalid_repr path in
          Cache.empty)
        (Cache.from_sexp sexp)

let store_cache ~on path cache =
  let open Eff.Syntax in
  let sexp_str = cache |> Cache.to_sexp |> Sexp.Canonical.to_string in
  let* () = Eff.write_file ~on path sexp_str in
  Lexicon.cache_stored path
