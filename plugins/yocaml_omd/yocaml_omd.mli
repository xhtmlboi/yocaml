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

(** Allows you to use [OMD](https://ocaml.org/p/omd/latest) to use
    [Markdown](https://en.wikipedia.org/wiki/Markdown) as a markup language.
    Historically, the package was named [yocaml_markdown] but was renamed
    [yocaml_omd] to support multiple Markdown parsers. *)

val to_html : (string, string) Yocaml.Task.t
(** [to_html] is an arrow that uses [OMD] to convert [Markdown] to [HTML]. *)

val content_to_html : unit -> ('a * string, 'a * string) Yocaml.Task.t
(** [content_to_html] is an arrow that uses [OMD] to convert the content of a
    file from [Markdown] to [HTML]. (Since we usually read a file with metadata
    as a pair of metadata and string). *)
