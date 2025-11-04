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

(** Archetypes are pre-designed, validatable and injectable models for rapid
    blog bootstrapping. However, as Yocaml is very generic... it's worth using
    it as an example rather than a concrete model. *)

(** {1 Components}

    Archetypes are fairly independent and can be used by customized models.
    We'll refer to them as components, because they can provide quick solutions
    for ambitious models. *)

module Datetime : sig
  (** Describes a date associated with a time. The "default" date format is
      [yyyy-mm-dd HH:mm-ss]. In addition to describing data as injectable or
      readable, the module provides a naive date processing API that seems to be
      useful for describing a blog. *)

  (** {1 Types}

      Types used to describe a date. *)

  (** Type describing a month *)
  type month =
    | Jan
    | Feb
    | Mar
    | Apr
    | May
    | Jun
    | Jul
    | Aug
    | Sep
    | Oct
    | Nov
    | Dec

  type year = private int
  (** Type describing a year (positive int, Because let's face it, we're not
      going to publish blogs during antiquity, are we?). *)

  type day = private int
  (** Type describing a day. A number from 1 to 31 (depending on the month). *)

  type hour = private int
  (** Type describing an hour. A number from 0 to 23. *)

  type min = private int
  (** Type describing a minut. A number from 0 to 59. *)

  type sec = private int
  (** Type describing a second. A number from 0 to 59. *)

  type t = {
      year : year
    ; month : month
    ; day : day
    ; hour : hour
    ; min : min
    ; sec : sec
  }
  (** Describes a complete date. As all potentially different values are
      private, the type must not be abstract (or private), as it must go through
      validation phases. *)

  (** {1 Building date} *)

  val make :
       ?time:int * int * int
    -> year:int
    -> month:int
    -> day:int
    -> unit
    -> t Data.Validation.validated_value
  (** [make ?time ~year ~month ~day ()] Builds a date when all data and
      validates all data.*)

  include Data.Validation.S with type t := t

  val validate : t Data.validable
  (** [validate data] try to read a date from a generic representation.*)

  (** {1 Dealing with date as metadata} *)

  include Data.S with type t := t

  val normalize : t -> Data.t
  (** [normalize datetime] render data generically (with additional fields).
      Here is the list of fields:
      - [year: int] the year value
      - [month: int] the month value
      - [day: int] the day value
      - [hour: int] the hour value
      - [min: int] the min value
      - [sec: int] the sec value
      - [has_time: bool] true if time is different than [0,0,0], false otherwise
      - [day_of_week: int] a number that represent the day of week (0: Monday,
        6: Sunday)
      - [repr: record] some representation of the date

      Representation of a date (field [repr]) :
      - [repr.month: string] a three-letters ident for the month
      - [repr.day_of_week: string] a three-letters ident for the day of the week
      - [repr.datetime: string] a string representation of the date
        [YYYY-mm-dd HH:mm:ss]
      - [repr.date: string] a string representation of the date [YYYY-mm-dd]
      - [repr.time: string] a string representation of the date [HH:mm:ss]

      Generating so much data may seem strange, but it allows the user to decide
      precisely, in his template, how to use/represent a date, which, in my
      opinion, is a good thing. No ? *)

  (** {1 Infix operators} *)

  module Infix : sig
    (** A collection of infix operators for comparing dates. *)

    val ( = ) : t -> t -> bool
    (** [a = b] returns [true] if [a] equal [b], [false] otherwise. *)

    val ( <> ) : t -> t -> bool
    (** [a <> b] returns [true] if [a] is not equal to [b], [false] otherwise.
    *)

    val ( > ) : t -> t -> bool
    (** [a > b] returns [true] if [a] is greater than [b], [false] otherwise. *)

    val ( >= ) : t -> t -> bool
    (** [a > b] returns [true] if [a] is greater or equal to [b], [false]
        otherwise. *)

    val ( < ) : t -> t -> bool
    (** [a > b] returns [true] if [a] is smaller than [b], [false] otherwise. *)

    val ( <= ) : t -> t -> bool
    (** [a > b] returns [true] if [a] is smaller or equal to [b], [false]
        otherwise. *)
  end

  include module type of Infix
  (** @inline*)

  (** {1 Util} *)

  val compare : t -> t -> int
  (** Comparison between datetimes. *)

  val equal : t -> t -> bool
  (** Equality between datetime. *)

  val min : t -> t -> t
  (** [min a b] returns the smallest [a] or [b]. *)

  val max : t -> t -> t
  (** [max a b] returns the greatest [a] or [b]. *)

  val pp : Format.formatter -> t -> unit
  (** Pretty printer for date. *)

  val pp_rfc822 : ?tz:string -> unit -> Format.formatter -> t -> unit
  (** Pretty printer according to the
      {{:https://www.w3.org/Protocols/rfc822/#z28} RFC822} specification. *)

  val pp_rfc3339 : ?tz:string -> unit -> Format.formatter -> t -> unit
  (** Pretty printer according to the
      {{:https://datatracker.ietf.org/doc/html/rfc3339} RFC822} specification.
  *)

  val dummy : t
  (** A dummy datetime. *)
end

(** {1 Models}

    A template is an archetype {i richer} that can be used to construct,
    {i out of the box} behavior such as pages or articles. And allows you to
    bootstrap {i quickly} a blog-engine (as generic as possible).

    The models are based on an object interface (hidden from the user) to enable
    easy composition. *)

module Page : sig
  (** A page is an archetype that naturally maps an HTML page, providing the
      necessary metadata to fill in the HTML-metadata ([<meta ...>]) and data to
      describe the various html tags ([<title>] and co). A page, which is often
      the basis of a compilation artifact, is also often associated with another
      archetype. For example, an Article is a page with additional fields.*)

  (** {1 Type} *)

  type t
  (** A type describing a page with associated fields:

      - [page_title] an optional title
      - [page_charset] an optional page charset
      - [description] an optional page description
      - [tags] an optional list of tags
      - [display_toc] an optional flag to displaying the table of contents or
        not
      - [toc] an optional representation of the table of contents

      The separation between fields prefixed with [page_] and those without
      prefix allows you to distinguish between fields that describe
      page-specific behavior and those that don't describe generic behavior. For
      example, an article is also a page, but can be given a different page
      title. *)

  (** {1 Accessors} *)

  val title : t -> string option
  val charset : t -> string option
  val description : t -> string option
  val tags : t -> string list
  val with_toc : t -> string option -> t

  (** {1 Deal with Page as Metadata}

      A page can be parsed and injected. *)

  include Data.Validation.S with type t := t

  include Required.DATA_READABLE with type t := t
  (** @inline *)

  (** In addition to the [page_title], [page_charset] and [page_description]
      fields, normalization returns a [meta] field that contains a list of
      [name; content] records to easily derive a list of metadata based on the
      page fields.

      It also exposes Boolean fields to determine whether a page has a title,
      description or charset with the parameters [has_page_title],
      [has_page_description], [has_page_charset] and [has_page_tags]. *)

  include Data.S with type t := t

  include Required.DATA_INJECTABLE with type t := t
  (** @inline *)
end

module Article : sig
  (** An article is a specialization of a page to describe blog posts
      (associated with a [title], [synopsis] and [date]). It's the minimal
      archetype for describing a blog post. *)

  (** {1 Type} *)

  type t
  (** A type describing an article. *)

  (** {1 Accessors} *)

  val page : t -> Page.t
  val title : t -> string
  val synopsis : t -> string option
  val date : t -> Datetime.t
  val with_toc : t -> string option -> t

  (** {1 Deal with Article as Metadata}

      An article can be parsed and injected. *)

  (** An article is also a page, so any data readable from a page is also
      readable from an article. If no value is given for [page_title], the
      metadata will use the article's [title]. The same applies to [description]
      and [synopsis]. *)

  include Data.Validation.S with type t := t

  include Required.DATA_READABLE with type t := t
  (** @inline *)

  (** As an article is also a page, article-normalized data includes
      article-normalized data with additional fields. As with optional fields,
      [synopsis] has a [has_synopsis] version. *)

  include Data.S with type t := t

  include Required.DATA_INJECTABLE with type t := t
  (** @inline *)
end

module Articles : sig
  (** Transforms a regular page into an article index. Useful for building an
      index (or archive page). The page is read as a regular page which must be
      injected with a list of [string * Article.t] pairs (where the first
      element is an identifier which will be used to reconstruct the URL of the
      article, the way in which the identifier is converted into a URL is left
      to the user, for example, in the template). *)

  (** {1 Type} *)

  type t
  (** A type describing a list of articles. *)

  val with_page : articles:(Path.t * Article.t) list -> page:Page.t -> t
  (** [with_page ~articles ~pages] builds the Article archetype with a page and
      a list of articles associated with their URLs. *)

  (** Unlike the previous archetypes, reading an index consists of reading a
      regular page, so this module does not implement the [DATA_READABLE]
      interface. However, it is possible to inject it. The classic workflow
      consists of reading the page's metadata. Constructing the list of articles
      to be displayed in the index, converting the page into an article and then
      applying the corresponding template cascade. *)

  val with_toc : t -> string option -> t

  val sort_by_date :
    ?increasing:bool -> (Path.t * Article.t) list -> (Path.t * Article.t) list
  (** [sort_by_date ?increasing articles] sorts items by date, if the
      [increasing] flag is set to [true], items will be ordered from oldest to
      newest. Otherwise, they will be sorted from newest to oldest. By default,
      the flag is set to [false]. *)

  val from_page : (Page.t * (Path.t * Article.t) list, t) Task.t
  (** [from_page articles page] transforms a regular page into an article index.
  *)

  val fetch :
       (module Required.DATA_PROVIDER)
    -> ?increasing:bool
    -> ?filter:((Path.t * Article.t) list -> (Path.t * Article.t) list)
    -> ?on:Eff.filesystem
    -> where:(Path.t -> bool)
    -> compute_link:(Path.t -> Path.t)
    -> Path.t
    -> (unit, (Path.t * Article.t) list) Task.t
  (** A helper task that transforms a directory path into a list of items,
      useful for building indexes. You can refer to the examples to see how this
      is used in a classic pipeline. *)

  val compute_index :
       (module Required.DATA_PROVIDER)
    -> ?increasing:bool
    -> ?filter:((Path.t * Article.t) list -> (Path.t * Article.t) list)
    -> ?on:Eff.filesystem
    -> where:(Path.t -> bool)
    -> compute_link:(Path.t -> Path.t)
    -> Path.t
    -> (Page.t, t) Task.t
  (** Pipe {!val:fetch} into a computed page. You can refer to the examples to
      see how this is used in a classic pipeline. *)

  include Data.S with type t := t

  include Required.DATA_INJECTABLE with type t := t
  (** @inline *)
end
