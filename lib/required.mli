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

(** Signatures enabling modules to be created, via functors or first-class
    modules. *)

(** {1 Dealing with Metadata} *)

type provider_error =
  | Parsing_error of { given : string; message : string }
  | Validation_error of { entity : string; error : Data.Validation.value_error }
  | Required_metadata of { entity : string }

module type DATA_PROVIDER = sig
  (** A Data Provider is used to deserialise metadata to data of type
      {!type:Yocaml.Data.t} in order to apply validations. *)

  type t
  (** The type represented by the data provider.*)

  val from_string : string -> (t, provider_error) result
  (** Produces a [ type t ] value from a string. *)

  val normalize : t -> Data.t
  (** Converts a value of type {!type:t} into a value of type {!type:Data.t}. *)
end

module type DATA_READABLE = sig
  (** Describes a type capable of being treated as metadata of type
      {!type:Data.t}. *)

  type t
  (** The type that describes the metadata. *)

  val entity_name : string
  (** Assigns a name to an entity (a set of metadata). *)

  val neutral : (t, provider_error) result
  (** Describes a neutral element, as a fallback in the absence of metadata. The
      function can return an error if the request is mandatory. *)

  val validate : Data.t -> t Data.Validation.validated_value
  (** [validate raw_data] Validates a data item represented by type
      {!type:Data.t} and projects it into a value of type {!type:t}. *)
end
