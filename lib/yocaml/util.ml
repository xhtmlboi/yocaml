let into = Filename.concat
let ( $ ) = ( @@ )

let with_extension ext path =
  let e = Filename.extension path in
  String.equal e $ "." ^ ext
;;

let basename = Filename.basename
let add_extension f extension = f ^ "." ^ extension
let remove_extension = Filename.remove_extension

let replace_extension f =
  let p = remove_extension f in
  add_extension p
;;

let consume_until c i s len =
  let buffer = Buffer.create 1 in
  let rec aux i =
    if i >= len
    then None
    else if s.[i] = c
    then (
      let () = Buffer.add_char buffer s.[i] in
      Some (succ i, buffer))
    else (
      let () = Buffer.add_char buffer s.[i] in
      aux (succ i))
  in
  aux i
;;

let split_metadata s =
  (* A very sad extractor. *)
  let len = String.length s in
  if len <= 3
  then None, s
  else if s.[0] = '-' && s.[1] = '-' && s.[2] = '-'
  then (
    match consume_until '\n' 3 s len with
    | None -> None, s
    | Some (index, _) ->
      let buffer = Buffer.create 1 in
      let rec loop i =
        if i >= len
        then None, s
        else (
          match s.[i] with
          | '-'
            when i + 2 <= String.length s
                 && s.[i + 1] = '-'
                 && s.[i + 2] = '-' ->
            ( Some (Buffer.to_bytes buffer |> Bytes.to_string)
            , String.sub s (i + 3) (len - (i + 3)) )
          | _ ->
            (match consume_until '\n' i s len with
            | Some (i, b) ->
              let () = Buffer.add_buffer buffer b in
              loop i
            | _ -> None, s))
      in
      loop index)
  else None, s
;;
