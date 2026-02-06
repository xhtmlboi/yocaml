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

let is_file = Eio.Path.is_file
let is_directory = Eio.Path.is_directory
let concat r x = Eio.Path.(r / x)
let native = Eio.Path.native_exn

let get_requested_uri env request =
  Yocaml_runtime.Server.Request_path.from_path ~is_file ~is_directory ~concat
    ~native env ~path:request.Http.Request.resource

let file ?(status = `OK) path str =
  let content_type = Yocaml_runtime.Server.Request_path.content_type str in
  (* A little bit sad but I can't figure out how to transform a file read with
     `with_open_in` into an unclosed `flow`... *)
  let body = Eio.Path.load path in
  Cohttp_eio.Server.respond_string
    ~headers:(Http.Header.of_list [ ("content-type", content_type) ])
    ~status ~body ()

let render_html ?(status = `Not_found) body =
  Cohttp_eio.Server.respond_string
    ~headers:
      (Http.Header.of_list [ ("content-type", "text/html; charset=utf-8") ])
    ~status ~body ()

let error404 htdoc =
  let path = Eio.Path.(htdoc / "404.html") in
  let str = Eio.Path.native_exn path in
  if Eio.Path.is_file path then file ~status:`Not_found path str
  else
    render_html
    @@ Yocaml_runtime.Server.Pages.error404 (Eio.Path.native_exn htdoc)

let dir path lpath =
  let index = Eio.Path.(path / "index.html") in
  if Eio.Path.is_file index then
    let index_str = Eio.Path.native_exn index in
    file index index_str
  else
    let children =
      Eio.Path.read_dir path
      |> List.map
           (Yocaml_runtime.Server.Kind.from_path ~is_directory ~concat path)
    in
    render_html @@ Yocaml_runtime.Server.Pages.directory lpath children

let handler htdoc refresh _socket request _body =
  let () = refresh () in
  match get_requested_uri htdoc request with
  | Error404 -> error404 htdoc
  | File (path, str) -> file path str
  | Dir (path, lpath) -> dir path lpath

let run ?custom_error_handler directory port program env =
  Eio.Switch.run (fun sw ->
      let refresh () = Runner.run ?custom_error_handler program env in
      let htdoc = Runtime.to_eio_path env directory in
      let socket =
        Eio.Net.listen env#net ~sw ~backlog:128 ~reuse_addr:true
          (`Tcp (Eio.Net.Ipaddr.V4.loopback, port))
      in
      let server =
        Cohttp_eio.Server.make ~callback:(handler htdoc refresh) ()
      in
      let () = Yocaml_runtime.Server.prompt port in
      Cohttp_eio.Server.run socket server
        ~on_error:(Yocaml_runtime.Server.exn_handler Eio.Exn.pp))
