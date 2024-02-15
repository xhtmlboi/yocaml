open Yocaml.Util

type 'a t = 'a

let bind x f = f x
let return x = x
let get_time () = Unix.gettimeofday ()
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

let level_to_logs =
  let open Yocaml in
  function
  | Log.Trace -> Logs.App
  | Log.Debug -> Logs.Debug
  | Log.Info -> Logs.Info
  | Log.Warning -> Logs.Warning
  | Log.Alert -> Logs.Error
;;

let log level message =
  let lvl = level_to_logs level in
  Logs.msg lvl (fun pp -> pp "%s" message)
;;

let read_dir path =
  try Sys.readdir path |> Array.to_list with
  | _ -> []
;;

let hash value =
  Digestif.SHA256.(digest_string value |> to_hex)
;;

let content_changes path new_content =
  let open Yocaml.Try.Monad in
  let+ old_content = read_file path in
  let new_content_checksum = hash new_content
  and old_content_checksum = hash old_content in
  not (String.equal new_content_checksum old_content_checksum)
;;

let command = Sys.command
