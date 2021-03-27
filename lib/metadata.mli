(** Data structures attachable to articles/documents.*)

(** Adding metadata that could be added dynamically to a template, during the
    generation of a page for example, is a step forward in the ergonomics of
    the blog! And yes, it avoids having to define a template per article.

    Even if my goal was to remain as agnostic as possible, I find it quite
    useful to have the necessary tools to bootstrap a blog quickly. So I
    decided to rely mainly on two libraries for parsing and metadata
    injection.

    - {{:https://github.com/avsm/ocaml-yaml} ocaml-yaml} for the
      metadata-description in a relatively readable format.
    - {{:https://github.com/rgrinberg/ocaml-mustache} ocaml-mustache} for data
      injection in a template. *)

(** {1 Common interface for declaring a set of metadata}

    As I am not particularly happy with the implementation I am proposing... I
    decided to make everything abstract. A collection of metadata should
    simply respect the following interface: *)

module type METADATA = sig
  (** The container of the metadata. *)
  type obj

  (** {2 Conversion} *)

  (** Try to produces an [obj] from a [yaml] value. *)
  val from_yaml : Yaml.value -> obj Validate.t

  (** Try to produces an [obj] from an optional value passing through [Yaml]. *)
  val from_string : string option -> obj Validate.t

  (** Produces a [Json], compliant to [Mustache] from an [obj]. *)
  val to_mustache : obj -> (string * Mustache.Json.value) list

  (** {2 Utils} *)

  (** Equality between [obj]. *)
  val equal : obj -> obj -> bool

  (** Printers for [obj]. *)
  val pp : Format.formatter -> obj -> unit

  (** A structured representation of [obj]. *)
  val repr : string list
end

(** {1 Defined metadata set}

    In order to be able to bootstrap a project quickly, here are some
    prefabricated data sets. *)

(** {2 Base document}

    Describes the bare minimum of a page to be built. So the optional presence
    of a title: [page_title]. *)

module Base : sig
  include METADATA

  (** {2 Accessors} *)

  (** fetch the page title. *)
  val page_title : obj -> string option
end

(** {2 A simple article}

    My main goal is to create my blog... describing articles seems useful. The
    template for articles "inherits" that of a basic document and requires
    these fields:

    - [page_title] optional [string]
    - [tags] optional [string list]
    - [date] mandatory [string with format: "yyyy-mm-dd"]
    - [article_title] the title of the article
    - [article_synopsis] the synopsis of the article.

    The date format, among others, is quite restrictive, but the aim is for a
    potential user to describe their own metadata sets. *)

module Article : sig
  include METADATA

  (** {2 Accessors} *)

  (** fetch the page title. *)
  val page_title : obj -> string option

  (** fetch the tags. *)
  val tags : obj -> string list

  (** fetch the date. *)
  val date : obj -> int * int * int

  (** fetch the article title. *)
  val article_title : obj -> string

  (** fetch the article synopsis. *)
  val article_synopsis : obj -> string
end
