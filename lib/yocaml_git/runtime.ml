open Yocaml

module type RUNTIME = Yocaml.Runtime.RUNTIME with type 'a t = 'a

module type CONFIG = sig
  val store : Git_kv.t
end

let path_of = Mirage_kv.Key.v

module Make
  (Source : RUNTIME)
  (Pclock : Mirage_clock.PCLOCK)
  (Config : CONFIG) =
struct
  module Store = Git_kv.Make (Pclock)

  type 'a t = 'a Lwt.t

  let bind = Lwt.bind
  let return = Lwt.return

  let create_dir ?(file_perm = 0) _ =
    (* Path are Keys in Git_kv so [create_dir] is useless*)
    let _ = file_perm in
    (* Trick for avoiding warning on unused variable  *)
    Lwt.return ()
  ;;

  let get_time () =
    Ptime.v (Pclock.now_d_ps ()) |> Ptime.to_float_s |> Lwt.return
  ;;

  let target_exists filepath =
    let path = path_of filepath in
    let open Lwt.Infix in
    Store.exists Config.store path
    >|= function
    | Ok v -> Option.is_some v
    | Error _ -> false
  ;;

  let store_write_error ~caller = function
    | Ok v -> Try.ok v
    | Error err ->
      Error.to_try
      $ Message (Fmt.str "%s: %a" caller Store.pp_write_error err)
  ;;

  let write_file filepath content =
    let path = path_of filepath in
    let open Lwt.Syntax in
    let+ result = Store.set Config.store path content in
    store_write_error ~caller:"write_file" result
  ;;

  let target_modification_time filepath =
    let path = path_of filepath in
    let open Lwt.Infix in
    Store.last_modified Config.store path
    >|= function
    | Ok v -> Try.ok (Float.to_int (Ptime.to_float_s v))
    | Error err ->
      Error.to_try
      $ Message (Fmt.str "target_modification_time: %a" Store.pp_error err)
  ;;

  let content_changes filepath new_content =
    let path = path_of filepath in
    let hash s = Digestif.SHA256.digest_string s in
    let open Lwt.Syntax in
    let+ old_content = Store.get Config.store path in
    let new_hash = hash new_content in
    match old_content with
    | Ok old_content ->
      let old_hash = hash old_content in
      Try.ok (not (Digestif.SHA256.equal new_hash old_hash))
    | Error err ->
      Error.to_try
      $ Message (Fmt.str "content_changes: %a" Store.pp_error err)
  ;;

  (* Additional Runtime for dealing with a Source. *)

  let file_exists filepath = Lwt.return (Source.file_exists filepath)
  let is_directory filepath = Lwt.return (Source.is_directory filepath)

  let get_modification_time filepath =
    Lwt.return (Source.get_modification_time filepath)
  ;;

  let read_file filepath = Lwt.return (Source.read_file filepath)
  let read_dir path = Lwt.return (Source.read_dir path)
  let log level message = Lwt.return (Source.log level message)
  let command cmd = Lwt.return (Source.command cmd)
end
