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

module Kind = struct
  type t = Directory of string | File of string

  let from_path ~is_directory ~concat base_path element =
    let fpath = concat base_path element in
    if is_directory fpath then Directory element else File element
end

module Request_path = struct
  type 'a t = File of 'a * string | Dir of 'a * string list | Error404

  let from_path ~is_file ~is_directory ~concat ~native htdoc ~path =
    let lpath =
      path
      |> String.split_on_char '/'
      |> List.filter (fun s -> not String.(equal s empty))
    in
    let spath = String.concat "/" lpath in
    if String.equal spath "" then Dir (htdoc, lpath)
    else
      let path = concat htdoc spath in
      let pstr = native path in
      if is_directory path then Dir (path, lpath)
      else if is_file path then File (path, pstr)
      else Error404

  let content_type file =
    match Filename.extension file with
    | ".html" -> "text/html"
    | ".jpg" | ".jpeg" -> "image/jpeg"
    | ".png" -> "image/png"
    | ".gif" -> "image/gif"
    | ".svg" -> "image/svg+xml"
    | ".css" -> "text/css"
    | ".js" -> "text/javascript"
    | ".json" -> "application/json"
    | ".xml" | ".rss" | ".atom" | ".feed" -> "application/xml"
    | _ -> "text/plain"
end

module Pages = struct
  let error404 htdoc =
    Format.asprintf
      "<h1>Error 404</h1><hr /><p>You can generate a <code>404.html</code> \
       page at the root (<code>%s</code>) of your target as a fallback.</p>"
      htdoc

  let expand path =
    let a =
      List.fold_left
        (fun acc path ->
          match acc with
          | [] -> [ [ path ] ]
          | x :: xs -> (path :: x) :: List.rev x :: xs)
        [] path
      |> function
      | x :: xs -> List.rev (List.rev x :: xs)
      | [] -> []
    in
    ("root", "") :: List.map2 (fun x y -> (x, String.concat "/" y)) path a

  let directory path children =
    let full_path =
      match path with [] -> "" | path -> "/" ^ String.concat "/" path
    in
    let top =
      path
      |> expand
      |> List.map (fun (n, u) -> Format.asprintf {|<a href="/%s">%s</a>|} u n)
      |> String.concat "/"
    in
    let children =
      List.sort
        (fun a b ->
          match (a, b) with
          | Kind.File _, Directory _ -> 1
          | Directory _, File _ -> -1
          | File a, File b | Directory a, Directory b -> String.compare a b)
        children
    in
    let listing =
      List.map
        (fun x ->
          let char, value =
            match x with Kind.Directory x -> ("📁", x) | File x -> ("🖹", x)
          in
          Format.asprintf {|<li>%s <a href="%s">%s</a></li>|} char
            (full_path ^ "/" ^ value)
            value)
        children
      |> String.concat ""
    in
    Format.asprintf "<nav><h1>%s</h1></nav><ul>%s</ul>" top listing
end

let prompt port =
  Logs.info (fun f -> f "Launching server <http://localhost:%04d>" port)

let exn_handler pp exn = Logs.warn (fun fmt -> fmt "%a" pp exn)
