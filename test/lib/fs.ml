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

type 'a stat = { name : string; mtime : int; content : 'a }

type item = File of string stat | Dir of t stat
and t = item list

let name { name; _ } = name
let content { content; _ } = content
let mtime { mtime; _ } = mtime
let name_of = function File { name; _ } | Dir { name; _ } -> name
let mtime_of = function File { mtime; _ } | Dir { mtime; _ } -> mtime
let is_dir = function Dir _ -> true | File _ -> false
let is_file = function Dir _ -> false | File _ -> true

let compare_item a b =
  (* A slightly naive comparison function, to be consistent when modifying file
     systems. *)
  match (a, b) with
  | File a, File b -> String.compare (name a) (name b)
  | Dir a, Dir b -> String.compare (name a) (name b)
  | Dir _, File _ -> 1
  | File _, Dir _ -> -1

let dir_content_of stat = stat |> content |> List.sort compare_item

let rec equal_item a b =
  (* A slightly naive equality function to implement the [testable] value of
     [Alcotest]. *)
  match (a, b) with
  | File a, File b ->
      String.equal (name a) (name b)
      && String.equal (content a) (content b)
      && Int.equal (mtime a) (mtime b)
  | Dir a, Dir b ->
      String.equal (name a) (name b)
      && Int.equal (mtime a) (mtime b)
      && List.equal equal_item (dir_content_of a) (dir_content_of b)
  | _ -> false

let rec pp_item ppf = function
  | File f ->
      Format.fprintf ppf "└─⟢ %s (mtime: %d) -> \"%s\"" (name f) (mtime f)
        (content f)
  | Dir d ->
      Format.fprintf ppf "└─⟤ %s (mtime: %d) /@[<v -10>@;%a@]" (name d)
        (mtime d)
        (Format.pp_print_list pp_item)
        (content d)

let pp ppf = Format.(fprintf ppf "@,%a@." (pp_print_list pp_item))
let equal = List.equal equal_item
let testable = Alcotest.testable pp equal
let testable_item = Alcotest.testable pp_item equal_item
let from_list x = x |> List.sort compare_item
let file ?(mtime = 1) name content = File { name; mtime; content }

let dir ?mtime name content =
  let mtime =
    Option.value
      ~default:
        (List.fold_left (fun p child -> max p (mtime_of child)) 0 content)
      mtime
  in
  Dir { name; mtime; content = content |> from_list }

let rec get fs path =
  match (fs, path) with
  | item :: xs, [ fragment ] ->
      if String.equal (name_of item) fragment then Some item else get xs path
  | Dir { name; content; _ } :: xs, fragment :: path_xs ->
      if String.equal name fragment then get content path_xs else get xs path
  | _ :: xs, path -> get xs path
  | [], _ -> None

let cat fs path =
  let p = String.split_on_char '/' path in
  match get fs p with
  | None -> Format.asprintf "cat: %s: No such file or directory" path
  | Some (Dir _) -> Format.asprintf "cat: %s: Is a directory" path
  | Some (File { content; _ }) -> content

let ( .%{} ) fs path = get fs @@ String.split_on_char '/' path

let split_path_and_target path =
  let rec aux acc = function
    | [ target ] -> Some (List.rev acc, target)
    | x :: xs -> aux (x :: acc) xs
    | [] -> None
  in
  aux [] path

let update fs path callback =
  match split_path_and_target path with
  | None -> fs
  | Some (path, target) ->
      let rec aux acc fs path =
        match (fs, path) with
        | [], [] ->
            callback ~target ~previous_item:None
            |> Option.fold ~none:acc ~some:(fun x -> x :: acc)
            |> from_list
        | item :: fs_xs, [] ->
            if String.equal (name_of item) target then
              let new_acc = acc @ fs_xs in
              callback ~target ~previous_item:(Some item)
              |> Option.fold ~none:new_acc ~some:(fun x -> x :: new_acc)
              |> from_list
            else aux (item :: acc) fs_xs []
        | (Dir { name; content; _ } as cdir) :: fs_xs, fragment :: path_xs ->
            if String.equal name fragment then
              let new_dir = dir name (aux [] content path_xs) in
              new_dir :: (acc @ fs_xs) |> from_list
            else aux (cdir :: acc) fs_xs path
        | [], fragment :: path_xs ->
            let new_dir = dir fragment (aux [] [] path_xs) in
            new_dir :: acc |> from_list
        | x :: fs_xs, path -> aux (x :: acc) fs_xs path
      in
      aux [] fs path

let ( .%{}<- ) fs path callback =
  update fs (String.split_on_char '/' path) callback

let rename name = function
  | File f -> File { f with name }
  | Dir d -> Dir { d with name }

type trace = { system : t; execution_trace : string list; time : int }

let trace_system { system; _ } = system
let trace_execution { execution_trace; _ } = execution_trace |> List.rev
let trace_time { time; _ } = time
let create_trace ?(time = 0) system = { system; execution_trace = []; time }

let push_trace trace action =
  { trace with execution_trace = action :: trace.execution_trace }

let update_system trace system = { trace with system }
let update_time trace amount = { trace with time = trace.time + amount }

let push_log trace level message =
  let level =
    match level with
    | `App -> "App"
    | `Error -> "Error"
    | `Warning -> "Warning"
    | `Info -> "Info"
    | `Debug -> "Debug"
  in
  push_trace trace @@ Format.asprintf "[LOG][%s]%s" level message

let on_pp ppf = function
  | `Target -> Format.fprintf ppf "Target"
  | `Source -> Format.fprintf ppf "Source"

let push_file_exists trace on path ex =
  push_trace trace
  @@ Format.asprintf "[FILE_EXISTS][%a]%a - %b" on_pp on Yocaml.Path.pp path ex

let push_read_file trace on path =
  push_trace trace
  @@ Format.asprintf "[READ_FILE][%a]%a" on_pp on Yocaml.Path.pp path

let push_time trace = push_trace trace @@ Format.asprintf "[TIME]"

let push_mtime trace on path =
  push_trace trace
  @@ Format.asprintf "[MTIME][%a]%a" on_pp on Yocaml.Path.pp path

let push_hash_content trace content =
  push_trace trace @@ Format.asprintf "[HASH][%s]" content

let push_write_file trace on path content =
  push_trace trace
  @@ Format.asprintf "[WRITE_FILE][%a][%a]%s" on_pp on Yocaml.Path.pp path
       content

let push_create_dir trace on path =
  push_trace trace
  @@ Format.asprintf "[WRITE_FILE][%a][%a]" on_pp on Yocaml.Path.pp path

let push_is_directory trace on path =
  push_trace trace
  @@ Format.asprintf "[IS_DIRECTORY][%a]%a" on_pp on Yocaml.Path.pp path

let push_read_directory trace on path =
  push_trace trace
  @@ Format.asprintf "[READ_DIRECTORY][%a]%a" on_pp on Yocaml.Path.pp path

let push_exec trace prog args =
  push_trace trace
  @@ Format.asprintf "[EXEC][%s]" (String.concat " " (prog :: args))

type _ Effect.t += Yocaml_test_increase_time : int -> unit Effect.t

let increase_time amount =
  Yocaml.Eff.perform @@ Yocaml_test_increase_time amount

let increase_time_with amount cache =
  Yocaml.Eff.(increase_time amount >>= Fun.const @@ return cache)

let perform_exec trace prog args =
  match prog :: args with
  | "echo" :: xs -> (trace, String.concat " " xs)
  | [ "ls"; path ] ->
      ( trace
      , match get trace.system (String.split_on_char '/' path) with
        | None -> "ls: no " ^ path
        | Some x -> Format.asprintf "%a" pp_item x )
  | [ "cat"; path ] ->
      ( trace
      , match get trace.system (String.split_on_char '/' path) with
        | None -> "cat: no " ^ path
        | Some (File { content; _ }) -> content
        | Some (Dir { name; _ }) -> name )
  | [ "write"; target; content ] ->
      let path = String.split_on_char '/' target in
      let system =
        update trace.system path (fun ~target:_ ~previous_item ->
            match previous_item with
            | Some (File _ as p) ->
                file ~mtime:trace.time (name_of p) content |> Option.some
            | x -> x)
      in
      ({ trace with system }, "done")
  | [ "a-cmd"; "--input"; p; "--output"; o ] ->
      let input = String.split_on_char '/' p in
      let output = String.split_on_char '/' o in
      let ctn =
        match get trace.system input with
        | None -> "no-file"
        | Some (Dir _) -> "is-directory"
        | Some (File { content; _ }) -> content
      in
      let system =
        update trace.system output (fun ~target:_ ~previous_item:_ ->
            let p = Filename.basename o in
            Some (file ~mtime:trace.time p (String.uppercase_ascii ctn)))
      in
      ({ trace with system }, "done")
  | x -> (trace, String.concat "," x)

let run ~trace program input =
  let handler =
    let trace = ref trace in
    Effect.Deep.
      {
        exnc = Stdlib.raise
      ; retc = (fun res -> (!trace, res))
      ; effc =
          (fun (type a) (eff : a Effect.t) ->
            let open Yocaml.Eff in
            match eff with
            | Yocaml_test_increase_time amount ->
                Some
                  (fun (k : (a, _) continuation) ->
                    (* We do not track the execution here because it is not
                       revelant for tests. *)
                    let () = trace := update_time !trace amount in
                    continue k ())
            | Yocaml_failwith exn ->
                Some
                  (fun _ ->
                    let s =
                      Format.asprintf "%a"
                        (Yocaml.Diagnostic.exception_to_diagnostic
                           ?custom_error:None ?in_exception_handler:None)
                        exn
                    in
                    Stdlib.raise @@ Failure s)
            | Yocaml_log (_, level, message) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_log !trace level message in
                    continue k ())
            | Yocaml_get_time () ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_time !trace in
                    let time = !trace.time in
                    continue k time)
            | Yocaml_file_exists (on, p) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let path = Yocaml.Path.to_list p in
                    let ex = Option.is_some @@ get !trace.system path in
                    let () = trace := push_file_exists !trace on p ex in
                    continue k ex)
            | Yocaml_read_file (on, gpath) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_read_file !trace on gpath in
                    let path = Yocaml.Path.to_list gpath in
                    match get !trace.system path with
                    | Some (File { content; _ }) -> continue k content
                    | _ ->
                        Stdlib.raise
                        @@ Yocaml.Eff.File_not_exists (`Source, gpath))
            | Yocaml_get_mtime (on, gpath) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_mtime !trace on gpath in
                    let path = Yocaml.Path.to_list gpath in
                    match get !trace.system path with
                    | Some (File { mtime; _ } | Dir { mtime; _ }) ->
                        continue k mtime
                    | _ ->
                        Stdlib.raise
                        @@ Yocaml.Eff.File_not_exists (`Source, gpath))
            | Yocaml_hash_content content ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_hash_content !trace content in
                    (* We do not really hash the content since we are working on very
                       small file content. *)
                    continue k ("H:" ^ content))
            | Yocaml_create_dir (on, gpath) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_create_dir !trace on gpath in
                    let path = Yocaml.Path.to_list gpath in
                    let new_fs =
                      update !trace.system path (fun ~target ~previous_item:_ ->
                          let mtime = !trace.time in
                          Some (dir ~mtime target []))
                    in
                    let () = trace := update_system !trace new_fs in
                    continue k ())
            | Yocaml_write_file (on, gpath, content) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_write_file !trace on gpath content in
                    let path = Yocaml.Path.to_list gpath in
                    let new_fs =
                      update !trace.system path (fun ~target ~previous_item:_ ->
                          let mtime = !trace.time in
                          Some (file ~mtime target content))
                    in
                    let () = trace := update_system !trace new_fs in
                    continue k ())
            | Yocaml_is_directory (on, gpath) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_is_directory !trace on gpath in
                    let path = Yocaml.Path.to_list gpath in
                    let res =
                      match get !trace.system path with
                      | Some (Dir _) -> true
                      | _ -> false
                      (* We suppose that if a file does not exists,
                         it is not a directory... *)
                    in
                    continue k res)
            | Yocaml_read_dir (on, gpath) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_read_directory !trace on gpath in
                    let path = Yocaml.Path.to_list gpath in
                    let res =
                      match get !trace.system path with
                      | Some (Dir { content; _ }) ->
                          Stdlib.List.map name_of content
                      | _ -> []
                      (* If the given path is not a directory, we naïvely
                         returns an empty list, but it fact, this case is
                         already catched by the read_directory
                         function. *)
                    in
                    continue k res)
            | Yocaml_exec_command (prog, args, _) ->
                Some
                  (fun (k : (a, _) continuation) ->
                    let () = trace := push_exec !trace prog args in
                    let new_trace, st = perform_exec !trace prog args in
                    let () = trace := new_trace in
                    continue k st)
            | _ -> None)
      }
  in
  Yocaml.Eff.run handler program input
