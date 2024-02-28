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

(** An artificial file system that interprets the effects described in
    {!module:Yocaml.Eff}.

    The representation of the file system is rather naive, it's a list of
    {!type:item} where an [item] can be either a directory or a file. Each
    [item] is referenced by a [name], an [mtime] (modification date) and a
    [content] (a character string for a file and a {!type:t} for a directory).

    The modification time is modelled by an [integer], which seems sufficient
    for unit tests. *)

(** {1 Types} *)

type item
(** Type describing a file system object (file or directory). *)

and t = private item list
(** Type describing a file system, a list of {!type:item}. The type is kept
    private to prevent the construction of unordered file systems. *)

(** {1 Alcotest stuff}

    Utilities to make the file system testable by alcotest. *)

val equal : t -> t -> bool
(** Equality between two file systems. *)

val pp : Format.formatter -> t -> unit
(** Pretty-printer for file systems. *)

val testable : t Alcotest.testable
(** Testable for file system. *)

val testable_item : item Alcotest.testable
(** Testable for file system item*)

(** {1 Building a file system} *)

val from_list : item list -> t
(** [from_list fs] Transforms a list of {!type:item} into a file system (because
    the {!type: t} type is private.*)

val file : ?mtime:int -> string -> string -> item
(** [file ?mtime name content] creates a file, an item of the file system
    (default [mtime] is [1]). *)

val dir : ?mtime:int -> string -> item list -> item
(** [dir ?mtime name children] creates a directory, an item of the file system.
    If no [mtime] is provided, it use the max [mtime] of the list of given
    children. *)

(** {1 Interact with a file system} *)

val get : t -> string list -> item option
(** [get fs path] Returns a file system ([fs]) item referenced by its path. For
    example, the path [/foo/bar] will be described by the list
    [/["foo"; "bar"/]]. *)

val update :
     t
  -> string list
  -> (target:string -> previous_item:item option -> item option)
  -> t
(** [update fs path f] Updates a file system [fs] reaching the right position
    and applying [f]. If the callback ([f]) returns [None], the previous file
    will be deleted. The path [/foo/bar] will be described by the list
    [/["foo"; "bar"/]] *)

val rename : string -> item -> item
(** [rename item] change the name of an item. *)

(** {2 Infix operators}

    Some infix operators to simplify writing unit tests. *)

val ( .%{} ) : t -> string -> item option
(** [fs.%{"foo/bar"}] is [get fs ["foo"; "bar"]]. *)

val ( .%{}<- ) :
     t
  -> string
  -> (target:string -> previous_item:item option -> item option)
  -> t
(** [fs.%{"foo/bar"} <- f] is [update fs ["foo"; "bar"] f]. *)

(** {1 Retreive informations from file system} *)

val mtime_of : item -> int
(** [mtime_of item] returns the [mtime] of an [item]. *)

val name_of : item -> string
(** [name_of item] returns the [name] of an [item]. *)

(** {1 Dummy interpreter} *)

type trace
(** Describes a filesystem, used into the effect interpretation. *)

val create_trace : ?mtime:int -> t -> trace
(** [create_trace fs] build a new trace on top of a file system. *)

val trace_system : trace -> t
(** [trace_system trace] returns the modified file system. *)

val trace_execution : trace -> string list
(** [trace_execution trace] get the instruction trace. *)

val trace_mtime : trace -> int
(** [trace_mtime trace] get the current modification time of a trace. *)

(** {2 Additional effects}

    Controlling time from a test is possible by defining additional effects. *)

type _ Effect.t +=
  | Yocaml_test_increase_time : int -> unit Effect.t
        (** An effect that allows to increase time. *)

val increase_time : int -> unit Yocaml.Eff.t
(** [increase_time x] perform the effect [Yocaml_test_increase_time]. *)

val increase_time_with : int -> 'a -> 'a Yocaml.Eff.t
(** [increase_time_with] is [increase_time] allowing to pass a state. *)

(** {2 Run effectful program} *)

val run : trace:trace -> ('a -> 'b Yocaml.Eff.t) -> 'a -> trace * 'b
(** [run ~trace program input] run a given [program] (with a given [input])
    using the dummy file system and updating the [trace]. *)
