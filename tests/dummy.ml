open Yocaml

module Filesystem = struct
  type path = string
  type mtime = int

  let ( / ) = Filename.concat

  module Fs_set = Set.Make (struct
    type t = path * mtime * string * bool

    let compare (p, _, _, _) (k, _, _, _) = String.compare p k
  end)

  type t = Fs_set.t
  type elt = Fs_set.elt

  let empty = Fs_set.empty

  let make files =
    Fs_set.add_seq
      (List.to_seq
         (List.concat_map
            (fun (path, mtime, content, is_file) ->
              if is_file
              then
                [ path, mtime, content, true
                ; Filename.dirname path, mtime, "", false
                ]
              else [ path, mtime, content, false ])
            files))
      empty
  ;;

  let file ?(mtime = 1) ?(content = "") path = path, mtime, content, true
  let dir ?(mtime = 1) path = path, mtime, "", false

  let write_file fs ?mtime filename content =
    let elt mtime = filename, mtime, content, true in
    (match Fs_set.find_opt (elt 1) fs with
    | None -> Try.ok (Option.value ~default:1 mtime, fs)
    | Some ((_, x, _, is_file) as e) ->
      if is_file
      then Try.ok (Option.value ~default:(succ x) mtime, Fs_set.remove e fs)
      else Error.(to_try $ Unreadable_file filename))
    |> Try.Functor.map (fun (time, tmp) -> Fs_set.add (elt time) tmp)
  ;;

  let get_file fs path = Fs_set.find_opt (file path) fs

  let file_exists fs path =
    Option.fold ~none:false ~some:(fun (_, _, _, x) -> x) (get_file fs path)
  ;;

  let substring_of sub s =
    let len = String.length sub in
    try
      let s' = String.sub s 0 len in
      s' = sub
    with
    | _ -> false
  ;;

  let directory_exists fs path =
    match get_file fs path with
    | Some (_, _, _, x) -> x
    | None -> Fs_set.exists (fun (p, _, _, _) -> substring_of p path) fs
  ;;

  let get_file_mtime fs path =
    Preface.Option.Monad.bind
      (fun (_, x, _, is_file) -> if is_file then Some x else None)
      (get_file fs path)
  ;;

  let get_file_content fs path =
    Preface.Option.Monad.bind
      (fun (_, _, x, is_file) -> if is_file then Some x else None)
      (get_file fs path)
  ;;
end

module Stdout = struct
  type t = string list

  let make () = []
  let put stdout message = message :: stdout
  let to_list = List.rev
end

type t =
  { mutable filesystem : Filesystem.t
  ; mutable stdout : Stdout.t
  }

let file = Filesystem.file

let write_file dummy ?mtime filename content =
  let open Try.Monad in
  let+ new_fs =
    Filesystem.write_file dummy.filesystem ?mtime filename content
  in
  dummy.filesystem <- new_fs
;;

let get_file dummy = Filesystem.get_file dummy.filesystem
let file_exists dummy = Filesystem.file_exists dummy.filesystem
let directory_exists dummy = Filesystem.directory_exists dummy.filesystem
let get_file_mtime dummy = Filesystem.get_file_mtime dummy.filesystem
let get_file_content dummy = Filesystem.get_file_content dummy.filesystem

let put dummy message =
  let new_stdout = Stdout.put dummy.stdout message in
  dummy.stdout <- new_stdout
;;

let log dummy level message =
  let l =
    let open Log in
    match level with
    | Trace -> "trace"
    | Debug -> "debug"
    | Info -> "info"
    | Warning -> "warning"
    | Alert -> "alert"
  in
  put dummy (Format.asprintf "%s: %s" l message)
;;

let inspect_stdout dummy = Stdout.to_list dummy.stdout

let make ?(filesystem = []) () =
  { stdout = Stdout.make (); filesystem = Filesystem.make filesystem }
;;

let perform_if_exists path f =
  Option.fold
    ~none:Error.(to_try (Unknown ("File not exists " ^ path)))
    ~some:Try.ok
  $ f path
;;

let handle dummy program =
  Effect.run
    { handler =
        (fun resume effect ->
          let f : type b. (b -> 'a) -> b Effect.f -> 'a =
           fun resume -> function
            | File_exists path -> resume $ file_exists dummy path
            | Target_exists path -> resume $ file_exists dummy path
            | Target_modification_time path ->
              resume $ perform_if_exists path (get_file_mtime dummy)
            | Get_modification_time path ->
              resume $ perform_if_exists path (get_file_mtime dummy)
            | Read_file path ->
              resume $ perform_if_exists path (get_file_content dummy)
            | Write_file (path, content) ->
              let res = write_file dummy path content in
              resume res
            | Log (level, message) -> resume $ log dummy level message
            | Read_dir (_path, _kind, _predicate) -> assert false
            | Throw _ | Raise _ -> assert false
          in
          f resume effect)
    }
    program
;;
