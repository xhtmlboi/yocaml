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

(** Identifies the agent used to generate a feed, for debugging and other
    purposes.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.4> *)

(** {1 Types} *)

type t = { name : string; uri : string option; version : string option }

(** {1 Helpers} *)

val make : ?uri:string -> ?version:string -> string -> t
(** [make ?url ?version name] constructs a feed generator. For [Rss2], [uri] and
    [version] are ignored. *)

val to_atom : t -> Xml.node
(** Generate an Atom node. *)

val to_rss2 : t -> Xml.node
(** Generate a Rss2 node. *)

val yocaml : t
(** A default generator (referencing YOCaml). *)
