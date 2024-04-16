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
    {{:https://ocaml.org/p/jingoo/latest} Jingoo}, a template engine inspired by
    {{:https://palletsprojects.com/p/jinja/} Jinja2} (from the Python world). *)

(** {1 Injection}

    Description of a pipeline for reading a template and injecting content. *)

module Pipeline : sig
  (** Describes the {i arrowized} interface for reading a file as a template and
      injecting content and variables. *)

  val as_template :
       (module Yocaml.Required.DATA_INJECTABLE with type t = 'a)
    -> ?strict:bool
    -> Yocaml.Path.t
    -> ('a * string, 'a * string) Yocaml.Task.t
  (** The analogous function for {!val:Yocaml.Pipeline.as_template} not
      requiring [DATA_TEMPLATE]. Identical to using
      [Yocaml.Pipeline.as_template (module Yocaml_jingoo) ...]. *)
end

(** {1 Data template}

    Describes the [Yocaml_jingoo] module as a template engine. Allows the latter
    to be passed to any function requiring it. *)

include Yocaml.Required.DATA_TEMPLATE with type t = Jingoo.Jg_types.tvalue
