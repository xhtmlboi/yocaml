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

module Blog = Simple_blog.Make (struct
  let source = Yocaml.Path.rel [ "examples"; "simple-blog-eio" ]
end)

(* We're almost done! Now that we have a function that "builds" our blog, all we
   need to do is pass it to a Runtime for it to execute "concretely." It's as
   simple as that. We allow the user to choose whether they just want to build
   the site or serve it statically. The code to manage the CLI is a bit adhoc :P
   but is only present as an example :)*)

let () =
  match Array.to_list Sys.argv with
  | _ :: "serve" :: xs ->
      (* If the [serve] argument is passed to the CLI. We're trying to parse a
         port. *)
      let port =
        Option.bind (List.nth_opt xs 0) int_of_string_opt
        |> Option.value ~default:8000
      in
      (* Then you can launch the server! *)
      Yocaml_eio.serve ~level:Logs.Info ~target:Blog.target ~port
        Blog.process_all
  | _ ->
      (* If no arguments (or the wrong values) are passed, the site is built *)
      Yocaml_eio.run Blog.process_all

(* And there you have it, our blog is now finished. To be able to build your
   site from scratch, with even more flexibility, we invite you to read through
   the various templates to understand how we interact with the blog's UI, and
   of course, the Archetype module to understand how to create your own data
   models! (However, be warned, the Archetype module is a bit dense, to allow by
   default for handling a wide range of "classic" use cases when building a
   blog.) *)
