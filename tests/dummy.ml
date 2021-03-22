open Wordpress.Util

module Filesystem = struct
  type path = string
  type mtime = int

  let ( / ) = Filename.concat

  module Fs_set = Set.Make (struct
    type t = path * mtime * string

    let compare (p, _, _) (k, _, _) = String.compare p k
  end)

  type t = Fs_set.t
  type elt = Fs_set.elt

  let empty = Fs_set.empty
  let make files = Fs_set.add_seq (List.to_seq files) empty
  let file ?(mtime = 1) ?(content = "") path = path, mtime, content

  let write_file fs ?mtime filename content =
    let elt mtime = filename, mtime, content in
    let time, tmp =
      match Fs_set.find_opt (elt 1) fs with
      | None -> Option.value ~default:1 mtime, fs
      | Some ((_, x, _) as e) ->
        Option.value ~default:(succ x) mtime, Fs_set.remove e fs
    in
    Fs_set.add (elt time) tmp
  ;;

  let get_file fs path = Fs_set.find_opt (file path) fs

  let file_exists fs path =
    Option.fold
      ~none:false
      ~some:Preface.Predicate.tautology
      (get_file fs path)
  ;;

  let get_file_mtime fs path =
    Option.map (fun (_, x, _) -> x) (get_file fs path)
  ;;

  let get_file_content fs path =
    Option.map (fun (_, _, x) -> x) (get_file fs path)
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
  let new_filesystem =
    Filesystem.write_file dummy.filesystem ?mtime filename content
  in
  dummy.filesystem <- new_filesystem
;;

let get_file dummy = Filesystem.get_file dummy.filesystem
let file_exists dummy = Filesystem.file_exists dummy.filesystem
let get_file_mtime dummy = Filesystem.get_file_mtime dummy.filesystem
let get_file_content dummy = Filesystem.get_file_content dummy.filesystem

let put dummy message =
  let new_stdout = Stdout.put dummy.stdout message in
  dummy.stdout <- new_stdout
;;

let log dummy level message =
  let l =
    let open Wordpress.Aliases in
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
    ~none:Wordpress.Error.(to_try (Unknown ("File not exists " ^ path)))
    ~some:Wordpress.Try.ok
  $ f path
;;

let handle dummy program =
  Wordpress.Effect.run
    { handler =
        (fun resume effect ->
          let f : type b. (b -> 'a) -> b Wordpress.Effect.f -> 'a =
           fun resume -> function
            | File_exists path -> resume $ file_exists dummy path
            | Get_modification_time path ->
              resume $ perform_if_exists path (get_file_mtime dummy)
            | Read_file path ->
              resume $ perform_if_exists path (get_file_content dummy)
            | Write_file (path, content) ->
              let () = write_file dummy path content in
              resume $ Wordpress.Try.ok ()
            | Log (level, message) -> resume $ log dummy level message
            | Throw _ -> assert false
          in
          f resume effect)
    }
    program
;;
