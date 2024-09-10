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

(** A set of functors designed to automate the construction of boring and
    repetitive modules. *)

(** A Runtime is an execution context (ie, Unix or Git). They describe the entry
    point of a YOCaml program and abstract the file system. *)
module Runtime (Runtime : Required.RUNTIME) :
  Required.RUNNER with type 'a t := 'a Eff.t and module Runtime := Runtime

(** Builds metadata reader functions based on a data provider. *)
module Data_reader (DP : Required.DATA_PROVIDER) :
  Required.DATA_READER
    with type t = DP.t
     and type 'a eff := 'a Eff.t
     and type ('a, 'b) arr := ('a, 'b) Task.t
     and type extraction_strategy := Metadata.extraction_strategy
