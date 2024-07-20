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

(** A Person construct is an element that describes a person, corporation, or
    similar entity.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-3.2> *)

(** {1 Types} *)

type t

(** {1 Helpers} *)

val make : ?uri:string -> ?email:string -> string -> t
(** [make ?uri ?email name] constructs an element of type {!type:t}. *)

val to_owner_name : t -> Xml.node
(** Generate the OPML node [ownerName]. *)

val to_owner_email : t -> Xml.node
(** Generate the OPML node [ownerEmail]. *)

val to_owner_id : t -> Xml.node
(** Generate the OPML node [ownerId]. *)

val to_atom :
  ?ns:string -> ?attr:Xml.Attr.t list -> name:string -> t -> Xml.node
(** Generate an Atom node. *)

val to_rss2 : t -> string
(** Generate a string representation of the person. *)
