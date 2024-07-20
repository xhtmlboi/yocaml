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

(** Implementation of the OPML (1 and 2) specification documented here:
    - {{:https://archive.wikiwix.com/cache/index2.php?url=http%3A%2F%2Fdev.opml.org%2Fspec1.html#federation=archive.wikiwix.com&tab=url}
        OPML 1.0}
    - {{:http://opml.org/spec2.opml} OPML 2.0}

    In fact, a document complying with the OPML2 specification is broadly
    compatible with specification 1, so it is
    {b recommended to use specification 2}.

    The module is not bundled with Arrows because transforming archetypes into
    an OPML feed is far less trivial and the encoding is less generalizable
    through archetypes. *)

(** {1 Types} *)

type t
(** Describes an OPML feed. *)

type outline
(** Describes an Outline. An [outline] is an XML element containing at least one
    required attribute, text, and zero or more additional attributes. An
    [outline] may contain zero or more [outline] sub-elements. No attribute may
    be repeated within the same [outline] element.

    @see <http://opml.org/spec2.opml#1629042239000> *)

(** {1 Construction of elements} *)

val outline :
     ?typ:string
  -> ?is_comment:bool
  -> ?is_breakpoint:bool
  -> ?xml_url:string
  -> ?html_url:string
  -> ?attr:Xml.Attr.t list
  -> ?categories:string list
  -> ?title:string
  -> text:string
  -> outline list
  -> outline
(** Describes an Outline. An [outline] is an XML element containing at least one
    required attribute, text, and zero or more additional attributes. An
    [outline] may contain zero or more [outline] sub-elements. No attribute may
    be repeated within the same [outline] element.

    @see <http://opml.org/spec2.opml#1629042239000> *)

val inclusion : url:string -> text:string -> outline
(** Describes a special outlines that can be opened (or included) into an OPML
    reader.

    @see <http://opml.org/spec2.opml#1629042832000> *)

val subscription :
     ?version:string
  -> ?description:string
  -> ?html_url:string
  -> ?language:string
  -> title:string
  -> feed_url:string
  -> unit
  -> outline
(** Describes a special outlines that describes a subscription to an RSS/ATOM
    feed.

    @see <http://opml.org/spec2.opml#1629042482000> *)

val feed :
     ?title:string
  -> ?date_created:Datetime.t
  -> ?date_modified:Datetime.t
  -> ?owner:Person.t
  -> ?expansion_state:int list
  -> ?vert_scroll_state:int
  -> ?window_top:int
  -> ?window_left:int
  -> ?window_bottom:int
  -> ?window_right:int
  -> outline list
  -> t
(** Construct a feed of outlines associated with an
    {{:http://opml.org/spec2.opml#1629042109000} Head} element.*)

(** {1 Generating OPML feeds} *)

val to_opml1 : ?encoding:string -> ?standalone:bool -> t -> Xml.t
(** Generates an OPML stream in accordance with specification 1.
    @see <https://archive.wikiwix.com/cache/index2.php?url=http%3A%2F%2Fdev.opml.org%2Fspec1.html#federation=archive.wikiwix.com&tab=url> *)

val to_opml2 : ?encoding:string -> ?standalone:bool -> t -> Xml.t
(** Generates an OPML stream in accordance with specification 2.
    @see <http://opml.org/spec2.opml> *)
