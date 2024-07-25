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

(** {1 Metadata validation}

    Data validation tools. *)

type 'a validated = ('a, Required.provider_error) result
(** A type that describes validated metadata. *)

val required : string -> ('a, Required.provider_error) result
(** Helper for [Yocaml.Required.DATA_READABLE.neutral]. *)

val validate :
     (module Required.DATA_PROVIDER)
  -> (module Required.DATA_READABLE with type t = 'a)
  -> string option
  -> 'a validated
(** [validate (module Provider) (module Readable) opt_str] Validates an optional
    string described in the syntax described by the [Provider] module using the
    validation function described by the [Readable] module. The function uses
    [Readable.neutral] as a fallback if the string is [null].*)

(** {1 Metadata extraction}

    A set of functions for extracting metadata from a read document. *)

(** {2 Extraction strategy}

    Defines the extraction strategy for a set of metadata. *)

(** There are several strategies for describing how to separate metadata from
    the actual content, but it is also possible to provide your own
    implementation using the [Custom] constructor. *)
type extraction_strategy =
  | Regular of char
  | Custom of (string -> string option * string)

val regular : char -> extraction_strategy
(** Define a regular strategy, using 3 [char] as a delimiter. *)

val jekyll : extraction_strategy
(** Define the {{:https://jekyllrb.com/docs/front-matter/} front-matter}
    delimiter. *)

val custom : (string -> string option * string) -> extraction_strategy
(** Define a custom extraction strategy. *)

(** {2 Extraction} *)

val extract_from_content :
  strategy:extraction_strategy -> string -> string option * string
(** [extract_from_content ~strategy content] Attempts to extract metadata from a
    document using a defined strategy.*)
