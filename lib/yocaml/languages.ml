module ISO639 = struct
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

  let name = function
    | Af -> "Afrikaans"
    | Sq -> "Albanian"
    | Eu -> "Basque"
    | Be -> "Belarusian"
    | Bg -> "Bulgarian"
    | Ca -> "Catalan"
    | Zh_cn -> "Chinese (Simplified)"
    | Zh_tw -> "Chinese (Traditional)"
    | Hr -> "Croatian"
    | Cs -> "Czech"
    | Da -> "Danish"
    | Nl -> "Dutch"
    | Nl_be -> "Dutch (Belgium)"
    | Nl_nl -> "Dutch (Netherlands)"
    | En -> "English"
    | En_au -> "English (Australia)"
    | En_bz -> "English (Belize)"
    | En_ca -> "English (Canada)"
    | En_ie -> "English (Ireland)"
    | En_jm -> "English (Jamaica)"
    | En_nz -> "English (New Zealand)"
    | En_ph -> "English (Phillipines)"
    | En_za -> "English (South Africa)"
    | En_tt -> "English (Trinidad)"
    | En_gb -> "English (United Kingdom)"
    | En_us -> "English (United States)"
    | En_zw -> "English (Zimbabwe)"
    | Et -> "Estonian"
    | Fo -> "Faeroese"
    | Fi -> "Finnish"
    | Fr -> "French"
    | Fr_be -> "French (Belgium)"
    | Fr_ca -> "French (Canada)"
    | Fr_fr -> "French (France)"
    | Fr_lu -> "French (Luxembourg)"
    | Fr_mc -> "French (Monaco)"
    | Fr_ch -> "French (Switzerland)"
    | Gl -> "Galician"
    | Gd -> "Gaelic"
    | De -> "German"
    | De_at -> "German (Austria)"
    | De_de -> "German (Germany)"
    | De_li -> "German (Liechtenstein)"
    | De_lu -> "German (Luxembourg)"
    | De_ch -> "German (Switzerland)"
    | El -> "Greek"
    | Haw -> "Hawaiian"
    | Hu -> "Hungarian"
    | Is -> "Icelandic"
    | In -> "Indonesian"
    | Ga -> "Irish"
    | It -> "Italian"
    | It_it -> "Italian (Italy)"
    | It_ch -> "Italian (Switzerland)"
    | Ja -> "Japanese"
    | Ko -> "Korean"
    | Mk -> "Macedonian"
    | No -> "Norwegian"
    | Pl -> "Polish"
    | Pt -> "Portuguese"
    | Pt_br -> "Portuguese (Brazil)"
    | Pt_pt -> "Portuguese (Portugal)"
    | Ro -> "Romanian"
    | Ro_mo -> "Romanian (Moldova)"
    | Ro_ro -> "Romanian (Romania)"
    | Ru -> "Russian"
    | Ru_mo -> "Russian (Moldova)"
    | Ru_ru -> "Russian (Russia)"
    | Sr -> "Serbian"
    | Sk -> "Slovak"
    | Sl -> "Slovenian"
    | Es -> "Spanish"
    | Es_ar -> "Spanish (Argentina)"
    | Es_bo -> "Spanish (Bolivia)"
    | Es_cl -> "Spanish (Chile)"
    | Es_co -> "Spanish (Colombia)"
    | Es_cr -> "Spanish (Costa Rica)"
    | Es_do -> "Spanish (Dominican Republic)"
    | Es_ec -> "Spanish (Ecuador)"
    | Es_sv -> "Spanish (El Salvador)"
    | Es_gt -> "Spanish (Guatemala)"
    | Es_hn -> "Spanish (Honduras)"
    | Es_mx -> "Spanish (Mexico)"
    | Es_ni -> "Spanish (Nicaragua)"
    | Es_pa -> "Spanish (Panama)"
    | Es_py -> "Spanish (Paraguay)"
    | Es_pe -> "Spanish (Peru)"
    | Es_pr -> "Spanish (Puerto Rico)"
    | Es_es -> "Spanish (Spain)"
    | Es_uy -> "Spanish (Uruguay)"
    | Es_ve -> "Spanish (Venezuela)"
    | Sv -> "Swedish"
    | Sv_fi -> "Swedish (Finland)"
    | Sv_se -> "Swedish (Sweden)"
    | Tr -> "Turkish"
    | Uk -> "Ukranian"
  ;;

  let identifier = function
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
  ;;

  let pp ppf x = Format.fprintf ppf "%s" (identifier x)
  let pp_name ppf x = Format.fprintf ppf "%s" (name x)

  let equal a b =
    match a, b with
    | Af, Af -> true
    | Sq, Sq -> true
    | Eu, Eu -> true
    | Be, Be -> true
    | Bg, Bg -> true
    | Ca, Ca -> true
    | Zh_cn, Zh_cn -> true
    | Zh_tw, Zh_tw -> true
    | Hr, Hr -> true
    | Cs, Cs -> true
    | Da, Da -> true
    | Nl, Nl -> true
    | Nl_be, Nl_be -> true
    | Nl_nl, Nl_nl -> true
    | En, En -> true
    | En_au, En_au -> true
    | En_bz, En_bz -> true
    | En_ca, En_ca -> true
    | En_ie, En_ie -> true
    | En_jm, En_jm -> true
    | En_nz, En_nz -> true
    | En_ph, En_ph -> true
    | En_za, En_za -> true
    | En_tt, En_tt -> true
    | En_gb, En_gb -> true
    | En_us, En_us -> true
    | En_zw, En_zw -> true
    | Et, Et -> true
    | Fo, Fo -> true
    | Fi, Fi -> true
    | Fr, Fr -> true
    | Fr_be, Fr_be -> true
    | Fr_ca, Fr_ca -> true
    | Fr_fr, Fr_fr -> true
    | Fr_lu, Fr_lu -> true
    | Fr_mc, Fr_mc -> true
    | Fr_ch, Fr_ch -> true
    | Gl, Gl -> true
    | Gd, Gd -> true
    | De, De -> true
    | De_at, De_at -> true
    | De_de, De_de -> true
    | De_li, De_li -> true
    | De_lu, De_lu -> true
    | De_ch, De_ch -> true
    | El, El -> true
    | Haw, Haw -> true
    | Hu, Hu -> true
    | Is, Is -> true
    | In, In -> true
    | Ga, Ga -> true
    | It, It -> true
    | It_it, It_it -> true
    | It_ch, It_ch -> true
    | Ja, Ja -> true
    | Ko, Ko -> true
    | Mk, Mk -> true
    | No, No -> true
    | Pl, Pl -> true
    | Pt, Pt -> true
    | Pt_br, Pt_br -> true
    | Pt_pt, Pt_pt -> true
    | Ro, Ro -> true
    | Ro_mo, Ro_mo -> true
    | Ro_ro, Ro_ro -> true
    | Ru, Ru -> true
    | Ru_mo, Ru_mo -> true
    | Ru_ru, Ru_ru -> true
    | Sr, Sr -> true
    | Sk, Sk -> true
    | Sl, Sl -> true
    | Es, Es -> true
    | Es_ar, Es_ar -> true
    | Es_bo, Es_bo -> true
    | Es_cl, Es_cl -> true
    | Es_co, Es_co -> true
    | Es_cr, Es_cr -> true
    | Es_do, Es_do -> true
    | Es_ec, Es_ec -> true
    | Es_sv, Es_sv -> true
    | Es_gt, Es_gt -> true
    | Es_hn, Es_hn -> true
    | Es_mx, Es_mx -> true
    | Es_ni, Es_ni -> true
    | Es_pa, Es_pa -> true
    | Es_py, Es_py -> true
    | Es_pe, Es_pe -> true
    | Es_pr, Es_pr -> true
    | Es_es, Es_es -> true
    | Es_uy, Es_uy -> true
    | Es_ve, Es_ve -> true
    | Sv, Sv -> true
    | Sv_fi, Sv_fi -> true
    | Sv_se, Sv_se -> true
    | Tr, Tr -> true
    | Uk, Uk -> true
    | _ -> false
  ;;
end
