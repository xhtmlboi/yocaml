open Cohttp
open Cohttp_lwt_unix

type strategy =
  | Directory
  | File of string
  | Error404

let rec define_strategy path =
  let open Lwt.Syntax in
  let* file_exists = Lwt_unix.file_exists path in
  if not file_exists
  then Lwt.return Error404
  else if Sys.is_directory path
  then define_strategy (Filename.concat path "index.html")
  else Lwt.return (File path)
;;

let file_to_bytes filename =
  let open Lwt_unix in
  let open Lwt.Syntax in
  let* descr = openfile filename [ O_RDONLY ] 0o444 in
  let channel = Lwt_io.of_fd ~mode:Input descr in
  let rec aux acc =
    let open Lwt.Infix in
    Lwt_io.read_char_opt channel
    >>= function
    | Some chr ->
      let () = Buffer.add_char acc chr in
      aux acc
    | None -> Lwt.return @@ Buffer.to_bytes acc
  in
  let* bytes = aux @@ Buffer.create 1 in
  let+ () = close descr in
  bytes
;;

let handle_file hook path =
  let open Lwt.Syntax in
  let mime = Magic_mime.lookup path in
  let headers = Header.init_with "Content-Type" mime in
  let status = `OK in
  let* () = hook () in
  let* bytes = file_to_bytes path in
  let body = `String (Bytes.to_string bytes) in
  Server.respond ~headers ~status ~body ()
;;

let handle_404 rootpath =
  let open Lwt.Syntax in
  let path = Filename.concat rootpath "404.html" in
  let* file_exists = Lwt_unix.file_exists path in
  if not file_exists
  then Server.respond_string ~status:`OK ~body:"Error/404" ()
  else handle_file (fun () -> Lwt.return_unit) path
;;

let server filepath port task =
  let module R = Yocaml.Runtime.Make (Runtime) in
  let handler _conn request _body =
    let uri = request |> Request.uri in
    let path = Path.resolve_local_file ~docroot:filepath ~uri in
    let open Lwt.Syntax in
    let* strategy = define_strategy path in
    match strategy with
    | File x -> handle_file (fun () -> Lwt.return (R.execute task)) x
    | _ -> handle_404 filepath
  in
  Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback:handler ())
;;
