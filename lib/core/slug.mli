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

(** An incredibly simple (and opinionated) implementation of
    {{:https://en.wikipedia.org/wiki/Clean_URL#Slug} Slug}.

    The implementation is rather dirigiste, and relatively unconfigurable, but
    it can easily be replaced by a different implementation and is only there to
    make it easier to bootstrap a blog. *)

(** {1 Types} *)

type t = string
(** A slug is just an alias on [string]. *)

(** {1 Building slugs} *)

val from :
     ?mapping:(char * string) list
  -> ?separator:char
  -> ?unknown_char:char
  -> string
  -> t
(** [from str] build a naive slug from a given string. *)

(** {1 Validating slugs} *)

val validate :
     ?separator:char
  -> ?unknown_char:char
  -> Data.t
  -> t Data.Validation.validated_value
(** Validated a slug. *)
