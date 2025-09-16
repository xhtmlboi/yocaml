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

(** An overlay on expression and effect performance.

    Currently ([OCaml 5.2.x]), the definition and interpretation of effects is a
    feature dedicated to implementing concurrent primitives for OCaml, for
    example: {{:https://v2.ocaml.org/api/Domain.html} the Domain API}. However,
    the effects type system has not yet been implemented, so the use of effects
    and handlers is still experimental.

    In YOCaml 1.0.0, effects were abstracted using a
    {{:https://okmij.org/ftp/Computation/free-monad.html} Freer Monad},
    described in the {{:https://github.com/xvw/preface} Preface}. However, since
    OCaml 5, it has been possible to describe effects, in order to be able to
    {i colour} the functions which propagate effects, we use an IO Monad. This
    allows us to distinguish pure functions from impure functions, while
    allowing the interpretation, a posteriori of effects, allowing
    specialisation via a Runtime to ensure the versatility of YOCaml. The
    trade-off is that you can't really take advantage of the direct style, but
    the presence of
    {{:https://v2.ocaml.org/manual/bindingops.html} binding operators} makes
    this loss fairly slight. *)

(** {1 The Eff Monad}

    The Eff Monad is an implementation of IO, which produces functions that
    propagate effects. It is used to distinguish between pure and impure
    functions. *)

type 'a t
(** A type describing an impure normal form. A function from ['a -> 'b] should
    be pure, and a function of ['a -> 'b Eff.t] should be impure and, in
    retrospect, be interpreted by an effect handler.*)

val return : 'a -> 'a t
(** [return x] lift [x] into an {i impure} context. *)

val bind : ('a -> 'b t) -> 'a t -> 'b t
(** [bind f x] gives the result of the computation [x] to the function [f]. *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** [map f x] mapping from ['a t] to ['b t]. *)

val join : 'a t t -> 'a t
(** [join x] remove one level of monadic structure, projecting its bound
    argument into the outer level. *)

val compose : ('a -> 'b t) -> ('b -> 'c t) -> 'a -> 'c t
(** [compose f g] is left to right composition of Kleisli Arrows of [f . g]. *)

val rcompose : ('b -> 'c t) -> ('a -> 'b t) -> 'a -> 'c t
(** [rcompose f g] is the right to left composition of Kleisli Arrows of
    [g . f]. *)

val apply : ('a -> 'b) t -> 'a t -> 'b t
(** [apply f x] apply f to x. *)

val zip : 'a t -> 'b t -> ('a * 'b) t
(** [zip x y] is the monoidal product of [x] and [y]. *)

val replace : 'a -> 'b t -> 'a t
(** [replace x e] replace the value of [e] by [x]. *)

val void : 'a t -> unit t
(** [void e] replace the value of [e] by [unit]. *)

val select : ('a, 'b) Either.t t -> ('a -> 'b) t -> 'b t
(** [select e f] apply [f] if [e] is [Left]. It allow to skip effect using
    [Right]. *)

val branch : ('a, 'b) Either.t t -> ('a -> 'c) t -> ('b -> 'c) t -> 'c t
(** [branch x f g ] if [x] is [Left], it performs [f], otherwise it performs
    [g]. *)

val map2 : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
(** Lift a 2-ary function. *)

val map3 : ('a -> 'b -> 'c -> 'd) -> 'a t -> 'b t -> 'c t -> 'd t
(** Lift a 3-ary function. *)

val map4 : ('a -> 'b -> 'c -> 'd -> 'e) -> 'a t -> 'b t -> 'c t -> 'd t -> 'e t
(** Lift a 4-ary function. *)

val map5 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f)
  -> 'a t
  -> 'b t
  -> 'c t
  -> 'd t
  -> 'e t
  -> 'f t
(** Lift a 5-ary function. *)

val map6 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g)
  -> 'a t
  -> 'b t
  -> 'c t
  -> 'd t
  -> 'e t
  -> 'f t
  -> 'g t
(** Lift a 6-ary function. *)

val map7 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'h)
  -> 'a t
  -> 'b t
  -> 'c t
  -> 'd t
  -> 'e t
  -> 'f t
  -> 'g t
  -> 'h t
(** Lift a 7-ary function. *)

val map8 :
     ('a -> 'b -> 'c -> 'd -> 'e -> 'f -> 'g -> 'h -> 'i)
  -> 'a t
  -> 'b t
  -> 'c t
  -> 'd t
  -> 'e t
  -> 'f t
  -> 'g t
  -> 'h t
  -> 'i t
(** Lift a 8-ary function. *)

(** {2 Traversable}

    Enables traversable structures to be traversed on effects. *)

module List : sig
  val traverse : ('a -> 'b t) -> 'a list -> 'b list t
  (** Map each element of a structure to an action, evaluate these actions from
      left to right, and collect the results. *)

  val sequence : 'a t list -> 'a list t
  (** Evaluate each action in the structure from left to right, and collect the
      results *)

  val filter_map : ('a -> 'b option t) -> 'a list -> 'b list t
  (** [filter_map] that acts on effectful predicates. *)

  val fold_left : ('acc t -> 'a -> 'acc t) -> 'acc t -> 'a t list -> 'acc t
  (** [fold_left f default l] apply [f] on each value of [l], accumulating into
      [default]. *)
end

(** {2 Infix operators}

    Comfort infix operators for composing programmes that produce effects. *)

module Infix : sig
  val ( <$> ) : ('a -> 'b) -> 'a t -> 'b t
  (** [f <$> x] is [map f x]. *)

  val ( <*> ) : ('a -> 'b) t -> 'a t -> 'b t
  (** [f <*> x] is [apply f x]. *)

  val ( <*? ) : ('a, 'b) Either.t t -> ('a -> 'b) t -> 'b t
  (** [c <*? f] is [select c f]*)

  val ( >>= ) : 'a t -> ('a -> 'b t) -> 'b t
  (** [m >>= f] is [bind f m]. *)

  val ( =<< ) : ('a -> 'b t) -> 'a t -> 'b t
  (** [f =<< m] is [bind f m]. *)

  val ( >|= ) : 'a t -> ('a -> 'b) -> 'b t
  (** [m >|= f] is [map f m]. *)

  val ( =|< ) : ('a -> 'b) -> 'a t -> 'b t
  (** [f =|< x] is [map f x]. *)

  val ( >=> ) : ('a -> 'b t) -> ('b -> 'c t) -> 'a -> 'c t
  (** [f >=> g] is [compose f g]. *)

  val ( <=< ) : ('b -> 'c t) -> ('a -> 'b t) -> 'a -> 'c t
  (** [f <=< g] is [rcompose f g]. *)
end

include module type of Infix
(** @inline *)

(** {2 Bindings operators}

    Comfort bindings operators for composing programmes that produce effects and
    get closer to the direct style. *)

module Syntax : sig
  val ( let+ ) : 'a t -> ('a -> 'b) -> 'b t
  (** [let+ x = e in f x] is [f <$> x]*)

  val ( and+ ) : 'a t -> 'b t -> ('a * 'b) t
  (** [let+ x = e and+ y = f in g x y] is [g <$> e <*> f]. *)

  val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
  (** [let* x = e in f x] is [e >>= f]. *)
end

include module type of Syntax
(** @inline *)

(** {1 User defined effects}

    Description of the effects that can be propagated by a YOCaml program. All
    effects are prefixed with [Yocaml_] to avoid conflicts with another program
    propagating different effects.

    Some effects are common (for example those used to log or propagate errors),
    some are used to act on the original filesystem and uses a parameter
    [`Source] and others act on the target and uses a parameter [`Target]. This
    makes it possible, for example, to generate in a target different from the
    source. This is useful, for example, when generating a site in a git
    repository, which uses a Unix file system as its source and a git repo as
    its target. *)

type filesystem = [ `Source | `Target ]

type _ Effect.t +=
  | Yocaml_log :
      (Logs.src option * [ `App | `Error | `Warning | `Info | `Debug ] * string)
      -> unit Effect.t
        (** Effect describing the logging of a message attached to a log level.
            The log level uses the various conventional levels offered, in
            particular, by the {{:https://erratique.ch/software/logs} Logs}
            library. *)
  | Yocaml_failwith : exn -> 'a Effect.t
        (** Effect that propagates an error. *)
  | Yocaml_get_time : unit -> int Effect.t
        (** Effect that get the current time. *)
  | Yocaml_file_exists : filesystem * Path.t -> bool Effect.t
        (** Effect that check if a file exists. *)
  | Yocaml_read_file : filesystem * bool * Path.t -> string Effect.t
        (** Effect that read a file from a given filepath (the second argument
            is used to notice if we need to perform a snapshot or not of the
            given file). *)
  | Yocaml_get_mtime : filesystem * Path.t -> int Effect.t
        (** Effect that get the modification time of a filepath. *)
  | Yocaml_hash_content : string -> string Effect.t
        (** Effect that hashes a string (used to hide the result of a
            transformation). *)
  | Yocaml_write_file : filesystem * Path.t * string -> unit Effect.t
        (** Effect which describes the writing of a file *)
  | Yocaml_is_directory : filesystem * Path.t -> bool Effect.t
        (** Effect that returns check if a path is a directory or not. *)
  | Yocaml_is_file : filesystem * Path.t -> bool Effect.t
        (** Effect that returns check if a path is a file. *)
  | Yocaml_read_dir : filesystem * Path.t -> Path.fragment list Effect.t
        (** Effect that returns a list of names of files (and directory) present
            in the given directory. (Names should be not prefixed by the given
            path). *)
  | Yocaml_create_dir : filesystem * Path.t -> unit Effect.t
        (** Effect that create a directory. *)
  | Yocaml_exec_command :
      string * string list * (int -> bool)
      -> string Effect.t
        (** Effect that perform an Unix call. *)

val perform : 'a Effect.t -> 'a t
(** [perform effect] colours an effect performance as impure. Replaces
    [Stdlib.Effect.perform x].*)

val run : ('b, 'c) Effect.Deep.handler -> ('a -> 'b t) -> 'a -> 'c
(** [run handler kleisli_arrow input] interprets a Kleisli Arrow
    ([kleisli_arrow]) for an effect handler ([effect_handler]) given as an
    argument ([input]). *)

(** {2 Exceptions}

    Exception that can be propagated by the performance of effects. *)

exception File_not_exists of filesystem * Path.t
(** Exception raised when a file does not exists. *)

exception Invalid_path of filesystem * Path.t
(** Exception raised when a file does not has a basename. *)

exception File_is_a_directory of filesystem * Path.t
(** Exception raised when we try to use a directory as a regular file. *)

exception Directory_is_a_file of filesystem * Path.t
(** Exception raised when we try to use a file as a directory. *)

exception Directory_not_exists of filesystem * Path.t
(** Exception raised when we try to use a directory as a regular file. *)

exception Provider_error of Required.provider_error
(** Exception raised when we try to validate an invalid source of metadata. *)

(** {2 Helpers for performing effects}

    Functions producing defined effects. *)

val yocaml_log_src : Logs.src
(** A source for YOCaml. *)

val log :
     ?src:Logs.src
  -> ?level:[ `App | `Error | `Warning | `Info | `Debug ]
  -> string
  -> unit t
(** [log ?src ~level message] performs the effect [Yocaml_log] with a given
    [level] and a [message]. *)

val logf :
     ?src:Logs.src
  -> ?level:[ `App | `Error | `Warning | `Info | `Debug ]
  -> ('a, Format.formatter, unit, unit t) format4
  -> 'a
(** [logf ?src ~level format] performs the effect [Yocaml_log] with a given
    [level] and using a format (like Printf). *)

val raise : exn -> 'a t
(** [raise exn] performs the effect [Yocaml_failwith] with a given [exn]. *)

val failwith : string -> 'a t
(** [failwith message] perform the effect [Yocaml_failwith] with a message that
    produces an error wrapped into a [Failure] exception. *)

val get_time : unit -> int t
(** [get_time ()] returns the current timestamp. *)

val exec : ?is_success:(int -> bool) -> string -> ?args:string list -> string t
(** [exec ?is_success prog ?args] will executes [prog ...args]. When
    [is_success] is provided, it is called with the exit code to determine
    whether it indicates success or failure. Without [is_success], success
    requires the process to return an exit code of 0.

    printing on standard output is returned. *)

val exec_cmd : ?is_success:(int -> bool) -> Cmd.t -> string t
(** [exec_cmd ?is_success cmd] is {!val:exec} but relaying on
    {!module:Yocaml.Cmd} for describing a shell call. *)

val file_exists : on:filesystem -> Path.t -> bool t
(** [file_exists ~on path] perform the effect [Yocaml_file_exists] with a given
    [path] return [true] if the file exists, [false] if not. *)

val read_file : ?snapshot:bool -> on:filesystem -> Path.t -> string t
(** [read_file ?snapshot ~on path] perform the effect [Yocaml_read_file] with a
    given [path] and try to read it. Perform [Yocaml_failwith] with
    {!exception:File_not_exists} if the file does not exists. [snapshot] is used
    to perform a snapshot of the file. *)

val read_file_as_metadata :
     (module Required.DATA_PROVIDER)
  -> (module Required.DATA_READABLE with type t = 'a)
  -> ?snapshot:bool
  -> on:filesystem
  -> Path.t
  -> 'a t
(** [read_file_as_metadata (module P) (module R) ~on path] reads a file located
    by a [path] on a data source ([on]) and validates the content as metadata
    according to a {!module-type:Yocaml.Required.DATA_PROVIDER}, [P], using the
    description provided by [R] of type
    {!module-type:Yocaml.Required.DATA_READABLE}. *)

val read_file_with_metadata :
     (module Required.DATA_PROVIDER)
  -> (module Required.DATA_READABLE with type t = 'a)
  -> ?extraction_strategy:Metadata.extraction_strategy
  -> ?snapshot:bool
  -> on:filesystem
  -> Path.t
  -> ('a * string) t
(** [read_file_with_metadata (module P) (module R) ?extraction_strategy ~on
     path] reads a file located by a [path] on a data source ([on]) and uses an
    [extraction_strategy] to separate the metadata from the content and
    validates the metadata according to a
    {!module-type:Yocaml.Required.DATA_PROVIDER}, [P], using the description
    provided by [R] of type {!module-type:Yocaml.Required.DATA_READABLE}. *)

val mtime : on:filesystem -> Path.t -> int t
(** [mtime ~on path] perform the effect [Yocaml_source_get_mtime] with a given
    [path] and try to get the modification time. Perform [Yocaml_failwith] with
    {!exception:File_not_exists} if the file does not exists.

    The logic of [mtime] differs slightly from that of Unix. If a directory is
    given as an argument, the function will return the largest [mtime]
    recursively contained in the directory. This makes it easy to treat
    directories as dependency sets. *)

val hash : string -> string t
(** [hash str] perform the effect [Yocaml_hash_content] on a given string. *)

val create_directory : on:filesystem -> Path.t -> unit t
(** [create_directory ~on target] performs recursively [Yocaml_create_dir] to
    create a directory. *)

val write_file : on:filesystem -> Path.t -> string -> unit t
(** [write_file ~on target content] performs the effect [Yocaml_write_file] that
    should writes a file to a given target. The function use
    {!val:Yocaml.Eff.create_directory} for creating intermediate directory in
    the path. *)

val is_directory : on:filesystem -> Path.t -> bool t
(** [is_directory ~on target] performs the effect [Yocaml_is_directory] that
    should check if a file is a directory or not. *)

val is_file : on:filesystem -> Path.t -> bool t
(** [is_file ~on target] performs the effect [Yocaml_is_directory] and if the
    file is not a directory, it return [true], [false] otherwise. *)

val read_directory :
     on:filesystem
  -> ?only:[ `Files | `Directories | `Both ]
  -> ?where:(Path.t -> bool)
  -> Path.t
  -> Path.t list t
(** [read_directory ~on ?only ?where path] returns a list of children (as a pair
    of the full path and the name ([fragment]) of the child) of the given
    directory, performing [Yocaml_read_dir]. *)

val copy_recursive : ?new_name:Path.fragment -> into:Path.t -> Path.t -> unit t
(** [copy_recursive ~on path] copy (recursively) a directory or a file into
    another one. *)

val get_basename : Path.t -> Path.fragment t
(** [get_basename path] returns the basename of a path (and fail if the path has
    no basename). *)
