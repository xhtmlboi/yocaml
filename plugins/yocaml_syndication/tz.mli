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

(** Describes (almost) a Timezone according to
    {{:https://www.w3.org/Protocols/rfc822/#z28} RFC822}. *)

(** {1 Types} *)

(** A type describing a timezone. *)
type t =
  | Ut
  | Gmt
  | Est
  | Edt
  | Cst
  | Cdt
  | Mst
  | Mdt
  | Pst
  | Pdt
  | T1Alpha
  | Plus of int
  | Minus of int

(** {1 Helpers} *)

val plus : int -> t
(** [plus 200] generates the TZ ["+0200"]. *)

val minus : int -> t
(** [minus 200] generates the TZ ["-0200"]. *)

val to_string : t -> string
(** [to_string tz] render a string representation of a timezone. *)
