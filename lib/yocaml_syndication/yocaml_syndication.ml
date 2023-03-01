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

  let entry_of_article url authors article =
    let module Article = Yocaml.Metadata.Article in
    let (year, month, day), time =
      Article.date article |> Yocaml.Date.to_pair
    in
    let time = Option.value time ~default:(0, 0, 0) in
    match
      Ptime.of_date_time
        ((year, Yocaml.Date.month_to_int month, day), (time, 0))
    with
    | None -> failwith "article date is not representable!"
    | Some updated ->
      Syndic.Atom.entry
        ~id:url
        ~title:(Text (Article.article_title article))
        ~authors
        ~updated
        ~summary:(Text (Article.article_description article))
        ()
  ;;
end
