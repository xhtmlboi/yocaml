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

(** Used to describe {i Unix-style} commands for executing arbitrary shell
    commands. It is up to the Runtime to use this representation to be
    cross-platform (for example, to use it with Windows).

    The library does not ensure typeafety but should be expressive enough to
    describe many CLI calls (and can serve as a basis for slightly stricter
    libraries). *)

(**/**)

(** {eof@ocaml[
      # #install_printer Yocaml.Cmd.pp ;;
      # #install_printer Yocaml.Cmd.pp_arg ;;
      # #install_printer Yocaml.Path.pp ;;
      # open Yocaml.Cmd ;;
    ]eof} *)

(**/**)

(** {1 Types}

    The way an order is structured respects this logic:
    [cmd_name -a --b foo bar1 bar2]:

    - [cmd_name] is the {b command name} (and is a regular string).
    - [-a] is a {b flag} and has the type {!type:arg}
    - [--b foo] is {b param} and has the type {!type:arg}.
    - [foo], [bar1] and [bar2] are [values], with type {!type:value}.

    A [value] can be a plain text or a {!type:Yocaml.Path.t} (that can be
    watched to form a dependency set).

    {eof@ocaml[
      # make "a-complicated_command" [
           flag "f";
           flag "w";
           param ~suffix:"=" "priority" @@ s "high";
           param "into" @@ w (Yocaml.Path.rel ["foo"; "bar"; "baz"]);
           arg @@ list ["a"; "b"; "c"; "d"]
        ] ;;
      - : t =
      a-complicated_command -f -w --priority=high --into ./foo/bar/baz a b c d
    ]eof} *)

type t
(** Describe a full command. *)

type arg
(** Describe an argument of a command. *)

type value
(** Describe a value.*)

(** {1 Building commands} *)

val make : string -> arg list -> t
(** [make cmd_name args] builds a shell command. *)

(** {2 Building Arguments} *)

val flag : ?prefix:string -> string -> arg
(** [flag ?prefix name] build a shell flag. The default [prefix] is [-]. Ie:
    [flag "foo"] is ["-foo"], but [flag ~prefix:"--T" "foo"] is ["--Tfoo"].

    {eof@ocaml[
      # flag "foo" ;;
      - : arg = -foo
      # flag ~prefix:"--T" "foo" ;;
      - : arg = --Tfoo
    ]eof} *)

val param : ?prefix:string -> ?suffix:string -> string -> value -> arg
(** [param ?prefix ?suffix key value] build a shell labeled argument. The
    default [prefix] is [--] and the default suffix is [" "]. A [param] use the
    following scheme: [prefix^key^suffix^value]. Ie:
    [param "foo" (string "bar")] is [--foo bar], but
    [param ~prefix:"--T" ~suffix:"=" "foo" (int 10)] is [--Tfoo=10].

    {eof@ocaml[
      # param "foo" @@ string "bar" ;;
      - : arg = --foo bar
      # param ~prefix:"--T" ~suffix:"=" "foo" @@ int 10 ;;
      - : arg = --Tfoo=10
    ]eof} *)

val arg : value -> arg
(** [arg x] create a plain argument. Ie: [arg (string "foo")] is [foo]. Value
    can be used to deal with non-structured argument, ie:
    [arg (string "--a b --c -d -eee")] seems perfectly valid. *)

(** {2 Building values} *)

val string : string -> value
(** [string x] build a regular string value. *)

val int : int -> value
(** [int x] build a value from an integer. *)

val char : char -> value
(** [char x] build a value from a char. *)

val float : float -> value
(** [float x] build a value from a float. *)

val bool : bool -> value
(** [int x] build a value from a list. *)

val list : ?sep:string -> string list -> value
(** [list ?sep values] collapse a list of string into one argument. By default
    [sep] is a space.

    The function does not lift an arbitrary list of values, as this would result
    in the loss of observable paths. *)

val path : ?watched:bool -> Path.t -> value
(** [path ?watched p] build a value from a path [p]. If [watched] is [true], the
    path can be observed as a dependency. (by default, [watched] is [false]. )*)

val watched : Path.t -> value
(** [watched p] is [path ~watched:true p]. *)

(** {2 Shortcuts}

    As it can be boring to build complex commands, the API provides a few
    shortcuts: *)

val s : string -> value
(** see {!val:string} *)

val i : int -> value
(** see {!val:int} *)

val c : char -> value
(** see {!val:char} *)

val f : float -> value
(** see {!val:float} *)

val p : ?watched:bool -> Path.t -> value
(** see {!val:path} *)

val w : Path.t -> value
(** see {!val:watched} *)

(** {1 Dependencies}

    When a path is provided to a command, it may or may not be observed as a
    dependency. *)

val deps_of : t -> Path.t list
(** [deps_of cmd] gives the set of observed dependencies. For example :

    {eof@ocaml[
      # deps_of @@ make "foo" [
           param "input"  @@ w (Yocaml.Path.rel ["a"; "b"; "c.txt"])
         ; param "with"   @@ w (Yocaml.Path.rel ["deps.txt"])
         ; param "output" @@ p (Yocaml.Path.rel ["out"; "abc.txt"])
        ] ;;
      - : Yocaml.Path.t list = [./a/b/c.txt; ./deps.txt]
    ]eof}

    (The output path is not watched). *)

(** {1 Helpers} *)

val pp : Format.formatter -> t -> unit
(** Pretty-printer for [cmd]. *)

val pp_arg : Format.formatter -> arg -> unit
(** Pretty-printer for [arg]. *)

val to_string : t -> string
(** [to_string cmd] convert a [command] to a [string]. *)

val normalize : t -> string * string list
(** [normalize cmd] return a pair of command and arguments. *)
