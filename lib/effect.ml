open Aliases
open Util

type (_, 'a) effects =
  | File_exists : filepath -> (< file_exists : e ; .. >, bool) effects
  | Get_modification_time :
      filepath
      -> (< get_modification_time : e ; .. >, int Try.t) effects
  | Read_file : filepath -> (< read_file : e ; .. >, string Try.t) effects
  | Write_file :
      (filepath * string)
      -> (< write_file : e ; .. >, unit Try.t) effects
  | Read_dir :
      (filepath
      * [< `Files | `Directories | `Both ]
      * filepath Preface.Predicate.t)
      -> (< read_dir : e ; .. >, filepath list) effects
  | Log : (log_level * string) -> (< log : e ; .. >, unit) effects
  | Throw : Error.t -> (< throw : e ; .. >, 'a) effects

module Freer = Preface.Make.Freer_monad.Over (struct
  type 'a t =
    ( < file_exists : e
      ; get_modification_time : e
      ; read_file : e
      ; write_file : e
      ; read_dir : e
      ; log : e
      ; throw : e >
    , 'a )
    effects
end)

let file_exists path = Freer.perform $ File_exists path
let get_modification_time path = Freer.perform $ Get_modification_time path
let read_file path = Freer.perform $ Read_file path
let write_file path content = Freer.perform $ Write_file (path, content)
let log level message = Freer.perform $ Log (level, message)
let trace = log Trace
let debug = log Debug
let info = log Info
let warning = log Warning
let alert = log Alert
let throw error = Freer.perform $ Throw error

let read_directory k path predicate =
  Freer.perform $ Read_dir (path, k, predicate)
;;

let read_children = read_directory `Both
let read_child_files = read_directory `Files
let read_child_directories = read_directory `Directories

module Traverse = Preface.List.Monad.Traversable (Freer)
include Freer
