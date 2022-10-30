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

  let store_write_error ~caller = function
    | Ok x -> Try.ok x
    | Error err ->
      Error.to_try
      $ Message (Fmt.str "%s: %a" caller Store.pp_write_error err)
  ;;

  type 'a t = 'a Lwt.t

  let bind = Lwt.bind
  let return = Lwt.return

  let create_dir ?(file_perm = 0) _ =
    (* Path are Keys in Irmin so [create_dir] is useless*)
    let _ = file_perm in
    (* Trick for avoiding warning on unused variable  *)
    Lwt.return ()
  ;;

  let get_time () =
    Ptime.v (Pclock.now_d_ps ()) |> Ptime.to_float_s |> Lwt.return
  ;;

  let target_exists filepath =
    let path = path_of filepath in
    let open Lwt.Syntax in
    let+ result = Store.exists Config.store path in
    match result with
    | Ok v -> Option.is_some v
    | Error _err -> assert false
  ;;

  let write_file filepath content =
    let path = path_of filepath in
    let open Lwt.Syntax in
    let+ result = Store.set Config.store path content in
    store_write_error ~caller:"Store.set" result
  ;;

  let target_modification_time filepath =
    let path = path_of filepath in
    let open Lwt.Syntax in
    let+ result = Store.last_modified Config.store path in
    match result with
    | Ok (timestamp, _tz) -> Try.ok timestamp
    | Error err ->
      Error.to_try
      $ Message (Fmt.str "Store.last_modified: %a" Store.pp_error err)
  ;;

  let content_changes filepath new_content =
    let path = path_of filepath in
    let hash s = Digestif.SHA256.digest_string s in
    let open Lwt.Syntax in
    let+ obj = Store.get Config.store path in
    let new_hash = hash new_content in
    match obj with
    | Ok old_content ->
      let old_hash = hash old_content in
      let res = not (Digestif.SHA256.equal new_hash old_hash) in
      Try.ok res
    | Error err ->
      Error.to_try $ Message (Fmt.str "Store.get: %a" Store.pp_error err)
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
