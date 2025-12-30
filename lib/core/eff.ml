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

type 'a t = unit -> 'a

let return x () = x
let bind f x = f (x ())
let map f x = bind (fun m -> return @@ f m) x
let join x = bind (fun x -> x) x
let compose f g x = bind g (f x)
let rcompose f g x = bind f (g x)
let apply ft xt = map (ft ()) xt
let zip x y = apply (map (fun a b -> (a, b)) x) y
let replace x e = map (fun _ -> x) e
let void e = replace () e

let select x y =
  bind
    (function
      | Either.Right v -> return v | Either.Left v -> map (fun f -> f v) y)
    x

let branch s l r =
  let a = map Either.(map_right left) s
  and b = map (fun f x -> Either.right (f x)) l in
  select (select a b) r

let map2 fu a b = apply (map fu a) b
let map3 fu a b c = apply (map2 fu a b) c
let map4 fu a b c d = apply (map3 fu a b c) d
let map5 fu a b c d e = apply (map4 fu a b c d) e
let map6 fu a b c d e f = apply (map5 fu a b c d e) f
let map7 fu a b c d e f g = apply (map6 fu a b c d e f) g
let map8 fu a b c d e f g h = apply (map7 fu a b c d e f g) h

module List = struct
  let traverse f l =
    let rec aux acc = function
      | [] -> map Stdlib.List.rev acc
      | x :: xs -> (aux [@tailcall]) (map2 Stdlib.List.cons (f x) acc) xs
    in
    aux (return []) l

  let sequence l = traverse Fun.id l

  let filter_map f l =
    let rec aux acc = function
      | [] -> return @@ Stdlib.List.rev acc
      | x :: xs ->
          bind (function
            | None -> (aux [@tailcall]) acc xs
            | Some x -> (aux [@tailcall]) (x :: acc) xs)
          @@ f x
    in
    aux [] l

  let fold_left f default list =
    let rec aux acc = function
      | [] -> acc
      | x :: xs -> (aux [@tailcall]) (bind (fun m -> f acc m) x) xs
    in
    aux default list
end

module Infix = struct
  let ( <$> ) = map
  let ( <*> ) = apply
  let ( <*? ) = select
  let ( =<< ) = bind
  let ( >>= ) x f = f =<< x
  let ( >|= ) x f = f <$> x
  let ( =|< ) = map
  let ( >=> ) = compose
  let ( <=< ) = rcompose
end

module Syntax = struct
  let ( let+ ) x f = map f x
  let ( and+ ) = zip
  let ( let* ) x f = bind f x
end

include Infix
include Syntax

type filesystem = [ `Source | `Target ]

type _ Effect.t +=
  | Yocaml_log :
      (Logs.src option * [ `App | `Error | `Warning | `Info | `Debug ] * string)
      -> unit Effect.t
  | Yocaml_failwith : exn -> 'a Effect.t
  | Yocaml_get_time : unit -> int Effect.t
  | Yocaml_file_exists : filesystem * Path.t -> bool Effect.t
  | Yocaml_read_file : filesystem * bool * Path.t -> string Effect.t
  | Yocaml_get_mtime : filesystem * Path.t -> int Effect.t
  | Yocaml_hash_content : string -> string Effect.t
  | Yocaml_write_file : filesystem * Path.t * string -> unit Effect.t
  | Yocaml_erase_file : filesystem * Path.t -> unit Effect.t
  | Yocaml_is_directory : filesystem * Path.t -> bool Effect.t
  | Yocaml_is_file : filesystem * Path.t -> bool Effect.t
  | Yocaml_read_dir : filesystem * Path.t -> Path.fragment list Effect.t
  | Yocaml_create_dir : filesystem * Path.t -> unit Effect.t
  | Yocaml_exec_command :
      string * string list * (int -> bool)
      -> string Effect.t

let perform raw_effect = return @@ Effect.perform raw_effect

let run handler arrow input =
  Effect.Deep.match_with (fun input -> arrow input ()) input handler

exception File_not_exists of filesystem * Path.t
exception Invalid_path of filesystem * Path.t
exception File_is_a_directory of filesystem * Path.t
exception Directory_is_a_file of filesystem * Path.t
exception Directory_not_exists of filesystem * Path.t
exception Provider_error of Required.provider_error

let yocaml_log_src = Logs.Src.create ~doc:"Log emitted by YOCaml" "yocaml"

let log ?src ?(level = `Debug) message =
  perform @@ Yocaml_log (src, level, message)

let raise exn = perform @@ Yocaml_failwith exn
let failwith message = perform @@ Yocaml_failwith (Failure message)
let get_time () = perform @@ Yocaml_get_time ()
let file_exists ~on path = perform @@ Yocaml_file_exists (on, path)

let logf ?src ?(level = `Debug) =
  Format.kasprintf (fun result -> log ?src ~level result)

let is_directory ~on path = perform @@ Yocaml_is_directory (on, path)
let is_file ~on path = perform @@ Yocaml_is_file (on, path)

let exec ?(is_success = Int.equal 0) exec_name ?(args = []) =
  perform @@ Yocaml_exec_command (exec_name, args, is_success)

let exec_cmd ?is_success cmd =
  let command, args = Cmd.normalize cmd in
  exec ?is_success ~args command

let ensure_file_exists ~on f path =
  let* exists = file_exists ~on path in
  if exists then f path else raise (File_not_exists (on, path))

let read_file ?(snapshot = false) ~on =
  ensure_file_exists ~on (fun path ->
      let* is_file = is_file ~on path in
      if is_file then perform @@ Yocaml_read_file (on, snapshot, path)
      else raise @@ File_is_a_directory (on, path))

let read_file_as_metadata (type a) (module P : Required.DATA_PROVIDER)
    (module R : Required.DATA_READABLE with type t = a) ?snapshot ~on path =
  let* file = read_file ?snapshot ~on path in
  file
  |> Option.some
  |> Metadata.validate (module P) (module R)
  |> Result.fold
       ~error:(fun err -> raise @@ Provider_error err)
       ~ok:(fun metadata -> return metadata)

let read_file_with_metadata (type a) (module P : Required.DATA_PROVIDER)
    (module R : Required.DATA_READABLE with type t = a)
    ?(extraction_strategy = Metadata.jekyll) ?snapshot ~on path =
  let* file = read_file ?snapshot ~on path in
  let raw_metadata, content =
    Metadata.extract_from_content ~strategy:extraction_strategy file
  in
  raw_metadata
  |> Metadata.validate (module P) (module R)
  |> Result.fold
       ~error:(fun err -> raise @@ Provider_error err)
       ~ok:(fun metadata -> return (metadata, content))

let get_mtime ~on path =
  let* exists = file_exists ~on path in
  if exists then perform @@ Yocaml_get_mtime (on, path) else return 0

let hash str = perform @@ Yocaml_hash_content str

let create_directory ~on path =
  let rec aux path =
    let* is_file = is_file ~on path in
    if is_file then raise (Directory_is_a_file (on, path))
    else
      let* is_directory = is_directory ~on path in
      if not is_directory then
        let parent = Path.dirname path in
        let* () = aux parent in
        perform @@ Yocaml_create_dir (on, path)
      else return ()
  in
  aux path

let write_file ~on path content =
  let parent = Path.dirname path in
  let* () = create_directory ~on parent in
  perform @@ Yocaml_write_file (on, path, content)

let erase_file ~on path =
  let* file = is_file ~on path in
  if file then perform @@ Yocaml_erase_file (on, path)
  else
    logf ~src:yocaml_log_src ~level:`Warning
      "%a is not a file (or does not exist)" Path.pp path

let read_directory ~on ?(only = `Both) ?(where = fun _ -> true) path =
  let* is_dir = is_directory ~on path in
  if is_dir then
    let predicate child =
      let file = Path.(path / child) in
      let* exists = file_exists ~on file in
      let+ is_dir = is_directory ~on file in
      let predicate =
        match only with
        | `Files -> exists && (not is_dir) && where file
        | `Directories -> exists && is_dir && where file
        | `Both -> exists && where file
      in
      if predicate then Some file else None
    in
    let* children = perform @@ Yocaml_read_dir (on, path) in
    List.filter_map predicate children
  else
    let+ () =
      logf ~src:yocaml_log_src ~level:`Warning "%a does not exist" Path.pp path
    in
    []

let mtime ~on path =
  let rec aux path =
    let* t = get_mtime ~on path in
    let* d = is_directory path ~on in
    if d then
      let* children = read_directory ~on ~only:`Both path in
      Stdlib.List.fold_left
        (fun max_time f ->
          let* a = max_time in
          let+ b = aux f in
          Int.max a b)
        (return t) children
    else return t
  in
  aux path

let get_basename source =
  match Path.basename source with
  | None -> raise (Invalid_path (`Source, source))
  | Some fragment -> return fragment

let copy_file into source =
  let* fragment = get_basename source in
  let dest = Path.(into / fragment) in
  let* content = read_file ~on:`Source source in
  write_file ~on:`Target dest content

let copy_recursive ?new_name ~into source =
  let rec aux ?new_name into source =
    let* is_dir = is_directory ~on:`Target into in
    if is_dir then
      let* source_is_file = is_file ~on:`Source source in
      if source_is_file then
        let* () =
          log ~src:yocaml_log_src ~level:`Debug
          @@ Lexicon.copy_file ?new_name ~into source
        in
        copy_file into source
      else
        let* source_is_directory = is_directory ~on:`Source source in
        if source_is_directory then
          let* () =
            log ~src:yocaml_log_src ~level:`Debug
            @@ Lexicon.copy_directory ?new_name ~into source
          in
          let* name = get_basename source in
          let name = Option.value new_name ~default:name in
          let name = Path.(into / name) in
          let* () = create_directory ~on:`Target name in
          let* children = read_directory ~on:`Source ~only:`Both source in
          let* _ = List.traverse (fun child -> aux name child) children in
          return ()
        else raise (File_not_exists (`Source, source))
    else
      let* is_file = is_file ~on:`Target into in
      if is_file then raise (Directory_is_a_file (`Target, into))
      else
        let* () = create_directory ~on:`Target into in
        aux ?new_name into source
  in
  aux ?new_name into source
