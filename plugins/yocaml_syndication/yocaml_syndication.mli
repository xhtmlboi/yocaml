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

(** A (partial) implementation of RSS and Atom to enable the production of
    syndication feeds.

    The implementations should be sufficient to build the archetypes offered by
    YOCaml, while allowing you to build flows manually (adapting to your data
    model). *)

(** {1 Syndication format}

    Implementation of syndication formats. *)

module Rss1 = Rss1
module Rss2 = Rss2

module Rss = Rss2
(** By default, [Rss] module is {!module:Rss2}. *)

(** {1 Element}

    Reusable elements for describing news feeds. *)

module Lang = Lang
module Tz = Tz
module Datetime = Datetime
module Text_input = Text_input
module Media_type = Media_type

(** {1 Low-level API}

    Direct (but partial) manipulation of XML documents to build Atoms or RSS
    feeds. *)

module Xml = Xml
