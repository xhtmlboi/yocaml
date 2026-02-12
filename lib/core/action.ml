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
            Eff.log ~src:Eff.yocaml_log_src ~level:`Debug
            @@ Lexicon.found_dynamic_dependencies target
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
  let cache = Cache.mark cache target in
  let* interaction = need_update cache has_dynamic_deps deps target in
  match interaction with
  | Nothing ->
      let+ () =
        Eff.log ~src:Eff.yocaml_log_src ~level:`Debug
        @@ Lexicon.target_already_up_to_date target
      in
      cache
  | Create -> when_creation now target eff cache
  | Update -> when_update now target eff cache

let perform_writing now target cache fc hc dynamic_deps =
  let open Eff.Syntax in
  let* () =
    Eff.log ~src:Eff.yocaml_log_src ~level:`Debug
    @@ Lexicon.target_is_written target
  in
  let* () = Eff.write_file ~on:`Target target fc in
  let+ () =
    Eff.log ~src:Eff.yocaml_log_src ~level:`Info
    @@ Lexicon.target_was_written target
  in
  Cache.update ~deps:dynamic_deps ~now cache target hc

let perform_update now target eff cache =
  let open Eff.Syntax in
  let* fc, dynamic_deps = eff () in
  let* hc = Eff.hash fc in
  match Cache.get cache target with
  | Some (pred_h, _, _) when String.equal hc pred_h ->
      let+ () =
        Eff.log ~src:Eff.yocaml_log_src ~level:`Debug
        @@ Lexicon.target_hash_is_unchanged target
      in
      Cache.update ~deps:dynamic_deps ~now cache target pred_h
  | _ ->
      let* () =
        Eff.log ~src:Eff.yocaml_log_src ~level:`Debug
        @@ Lexicon.target_hash_is_changed target
      in
      perform_writing now target cache fc hc dynamic_deps

let propagate_target target program cache =
  let handler =
    Effect.Deep.
      {
        exnc = (fun exn -> raise exn)
      ; retc = Eff.return
      ; effc =
          (fun (type a) (eff : a Effect.t) ->
            match eff with
            | Eff.Yocaml_failwith (Eff.Provider_error e) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let open Eff in
                    let new_exn =
                      Eff.Provider_error { e with target = Some target }
                    in
                    let* x = raise new_exn in
                    continue k x)
            | _ -> None)
      }
  in
  Eff.run handler (fun cache -> program cache) cache

let write_dynamic_file target task =
  propagate_target target
    (perform target task
       ~when_creation:(fun now target eff cache ->
         let open Eff.Syntax in
         let* fc, dynamic_deps = eff () in
         let* hc = Eff.hash fc in
         perform_writing now target cache fc hc dynamic_deps)
       ~when_update:perform_update)

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

let write_files f task assoc cache =
  let deps = Task.dependencies_of task in
  let has_dynamic_dependencies = Task.has_dynamic_dependencies task in
  let open Eff in
  let+ cache, _ =
    fold_list ~state:None assoc
      (fun (target, sub_task) performed_task cache ->
        let* task_result =
          (* Frustratingly, we perform the task once, but in the
              presence of dynamic dependencies, it's a bit difficult
              to find the right approach, so I think it's OK.
              [Better API < Better performance] ... in a very subtle case. *)
          match performed_task with
          | None -> (
              let is_maybe_dynamic =
                has_dynamic_dependencies
                && Task.has_dynamic_dependencies sub_task
              in
              if is_maybe_dynamic then
                Eff.(Task.action_of task () >|= fun x -> `Continue x)
              else
                let full_deps =
                  Deps.concat deps (Task.dependencies_of sub_task)
                in
                let* interaction = need_update cache false full_deps target in
                match interaction with
                | Nothing -> Eff.return `Cutoff
                | Create | Update ->
                    Eff.(Task.action_of task () >|= fun x -> `Continue x))
          | Some r -> Eff.return (`Continue r)
        in
        match task_result with
        | `Cutoff -> Eff.return (cache, None)
        | `Continue task_result ->
            let task =
              Task.make ~has_dynamic_dependencies deps (fun () ->
                  Eff.return task_result)
            in
            let+ cache = f target Task.(task >>> sub_task) cache in
            (cache, Some task_result))
      cache
  in
  cache

let write_dynamic_files t = write_files write_dynamic_file t
let write_static_files t = write_files write_static_file t

let mark_cache on cache path =
  match on with `Source -> cache | `Target -> Cache.mark cache path

let restore_cache ?(on = `Target) path =
  let open Eff.Syntax in
  let* exists = Eff.file_exists ~on path in
  if exists then
    let* cache_content = Eff.read_file ~on path in
    let sexp = Sexp.Canonical.from_string cache_content in
    match sexp with
    | Error _ ->
        let+ () =
          Eff.log ~src:Eff.yocaml_log_src ~level:`Warning
          @@ Lexicon.cache_invalid_csexp path
        in
        Cache.empty
    | Ok sexp ->
        Result.fold
          ~ok:(fun cache ->
            let+ () =
              Eff.log ~src:Eff.yocaml_log_src ~level:`Debug
              @@ Lexicon.cache_restored path
            in
            mark_cache on cache path)
          ~error:(fun _ ->
            let+ () =
              Eff.log ~src:Eff.yocaml_log_src ~level:`Warning
              @@ Lexicon.cache_invalid_repr path
            in
            Cache.empty)
          (Cache.from_sexp sexp)
  else
    let+ () =
      Eff.log ~src:Eff.yocaml_log_src ~level:`Debug
      @@ Lexicon.cache_initiated path
    in
    Cache.empty

let store_cache ?(on = `Target) path cache =
  let open Eff.Syntax in
  let sexp_str = cache |> Cache.to_sexp |> Sexp.Canonical.to_string in
  let* () = Eff.write_file ~on path sexp_str in
  Eff.log ~src:Eff.yocaml_log_src ~level:`Debug @@ Lexicon.cache_stored path

let remove_residuals ~target cache =
  let on = `Target in
  let open Eff.Syntax in
  let trace = Cache.trace cache in
  let* () =
    Eff.logf ~src:Eff.yocaml_log_src ~level:`Info "Remove residuals for %a"
      Path.pp target
  in
  let* target_trace = Trace.from_directory ~on target in
  let residuals = Trace.diff ~target:target_trace trace in
  let+ _ =
    Eff.List.traverse
      (fun residual ->
        let* () = Eff.erase_file ~on residual in
        Eff.logf ~src:Eff.yocaml_log_src ~level:`Info "%a deleted!" Path.pp
          residual)
      residuals
  in
  cache

let with_cache ?on path f =
  let open Eff in
  restore_cache ?on path >>= f >>= store_cache ?on path

let exec_cmd ?is_success cmd target =
  let action _ _ eff cache =
    let open Eff in
    let+ () = eff () in
    cache
  in
  perform target
    (Pipeline.exec_cmd ?is_success (cmd (Cmd.p target)))
    ~when_creation:action ~when_update:action

module Static = struct
  let write_file path task = write_static_file path task
  let write_files task = write_static_files task

  let write_file_with_metadata path task =
    write_file path
      (let open Task in
       task >>> Static.keep_content ())
end

module Dynamic = struct
  let write_file path task = write_dynamic_file path task
  let write_files task = write_dynamic_files task

  let write_file_with_metadata path task =
    write_file path
      (let open Task in
       task >>> Dynamic.keep_content ())
end
