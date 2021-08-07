open Yocaml.Util

let file_exists = Sys.file_exists
let is_directory = Sys.is_directory
let target_exists = file_exists

let get_modification_time path =
  let open Unix in
  try
    let s = stat path in
    Yocaml.Try.ok $ int_of_float s.st_mtime
  with
  | Unix_error (err, f, p) ->
    Yocaml.Error.(to_try (Unix (Unix.error_message err, f, p)))
;;

let target_modification_time = get_modification_time

let bytes_of_in_channel channel =
  let length = in_channel_length channel in
  let buffer = Bytes.create length in
  let () = really_input channel buffer 0 length in
  buffer
;;

let read_file filename =
  try
    let channel = open_in filename in
    let bytes = bytes_of_in_channel channel in
    let () = close_in channel in
    Ok (bytes |> Bytes.to_string)
  with
  | _ -> Yocaml.Error.(to_try (Unreadable_file filename))
;;

let rec create_dir ?(file_perm = 0o777) path =
  if not (Sys.file_exists path)
  then (
    let parent = Filename.dirname path in
    let () = create_dir ~file_perm parent in
    try Unix.mkdir path file_perm with
    | _ -> ())
;;

let write_file filename content =
  try
    let chan = open_out filename in
    let () = output_string chan content in
    let () = close_out chan in
    Yocaml.Try.ok ()
  with
  | _ -> Yocaml.Error.(to_try (Unreadable_file filename))
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
  let open Yocaml in
  (function
    | Log.Trace -> "trace"
    | Log.Debug -> "debug"
    | Log.Info -> "info"
    | Log.Warning -> "warning"
    | Log.Alert -> "alert")
  %> String.uppercase_ascii
;;

let fmt s x = "\027[" ^ s ^ "m" ^ x ^ "\027[0m"

let colorize =
  let open Yocaml in
  function
  | Log.Trace -> "97", "100;37"
  | Log.Debug -> "36", "46;30"
  | Log.Info -> "32", "42;30"
  | Log.Warning -> "33", "43;30"
  | Log.Alert -> "31", "41;30"
;;

let print_level =
  let open Yocaml in
  function
  | Log.Trace | Log.Debug | Log.Info -> Format.printf
  | Log.Warning | Log.Alert -> Format.eprintf
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
