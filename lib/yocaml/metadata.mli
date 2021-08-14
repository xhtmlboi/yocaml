(** Data structures attachable to articles/documents.*)

(** Adding metadata that could be added dynamically to a template, during the
    generation of a page for example, is a step forward in the ergonomics of
    the blog! And yes, it avoids having to define a template per article. *)

(** {1 Metadata description}

    Minimum interfaces for describing metadata sets. *)

(** {2 Injectable metadata}

    Describes a data set that can be injected, for example into a template.*)

module type INJECTABLE = sig
  type t

  (** Produces a structured object, compliant to a template input from a [t]. *)
  val inject
    :  (module Key_value.DESCRIBABLE with type t = 'a)
    -> t
    -> (string * 'a) list
end

(** Inject [Injectable] data into a String using a templating strategy. *)
module type RENDERABLE = sig
  type t

  val to_string : ?strict:bool -> (string * t) list -> string -> string

  include Key_value.DESCRIBABLE with type t := t
end

(** {2 Readable metadata}

    A document can be decorated with metadata that can be read and validated. *)

(** Describes how to transform and validate strings into structured objects.
    An example of a Validable is the [Yocaml_yaml] module.*)
module type VALIDABLE = sig
  type t

  val from_string : string -> t Validate.t

  include Key_value.VALIDATOR with type t := t
end

(** Describes how to transform data processed by the Validable into a concrete
    type using validation functions from [VALIDABLE]. *)
module type READABLE = sig
  type t

  (** Try to produces a [t] from an optional value. *)
  val from_string : (module VALIDABLE) -> string option -> t Validate.t
end

(** {1 Utility}

    A collection of public features for building metadata sets. *)

(** {2 Date}

    A rather naive representation of dates. *)

module Date : sig
  type t = Date.t

  val from : (module VALIDABLE with type t = 'a) -> 'a -> t Validate.t

  include INJECTABLE with type t := t
end

(** {1 Metadata description}

    Example of a metadata set. These examples are directly usable but you
    should write your own! *)

(** {2 A single page}

    This collection of metadata describes a single page, characterised by a
    [title] and a [description]. Both parameters are optional. *)

module Page : sig
  include INJECTABLE
  include READABLE with type t := t

  val make : string option -> string option -> t
  val title : t -> string option
  val description : t -> string option
  val set_title : string option -> t -> t
  val set_description : string option -> t -> t
  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
end

(** {2 An Article}

    This collection of metadata describes an article, characterised by a
    [title] and a [description] (optional like for single page). And
    article-related metadata: [article_title], [article_description], [tags]
    and [date]. *)

module Article : sig
  include INJECTABLE
  include READABLE with type t := t

  val make
    :  string
    -> string
    -> string list
    -> Date.t
    -> string option
    -> string option
    -> t

  val article_title : t -> string
  val article_description : t -> string
  val date : t -> Date.t
  val tags : t -> string list
  val title : t -> string option
  val description : t -> string option
  val set_article_title : string -> t -> t
  val set_article_description : string -> t -> t
  val set_date : Date.t -> t -> t
  val set_tags : string list -> t -> t
  val set_title : string option -> t -> t
  val set_description : string option -> t -> t
  val equal : t -> t -> bool
  val pp : Format.formatter -> t -> unit
  val compare_by_date : t -> t -> int
  val to_rss_item : string -> t -> Rss.Item.t
end

(** {2 A page with a list of article} *)

module Articles : sig
  include INJECTABLE

  val make
    :  ?title:string
    -> ?description:string
    -> (Article.t * string) list
    -> t

  val sort_articles_by_date : ?decreasing:bool -> t -> t
  val articles : t -> (Article.t * string) list
  val title : t -> string option
  val description : t -> string option
  val set_title : string option -> t -> t
  val set_description : string option -> t -> t
  val set_articles : (Article.t * string) list -> t -> t
end
