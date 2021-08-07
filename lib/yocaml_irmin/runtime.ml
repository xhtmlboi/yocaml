open Yocaml

module type CONFIG = sig
  val config : Irmin.config
  val branch : string
  val author : string option
  val author_email : string option
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
               with type branch = string
                and type key = string list
                and type contents = string)
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
    let info =
      Irmin_unix.info ~author:commit_author "create file [%s]" filepath
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
        let date = Irmin.Info.date info in
        Ok (Int64.to_int date)
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
