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

(** Generic utilities for dealing with arbitrary markup formats. In general, the
    modules here are specified for, for example, composing with Markdown. *)

module Toc : sig
  (** Generic table of contents representation. *)

  type 'a t
  (** Type describing an entry tree in a table of contents. The representation
      of the elements is left to the implementation of plugins. *)

  val from_list : (int * 'a) list -> 'a t
  (** Builds a table of contents from an indexed list. For example, a list of
      headings in a Markdown document. *)

  val to_labelled_list : 'a t -> (int list * 'a) list
  (** [to_labelled_list toc] converts [toc] into a list of labelled nodes. Each
      node is paired with an index represented as a list of integers, which
      indicates the node’s position in the hierarchical tree structure. *)

  val traverse :
       on_list:('a list -> string)
    -> on_item:(string -> 'a)
    -> on_link:(id:'b -> title:'c -> string)
    -> ('b * 'c) t
    -> string option
  (** Walk recursively on a [toc] applying function on every element to produce
      a string.*)

  val to_html : ?ol:bool -> ('a -> string) -> (string * 'a) t -> string option
  (** [to_html ?ol label_to_string toc_of_id_and_label] from a table of contents
      build on top of a list of [id * label], generate the corresponding HTML.
  *)
end
