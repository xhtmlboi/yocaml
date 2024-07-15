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

(** Plugin for describing metadata with Yaml, based on the
    {{:https://ocaml.org/p/yaml/latest} Yaml package}. *)

(** {1 Reading file with metadata}

    Just as the [Yocaml] package describes a {i low-level} interface for
    propagating effects, the {!module:Yocaml.Eff} module, and an interface for
    composing arrows, via the {!module:Yocaml.Pipeline} module, the plugin
    describes two sub-modules to serve the same needs. *)

module Eff : sig
  (** Describes the {i low-level} interface for reading a file and parsing its
      metadata into Yaml. *)

  val read_file_with_metadata :
       (module Yocaml.Required.DATA_READABLE with type t = 'a)
    -> ?extraction_strategy:Yocaml.Metadata.extraction_strategy
    -> on:Yocaml.Eff.filesystem
    -> Yocaml.Path.t
    -> ('a * string) Yocaml.Eff.t
  (** The analogous function of {!val:Yocaml.Eff.read_file_with_metadata}, not
      requiring a [DATA_PROVIDER]. Identical to using
      [Yocaml.Eff.read_file_with_metadata (module Yocaml_yaml) ...].*)

  val read_file_as_metadata :
       (module Yocaml.Required.DATA_READABLE with type t = 'a)
    -> on:Yocaml.Eff.filesystem
    -> Yocaml.Path.t
    -> 'a Yocaml.Eff.t
  (** The analogous function of {!val:Yocaml.Eff.read_file_as_metadata}, not
      requiring a [DATA_PROVIDER]. Identical to using
      [Yocaml.Eff.read_file_as_metadata (module Yocaml_yaml) ...].*)
end

module Pipeline : sig
  (** Describes the {i arrowized} interface for reading a file and parsing its
      metadata into Yaml. *)

  val read_file_with_metadata :
       (module Yocaml.Required.DATA_READABLE with type t = 'a)
    -> ?extraction_strategy:Yocaml.Metadata.extraction_strategy
    -> Yocaml.Path.t
    -> (unit, 'a * string) Yocaml.Task.t
  (** The analogous function of {!val:Yocaml.Pipeline.read_file_with_metadata},
      not requiring a [DATA_PROVIDER]. Identical to using
      [Yocaml.Pipeline.read_file_with_metadata (module Yocaml_yaml) ...].*)

  val read_file_as_metadata :
       (module Yocaml.Required.DATA_READABLE with type t = 'a)
    -> Yocaml.Path.t
    -> (unit, 'a) Yocaml.Task.t
  (** The analogous function of {!val:Yocaml.Pipeline.read_file_as_metadata},
      not requiring a [DATA_PROVIDER]. Identical to using
      [Yocaml.Pipeline.read_file_as_metadata (module Yocaml_yaml) ...].*)
end

(** {1 Data Provider}

    As it is possible to describe metadata in Yaml, the plugin is a
    [Data_provider]. *)

include Yocaml.Required.DATA_PROVIDER with type t = Yaml.value
(** @inline *)
