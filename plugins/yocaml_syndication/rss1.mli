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

(** Implementation of the RSS1 specification, documented here:
    {{:https://web.resource.org/rss/1.0/spec} specs}. RSS2 or Atom are to be
    preferred, but RSS1 is present for historical reasons (if a user does not
    want to migrate his feed).

    As this specification is not widely recommended, no additional modules are
    implemented. *)

(** {1 Types}

    Types that briefly describe the RSS 1 specification. As the channel is
    closely linked to the description of a feed, the module does not export a
    [channel] type, as it is constructed when the feed is built. *)

type image
(** Type describing an image associated with the feed.
    @see <https://web.resource.org/rss/1.0/spec#s5.4> *)

type item
(** Type describing an item.
    @see <https://web.resource.org/rss/1.0/spec#s5.5> *)

(** {1 Construction of elements} *)

val image : title:string -> link:string -> url:string -> image
(** Build an image.
    @see <https://web.resource.org/rss/1.0/spec#s5.4> *)

val item : title:string -> link:string -> description:string -> item
(** Build an item.
    @see <https://web.resource.org/rss/1.0/spec#s5.5> *)

(** {1 Building a feed} *)

val feed :
     ?encoding:string
  -> ?standalone:bool
  -> ?image:image
  -> ?textinput:Text_input.t
  -> title:string
  -> url:string
  -> link:string
  -> description:string
  -> ('a -> item)
  -> 'a list
  -> Xml.t
(** Build a RSS1`feed. [url] is the [rdf identifier] of the feed (usually the
    url of the feed) and [link] is the link of the website attached to the feed.

    @see <https://web.resource.org/rss/1.0/spec#s5.3> *)

(** {1 Arrows for building a feed} *)

val from :
     ?encoding:string
  -> ?standalone:bool
  -> ?image:image
  -> ?textinput:Text_input.t
  -> title:string
  -> url:string
  -> link:string
  -> description:string
  -> ('a -> item)
  -> ('a list, string) Yocaml.Task.t
(** An arrow that build a feed that from an arbitrary list. *)

val from_articles :
     ?encoding:string
  -> ?standalone:bool
  -> ?image:image
  -> ?textinput:Text_input.t
  -> title:string
  -> url:string
  -> link:string
  -> description:string
  -> unit
  -> ((Yocaml.Path.t * Yocaml.Archetype.Article.t) list, string) Yocaml.Task.t
(** An arrow that build a feed that fit with
    {!val:Yocaml.Archetype.Articles.fetch}. *)
