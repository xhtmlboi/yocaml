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

(** Implementation of the ATOM specification, documented here:
    {{:https://datatracker.ietf.org/doc/html/rfc4287} specs}. *)

(** {1 Types}

    Types that briefly describe the Atom specification. *)

type text_construct
(** A Text construct contains human-readable text, usually in small quantities.
    The content of Text constructs is Language-Sensitive.
    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-3.1> *)

(** Define the kind of a link. Formally the [rel] attribute.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.7.2> *)
type link_rel = Alternate | Related | Self | Enclosure | Via | Link of string

type link
(** Defines a reference from an entry or feed to a Web resource. This
    specification assigns no meaning to the content (if any) of this element.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.7> *)

type source
(** If an entry is copied from one feed into another feed, then the source
    feed's metadata (all child elements of feed other than the atom:entry
    elements) MAY be preserved within the copied entry by adding an source child
    element, if it is not already present in the entry, and including some or
    all of the source feed's Metadata elements as the source element's children.
    Such metadata SHOULD be preserved if the source feed contains any of the
    child elements author, contributor, rights, or category and those child
    elements are not present in the source entry.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.11> *)

type content
(** The content element either contains or links to the content of the entry.
    The content of atom:content is Language-Sensitive.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.1.3> *)

type entry
(** The "entry" element represents an individual entry, acting as a container
    for metadata and data associated with the entry. This element can appear as
    a child of the feed element, or it can appear as the document (i.e.,
    top-level) element of a stand-alone Atom Entry Document.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.1.2> *)

type updated_strategy
(** Defines how the feed's [updated] field will be calculated. *)

(** {1 Construction of elements} *)

(** {2 Text Construct}

    A Text construct contains human-readable text, usually in small quantities.
    The content of Text constructs is Language-Sensitive.
    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-3.1> *)

val text : string -> text_construct
(** [text s] constructs an element of type {!type:text_construct} textual.
    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-3.1> *)

val html : string -> text_construct
(** [html s] constructs an element of type {!type:text_construct} HTML.
    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-3.1> *)

val xhtml : ?need_prefix:bool -> Xml.node -> text_construct
(** [xhtml ?need_prefix s] constructs an element of type {!type:text_construct}
    XHTML. If [need_prefix] is [true], every children of the given node will be
    prefixed by the [xhtml] namespace.
    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-3.1> *)

(** {2 Links}

    Defines a reference from an entry or feed to a Web resource. This
    specification assigns no meaning to the content (if any) of this element.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.7> *)

val link :
     ?rel:link_rel
  -> ?media_type:Media_type.t
  -> ?hreflang:string
  -> ?length:int
  -> ?title:string
  -> string
  -> link
(** Constructs a link (an external source).

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.7> *)

val alternate :
     ?media_type:Media_type.t
  -> ?hreflang:string
  -> ?length:int
  -> ?title:string
  -> string
  -> link
(** [alternate] is [link ~rel:Alternate]. *)

val related :
     ?media_type:Media_type.t
  -> ?hreflang:string
  -> ?length:int
  -> ?title:string
  -> string
  -> link
(** [related] is [link ~rel:related]. *)

val self :
     ?media_type:Media_type.t
  -> ?hreflang:string
  -> ?length:int
  -> ?title:string
  -> string
  -> link
(** [self] is [link ~rel:Self]. *)

val enclosure :
     ?media_type:Media_type.t
  -> ?hreflang:string
  -> ?length:int
  -> ?title:string
  -> string
  -> link
(** [enclosure] is [link ~rel:enclosure]. *)

val via :
     ?media_type:Media_type.t
  -> ?hreflang:string
  -> ?length:int
  -> ?title:string
  -> string
  -> link
(** [via] is [link ~rel:Via]. *)

(** {2 Source}

    If an entry is copied from one feed into another feed, then the source
    feed's metadata (all child elements of feed other than the entry elements)
    MAY be preserved within the copied entry by adding an source child element,
    if it is not already present in the entry, and including some or all of the
    source feed's Metadata elements as the source element's children. Such
    metadata SHOULD be preserved if the source feed contains any of the child
    elements author, contributor, rights, or category and those child elements
    are not present in the source entry.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.11> *)

val source :
     ?subtitle:text_construct
  -> ?contributors:Person.t list
  -> ?categories:Category.t list
  -> ?generator:Generator.t option
  -> ?icon:string
  -> ?logo:string
  -> ?links:link list
  -> ?rights:text_construct
  -> ?updated:Datetime.t
  -> ?title:text_construct
  -> ?authors:Person.t list
  -> ?id:string
  -> unit
  -> source
(** Construct a [source]. *)

(** {2 Content}

    The content element either contains or links to the content of the entry.
    The content of content is Language-Sensitive.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.1.3> *)

val content_text : string -> content
(** [content_text s] constructs a textual content. *)

val content_html : string -> content
(** [content_html s] constructs an HTML content. *)

val content_xhtml : ?need_prefix:bool -> Xml.node -> content
(** [content_xhtml ?need_prefix s] constructs an XHTML content (like
    {!val:xhtml}). *)

val content_mime : ?media_type:Media_type.t -> string -> content
(** [content_mime ?media_type value] constructs a mime content. *)

val content_src : ?media_type:Media_type.t -> string -> content
(** [content_src ?media_type uri] constructs a source content.
    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.1.3.2> *)

(** {2 Entry}

    The "entry" element represents an individual entry, acting as a container
    for metadata and data associated with the entry. This element can appear as
    a child of the feed element, or it can appear as the document (i.e.,
    top-level) element of a stand-alone Atom Entry Document.

    @see <https://datatracker.ietf.org/doc/html/rfc4287#section-4.1.2> *)

val entry :
     ?authors:Person.t list
  -> ?contributors:Person.t list
  -> ?links:link list
  -> ?categories:Category.t list
  -> ?published:Datetime.t
  -> ?rights:text_construct
  -> ?source:source
  -> ?summary:text_construct
  -> ?content:content
  -> title:text_construct
  -> id:string
  -> updated:Datetime.t
  -> unit
  -> entry
(** Constructs an entry. *)

(** {1 Building a feed} *)

val updated_from_entries : ?default_value:Datetime.t -> unit -> updated_strategy
(** Uses entries to describe the last update date. If no entry is provided, the
    date provisioned by [default_value] will be used. *)

val updated_given : Datetime.t -> updated_strategy
(** Use a fixed [updated] value. *)

val feed :
     ?encoding:string
  -> ?standalone:bool
  -> ?subtitle:text_construct
  -> ?contributors:Person.t list
  -> ?categories:Category.t list
  -> ?generator:Generator.t option
  -> ?icon:string
  -> ?logo:string
  -> ?links:link list
  -> ?rights:text_construct
  -> updated:updated_strategy
  -> title:text_construct
  -> authors:Person.t Yocaml.Nel.t
  -> id:string
  -> ('a -> entry)
  -> 'a list
  -> Xml.t
(** Build an Atom feed.

    @see <https://datatracker.ietf.org/doc/html/rfc4287> *)

(** {1 Arrows for building a feed} *)

val from :
     ?encoding:string
  -> ?standalone:bool
  -> ?subtitle:text_construct
  -> ?contributors:Person.t list
  -> ?categories:Category.t list
  -> ?generator:Generator.t option
  -> ?icon:string
  -> ?logo:string
  -> ?links:link list
  -> ?rights:text_construct
  -> updated:updated_strategy
  -> title:text_construct
  -> authors:Person.t Yocaml.Nel.t
  -> id:string
  -> ('a -> entry)
  -> ('a list, string) Yocaml.Task.t
(** An arrow that build a feed that from an arbitrary list. *)

val from_articles :
     ?encoding:string
  -> ?standalone:bool
  -> ?subtitle:text_construct
  -> ?contributors:Person.t list
  -> ?categories:Category.t list
  -> ?generator:Generator.t option
  -> ?icon:string
  -> ?logo:string
  -> ?links:link list
  -> ?rights:text_construct
  -> ?updated:updated_strategy
  -> ?id:string
  -> site_url:string
  -> feed_url:string
  -> title:text_construct
  -> authors:Person.t Yocaml.Nel.t
  -> unit
  -> ((Yocaml.Path.t * Yocaml.Archetype.Article.t) list, string) Yocaml.Task.t
(** An arrow that build a feed that fit with
    {!val:Yocaml.Archetype.Articles.fetch}. [link] is concatenate with the given
    [path] to compute the [url] of an item. *)
