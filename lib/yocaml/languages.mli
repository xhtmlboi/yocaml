(** Deal with languages identifiers.*)

module ISO639 : sig
  (** The ISO639 specification for describing languages.*)

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

  val name : t -> string
  val identifier : t -> string
  val pp : Format.formatter -> t -> unit
  val pp_name : Format.formatter -> t -> unit
end
