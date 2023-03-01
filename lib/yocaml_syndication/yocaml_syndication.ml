module Atom = struct
  type t = Syndic.Atom.feed

  let default_generator =
    { Syndic.Atom.version = Some "dev"
    ; uri = Some (Uri.of_string "https://github.com/xhtmlboi/yocaml")
    ; content = "YOcaml"
    }
  ;;

  let make
    ?authors
    ?categories
    ?contributors
    ?(generator = default_generator)
    ?icon
    ?links
    ?logo
    ?rights
    ?subtitle
    ~id
    ~title
    ~updated
    =
    Syndic.Atom.feed
      ?authors
      ?categories
      ?contributors
      ?icon
      ~generator
      ?links
      ?logo
      ?rights
      ?subtitle
      ~id
      ~title
      ~updated
  ;;

  let pp ppf feed =
    Format.fprintf ppf "%s" (Syndic.Atom.to_xml feed |> Syndic.XML.to_string)
  ;;

  let pp_atom ?(xml_version = "1.0") ?(encoding = "UTF-8") ppf feed =
    Format.fprintf
      ppf
      "<?xml version=%S encoding=%S?>%s"
      xml_version
      encoding
      (Syndic.Atom.to_xml feed |> Syndic.XML.to_string)
  ;;

  let to_atom ?xml_version ?encoding feed =
    Format.asprintf "%a" (pp_atom ?xml_version ?encoding) feed
  ;;
end
