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
  (** Converts a value of type {!type:t} into a value of type
      {!type:Yocaml.Data.t}. *)
end

module type DATA_READABLE = sig
  (** Describes a type capable of being readable as metadata of type
      {!type:Yocaml.Data.t}. Used to lift a module into a validator for data
      described by a {!module-type:Yocaml.Required.DATA_PROVIDER}. *)

  type t
  (** The type that describes the metadata. *)

  val entity_name : string
  (** Assigns a name to an entity (a set of metadata). *)

  val neutral : (t, provider_error) result
  (** Describes a neutral element, as a fallback in the absence of metadata. The
      function can return an error if the request is mandatory. *)

  val validate : Data.t -> t Data.Validation.validated_value
  (** [validate raw_data] Validates a data item represented by type
      {!type:Yocaml.Data.t} and projects it into a value of type {!type:t}. *)
end

module type DATA_INJECTABLE = sig
  (** Describes a type capable of being injected as metadata of type
      {!type:Yocaml.Data.t}. Used to lift a module into an injecter of arbitrary
      types to a template (for example). *)

  type t
  (** The type that describes the metadata. *)

  val normalize : t -> (string * Data.t) list
  (** Converts a value of type {!type:t} into a value of type
      {!type:Yocaml.Data.t}. *)
end

module type DATA_TEMPLATE = sig
  (** Describes a language capable of applying a template by assigning data to
      it (normalized using {!module-type:Yocaml.Required.DATA_INJECTABLE}). *)

  type t
  (** The type that describes the template language. *)

  val from : Data.t -> t
  (** [from data] Transforms a normalized data representation ([data]) into an
      associative list of data that can be injected into a template. *)

  val render : ?strict:bool -> (string * t) list -> string -> string
  (** [render ?strict parameters content] injects [parameters] data into
      [content] and returns the result of the applied content. To inject
      metadata into a template. *)
end

module type DATA_READER = sig
  (** Describes a provider for reading Metadata from a [DATA_PROVIDER]. *)

  type t
  (** The type that describes the data provider *)

  type 'a eff
  (** Effect type. Usually {!type:Yocaml.Eff.t}. *)

  type ('a, 'b) arr
  (** Arrow type. Usually {!type:Yocaml.Task.t}. *)

  type extraction_strategy
  (** The extraction strategy. Usually
      {!type:Yocaml.Metadata.extraction_strategy}*)

  (** {1 Reading file with metadata}

      Just as the [Yocaml] package describes a {i low-level} interface for
      propagating effects, the {!module:Yocaml.Eff} module, and an interface for
      composing arrows, via the {!module:Yocaml.Pipeline} module, the plugin
      describes two sub-modules to serve the same needs. *)

  module Eff : sig
    (** Describes the {i low-level} interface for reading a file and parsing its
        metadata described by the type {!type:t}. *)

    val read_file_with_metadata :
         (module DATA_READABLE with type t = 'a)
      -> ?extraction_strategy:extraction_strategy
      -> ?snapshot:bool
      -> on:[ `Source | `Target ]
      -> Path.t
      -> ('a * string) eff
    (** The analogous function of {!val:Yocaml.Eff.read_file_with_metadata}, not
        requiring a [DATA_PROVIDER]. *)

    val read_file_as_metadata :
         (module DATA_READABLE with type t = 'a)
      -> ?snapshot:bool
      -> on:[ `Source | `Target ]
      -> Path.t
      -> 'a eff
    (** The analogous function of {!val:Yocaml.Eff.read_file_as_metadata}, not
        requiring a [DATA_PROVIDER].*)
  end

  module Pipeline : sig
    (** Describes the {i arrowized} interface for reading a file and parsing its
        metadata. *)

    val read_file_with_metadata :
         (module DATA_READABLE with type t = 'a)
      -> ?extraction_strategy:extraction_strategy
      -> ?snapshot:bool
      -> Path.t
      -> (unit, 'a * string) arr
    (** The analogous function of
        {!val:Yocaml.Pipeline.read_file_with_metadata}, not requiring a
        [DATA_PROVIDER]. *)

    val read_file_as_metadata :
         (module DATA_READABLE with type t = 'a)
      -> ?snapshot:bool
      -> Path.t
      -> (unit, 'a) arr
    (** The analogous function of {!val:Yocaml.Pipeline.read_file_as_metadata},
        not requiring a [DATA_PROVIDER]. *)
  end

  (** {1 Data Provider}

      As it is possible to describe metadata as a [Data_provider]. *)

  include DATA_PROVIDER with type t := t
  (** @inline *)
end

(** {1 Runtime}

    A runtime is a context for executing a YOCaml program (for example, Unix).
    It allows all the primitives described by the effects to be implemented
    without having to worry about implementing an effects handler. *)

module type RUNTIME = sig
  type runtime_error
  (** Runtime errors can be defined by the runtime creator. *)

  type 'a t
  (** Each command is wrapped in a value of type ['a t], making it possible to
      build runtimes wrapped in monads (for example, Git/Irmin, which are
      currently based on Lwt).*)

  val runtime_error_to_string : runtime_error -> string
  (** Converts a runtime error into a character string for diagnosis. *)

  val bind : ('a -> 'b t) -> 'a t -> 'b t
  (** the bind primitive for {!type:t}. *)

  val return : 'a -> 'a t
  (** the return primitive for {!type:t}. *)

  val log :
       ?src:Logs.src
    -> [ `App | `Error | `Warning | `Info | `Debug ]
    -> string
    -> unit t
  (** [log level message] log a [message] with a given [message]. *)

  val get_time : unit -> float t
  (** [get_time ()] returns the current timestamp. *)

  val file_exists : on:[ `Source | `Target ] -> Path.t -> bool t
  (** [file_exists ~on:source path] returns [true] if the file exists, false
      otherwise. *)

  val read_file :
    on:[ `Source | `Target ] -> Path.t -> (string, runtime_error) result t
  (** [read_file ~on:source path] returns the content of a file. *)

  val erase_file :
    on:[ `Source | `Target ] -> Path.t -> (unit, runtime_error) result t
  (** [erase_file ~on:source path] erase the given file *)

  val get_mtime :
    on:[ `Source | `Target ] -> Path.t -> (float, runtime_error) result t
  (** [get_mtime ~on:source path] returns the modification time of a file. *)

  val hash_content : string -> string t
  (** [hash_content str] hash a content. *)

  val create_directory :
    on:[ `Source | `Target ] -> Path.t -> (unit, runtime_error) result t
  (** [create_directory ~on path] create a directory. *)

  val write_file :
       on:[ `Source | `Target ]
    -> Path.t
    -> string
    -> (unit, runtime_error) result t
  (** [write_file ~on:source path content] write a file. *)

  val is_directory : on:[ `Source | `Target ] -> Path.t -> bool t
  (** [is_directory ~on:source path] returns [true] if the given path is a
      directory, [false] otherwise. *)

  val is_file : on:[ `Source | `Target ] -> Path.t -> bool t
  (** [is_file ~on:source path] returns [true] if the given path is a file,
      [false] otherwise. *)

  val read_dir :
       on:[ `Source | `Target ]
    -> Path.t
    -> (Path.fragment list, runtime_error) result t
  (** [read_dir ~on:source path] returns a list of filename (fragment) of a
      given directory. *)

  val exec :
       ?is_success:(int -> bool)
    -> string
    -> string list
    -> (string, runtime_error) result t
  (** [exec ?is_success prog ?args] will executes [prog ...args]. When
      [is_success] is provided, it is called with the exit code to determine
      whether it indicates success or failure. Without [is_success], success
      requires the process to return an exit code of 0.

      printing on standard output is returned. *)
end

(** {1 Runner}

    A Runner is used to run a Yocaml program in the context of a
    {!module-type:Yocaml.Required.RUNTIME}. *)

module type RUNNER = sig
  type 'a t
  (** Effect type. Usually {!type:Yocaml.Eff.t}. *)

  module Runtime : RUNTIME
  (** The given runtime. *)

  val run :
       ?custom_error_handler:
         (Format.formatter -> Data.Validation.custom_error -> unit)
    -> (unit -> unit t)
    -> unit Runtime.t
  (** Runs a YOCaml program (and interprets its effects, youhou). *)
end
