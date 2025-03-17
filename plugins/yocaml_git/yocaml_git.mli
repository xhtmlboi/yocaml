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

(** The Git Runtime for YOCaml.

    Builds a runtime based on a source runtime generating artefacts in a Git
    database, which can then be served by a Unikernel (ie:
    {{:https://github.com/robur-coop/unipi} unipi}). *)

val run :
     (module Required.SOURCE)
  -> context:[ `SSH ]
  -> ?author:string
  -> ?email:string
  -> ?message:string
  -> remote:string
  -> ?level:Yocaml_runtime.Log.level
  -> ?custom_error_handler:
       (Format.formatter -> Yocaml.Data.Validation.custom_error -> unit)
  -> (unit -> unit Yocaml.Eff.t)
  -> (unit, [> `Msg of string ]) result Lwt.t
(** Executes a YOCaml program using a given Runtime for processing with [Source]
    and using a [Git Store] as compilation target. What the YOCaml progam
    generates is compared with what you can view from the given remote
    repository and updated with a new Git commit. Then, we [push] these changes
    to the remote repository.

    [ctx] contains multiple informations needed to initiate a communication with
    the given remote repository. See [Git_unix.ctx] for more details. *)

(** {1 Building a source}

    Since Git is only the target, we need to provision the source, with a
    function capable of transforming the type of the source runtime to [lwt] by
    implementing a [lift function]. *)

module Required = Required
(** Interfaces required. *)

(** Allows the creation of a source where the type of the source runtime is the
    identity ([type ‘a t = ’a]), as for the [Unix] runtime (for example). *)

module From_identity (Source : Yocaml.Required.RUNTIME with type 'a t = 'a) :
  Required.SOURCE with type 'a t = 'a Source.t
