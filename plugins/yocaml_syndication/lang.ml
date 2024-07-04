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

let other s = Other s

let to_string = function
  | Af -> "af"
  | Sq -> "sq"
  | Eu -> "eu"
  | Be -> "be"
  | Bg -> "bg"
  | Ca -> "ca"
  | Zh_cn -> "zh-cn"
  | Zh_tw -> "zh-tw"
  | Hr -> "hr"
  | Cs -> "cs"
  | Da -> "da"
  | Nl -> "nl"
  | Nl_be -> "nl-be"
  | Nl_nl -> "nl-nl"
  | En -> "en"
  | En_au -> "en-au"
  | En_bz -> "en-bz"
  | En_ca -> "en-ca"
  | En_ie -> "en-ie"
  | En_jm -> "en-jm"
  | En_nz -> "en-nz"
  | En_ph -> "en-ph"
  | En_za -> "en-za"
  | En_tt -> "en-tt"
  | En_gb -> "en-gb"
  | En_us -> "en-us"
  | En_zw -> "en-zw"
  | Et -> "et"
  | Fo -> "fo"
  | Fi -> "fi"
  | Fr -> "fr"
  | Fr_be -> "fr-be"
  | Fr_ca -> "fr-ca"
  | Fr_fr -> "fr-fr"
  | Fr_lu -> "fr-lu"
  | Fr_mc -> "fr-mc"
  | Fr_ch -> "fr-ch"
  | Gl -> "gl"
  | Gd -> "gd"
  | De -> "de"
  | De_at -> "de-at"
  | De_de -> "de-de"
  | De_li -> "de-li"
  | De_lu -> "de-lu"
  | De_ch -> "de-ch"
  | El -> "el"
  | Haw -> "haw"
  | Hu -> "hu"
  | Is -> "is"
  | In -> "in"
  | Ga -> "ga"
  | It -> "it"
  | It_it -> "it-it"
  | It_ch -> "it-ch"
  | Ja -> "ja"
  | Ko -> "ko"
  | Mk -> "mk"
  | No -> "no"
  | Pl -> "pl"
  | Pt -> "pt"
  | Pt_br -> "pt-br"
  | Pt_pt -> "pt-pt"
  | Ro -> "ro"
  | Ro_mo -> "ro-mo"
  | Ro_ro -> "ro-ro"
  | Ru -> "ru"
  | Ru_mo -> "ru-mo"
  | Ru_ru -> "ru-ru"
  | Sr -> "sr"
  | Sk -> "sk"
  | Sl -> "sl"
  | Es -> "es"
  | Es_ar -> "es-ar"
  | Es_bo -> "es-bo"
  | Es_cl -> "es-cl"
  | Es_co -> "es-co"
  | Es_cr -> "es-cr"
  | Es_do -> "es-do"
  | Es_ec -> "es-ec"
  | Es_sv -> "es-sv"
  | Es_gt -> "es-gt"
  | Es_hn -> "es-hn"
  | Es_mx -> "es-mx"
  | Es_ni -> "es-ni"
  | Es_pa -> "es-pa"
  | Es_py -> "es-py"
  | Es_pe -> "es-pe"
  | Es_pr -> "es-pr"
  | Es_es -> "es-es"
  | Es_uy -> "es-uy"
  | Es_ve -> "es-ve"
  | Sv -> "sv"
  | Sv_fi -> "sv-fi"
  | Sv_se -> "sv-se"
  | Tr -> "tr"
  | Uk -> "uk"
  | Other s -> s
