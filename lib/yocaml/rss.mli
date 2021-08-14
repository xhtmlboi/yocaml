(** A minimalist RSS2 representation. *)

(** {1 Document Structure} *)

(** {2 Describe an RSS Image} *)

module Image : sig
  type t

  val make
    :  ?description:string
    -> ?width:int
    -> ?height:int
    -> title:string
    -> link:string
    -> url:string
    -> unit
    -> t

  val pp : Format.formatter -> t -> unit
  val equal : t -> t -> bool
end

(** {2 Describes an RSS Category} *)

module Category : sig
  type t

  val make : ?domain:string -> category:string -> unit -> t
  val pp : Format.formatter -> t -> unit
  val equal : t -> t -> bool
end

(** {2 Describes an RSS Enclosure} *)

module Enclosure : sig
  type t

  val make : url:string -> media_type:Mime.t -> length:int -> unit -> t
  val pp : Format.formatter -> t -> unit
  val equal : t -> t -> bool
end

(** {2 Describes an RSS Source} *)

module Source : sig
  type t

  val make : url:string -> title:string -> unit -> t
  val pp : Format.formatter -> t -> unit
  val equal : t -> t -> bool
end

(** {2 Describes an RSS Guid} *)

module Guid : sig
  type t

  val make : ?is_permalink:bool -> url:string -> unit -> t
  val permalink : string -> t
  val link : string -> t
  val pp : Format.formatter -> t -> unit
  val equal : t -> t -> bool
end

(** {2 Describes an RSS Item} *)

module Item : sig
  type t

  val make
    :  ?author:string
    -> ?categories:Category.t list
    -> ?comments:string
    -> ?enclosure:Enclosure.t
    -> ?source:Source.t
    -> title:string
    -> link:string
    -> pub_date:Date.t
    -> description:string
    -> guid:Guid.t
    -> unit
    -> t

  val pp
    :  ?default_time:Date.hour * Date.min * Date.sec
    -> Format.formatter
    -> t
    -> unit

  val equal : t -> t -> bool
end

(** {2 Describe an RSS Cloud service} *)

module Cloud : sig
  type protocol =
    | Xml_rpc
    | Soap
    | Http_post

  type t

  val make
    :  domain:string
    -> port:int
    -> path:string
    -> register_procedure:string
    -> protocol:protocol
    -> unit
    -> t

  val pp : Format.formatter -> t -> unit
  val equal : t -> t -> bool
end

(** {2 Describe an RSS Channel} *)

module Channel : sig
  type t

  val make
    :  ?pub_date:Date.t
    -> ?last_build_date:Date.t
    -> ?category:Category.t
    -> ?image:Image.t
    -> ?cloud:Cloud.t
    -> ?copyright:string
    -> ?docs:string
    -> ?generator:string
    -> ?managing_editor:string
    -> ?ttl:int
    -> ?webmaster:string
    -> title:string
    -> link:string
    -> feed_link:string
    -> description:string
    -> Item.t list
    -> t

  val pp
    :  ?default_time:Date.hour * Date.min * Date.sec
    -> Format.formatter
    -> t
    -> unit

  val pp_rss
    :  ?xml_version:string
    -> ?encoding:string
    -> ?default_time:Date.hour * Date.min * Date.sec
    -> Format.formatter
    -> t
    -> unit

  val to_rss
    :  ?xml_version:string
    -> ?encoding:string
    -> ?default_time:Date.hour * Date.min * Date.sec
    -> t
    -> string

  val equal : t -> t -> bool
end
