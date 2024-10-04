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

(** Implementation of the RSS2 specification, documented here:
    {{:https://www.rssboard.org/rss-specification} specs}. *)

(** {1 Types}

    Types that briefly describe the RSS 2 specification. As the channel is
    closely linked to the description of a feed, the module does not export a
    [channel] type, as it is constructed when the feed is built. *)

(** Type describing days (for skip days).
    @see <https://www.rssboard.org/rss-specification> *)
type days = Mon | Tue | Wed | Thu | Fri | Sat | Sun

(** Type describing the cloud protocol.
    @see <https://www.rssboard.org/rss-specification#ltcloudgtSubelementOfLtchannelgt> *)
type cloud_protocol = Xml_rpc | Soap | Http_post

type cloud
(** Type describing the cloud attribute.
    @see <https://www.rssboard.org/rss-specification#ltcloudgtSubelementOfLtchannelgt> *)

type enclosure
(** Type describing the enclosure attribute.
    @see <https://www.rssboard.org/rss-specification#ltenclosuregtSubelementOfLtitemgt> *)

type guid
(** Type describing the guid attribute.
    @see <https://www.rssboard.org/rss-specification#ltguidgtSubelementOfLtitemgt> *)

type guid_strategy
(** Type describing the guid inference attribute.
    @see <https://www.rssboard.org/rss-specification#ltguidgtSubelementOfLtitemgt> *)

type source
(** Type describing the source attribute.
    @see <https://www.rssboard.org/rss-specification#ltsourcegtSubelementOfLtitemgt> *)

type image
(** Type describing the image attribute.
    @see <https://www.rssboard.org/rss-specification#ltimagegtSubelementOfLtchannelgt> *)

type item
(** Type describing an item.
    @see <https://www.rssboard.org/rss-specification#hrelementsOfLtitemgt> *)

(** {1 Construction of elements} *)

val cloud :
     protocol:cloud_protocol
  -> domain:string
  -> port:int
  -> path:string
  -> register_procedure:string
  -> cloud
(** Type describing the cloud attribute.
    @see <https://www.rssboard.org/rss-specification#ltcloudgtSubelementOfLtchannelgt> *)

val enclosure : url:string -> media_type:Media_type.t -> length:int -> enclosure
(** Type describing the enclosure attribute.
    @see <https://www.rssboard.org/rss-specification#ltenclosuregtSubelementOfLtitemgt> *)

val guid_from_title : guid_strategy
(** Infer GUID from the item title. *)

val guid_from_link : guid_strategy
(** Infer GUID from the item url. *)

val guid : is_permalink:bool -> string -> guid_strategy
(** Build a guid.
    @see <https://www.rssboard.org/rss-specification#ltguidgtSubelementOfLtitemgt> *)

val source : title:string -> url:string -> source
(** Build a sourcee.
    @see <https://www.rssboard.org/rss-specification#ltsourcegtSubelementOfLtitemgt> *)

val image :
     title:string
  -> link:string
  -> ?description:string
  -> ?width:int
  -> ?height:int
  -> url:string
  -> unit
  -> image
(** Build an image.
    @see <https://www.rssboard.org/rss-specification#ltimagegtSubelementOfLtchannelgt> *)

val item :
     ?author:Person.t
  -> ?categories:Category.t list
  -> ?comments:string
  -> ?enclosure:enclosure
  -> ?guid:guid_strategy
  -> ?pub_date:Datetime.t
  -> ?source:source
  -> title:string
  -> link:string
  -> description:string
  -> unit
  -> item
(** Build an item.
    @see <https://www.rssboard.org/rss-specification#hrelementsOfLtitemgt> *)

(** {1 Building a feed} *)

val feed :
     ?encoding:string
  -> ?standalone:bool
  -> ?language:Lang.t
  -> ?copyright:string
  -> ?managing_editor:Person.t
  -> ?webmaster:Person.t
  -> ?pub_date:Datetime.t
  -> ?last_build_date:Datetime.t
  -> ?categories:Category.t list
  -> ?generator:Generator.t
  -> ?cloud:cloud
  -> ?ttl:int
  -> ?image:(title:string -> link:string -> image)
  -> ?text_input:Text_input.t
  -> ?skip_hours:int list
  -> ?skip_days:days list
  -> title:string
  -> link:string
  -> url:string
  -> description:string
  -> ('a -> item)
  -> 'a list
  -> Xml.t
(** Build a RSS2 feed.

    @see <https://www.rssboard.org/rss-specification> *)

(** {1 Arrows for building a feed} *)

val from :
     ?encoding:string
  -> ?standalone:bool
  -> ?language:Lang.t
  -> ?copyright:string
  -> ?managing_editor:Person.t
  -> ?webmaster:Person.t
  -> ?pub_date:Datetime.t
  -> ?last_build_date:Datetime.t
  -> ?categories:Category.t list
  -> ?generator:Generator.t
  -> ?cloud:cloud
  -> ?ttl:int
  -> ?image:(title:string -> link:string -> image)
  -> ?text_input:Text_input.t
  -> ?skip_hours:int list
  -> ?skip_days:days list
  -> title:string
  -> site_url:string
  -> feed_url:string
  -> description:string
  -> ('a -> item)
  -> ('a list, string) Yocaml.Task.t
(** An arrow that build a feed that from an arbitrary list. *)

val from_articles :
     ?encoding:string
  -> ?standalone:bool
  -> ?language:Lang.t
  -> ?copyright:string
  -> ?managing_editor:Person.t
  -> ?webmaster:Person.t
  -> ?pub_date:Datetime.t
  -> ?categories:Category.t list
  -> ?generator:Generator.t
  -> ?cloud:cloud
  -> ?ttl:int
  -> ?image:(title:string -> link:string -> image)
  -> ?text_input:Text_input.t
  -> ?skip_hours:int list
  -> ?skip_days:days list
  -> title:string
  -> site_url:string
  -> feed_url:string
  -> description:string
  -> unit
  -> ((Yocaml.Path.t * Yocaml.Archetype.Article.t) list, string) Yocaml.Task.t
(** An arrow that build a feed that fit with
    {!val:Yocaml.Archetype.Articles.fetch}. [link] is concatenate with the given
    [path] to compute the link of an item. *)
