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

(** Generators for use with {{:https://ocaml.org/p/qcheck/latest} QCheck2} *)

val sexp : Yocaml.Sexp.t QCheck2.Gen.t
val path : Yocaml.Path.t QCheck2.Gen.t
val deps : Yocaml.Deps.t QCheck2.Gen.t
val cache_entry : Yocaml.Cache.entry QCheck2.Gen.t
val cache : Yocaml.Cache.t QCheck2.Gen.t
