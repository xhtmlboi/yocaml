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

let get_requested_uri env request =
  Yocaml_runtime.Server.Request_path.from_path ~is_file ~is_directory ~concat
    ~native env ~path:request.Cohttp.Request.resource

let read_file path =
  Lwt_io.with_file ~mode:Lwt_io.Input path (fun channel -> Lwt_io.read channel)

let file ?(status = `OK) path =
  let open Lwt.Syntax in
  let content_type = Yocaml_runtime.Server.Request_path.content_type path in
  let* body = read_file path in
  Cohttp_lwt_unix.Server.respond_string
    ~headers:(Cohttp.Header.of_list [ ("content-type", content_type) ])
    ~status ~body ()

let render_html ?(status = `Not_found) body =
  Cohttp_lwt_unix.Server.respond_string
    ~headers:
      (Cohttp.Header.of_list [ ("content-type", "text/html; charset=utf-8") ])
    ~status ~body ()

let error404 htdoc =
  let path = concat htdoc "404.html" in
  if is_file path then file ~status:`Not_found path
  else render_html @@ Yocaml_runtime.Server.Pages.error404 htdoc

let dir path lpath =
  let index = concat path "index.html" in
  if is_file index then file index
  else
    let children =
      path
      |> Sys.readdir
      |> Array.to_list
      |> List.map
           (Yocaml_runtime.Server.Kind.from_path ~is_directory ~concat path)
    in
    render_html @@ Yocaml_runtime.Server.Pages.directory lpath children

let handler htdoc refresh _socker request _body =
  let () = refresh () in
  match get_requested_uri htdoc request with
  | Error404 -> error404 htdoc
  | File (path, _) -> file path
  | Dir (path, lpath) -> dir path lpath

let run ?custom_error_handler directory port program =
  let refresh () = Runner.run ?custom_error_handler program in
  let htdoc = Yocaml.Path.to_string directory in
  let callback = handler htdoc refresh in
  let pp_exn ppf exn = Format.fprintf ppf "%s" (Printexc.to_string exn) in
  let listener =
    Cohttp_lwt_unix.Server.create
      ~on_exn:(Yocaml_runtime.Server.exn_handler pp_exn)
      ~mode:(`TCP (`Port port))
      (Cohttp_lwt_unix.Server.make ~callback ())
  in
  let () = Yocaml_runtime.Server.prompt port in
  Lwt_main.run listener
