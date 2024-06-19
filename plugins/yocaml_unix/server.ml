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

module Pages = struct
  let error404 htdoc =
    Format.asprintf
      "<h1>Error 404</h1><hr /><p>You can generate a <code>404.html</code> \
       page at the root (<code>%s</code>) of your target as a fallback.</p>"
      (Eio.Path.native_exn htdoc)
end

type 'a requested_path =
  | File of 'a Eio.Path.t * string
  | Dir of 'a Eio.Path.t
  | Error404

let get_requested_uri htdoc request =
  let path =
    Http.Request.resource request
    |> String.split_on_char '/'
    |> List.filter (fun s -> not String.(equal s empty))
    |> String.concat "/"
  in
  if String.equal path "" then Dir htdoc
  else
    let path = Eio.Path.(htdoc / path) in
    let pstr = Eio.Path.native_exn path in
    if Eio.Path.is_directory path then Dir path
    else if Eio.Path.is_file path then File (path, pstr)
    else Error404

let file ?(status = `OK) path str =
  let content_type =
    if String.equal (Filename.extension str) ".html" then "text/html"
    else Magic_mime.lookup ~default:"text/plain" str
  in
  (* A little bit sad but I can't figure out how to transform a file read with
     `with_open_in` into an unclosed `flow`... *)
  let body = Eio.Path.load path in
  Cohttp_eio.Server.respond_string
    ~headers:(Http.Header.of_list [ ("content-type", content_type) ])
    ~status ~body ()

let error404 htdoc =
  let path = Eio.Path.(htdoc / "404.html") in
  let str = Eio.Path.native_exn path in
  if Eio.Path.is_file path then file ~status:`Not_found path str
  else
    let body = Pages.error404 htdoc in
    Cohttp_eio.Server.respond_string
      ~headers:(Http.Header.of_list [ ("content-type", "text/html") ])
      ~status:`Not_found ~body ()

let dir htdoc path =
  let index = Eio.Path.(path / "index.html") in
  if Eio.Path.is_file index then
    let index_str = Eio.Path.native_exn index in
    file index index_str
  else error404 htdoc

let handler htdoc refresh _socket request _body =
  let () = refresh () in
  match get_requested_uri htdoc request with
  | Error404 -> error404 htdoc
  | File (path, str) -> file path str
  | Dir path -> dir htdoc path

let error_handler exn = Logs.warn (fun fmt -> fmt "%a" Eio.Exn.pp exn)

let prompt port =
  Logs.info (fun f -> f "Launching server <http://localhost:%04d>" port)

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
      let () = prompt port in
      Cohttp_eio.Server.run socket server ~on_error:error_handler)
