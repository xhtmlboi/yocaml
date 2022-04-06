open Yocaml

module type CONFIG = sig
  val config : Irmin.config
  val branch : string
  val author : string option
  val author_email : string option
end

module type LWT_RUN = sig
  val run : 'a Lwt.t -> 'a
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
    (Source : Yocaml.Runtime.RUNTIME)
    (Store : Irmin.S
               with type Schema.Branch.t = string
                and type Schema.Path.t = string list
                and type Schema.Contents.t = string)
    (Lwt_main : LWT_RUN)
    (Config : CONFIG) =
struct
  let commit_author =
    let user = Option.value ~default:"yocaml" Config.author
    and mail = Option.value ~default:"admin@yocaml.io" Config.author_email in
    Format.asprintf "%s <%s>" user mail
  ;;

  let branch =
    let open Lwt.Syntax in
    let* repo = Store.Repo.v Config.config in
    Store.of_branch repo Config.branch
  ;;

  let create_dir ?(file_perm = 0) _ =
    (* Path are Keys in Irmin so [create_dir] is useless*)
    let _ = file_perm in
    (* Trick for avoiding warning on unused variable  *)
    ()
  ;;

  let get_time () = 0.0

  let target_exists filepath =
    let path = path_of filepath in
    let task =
      let open Lwt.Syntax in
      let* active_branch = branch in
      Store.mem active_branch path
    in
    Lwt_main.run task
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
    let task =
      let open Lwt.Syntax in
      let* active_branch = branch in
      let+ result = Store.set ~info active_branch path content in
      set_error result
    in
    Lwt_main.run task
  ;;

  let target_modification_time filepath =
    let path = path_of filepath in
    let task =
      let open Lwt.Syntax in
      let* active_branch = branch in
      let+ commits = Store.last_modified ~n:1 active_branch path in
      match List.rev commits with
      | [] -> Ok 0
      | commit :: _ ->
        let info = Store.Commit.info commit in
        let date = Store.Info.date info in
        Ok (Int64.to_int date)
    in
    Lwt_main.run task
  ;;

  let content_changes filepath new_content =
    let path = path_of filepath in
    let hash s = Digestif.SHA256.digest_string s in
    let task =
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
    in
    Lwt_main.run task
  ;;

  (* Additional Runtime for dealing with a Source. *)

  let file_exists = Source.file_exists
  let is_directory = Source.is_directory
  let get_modification_time = Source.get_modification_time
  let read_file = Source.read_file
  let read_dir = Source.read_dir
  let log = Source.log
end
