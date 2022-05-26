open Util

type (_, 'a) effects =
  | File_exists : Filepath.t -> (< file_exists : unit ; .. >, bool) effects
  | Target_exists :
      Filepath.t
      -> (< target_exists : unit ; .. >, bool) effects
  | Get_modification_time :
      Filepath.t
      -> (< get_modification_time : unit ; .. >, int Try.t) effects
  | Target_modification_time :
      Filepath.t
      -> (< target_modification_time : unit ; .. >, int Try.t) effects
  | Read_file :
      Filepath.t
      -> (< read_file : unit ; .. >, string Try.t) effects
  | Content_changes :
      (Filepath.t * string)
      -> ( < content_changes : unit ; .. >
         , (string, unit) Either.t Try.t )
         effects
  | Write_file :
      (Filepath.t * string)
      -> (< write_file : unit ; .. >, unit Try.t) effects
  | Read_dir :
      (Filepath.t
      * [< `Files | `Directories | `Both ]
      * Filepath.t Preface.Predicate.t)
      -> (< read_dir : unit ; .. >, Filepath.t list) effects
  | Command : string -> (< command : unit ; .. >, int) effects
  | Log : (Log.level * string) -> (< log : unit ; .. >, unit) effects
  | Throw : Error.t -> (< throw : unit ; .. >, 'a) effects
  | Raise : exn -> (< raise_ : unit ; .. >, 'a) effects

module Freer = Preface.Make.Freer_monad.Over (struct
  type 'a t =
    ( < file_exists : unit
      ; target_exists : unit
      ; get_modification_time : unit
      ; target_modification_time : unit
      ; read_file : unit
      ; write_file : unit
      ; content_changes : unit
      ; read_dir : unit
      ; log : unit
      ; command : unit
      ; throw : unit
      ; raise_ : unit >
    , 'a )
    effects
end)

let file_exists path = Freer.perform $ File_exists path
let target_exists path = Freer.perform $ Target_exists path
let get_modification_time path = Freer.perform $ Get_modification_time path

let target_modification_time path =
  Freer.perform $ Target_modification_time path
;;

let read_file path = Freer.perform $ Read_file path

let content_changes file content =
  Freer.perform $ Content_changes (file, content)
;;

let write_file path content = Freer.perform $ Write_file (path, content)
let log level message = Freer.perform $ Log (level, message)
let trace = log Trace
let debug = log Debug
let info = log Info
let warning = log Warning
let alert = log Alert
let throw error = Freer.perform $ Throw error
let raise_ exn = Freer.perform $ Raise exn

let read_directory k path predicate =
  Freer.perform $ Read_dir (path, k, predicate)
;;

let read_children = read_directory `Both
let read_child_files = read_directory `Files
let read_child_directories = read_directory `Directories
let command cmd = Freer.perform $ Command cmd

module Traverse = Preface.List.Monad.Traversable (Freer)
include Freer

let sequence lists handler first =
  lists >>= List.fold_left (fun t x -> t >>= handler x) first
;;

let collect_children_with_callback f paths predicate =
  List.map (fun path -> f path predicate) paths
  |> Traverse.sequence
  |> map List.flatten
;;

let collect_children = collect_children_with_callback read_children
let collect_child_files = collect_children_with_callback read_child_files

let collect_child_directories =
  collect_children_with_callback read_child_directories
;;

let process_files paths predicate effect =
  let effects = collect_child_files paths predicate in
  sequence effects (fun x _ -> effect x) (return ())
;;

module Infix = struct
  include Freer.Applicative.Infix
  include (Freer.Infix : Preface.Specs.Monad.INFIX with type 'a t := 'a t)
end

module Syntax = struct
  include Freer.Applicative.Syntax
  include (Freer.Syntax : Preface.Specs.Monad.SYNTAX with type 'a t := 'a t)
end

include (Infix : module type of Infix with type 'a t := 'a t)
include (Syntax : module type of Syntax with type 'a t := 'a t)
