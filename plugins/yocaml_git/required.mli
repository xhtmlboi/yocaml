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

(** Requirements for building a Git Runtime. *)

module type SOURCE = sig
  (** Describes a natural transformation allowing a Yocaml program of type
      [‘a t] to be transformed into a program of type [’a Lwt.t] (so that it can
      be used via [Yocaml_git]. *)

  include Yocaml.Required.RUNTIME

  val lift : 'a t -> 'a Lwt.t
  (** [lift x] lift a value from ['a t] to ['a Lwt.t]. *)
end

module type CONFIG = sig
  (** Store configuration. *)

  val store : Git_kv.t
  (** The type of the Git store. *)
end
