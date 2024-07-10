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

(** Conveys information about a category associated with an entry or feed. This
    specification assigns no meaning to the content (if any) of this element.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.2> *)

(** {1 Types} *)

type t

(** {1 Helpers} *)

val make : ?scheme:string -> ?label:string -> string -> t
(** [make ?scheme ?label term] constructs an element of {!type:t}. [scheme] is
    used as [domain] for [rss2] and [label] is discarded. *)

val to_atom : t -> Xml.node
(** Generate an Atom node. *)

val to_rss2 : t -> Xml.node
(** Generate a Rss2 node. *)
