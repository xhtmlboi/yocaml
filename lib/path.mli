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

(** A path describes a path in the file system. It is only a description, which
    {b does not produce any ad-hoc verification}. It is therefore unfortunately
    possible to describe inconsistent paths (however, the expression of
    inconsistent paths is captured by the YOCaml core executable).

    The implementation of paths is clearly not the most optimised, it would be
    possible to do much more efficiently (for example, build the list in reverse
    or use a difference list) but we assume that this is not a catastrophic
    operation as file paths are generally short.

    {b TODO}: The aim of this implementation is to find an API that is easy to
    extend to capture the different uses in YOCaml. Once this API has
    stabilised, we can think about a less naive implementation. *)

(** {1 Types}

    The different types used to describe a path. These are essentially aliases
    for [strings] and [lists of strings].*)

type fragment = string
(** A fragment is an element of a path. For example, in the following path:
    ["foo/bar/baz"], fragments are : ["foo"], ["bar"] and ["baz"]. *)

type t
(** A path ([Path.t]) is just a line of fragments. Building paths that are
    "correct by construction" is an attractive idea, but it involves working
    with more complicated types. We prefer to use {{!module:Eff} Effect
    interpretation} to deal with incorrect path errors. *)

(** {1 Path manipulation} *)

val rel : fragment list -> t
(** [rel fragments] build a relative path (mostly used for YOCaml rules). *)

val abs : fragment list -> t
(** [abs fragments] build an absolute path. *)

val root : t
(** Returns the root of the file system. [root = abs []]. *)

val pwd : t
(** Returns the current dir of the file system. [pwd = rel []]. *)

val append : t -> fragment list -> t
(** [append path fragments] Produces a new path which adds the list of given
    fragments to the end of the given path. *)

val extension : t -> string
(** [extension path] apply [Filename.extension] on the last fragment of the
    path. If there is no extension, it returns an empty string. *)

val extension_opt : t -> string option
(** Like {!val:extension} but wrap the result in an option. *)

val remove_extension : t -> t
(** Remove the extension of the last fragment. If the last fragment has no
    extension, it keep the original path. *)

val add_extension : string -> t -> t
(** [add_extension ext path] add the extension [ext] to the last fragment of the
    path. If the path or the extension is empty, it keep it without change.
    [.ext] is treated like [ext]. *)

val change_extension : string -> t -> t
(** [change_extension ext path] replace (or add) [ext] to the given [path]. The
    function follows the same scheme of [add_extension]. If the extension is
    invalid, it will returns the path with the extension removed. *)

(** {1 Utils} *)

val pp : Format.formatter -> t -> unit
(** Pretty printers for {!type:t} values. *)

val equal : t -> t -> bool
(** Equality function for {!type:t} values. *)

val pp_fragment : Format.formatter -> fragment -> unit
(** Pretty printers for {!type:fragment} values. *)

val equal_fragment : fragment -> fragment -> bool
(** Equality function for {!type:fragment} values. *)

val compare : t -> t -> int
(** Comparisons between {!type:t}. An absolute path will always be smaller than
    a relative path (for arbitrary and unhelpful reasons). *)

val to_string : t -> string
(** [to_string path] lift a path into a string. *)

(** {1 Infix operators}

    As paths are used somewhat invasively in YOCaml to describe resources and
    targets, certain infix operators make it easier to manipulate them. *)

val ( ++ ) : t -> fragment list -> t
(** [path ++ fragments] is [append path fragments] (the function is
    [left-associative] allowing chain). *)

val ( / ) : t -> fragment -> t
(** [path / fragment ] is [append path [fragment]]. *)
