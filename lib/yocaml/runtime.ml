open Util

module type RUNTIME = sig
  type 'a t

  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val return : 'a -> 'a t
  val get_time : unit -> float t
  val file_exists : Filepath.t -> bool t
  val target_exists : Filepath.t -> bool t
  val is_directory : Filepath.t -> bool t
  val get_modification_time : Filepath.t -> int Try.t t
  val target_modification_time : Filepath.t -> int Try.t t
  val read_file : Filepath.t -> string Try.t t
  val content_changes : Filepath.t -> string -> bool Try.t t
  val write_file : Filepath.t -> string -> unit Try.t t
  val read_dir : Filepath.t -> Filepath.t list t
  val create_dir : ?file_perm:int -> Filepath.t -> unit t
  val log : Log.level -> string -> unit t
end

module Make (R : RUNTIME) = struct
  let ( let* ) = R.bind

  let create_predicate path pred = function
    | `Files ->
      fun x ->
        let p = x |> into path in
        let* file_exists = R.file_exists p in
        let* is_directory = R.is_directory p in
        if file_exists && (not is_directory) && pred x
        then R.return (Some p)
        else R.return None
    | `Directories ->
      fun x ->
        let p = x |> into path in
        let* file_exists = R.file_exists p in
        let* is_directory = R.is_directory p in
        if file_exists && (not is_directory) && pred x
        then R.return (Some p)
        else R.return None
    | `Both ->
      fun x ->
        let p = x |> into path in
        if pred x then R.return (Some p) else R.return None
  ;;

  let filter_map f l =
    let rec go acc = function
      | [] -> R.return (List.rev acc)
      | hd :: tl ->
        let* hd = f hd in
        (match hd with
        | Some v -> (go [@tailcall]) (v :: acc) tl
        | None -> (go [@tailcall]) acc tl)
    in
    go [] l
  ;;

  let execute program =
    let perform : type a. a Effect.f -> a R.t = function
      | Effect.Get_modification_time path -> R.get_modification_time path
      | Effect.File_exists path -> R.file_exists path
      | Effect.Target_modification_time path ->
        R.target_modification_time path
      | Effect.Target_exists path -> R.target_exists path
      | Effect.Read_file path -> R.read_file path
      | Effect.Content_changes (path, content) ->
        let* v = R.content_changes path content in
        R.return
          (Try.Functor.map
             (function
               | true -> Either.left content
               | false -> Either.right ())
             v)
      | Effect.Write_file (path, content) ->
        let* () = R.create_dir $ Filename.dirname path in
        R.write_file path content
      | Effect.Read_dir (path, kind, predicate) ->
        let* children = R.read_dir path in
        filter_map (create_predicate path predicate kind) children
      | Effect.Log (level, message) -> R.log level message
      | Effect.Throw error ->
        let* () = R.log Log.Alert (Lexicon.crap_there_is_an_error error) in
        Error.raise' error
      | Effect.Raise exn ->
        let* () = R.log Log.Alert (Lexicon.crap_there_is_an_exception exn) in
        raise exn
    in
    let handler : type b. (b R.t -> 'a R.t) -> b Effect.f -> 'a R.t =
     fun resume effect -> resume $ perform effect
    in
    let handler : type b. (b -> 'a R.t) -> b Effect.f -> 'a R.t =
     fun resume effect ->
      let resume v = R.bind v (fun v -> resume v) in
      handler resume effect
    in
    Effect.run { handler } (Effect.map R.return program)
  ;;
end
