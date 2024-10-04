(* YOCaml a static blog generator.
   Copyright (C) 2024 The Funkyworkers and The YOCaml's developers

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

let is_file = Sys.file_exists
let is_directory k = is_file k && Sys.is_directory k
let concat = Filename.concat
let native = Fun.id

let get_requested_uri env reqd =
  let request = H1.Reqd.request reqd in
  let path = request.H1.Request.target in
  let path = if String.length path > 0 then String.sub path 1 (String.length path - 1) else path in
  Yocaml_runtime.Server.Request_path.from_path ~is_file ~is_directory ~concat
    ~native env ~path

let file ?(status = `OK) reqd path =
  let content_type = Yocaml_runtime.Server.Request_path.content_type path in
  let ic = open_in path in
  let len = in_channel_length ic in
  let tmp = Bytes.create 0x7ff in
  let headers =
    H1.Headers.of_list
      [ ("content-type", content_type); ("content-length", string_of_int len) ]
  in
  let resp = H1.Response.create ~headers status in
  let body = H1.Reqd.respond_with_streaming reqd resp in
  let rec go () =
    let len = input ic tmp 0 (Bytes.length tmp) in
    if len = 0 then (
      close_in ic;
      H1.Body.Writer.close body)
    else (
      H1.Body.Writer.write_string body (Bytes.sub_string tmp 0 len);
      H1.Body.Writer.flush body go)
  in
  go ()

let render_html ?(status = `Not_found) reqd body =
  let headers =
    H1.Headers.of_list
      [
        ("content-type", "text/html; charset=utf-8")
      ; ("content-length", string_of_int (String.length body))
      ]
  in
  let resp = H1.Response.create ~headers status in
  H1.Reqd.respond_with_string reqd resp body

let error404 reqd htdoc =
  let path = concat htdoc "404.html" in
  if is_file path then file ~status:`Not_found reqd path
  else render_html reqd (Yocaml_runtime.Server.Pages.error404 htdoc)

let dir reqd path lpath =
  let index = concat path "index.html" in
  if is_file index then file reqd index
  else
    let children =
      path
      |> Sys.readdir
      |> Array.to_list
      |> List.map
           (Yocaml_runtime.Server.Kind.from_path ~is_directory ~concat path)
    in
    render_html reqd (Yocaml_runtime.Server.Pages.directory lpath children)

let[@warning "-8"] handler htdoc refresh _socket
    (`V1 reqd : Httpcats.Server.reqd) =
  let () = refresh () in
  match get_requested_uri htdoc reqd with
  | Error404 -> error404 reqd htdoc
  | File (path, _) -> file reqd path
  | Dir (path, lpath) -> dir reqd path lpath

let run ?custom_error_handler directory port program =
  let refresh () = Runner.run ?custom_error_handler program in
  let htdoc = Yocaml.Path.to_string directory in
  let handler = handler htdoc refresh in
  let sockaddr = Unix.(ADDR_INET (inet_addr_loopback, port)) in
  Miou_unix.run ~domains:0 @@ fun () ->
  Yocaml_runtime.Server.prompt port;
  Httpcats.Server.clear ~handler sockaddr
