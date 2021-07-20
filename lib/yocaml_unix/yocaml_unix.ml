open Yocaml
open Util

let mtime path =
  let open Unix in
  try
    let s = stat path in
    Try.ok $ int_of_float s.st_mtime
  with
  | Unix_error (err, f, p) -> Error.(to_try (Unix (err, f, p)))
;;

let bytes_of_in_channel channel =
  let length = in_channel_length channel in
  let buffer = Bytes.create length in
  let () = really_input channel buffer 0 length in
  buffer
;;

let read filename =
  try
    let channel = open_in filename in
    let bytes = bytes_of_in_channel channel in
    let () = close_in channel in
    Ok (bytes |> Bytes.to_string)
  with
  | _ -> Error.(to_try (Unreadable_file filename))
;;

let rec create_path ?(file_perm = 0o777) path =
  if not (Sys.file_exists path)
  then (
    let parent = Filename.dirname path in
    let () = create_path ~file_perm parent in
    try Unix.mkdir path file_perm with
    | _ -> ())
;;

let write filename content =
  try
    let chan = open_out filename in
    let () = output_string chan content in
    let () = close_out chan in
    Try.ok ()
  with
  | _ -> Error.(to_try (Unreadable_file filename))
;;

let time () =
  let open Unix in
  let t = gmtime $ time () in
  Format.asprintf
    "%d-%d-%d %d:%d;%d"
    (t.tm_year + 1900)
    (succ t.tm_mon)
    t.tm_mday
    t.tm_hour
    t.tm_min
    t.tm_sec
;;

let level_to_string =
  let open Preface.Fun in
  (function
    | Aliases.Trace -> "trace"
    | Aliases.Debug -> "debug"
    | Aliases.Info -> "info"
    | Aliases.Warning -> "warning"
    | Aliases.Alert -> "alert")
  %> String.uppercase_ascii
;;

let fmt s x = "\027[" ^ s ^ "m" ^ x ^ "\027[0m"

let colorize = function
  | Aliases.Trace -> "97", "100;37"
  | Aliases.Debug -> "36", "46;30"
  | Aliases.Info -> "32", "42;30"
  | Aliases.Warning -> "33", "43;30"
  | Aliases.Alert -> "31", "41;30"
;;

let print_level = function
  | Aliases.Trace | Aliases.Debug | Aliases.Info -> Format.printf
  | Aliases.Warning | Aliases.Alert -> Format.eprintf
;;

let log level message =
  let l = level_to_string level in
  let t = fmt "90" (time ()) in
  let cm, cl = colorize level in
  let m = fmt cm message in
  let flag = fmt cl $ " " ^ String.make 1 l.[0] ^ " " in
  print_level level "%s %s | %s\n" flag t m
;;

let read_dir path =
  try Sys.readdir path |> Array.to_list with
  | _ -> []
;;

let read_predicate path pred = function
  | `Files ->
    fun x ->
      let p = x |> into path in
      if Sys.file_exists p && not $ Sys.is_directory p && pred x
      then Some p
      else None
  | `Directories ->
    fun x ->
      let p = x |> into path in
      if Sys.file_exists p && not $ Sys.is_directory p && pred x
      then Some p
      else None
  | `Both ->
    fun x ->
      let p = x |> into path in
      if pred x then Some p else None
;;

let execute program =
  Effect.run
    { handler =
        (fun resume effect ->
          let f : type b. (b -> 'a) -> b Effect.f -> 'a =
           fun resume -> function
            | File_exists path -> resume $ Sys.file_exists path
            | Get_modification_time path -> resume $ mtime path
            | Read_file path -> resume $ read path
            | Write_file (path, content) ->
              let () = create_path (Filename.dirname path) in
              resume $ write path content
            | Read_dir (path, kind, predicate) ->
              let children = read_dir path in
              resume
              $ List.filter_map (read_predicate path predicate kind) children
            | Log (level, message) ->
              let () = log level message in
              resume ()
            | Throw error ->
              let () =
                log Aliases.Alert (Lexicon.crap_there_is_an_error error)
              in
              Error.raise' error
            | Raise exn ->
              let () =
                log Aliases.Alert (Lexicon.crap_there_is_an_exception exn)
              in
              raise exn
          in
          f resume effect)
    }
    program
;;
