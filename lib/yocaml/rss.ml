open Util

(* I definitely should learn more about Tyxml... or Syndic. *)

let pp_empty ppf = Format.fprintf ppf ""

let pp_opt pp ppf = function
  | Some x -> Format.fprintf ppf "%a" pp x
  | None -> pp_empty ppf
;;

let pp_string = Format.pp_print_string
let pp_int = Format.pp_print_int
let pp_bool = Format.pp_print_bool

type attribute =
  | A : (string * 'a * (Format.formatter -> 'a -> unit)) -> attribute
  | AOpt :
      (string * 'a option * (Format.formatter -> 'a -> unit))
      -> attribute

type body = B : ('a * (Format.formatter -> 'a -> unit)) -> body

let unpack_attribute s = function
  | A (key, x, f) -> Format.asprintf {|%s %s="%a"|} s key f x
  | AOpt (key, Some x, f) -> Format.asprintf {|%s %s="%a"|} s key f x
  | AOpt (_, None, _) -> ""
;;

let unpack_body s = function
  | B (x, f) -> Format.asprintf "%s%a" s f x
;;

let attr k v p = A (k, v, p)
let attr_opt k v p = AOpt (k, v, p)
let body v p = B (v, p)

let pp_attr ppf attr =
  let s = List.fold_left unpack_attribute "" attr in
  Format.fprintf ppf "%s" s
;;

let pp_body ppf body =
  let s = List.fold_left unpack_body "" body in
  Format.fprintf ppf "%s" s
;;

let xml_node name ?(a = []) ppf content =
  match content with
  | [] -> Format.fprintf ppf "<%s%a />" name pp_attr a
  | content ->
    Format.fprintf ppf "<%s%a>%a</%s>" name pp_attr a pp_body content name
;;

let pp_title ppf x = xml_node "title" ppf [ body x pp_string ]
let pp_link ppf x = xml_node "link" ppf [ body x pp_string ]
let pp_description ppf x = xml_node "description" ppf [ body x pp_string ]
let pp_url ppf x = xml_node "url" ppf [ body x pp_string ]
let pp_width ppf x = xml_node "width" ppf [ body x pp_int ]
let pp_height ppf x = xml_node "height" ppf [ body x pp_int ]

let pp_pub_date ?(default_time = 10, 0, 0) ppf x =
  xml_node "pubDate" ppf [ body x $ Date.pp_rfc822 ~default_time ]
;;

let pp_author ppf x = xml_node "author" ppf [ body x pp_string ]
let pp_comments ppf x = xml_node "comments" ppf [ body x pp_string ]
let pp_copyright ppf x = xml_node "copyright" ppf [ body x pp_string ]
let pp_docs ppf x = xml_node "docs" ppf [ body x pp_string ]
let pp_generator ppf x = xml_node "generator" ppf [ body x pp_string ]
let pp_ttl ppf x = xml_node "ttl" ppf [ body x pp_int ]
let pp_webmaster ppf x = xml_node "webMaster" ppf [ body x pp_string ]

let pp_feed_link ppf x =
  xml_node
    "atom:link"
    ppf
    ~a:
      [ attr "href" x pp_string
      ; attr "rel" "self" pp_string
      ; attr "type" "application/rss+xml" pp_string
      ]
    []
;;

let pp_last_build_date ?(default_time = 10, 0, 0) ppf x =
  xml_node "pubDate" ppf [ body x $ Date.pp_rfc822 ~default_time ]
;;

let pp_managing_editor ppf x =
  xml_node "managingEditor" ppf [ body x pp_string ]
;;

module Image = struct
  type t =
    { title : string
    ; link : string
    ; url : string
    ; height : int option
    ; width : int option
    ; description : string option
    }

  let make ?description ?width ?height ~title ~link ~url () =
    { title; link; url; height; width; description }
  ;;

  let pp ppf img =
    xml_node
      "image"
      ppf
      [ body img.title pp_title
      ; body img.link pp_link
      ; body img.url pp_url
      ; body img.description $ pp_opt pp_description
      ; body img.width $ pp_opt pp_width
      ; body img.height $ pp_opt pp_height
      ]
  ;;

  let equal a b =
    String.equal a.title b.title
    && String.equal a.link b.link
    && String.equal a.url b.url
    && Option.equal Int.equal a.width b.width
    && Option.equal Int.equal a.height b.height
    && Option.equal String.equal a.description b.description
  ;;
end

module Category = struct
  type t =
    { category : string
    ; domain : string option
    }

  let make ?domain ~category () = { category; domain }

  let pp ppf category =
    xml_node
      "category"
      ppf
      ~a:[ attr_opt "domain" category.domain pp_string ]
      [ body category.category pp_string ]
  ;;

  let expand = List.map (fun c -> body c pp)

  let equal a b =
    String.equal a.category b.category
    && Option.equal String.equal a.domain b.domain
  ;;
end

module Enclosure = struct
  type t =
    { length : int
    ; media_type : Mime.t
    ; url : string
    }

  let make ~url ~media_type ~length () = { length; media_type; url }

  let pp ppf enclosure =
    xml_node
      "enclosure"
      ppf
      ~a:
        [ attr "url" enclosure.url pp_string
        ; attr "length" enclosure.url pp_string
        ; attr "type" enclosure.media_type Mime.pp
        ]
      []
  ;;

  let equal a b =
    Int.equal a.length b.length
    && Mime.equal a.media_type b.media_type
    && String.equal a.url b.url
  ;;
end

module Guid = struct
  type t =
    { url : string
    ; is_permalink : bool
    }

  let make ?(is_permalink = false) ~url () = { is_permalink; url }
  let permalink url = make ~is_permalink:true ~url ()
  let link url = make ~is_permalink:false ~url ()

  let pp ppf guid =
    xml_node
      "guid"
      ppf
      ~a:[ attr "isPermaLink" guid.is_permalink pp_bool ]
      [ body guid.url pp_string ]
  ;;

  let equal a b =
    String.equal a.url b.url && Bool.equal a.is_permalink b.is_permalink
  ;;
end

module Source = struct
  type t =
    { url : string
    ; title : string
    }

  let make ~url ~title () = { url; title }

  let pp ppf source =
    xml_node
      "source"
      ppf
      ~a:[ attr "url" source.url pp_string ]
      [ body source.title pp_string ]
  ;;

  let equal a b = String.equal a.title b.title && String.equal a.url b.url
end

module Item = struct
  type t =
    { title : string
    ; link : string
    ; pub_date : Date.t
    ; description : string
    ; guid : Guid.t
    ; author : string option
    ; categories : Category.t list
    ; comments : string option
    ; enclosure : Enclosure.t option
    ; source : Source.t option
    }

  let make
    ?author
    ?(categories = [])
    ?comments
    ?enclosure
    ?source
    ~title
    ~link
    ~pub_date
    ~description
    ~guid
    ()
    =
    { title
    ; link
    ; pub_date
    ; description
    ; guid
    ; author
    ; categories
    ; comments
    ; enclosure
    ; source
    }
  ;;

  let pp ?(default_time = 10, 0, 0) ppf entry =
    xml_node
      "item"
      ppf
      ([ body entry.title pp_title
       ; body entry.link pp_link
       ; body entry.pub_date $ pp_pub_date ~default_time
       ; body entry.description pp_description
       ; body entry.guid Guid.pp
       ; body entry.author $ pp_opt pp_author
       ; body entry.comments $ pp_opt pp_comments
       ; body entry.enclosure $ pp_opt Enclosure.pp
       ; body entry.source $ pp_opt Source.pp
       ]
      @ Category.expand entry.categories)
  ;;

  let equal a b =
    String.equal a.title b.title
    && String.equal a.link b.link
    && Date.equal a.pub_date b.pub_date
    && String.equal a.description b.description
    && Guid.equal a.guid b.guid
    && Option.equal String.equal a.author b.author
    && Preface.List.equal Category.equal a.categories b.categories
    && Option.equal String.equal a.comments b.comments
    && Option.equal Enclosure.equal a.enclosure b.enclosure
    && Option.equal Source.equal a.source b.source
  ;;

  let expand = List.map (fun c -> body c pp)
end

module Cloud = struct
  type protocol =
    | Xml_rpc
    | Soap
    | Http_post

  type t =
    { domain : string
    ; port : int
    ; path : string
    ; register_procedure : string
    ; protocol : protocol
    }

  let make ~domain ~port ~path ~register_procedure ~protocol () =
    { domain; port; path; register_procedure; protocol }
  ;;

  let equal_protocol a b =
    match a, b with
    | Xml_rpc, Xml_rpc -> true
    | Soap, Soap -> true
    | Http_post, Http_post -> true
    | _ -> false
  ;;

  let pp_protocol ppf x =
    Format.fprintf
      ppf
      "%s"
      (match x with
       | Xml_rpc -> "xml-rpc"
       | Soap -> "soap"
       | Http_post -> "http-post")
  ;;

  let pp ppf cloud =
    xml_node
      "cloud"
      ppf
      ~a:
        [ attr "domain" cloud.domain pp_string
        ; attr "port" cloud.port pp_int
        ; attr "path" cloud.path pp_string
        ; attr "registerProcedure" cloud.register_procedure pp_string
        ; attr "protocol" cloud.protocol pp_protocol
        ]
      []
  ;;

  let equal a b =
    String.equal a.domain b.domain
    && Int.equal a.port b.port
    && String.equal a.path b.path
    && String.equal a.register_procedure b.register_procedure
    && equal_protocol a.protocol b.protocol
  ;;
end

module Channel = struct
  type t =
    { title : string
    ; description : string
    ; link : string
    ; feed_link : string
    ; pub_date : Date.t option
    ; last_build_date : Date.t option
    ; category : Category.t option
    ; image : Image.t option
    ; cloud : Cloud.t option
    ; copyright : string option
    ; docs : string option
    ; generator : string option
    ; managing_editor : string option
    ; ttl : int option
    ; webmaster : string option
    ; items : Item.t list
    }

  let make
    ?pub_date
    ?last_build_date
    ?category
    ?image
    ?cloud
    ?copyright
    ?docs
    ?generator
    ?managing_editor
    ?ttl
    ?webmaster
    ~title
    ~link
    ~feed_link
    ~description
    items
    =
    { pub_date
    ; last_build_date
    ; category
    ; image
    ; cloud
    ; copyright
    ; docs
    ; generator
    ; managing_editor
    ; ttl
    ; webmaster
    ; title
    ; link
    ; feed_link
    ; description
    ; items
    }
  ;;

  let pp ?(default_time = 10, 0, 0) ppf channel =
    xml_node
      "channel"
      ppf
      ([ body channel.title pp_title
       ; body channel.link pp_link
       ; body channel.feed_link pp_feed_link
       ; body channel.description pp_description
       ; body channel.pub_date $ pp_opt (pp_pub_date ~default_time)
       ; body channel.last_build_date
         $ pp_opt (pp_last_build_date ~default_time)
       ; body channel.category $ pp_opt Category.pp
       ; body channel.image $ pp_opt Image.pp
       ; body channel.cloud $ pp_opt Cloud.pp
       ; body channel.copyright $ pp_opt pp_copyright
       ; body channel.docs $ pp_opt pp_docs
       ; body channel.generator $ pp_opt pp_generator
       ; body channel.managing_editor $ pp_opt pp_managing_editor
       ; body channel.ttl $ pp_opt pp_ttl
       ; body channel.webmaster $ pp_opt pp_webmaster
       ]
      @ Item.expand
          (List.sort
             (fun x y -> Date.compare y.Item.pub_date x.Item.pub_date)
             channel.items))
  ;;

  let equal a b =
    Option.equal Date.equal a.pub_date b.pub_date
    && Option.equal Date.equal a.last_build_date b.last_build_date
    && Option.equal Category.equal a.category b.category
    && Option.equal Image.equal a.image b.image
    && Option.equal Cloud.equal a.cloud b.cloud
    && Option.equal String.equal a.copyright b.copyright
    && Option.equal String.equal a.docs b.docs
    && Option.equal String.equal a.generator b.generator
    && Option.equal String.equal a.managing_editor b.managing_editor
    && Option.equal Int.equal a.ttl b.ttl
    && Option.equal String.equal a.webmaster b.webmaster
    && String.equal a.title b.title
    && String.equal a.link b.link
    && String.equal a.feed_link b.feed_link
    && String.equal a.description b.description
    && Preface.List.equal Item.equal a.items b.items
  ;;

  let pp_rss
    ?(xml_version = "1.0")
    ?(encoding = "UTF-8")
    ?(default_time = 10, 0, 0)
    ppf
    =
    Format.fprintf
      ppf
      "<?xml version=%S encoding=%S ?><rss version=\"2.0\" \
       xmlns:atom=\"http://www.w3.org/2005/Atom\">%a</rss>"
      xml_version
      encoding
      (pp ~default_time)
  ;;

  let to_rss ?xml_version ?encoding ?(default_time = 10, 0, 0) =
    Format.asprintf "%a" $ pp_rss ?xml_version ?encoding ~default_time
  ;;
end
