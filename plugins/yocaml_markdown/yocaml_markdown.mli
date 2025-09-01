(* YOCaml a static blog generator.
   Copyright (C) 2025 The Funkyworkers and The YOCaml's developers

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

(** The recommended plugin for converting Markdown documents. It relies on the
    use of different packets to ensure different levels of conversion:

    - {{:Cmarkit} https://ocaml.org/p/cmarkit/latest}
    - {{:Hilite} https://ocaml.org/p/hilite/latest} for highlighting *)

val from_string_to_html :
     ?strict:bool
  -> ?heading_auto_ids:bool
  -> ?highlight:(Cmarkit.Doc.t -> Cmarkit.Doc.t)
  -> ?safe:bool
  -> string
  -> string
(** A shortcut to directly convert a Makrdown string into an HTML string. *)

(** {1 Document}

    Allows you to compose directly with Cmarkit documents. *)

module Doc : sig
  (** Features related to direct document processing Cmarkit. *)

  val make :
       ?strict:bool
    -> ?heading_auto_ids:bool
    -> ?highlight:(Cmarkit.Doc.t -> Cmarkit.Doc.t)
    -> string
    -> Cmarkit.Doc.t
  (** Produce a complete document. By default, [highlight] use the function
      {!val:syntax_highlighting}. *)

  val from_string :
    ?strict:bool -> ?heading_auto_ids:bool -> string -> Cmarkit.Doc.t
  (** Converts a string into a Cmarkit document. If you want more parameters,
      you can still use the Cmarkit function. *)

  val default_grammars_set : TmLanguage.t
  (** Returns a set of default supported grammars set. *)

  val table_of_contents : Cmarkit.Doc.t -> (string * string) Yocaml.Toc.t
  (** Compute the table of contents of a Markdown document (Where the first
      element of the couple is the ID of the section and the second is the
      VALUE). *)

  val syntax_highlighting :
       ?skip_unknown_languages:bool
    -> ?tm:TmLanguage.t
    -> ?lookup_method:Hilite.tm_lookup_method
    -> unit
    -> Cmarkit.Doc.t
    -> Cmarkit.Doc.t
  (** Highlight the given document using Hilite. *)

  val no_highlighting : Cmarkit.Doc.t -> Cmarkit.Doc.t
  (** To be used with {!val:make}. *)

  val to_html : ?safe:bool -> Cmarkit.Doc.t -> string
  (** Converts a document to an HTML string. *)
end

(** {1 Pipeline}

    Concrete pipelines. *)

module Pipeline : sig
  (** Task to deal with Pipelines. *)

  val make :
       ?strict:bool
    -> ?heading_auto_ids:bool
    -> ?highlight:(Cmarkit.Doc.t -> Cmarkit.Doc.t)
    -> ?safe:bool
    -> unit
    -> (string, string) Yocaml.Task.t
  (** Convert a Markdown string to an HTML String. *)

  val to_doc :
       ?strict:bool
    -> ?heading_auto_ids:bool
    -> ?highlight:(Cmarkit.Doc.t -> Cmarkit.Doc.t)
    -> unit
    -> (string, Cmarkit.Doc.t) Yocaml.Task.t
  (** A Task for converting a string into a Cmarkit document. *)

  val table_of_contents :
    (Cmarkit.Doc.t, (string * string) Yocaml.Toc.t) Yocaml.Task.t
  (** Compute the table of content of a given document. *)

  val with_table_of_contents :
    ( Cmarkit.Doc.t
    , (string * string) Yocaml.Toc.t * Cmarkit.Doc.t )
    Yocaml.Task.t
  (** Compute the table of contents of a given document and collapse the result.
  *)

  val table_of_contents_metadata :
       unit
    -> ( 'a * Cmarkit.Doc.t
       , ('a * (string * string) Yocaml.Toc.t) * Cmarkit.Doc.t )
       Yocaml.Task.t
  (** Deal with table of contents at the metadata level. *)

  val to_html : ?safe:bool -> unit -> (Cmarkit.Doc.t, string) Yocaml.Task.t
  (** A Task to convert a document to HTML. *)

  val table_of_contents_to_html :
       ?ol:bool
    -> unit
    -> ( ('a * (string * string) Yocaml.Toc.t) * 'b
       , ('a * string option) * 'b )
       Yocaml.Task.t
  (** Convert the table of content into an HTML representation. *)

  module With_metadata : sig
    val make :
         ?strict:bool
      -> ?heading_auto_ids:bool
      -> ?highlight:(Cmarkit.Doc.t -> Cmarkit.Doc.t)
      -> ?safe:bool
      -> unit
      -> ('a * string, 'a * string) Yocaml.Task.t
    (** Convert a Markdown string to an HTML String taking metadata in account.
    *)

    val make_with_table_of_contents :
         ?strict:bool
      -> ?heading_auto_ids:bool
      -> ?highlight:(Cmarkit.Doc.t -> Cmarkit.Doc.t)
      -> ?ol:bool
      -> ?safe:bool
      -> unit
      -> ('a * string, ('a * string option) * string) Yocaml.Task.t
    (** Same as {!val:make} but with table of contents handling. *)

    val to_doc :
         ?strict:bool
      -> ?heading_auto_ids:bool
      -> ?highlight:(Cmarkit.Doc.t -> Cmarkit.Doc.t)
      -> unit
      -> ('a * string, 'a * Cmarkit.Doc.t) Yocaml.Task.t
    (** A Task for converting a string into a Cmarkit document. *)

    val table_of_contents :
         unit
      -> ( 'a * Cmarkit.Doc.t
         , ('a * (string * string) Yocaml.Toc.t) * Cmarkit.Doc.t )
         Yocaml.Task.t

    val table_of_contents_to_html :
         ?ol:bool
      -> unit
      -> ( ('a * (string * string) Yocaml.Toc.t) * 'b
         , ('a * string option) * 'b )
         Yocaml.Task.t
    (** Convert the table of content into an HTML representation. *)

    val with_table_of_contents :
         ?strict:bool
      -> ?heading_auto_ids:bool
      -> ?highlight:(Cmarkit.Doc.t -> Cmarkit.Doc.t)
      -> ?ol:bool
      -> unit
      -> ('a * string, ('a * string option) * Cmarkit.Doc.t) Yocaml.Task.t
    (** Convert a document and collapse the table of content into the metadata
        field.*)

    val to_html :
      ?safe:bool -> unit -> ('a * Cmarkit.Doc.t, 'a * string) Yocaml.Task.t
  end
end
