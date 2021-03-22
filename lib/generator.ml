let mtime path =
  let open Unix in
  try
    let s = stat path in
    Try.ok @@ int_of_float s.st_mtime
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
  let t = gmtime @@ time () in
  Format.asprintf
    "%d-%d-%d %d:%d;%d"
    (t.tm_year + 1900)
    (succ t.tm_mon)
    t.tm_mday
    t.tm_hour
    t.tm_min
    t.tm_sec
;;

let log level message =
  let l =
    (let open Aliases in
    match level with
    | Trace -> "trace"
    | Debug -> "debug"
    | Info -> "info"
    | Warning -> "warning"
    | Alert -> "alert")
    |> String.uppercase_ascii
  in
  let t = time () in
  print_endline (Format.asprintf "%s [%s]\t%s" t l message)
;;

let run program =
  Effect.run
    { handler =
        (fun resume effect ->
          let f : type b. (b -> 'a) -> b Effect.f -> 'a =
           fun resume -> function
            | File_exists path -> resume @@ Sys.file_exists path
            | Get_modification_time path -> resume @@ mtime path
            | Read_file path -> resume @@ read path
            | Write_file (path, content) -> resume @@ write path content
            | Log (level, message) ->
              let () = log level message in
              resume ()
            | Throw error -> Error.raise' error
          in
          f resume effect)
    }
    program
;;
