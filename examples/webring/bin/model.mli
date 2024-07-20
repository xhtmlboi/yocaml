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

(** Describes the additional data model.

    The model is a list of [members] that respect this structure:
    - [id] a unique identifier (used to generate subpath)
    - [url] the website of the member
    - [main_lang] (fr | en) the main language of the [url]
    - [feed_url] and URL of the member feed. *)

type t

val to_outlines : t -> Yocaml_syndication.Opml.outline list

include Yocaml.Required.DATA_INJECTABLE with type t := t
include Yocaml.Required.DATA_READABLE with type t := t

(** Describing a member of the Webring *)

module Member : sig
  type t

  val id : t -> string

  include Yocaml.Required.DATA_INJECTABLE with type t := t
end

(** Cycle description for creating the webring participant chain. *)

module Cycle : sig
  type l := t
  type t

  val from : l -> t list
  val prev : t -> Member.t
  val curr : t -> Member.t
  val succ : t -> Member.t
  val select : [ `Prev | `Curr | `Succ ] -> t -> t

  include Yocaml.Required.DATA_INJECTABLE with type t := t
end
