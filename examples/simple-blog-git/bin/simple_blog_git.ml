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

let author = "The XHTMLBoy"
let email = "xhtmlboi@gmail.com"
let message = "pushed from YOCaml 2"
let remote = "https://gitlab.com/xhtmlboi/yocaml-git-experience.git"

module Blog = Simple_blog.Make_with_target (struct
  let source = Yocaml.Path.rel [ "examples"; "simple-blog-git" ]
  let target = Yocaml.Path.rel [ "www" ]
end)

module Source = Yocaml_git.From_identity (Yocaml_unix.Runtime)

let () =
  Yocaml_git.run
    (module Source)
    (module Pclock)
    ~context:`SSH ~author ~email ~message ~remote Blog.process_all
  |> Lwt_main.run
  |> Result.iter_error (fun (`Msg err) -> invalid_arg err)
