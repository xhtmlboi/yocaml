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

(** Plugin for describing templates using
    {{:https://github.com/benfaerber/liquid-ml} liquid-ml}, an OCaml implementation
    of {{:https://shopify.github.io/liquid/} Shopify's Liquid} templating language. *)

(** {1 Injection}

    Description of a pipeline for reading a template and injecting content. *)

val read_template :
     ?snapshot:bool
  -> ?strict:bool
  -> Yocaml.Path.t
  -> ( unit
     ,    (module Yocaml.Required.DATA_INJECTABLE with type t = 'a)
       -> metadata:'a
       -> string
       -> string )
     Yocaml.Task.t
(** Return a function that apply [~metadata] and [~content] to a given template.
    Made the usage with applicative easier. *)

val read_templates :
     ?snapshot:bool
  -> ?strict:bool
  -> Yocaml.Path.t list
  -> ( unit
     ,    (module Yocaml.Required.DATA_INJECTABLE with type t = 'a)
       -> metadata:'a
       -> string
       -> string )
     Yocaml.Task.t
(** Return a function that apply [~metadata] and [~content] to a list of
    templates (in sequential order). Made the usage with applicative easier. *)

module Pipeline : sig
  (** Describes the {i arrowized} interface for reading a file as a template and
      injecting content and variables. *)

  val as_template :
       (module Yocaml.Required.DATA_INJECTABLE with type t = 'a)
    -> ?snapshot:bool
    -> ?strict:bool
    -> Yocaml.Path.t
    -> ('a * string, 'a * string) Yocaml.Task.t
  (** The analogous function for {!val:Yocaml.Pipeline.as_template} not
      requiring [DATA_TEMPLATE]. Identical to using
      [Yocaml.Pipeline.as_template (module Yocaml_liquid) ...]. *)
end

(** {1 Data template}

    Describes the [Yocaml_liquid] module as a template engine. Allows the
    latter to be passed to any function requiring it. *)

include Yocaml.Required.DATA_TEMPLATE with type t = Liquid_ml.Exports.value
(** @inline *)