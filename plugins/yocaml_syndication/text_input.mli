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

(** The purpose of the [<textInput>] element is something of a mystery. You can
    use it to specify a search engine box. Or to allow a reader to provide
    feedback. Most aggregators ignore it. *)

(** {1 Type} *)

type t
(** The type describing a [TextInput]*)

(** {1 Creation} *)

val make : title:string -> description:string -> name:string -> link:string -> t
(** Build a textinput.
    @see <https://web.resource.org/rss/1.0/spec#s5.6> *)

(** {1 Projection} *)

val to_rss1 : t -> Xml.node
val to_rss1_channel : t -> Xml.node
val to_rss2 : t -> Xml.node
