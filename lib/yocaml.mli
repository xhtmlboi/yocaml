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

(** [Yocaml] is the entry point for a YOCaml program. It describes the
    core/engine of the framework. *)

(** {1 Elements}

    Modules describing the elements {i constituting} YOCaml, for example file
    paths etc. *)

module Path = Path

(** {1 Building rules}

    Modules for describing construction rules. Tasks to be executed, sets of
    dependencies, etc. *)

module Deps = Deps

(** {1 Effects abstraction}

    Modules relating to the
    {{:https://v2.ocaml.org/releases/5.1/htmlman/effects.html#s%3Aeffect-handlers}
      abstraction and performance of effects}. *)

module Eff = Eff
