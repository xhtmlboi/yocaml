open Yocaml

module type RUNTIME = Yocaml.Runtime.RUNTIME with type 'a t = 'a

module type CONFIG = sig
  type repo

  val branch : string
  val author : string option
  val author_email : string option
  val repository : repo
end

let set_error = function
  | Ok x -> Try.ok x
  | Error (`Conflict conflict) ->
    Error.to_try $ Message ("Conflict: " ^ conflict)
  | Error (`Too_many_retries n) ->
    Error.to_try $ Message (Format.asprintf "Too many retiries %d" n)
  | Error (`Test_was _) -> Error.to_try $ Message "Test_was"
;;

let path_of = String.split_on_char '/'

module Make
    (Source : RUNTIME)
    (Pclock : Mirage_clock.PCLOCK)
    (Store : Irmin.S
               with type Schema.Branch.t = string
                and type Schema.Path.t = string list
                and type Schema.Contents.t = string)
    (Config : CONFIG with type repo = Store.repo) =
struct
  type 'a t = 'a Lwt.t

  let bind = Lwt.bind
  let return = Lwt.return

  let commit_author =
    let user = Option.value ~default:"yocaml" Config.author
    and mail = Option.value ~default:"admin@yocaml.io" Config.author_email in
    Format.asprintf "%s <%s>" user mail
  ;;

  let branch = Store.of_branch Config.repository Config.branch

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
    let* active_branch = branch in
    Store.mem active_branch path
  ;;

  let write_file filepath content =
    let date = Int64.of_float $ Source.get_time () in
    let info () =
      Store.Info.v
        ~author:commit_author
        ~message:(Format.asprintf "create file [%s]" filepath)
        date
    in
    let path = path_of filepath in
    let open Lwt.Syntax in
    let* active_branch = branch in
    let+ result = Store.set ~info active_branch path content in
    set_error result
  ;;

  let target_modification_time filepath =
    let path = path_of filepath in
    let open Lwt.Syntax in
    let* active_branch = branch in
    let+ commits = Store.last_modified ~n:1 active_branch path in
    match List.rev commits with
    | [] -> Ok 0
    | commit :: _ ->
      let info = Store.Commit.info commit in
      let date = Store.Info.date info in
      Ok (Int64.to_int date)
  ;;

  let content_changes filepath new_content =
    let path = path_of filepath in
    let hash s = Digestif.SHA256.digest_string s in
    let open Lwt.Syntax in
    let* active_branch = branch in
    let* obj = Store.find active_branch path in
    let new_hash = hash new_content in
    Lwt.return
      (Option.fold
         ~none:(Ok true)
         ~some:(fun old_content ->
           let old_hash = hash old_content in
           let f = not (Digestif.SHA256.equal new_hash old_hash) in
           Ok f)
         obj)
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
end
