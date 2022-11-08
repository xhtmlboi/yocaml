let mime_database = Conan_magic_database.tree

type strategy =
  | Directory
  | File of string
  | Error_404

let rec define_strategy path =
  if not (Sys.file_exists path)
  then Error_404
  else if Sys.is_directory path
  then define_strategy (Filename.concat path "index.html")
  else File path
;;

let file_to_bytes filename =
  let ic = open_in filename in
  let ln = in_channel_length ic in
  let rs = Bytes.create ln in
  really_input ic rs 0 ln;
  close_in ic;
  Bytes.unsafe_to_string rs
;;

let mime_type =
  let tbl = Hashtbl.create 0x100 in
  fun path ->
    match Hashtbl.find tbl path with
    | mime_type -> mime_type
    | exception Not_found ->
      let mime_type =
        Result.map
          Conan.Metadata.mime
          (Conan_unix.run_with_tree mime_database path)
      in
      let mime_type = Result.value ~default:None mime_type in
      Hashtbl.replace tbl path mime_type;
      mime_type
;;

let handle_file ?(status = `OK) path reqd =
  let bytes = file_to_bytes path in
  let open Httpaf in
  let headers =
    match mime_type path with
    | Some mime_type ->
      Headers.of_list
        [ "content-type", mime_type
        ; "content-length", string_of_int (String.length bytes)
        ; "connection", "close"
        ]
    | None ->
      Headers.of_list
        [ "content-length", string_of_int (String.length bytes)
        ; "connection", "close"
        ]
  in
  let response = Response.create ~headers status in
  Reqd.respond_with_string reqd response bytes
;;

let handle_404 rootpath reqd =
  let path = Filename.concat rootpath "404.html" in
  if Sys.file_exists path
  then handle_file ~status:`Not_found path reqd
  else
    let open Httpaf in
    let contents = Fmt.str "Error/404" in
    let headers =
      Headers.of_list
        [ "content-type", "text/plain"
        ; "content-length", string_of_int (String.length contents)
        ; "connection", "close"
        ]
    in
    let response = Response.create ~headers `Not_found in
    Reqd.respond_with_string reqd response contents
;;

let error_handler (_ipaddr, _port) ?request:_ error respond =
  let open Httpaf in
  let error =
    match error with
    | `Bad_gateway -> Fmt.str "Bad gateway"
    | `Bad_request -> Fmt.str "Bad request"
    | `Exn exn ->
      Fmt.str "Internal server error (exception): %S" (Printexc.to_string exn)
    | `Internal_server_error -> Fmt.str "Internal server error"
  in
  let headers =
    Headers.of_list
      [ "content-type", "text/plain"
      ; "content-length", string_of_int (String.length error)
      ; "connection", "close"
      ]
  in
  let body = respond headers in
  Body.write_string body error;
  Body.close_writer body
;;

module HTTP_server = Paf_mirage.Make (Tcpv4v6_socket)

let server filepath stack port task =
  let module R = Yocaml.Runtime.Make (Runtime) in
  let handler _flow (_ipaddr, _port) reqd =
    let open Httpaf in
    let { Request.target; _ } = Reqd.request reqd in
    let target = String.split_on_char '/' target in
    let target = List.fold_left Fpath.add_seg (Fpath.v filepath) target in
    match define_strategy (Fpath.to_string target) with
    | File x ->
      R.execute task;
      handle_file x reqd
    | _ -> handle_404 filepath reqd
  in
  let http_service = HTTP_server.http_service ~error_handler handler in
  let open Lwt.Syntax in
  let* http_server = HTTP_server.init ~port stack in
  let (`Initialized thread) = HTTP_server.serve http_service http_server in
  thread
;;
