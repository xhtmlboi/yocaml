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
    let* need_shortcut, deps, last_build_date =
      match Cache.get cache target with
      | None ->
          (* If there's no information in the cache, it's annoying and dynamic
             dependencies will probably have to be rechecked, right? In some
             cases, a file will be rebuilt, which is a bit of a shame, but it
             allows you to be less rigorous about cache maintenance, in the
             event of corruption or concurrent access. So it's a loss that's
             considered acceptable... sorry about that, but I'm not sure
             there's a "panacea". *)
          Eff.return (has_dynamic_deps, deps, None)
      | Some (_, dynamic_deps, last_build_date)
        when not (Deps.is_empty dynamic_deps) ->
          (* If an entry exists in the cache and the target is attached to
             dynamic dependencies, try to rebuild the file taking into account
             the dynamic dependencies. *)
          let+ () =
            Eff.log ~level:`Debug @@ Lexicon.found_dynamic_dependencies target
          in
          (false, Deps.concat deps dynamic_deps, last_build_date)
      | Some (_, _, last_build_date) -> Eff.return (false, deps, last_build_date)
    in

    if need_shortcut then Eff.return Update
    else
      let* real_mtime_target = Eff.mtime ~on:`Target target in
      let mtime_target =
        Option.fold ~none:real_mtime_target
          ~some:(fun last_build_date ->
            Int.max last_build_date real_mtime_target)
          last_build_date
      in
      let+ mtime_deps = Deps.get_mtimes deps in
      if List.exists (fun mtime_dep -> mtime_dep >= mtime_target) mtime_deps
      then Update
      else Nothing
  else Eff.return Create

let perform target task ~when_creation ~when_update cache =
  let open Eff.Syntax in
  let deps, eff, has_dynamic_deps = Task.destruct task in
  let* now = Eff.get_time () in
  let* interaction = need_update cache has_dynamic_deps deps target in
  match interaction with
  | Nothing ->
      let+ () =
        Eff.log ~level:`Debug @@ Lexicon.target_already_up_to_date target
      in
      cache
  | Create -> when_creation now target eff cache
  | Update -> when_update now target eff cache

let perform_writing now target cache fc hc dynamic_deps =
  let open Eff.Syntax in
  let* () = Eff.log ~level:`Debug @@ Lexicon.target_is_written target in
  let* () = Eff.write_file ~on:`Target target fc in
  let+ () = Eff.log ~level:`Info @@ Lexicon.target_was_written target in
  Cache.update ~deps:dynamic_deps ~now cache target hc

let perform_update now target eff cache =
  let open Eff.Syntax in
  let* fc, dynamic_deps = eff () in
  let* hc = Eff.hash fc in
  match Cache.get cache target with
  | Some (pred_h, _, _) when String.equal hc pred_h ->
      let+ () =
        Eff.log ~level:`Debug @@ Lexicon.target_hash_is_unchanged target
      in
      Cache.update ~deps:dynamic_deps ~now cache target pred_h
  | _ ->
      let* () =
        Eff.log ~level:`Debug @@ Lexicon.target_hash_is_changed target
      in
      perform_writing now target cache fc hc dynamic_deps

let write_dynamic_file target task =
  perform target task
    ~when_creation:(fun now target eff cache ->
      let open Eff.Syntax in
      let* fc, dynamic_deps = eff () in
      let* hc = Eff.hash fc in
      perform_writing now target cache fc hc dynamic_deps)
    ~when_update:perform_update

let write_static_file target task cache =
  write_dynamic_file target Task.(task ||> no_dynamic_deps) cache

let copy_file ?new_name ~into path cache =
  match Path.basename path with
  | None -> Eff.raise @@ Eff.Invalid_path (`Source, path)
  | Some fragment ->
      let name = Option.value ~default:fragment new_name in
      let dest = Path.(into / name) in
      write_static_file dest (Pipeline.read_file path) cache

let copy_directory ?new_name ~into source cache =
  let open Eff.Syntax in
  let perform_copy _ _ eff cache =
    let+ (), _ = eff () in
    cache
  in
  let* name = Eff.get_basename source in
  let name = Option.value new_name ~default:name in
  let target = Path.(into / name) in
  let task =
    Task.(
      make (Deps.singleton source) (fun () ->
          Eff.copy_recursive ?new_name ~into source)
      ||> no_dynamic_deps)
  in
  perform target task ~when_creation:perform_copy ~when_update:perform_copy
    cache

let fold ?only ?where ~state path action cache =
  let open Eff in
  let* children = read_directory ~on:`Source ?only ?where path in
  Stdlib.List.fold_left
    (fun state file ->
      let* cache, state = state in
      action file state cache)
    (return (cache, state))
    children

let fold_list ~state list action cache =
  let open Eff in
  Stdlib.List.fold_left
    (fun state elt ->
      let* cache, state = state in
      action elt state cache)
    (return (cache, state))
    list

let batch ?only ?where path action cache =
  let open Eff in
  let+ cache, () =
    fold ?only ?where ~state:() path
      (fun file () cache ->
        let+ cache = action file cache in
        (cache, ()))
      cache
  in
  cache

let batch_list list action cache =
  let open Eff in
  let+ cache, () =
    fold_list ~state:() list
      (fun elt () cache ->
        let+ cache = action elt cache in
        (cache, ()))
      cache
  in
  cache

let restore_cache ?(on = `Source) path =
  let open Eff.Syntax in
  let* exists = Eff.file_exists ~on path in
  if exists then
    let* cache_content = Eff.read_file ~on path in
    let sexp = Sexp.Canonical.from_string cache_content in
    match sexp with
    | Error _ ->
        let+ () = Eff.log ~level:`Warning @@ Lexicon.cache_invalid_csexp path in
        Cache.empty
    | Ok sexp ->
        Result.fold
          ~ok:(fun cache ->
            let+ () = Eff.log ~level:`Debug @@ Lexicon.cache_restored path in
            cache)
          ~error:(fun _ ->
            let+ () =
              Eff.log ~level:`Warning @@ Lexicon.cache_invalid_repr path
            in
            Cache.empty)
          (Cache.from_sexp sexp)
  else
    let+ () = Eff.log ~level:`Debug @@ Lexicon.cache_initiated path in
    Cache.empty

let store_cache ?(on = `Source) path cache =
  let open Eff.Syntax in
  let sexp_str = cache |> Cache.to_sexp |> Sexp.Canonical.to_string in
  let* () = Eff.write_file ~on path sexp_str in
  Eff.log ~level:`Debug @@ Lexicon.cache_stored path

let exec_cmd ?is_success cmd target =
  let action _ _ eff cache =
    let open Eff in
    let+ () = eff () in
    cache
  in
  perform target
    (Pipeline.exec_cmd ?is_success (cmd (Cmd.p target)))
    ~when_creation:action ~when_update:action
