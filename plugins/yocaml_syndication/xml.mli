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

(** Tool for structuring (and printing) XML, used as a basis for describing XML
    nodes. The implementation is rather naive, but its purpose is simply to
    describe syndication flows, hence the "simplicity of the implementation".

    The first version lived in the [Yocaml] package and was based on an
    imoderate use of existentials. *)

(** {1 Attributes}

    Compose with XML attributes in the form `key="value"`. *)

module Attr : sig
  (** An attribute is an association between a key and a value (quoted). Please
      note that this library does not guarantee that the key or value is
      correctly formatted, and it is the user's responsibility to produce only
      correct values. *)

  (** {1 Types} *)

  type t
  (** Describes a [key * value] pair. *)

  type set
  (** Describes a list of attributes. The set of attributes must be unique, and
      the type is backed up by a Map to ensure that an attribute (described by
      its key) is present only once. *)

  (** {1 API} *)

  val make : ('a -> string) -> ?ns:string -> key:string -> 'a -> t
  (** [make ?ns ~key f value] Builds an arbitrary attribute value. The [ns]
      optional parameter allows to scope an attribute to a given namespace. *)

  val string : ?ns:string -> key:string -> string -> t
  (** [string ?ns ~key value] Builds a string attribute. *)

  val int : ?ns:string -> key:string -> int -> t
  (** [int ?ns ~key value] Builds an integer attribute. *)

  val float : ?ns:string -> key:string -> float -> t
  (** [float ?ns ~key value] Builds a float attribute. *)

  val bool : ?ns:string -> key:string -> bool -> t
  (** [bool ?ns ~key value] Builds a boolean attribute. *)

  val char : ?ns:string -> key:string -> char -> t
  (** [char ?ns ~key value] Builds a char attribute. *)

  val escaped : ?ns:string -> key:string -> string -> t
  (** [escaped ?ns ~key value] Build an attribute with special character
      replaced. *)
end

(** {1 Nodes}

    Description of XML nodes (or leaves). *)

(** {1 Types} *)

type node
(** Describes an XML node. An XML tree can be described by a [node] (a branch
    made up of branches) or by a [leaf] (a branch containing a PCDATA character
    string).*)

type t
(** Describes an XML document. *)

(** {1 API} *)

val document :
  ?version:string -> ?encoding:string -> ?standalone:bool -> node -> t
(** Create a complete XML document. *)

val leaf :
     ?indent:bool
  -> ?ns:string
  -> name:string
  -> ?attr:Attr.t list
  -> string option
  -> node
(** Describes a node that only contains PCDATA. *)

val cdata : string -> string option
(** [cdata txt] compose with {!val:leaf} to allow special chars. *)

val escape : string -> string option
(** [escape txt] compose with {!val:leaf} to escape special chars. *)

val node : ?ns:string -> name:string -> ?attr:Attr.t list -> node list -> node
(** Describesa node that contains nested nodes. *)

val namespace : ns:string -> node -> node
(** [namespace ~ns node] adds a namespace to the node and every node children.
*)

val opt : node option -> node
(** [opt node] conditionnally adds [node]. *)

val may : ('a -> node) -> 'a option -> node
(** [may f x] Lift a value into a node if it exists. *)

val may_leaf :
     ?indent:bool
  -> ?finalize:(string -> string option)
  -> name:string
  -> ('a -> string)
  -> 'a option
  -> node
(** [may_leaf ~name f x] May build a [leaf]. *)

val to_string : t -> string
(** Pretty printer for XML document. *)
