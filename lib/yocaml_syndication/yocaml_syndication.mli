(** An Atom representation. *)

(** {1 Describe an Atom feed} *)

module Atom : sig
  type t = Syndic.Atom.feed

  val make
    :  ?authors:Syndic.Atom.author list
    -> ?categories:Syndic.Atom.category list
    -> ?contributors:Syndic.Atom.author list
    -> ?icon:Uri.t
    -> ?links:Syndic.Atom.link list
    -> ?logo:Uri.t
    -> ?rights:Syndic.Atom.text_construct
    -> ?subtitle:Syndic.Atom.text_construct
    -> id:Uri.t
    -> title:Syndic.Atom.text_construct
    -> updated:Syndic.Date.t
    -> Syndic.Atom.entry list
    -> t

  val pp : Format.formatter -> t -> unit

  val pp_atom
    :  ?xml_version:string
    -> ?encoding:string
    -> Format.formatter
    -> t
    -> unit

  val to_atom : ?xml_version:string -> ?encoding:string -> t -> string
end
