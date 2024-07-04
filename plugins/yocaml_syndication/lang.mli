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

(** A description of languages based on the ISO-639-2 standard, with an
    extension allowing languages to be added manually. *)

(** {1 Types} *)

type t =
  | Af
  | Sq
  | Eu
  | Be
  | Bg
  | Ca
  | Zh_cn
  | Zh_tw
  | Hr
  | Cs
  | Da
  | Nl
  | Nl_be
  | Nl_nl
  | En
  | En_au
  | En_bz
  | En_ca
  | En_ie
  | En_jm
  | En_nz
  | En_ph
  | En_za
  | En_tt
  | En_gb
  | En_us
  | En_zw
  | Et
  | Fo
  | Fi
  | Fr
  | Fr_be
  | Fr_ca
  | Fr_fr
  | Fr_lu
  | Fr_mc
  | Fr_ch
  | Gl
  | Gd
  | De
  | De_at
  | De_de
  | De_li
  | De_lu
  | De_ch
  | El
  | Haw
  | Hu
  | Is
  | In
  | Ga
  | It
  | It_it
  | It_ch
  | Ja
  | Ko
  | Mk
  | No
  | Pl
  | Pt
  | Pt_br
  | Pt_pt
  | Ro
  | Ro_mo
  | Ro_ro
  | Ru
  | Ru_mo
  | Ru_ru
  | Sr
  | Sk
  | Sl
  | Es
  | Es_ar
  | Es_bo
  | Es_cl
  | Es_co
  | Es_cr
  | Es_do
  | Es_ec
  | Es_sv
  | Es_gt
  | Es_hn
  | Es_mx
  | Es_ni
  | Es_pa
  | Es_py
  | Es_pe
  | Es_pr
  | Es_es
  | Es_uy
  | Es_ve
  | Sv
  | Sv_fi
  | Sv_se
  | Tr
  | Uk
  | Other of string

(** {1 Helpers} *)

val other : string -> t
(** [other s] lift an external language. *)

val to_string : t -> string
(** [to_string lang] returns the string representation of a language. *)
