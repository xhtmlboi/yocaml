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

module Make (Runtime : Required.RUNTIME) = struct
  let exnc ?custom_error_handler exn =
    let msg =
      Format.asprintf "%a"
        (Diagnostic.exception_to_diagnostic ?custom_error:custom_error_handler
           ~in_exception_handler:true)
        exn
    in
    msg |> Runtime.log `Error |> Runtime.bind (fun () -> raise Exit)

  let runtimec error =
    let error = Runtime.runtime_error_to_string error in
    let msg =
      Format.asprintf "%a" Diagnostic.runtime_error_to_diagnostic error
    in
    Runtime.log `Error msg

  let map f x = Runtime.bind (fun x -> Runtime.return @@ f x) x
  let map_ok f x = map (Result.map f) x

  let read_file ~on snapshots path = function
    | false -> Runtime.read_file ~on path
    | true -> (
        match Path.Map.find_opt path !snapshots with
        | Some content ->
            Runtime.bind
              (fun () -> Runtime.return (Ok content))
              (Runtime.log `Debug
              @@ Format.asprintf "%a already stored" Path.pp path)
        | None ->
            path
            |> Runtime.read_file ~on
            |> map_ok (fun content ->
                   let () = snapshots := Path.Map.add path content !snapshots in
                   content))

  let run ?custom_error_handler program =
    let exnc = exnc ?custom_error_handler in
    let snapshots : string Path.Map.t ref = ref Path.Map.empty in
    let handler =
      Effect.Deep.
        {
          exnc
        ; retc = (fun () -> Runtime.return ())
        ; effc =
            (fun (type a) (eff : a Effect.t) ->
              match eff with
              | Eff.Yocaml_failwith exn -> Some (fun _k -> exnc exn)
              | Eff.Yocaml_log (src, level, message) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind (continue k) (Runtime.log ?src level message))
              | Eff.Yocaml_get_time () ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind (continue k) (Runtime.get_time ()))
              | Eff.Yocaml_file_exists (filesystem, path) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind (continue k)
                        (Runtime.file_exists ~on:filesystem path))
              | Eff.Yocaml_read_file (filesystem, as_snapshot, path) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind
                        (function
                          | Ok x -> continue k x | Error err -> runtimec err)
                        (read_file ~on:filesystem snapshots path as_snapshot))
              | Eff.Yocaml_get_mtime (filesystem, path) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind
                        (function
                          | Ok x -> continue k x | Error err -> runtimec err)
                        (Runtime.get_mtime ~on:filesystem path))
              | Eff.Yocaml_hash_content content ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind (continue k) (Runtime.hash_content content))
              | Eff.Yocaml_write_file (filesystem, path, content) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind
                        (function
                          | Ok x -> continue k x | Error err -> runtimec err)
                        (Runtime.write_file ~on:filesystem path content))
              | Eff.Yocaml_create_dir (filesystem, path) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind
                        (function
                          | Ok x -> continue k x | Error err -> runtimec err)
                        (Runtime.create_directory ~on:filesystem path))
              | Eff.Yocaml_is_directory (filesystem, path) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind (continue k)
                        (Runtime.is_directory ~on:filesystem path))
              | Eff.Yocaml_is_file (filesystem, path) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind (continue k)
                        (Runtime.is_file ~on:filesystem path))
              | Eff.Yocaml_read_dir (filesystem, path) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind
                        (function
                          | Ok x -> continue k x | Error err -> runtimec err)
                        (Runtime.read_dir ~on:filesystem path))
              | Eff.Yocaml_exec_command (prog, args, is_success) ->
                  Some
                    (fun (k : (a, _) continuation) ->
                      Runtime.bind
                        (function
                          | Ok x -> continue k x | Error err -> runtimec err)
                        (Runtime.exec ~is_success prog args))
              | _ -> None)
        }
    in
    Eff.run handler program ()
end
