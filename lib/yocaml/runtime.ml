open Util
open Aliases

module type RUNTIME = sig
  val file_exists : filepath -> bool
  val is_directory : filepath -> bool
  val get_modification_time : filepath -> int Try.t
  val read_file : filepath -> string Try.t
  val write_file : filepath -> string -> unit Try.t
  val read_dir : filepath -> filepath list
  val create_dir : ?file_perm:int -> filepath -> unit
  val log : Aliases.log_level -> string -> unit
end

let create_predicate (module R : RUNTIME) path pred = function
  | `Files ->
    fun x ->
      let p = x |> into path in
      if R.file_exists p && not $ R.is_directory p && pred x
      then Some p
      else None
  | `Directories ->
    fun x ->
      let p = x |> into path in
      if R.file_exists p && not $ R.is_directory p && pred x
      then Some p
      else None
  | `Both ->
    fun x ->
      let p = x |> into path in
      if pred x then Some p else None
;;

let execute (module R : RUNTIME) program =
  Effect.run
    { handler =
        (fun resume effect ->
          let f : type b. (b -> 'a) -> b Effect.f -> 'a =
           fun resume -> function
            | Effect.Get_modification_time path ->
              resume $ R.get_modification_time path
            | Effect.File_exists path -> resume $ R.file_exists path
            | Effect.Read_file path -> resume $ R.read_file path
            | Effect.Write_file (path, content) ->
              let () = R.create_dir $ Filename.dirname path in
              resume $ R.write_file path content
            | Effect.Read_dir (path, kind, predicate) ->
              let children = R.read_dir path in
              let full_predicate =
                create_predicate (module R) path predicate kind
              in
              resume $ List.filter_map full_predicate children
            | Effect.Log (level, message) ->
              let () = R.log level message in
              resume ()
            | Effect.Throw error ->
              let () =
                R.log Aliases.Alert (Lexicon.crap_there_is_an_error error)
              in
              Error.raise' error
            | Effect.Raise exn ->
              let () =
                R.log Aliases.Alert (Lexicon.crap_there_is_an_exception exn)
              in
              raise exn
          in
          f resume effect)
    }
    program
;;
