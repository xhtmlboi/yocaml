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

let alt_opt a b = match a with Some a -> Some a | None -> b
let is_empty_list = function [] -> true | _ -> false

module Datetime = struct
  type month =
    | Jan
    | Feb
    | Mar
    | Apr
    | May
    | Jun
    | Jul
    | Aug
    | Sep
    | Oct
    | Nov
    | Dec

  type day_of_week = Mon | Tue | Wed | Thu | Fri | Sat | Sun
  type year = int
  type day = int
  type hour = int
  type min = int
  type sec = int

  type t = {
      year : year
    ; month : month
    ; day : day
    ; hour : hour
    ; min : min
    ; sec : sec
  }

  let invalid_int x message =
    Data.Validation.fail_with ~given:(string_of_int x) message

  let month_from_int x =
    if x > 0 && x <= 12 then
      Result.ok
        [| Jan; Feb; Mar; Apr; May; Jun; Jul; Aug; Sep; Oct; Nov; Dec |].(x - 1)
    else invalid_int x "Invalid month value"

  let year_from_int x =
    if x >= 0 then Result.ok x else invalid_int x "Invalid year value"

  let is_leap year =
    if year mod 100 = 0 then year mod 400 = 0 else year mod 4 = 0

  let days_in_month year month =
    match month with
    | Jan | Mar | May | Jul | Aug | Oct | Dec -> 31
    | Feb -> if is_leap year then 29 else 28
    | _ -> 30

  let day_from_int year month x =
    let dim = days_in_month year month in
    if x >= 1 && x <= dim then Result.ok x
    else invalid_int x "Invalid day value"

  let hour_from_int x =
    if x >= 0 && x < 24 then Result.ok x else invalid_int x "Invalid hour value"

  let min_from_int x =
    if x >= 0 && x < 60 then Result.ok x else invalid_int x "Invalid min value"

  let sec_from_int x =
    if x >= 0 && x < 60 then Result.ok x else invalid_int x "Invalid sec value"

  let make_raw ?(time = (0, 0, 0)) ~year ~month ~day () =
    let hour, min, sec = time in
    { year; month; day; hour; min; sec }

  let dummy_date = make_raw ~time:(0, 0, 0) ~year:1977 ~month:Jan ~day:1 ()
  let ( let* ) = Result.bind

  let make ?(time = (0, 0, 0)) ~year ~month ~day () =
    let hour, min, sec = time in
    let* year = year_from_int year in
    let* month = month_from_int month in
    let* day = day_from_int year month day in
    let* hour = hour_from_int hour in
    let* min = min_from_int min in
    let* sec = sec_from_int sec in
    Result.ok { year; month; day; hour; min; sec }

  let validate_from_datetime_str str =
    let str = String.trim str in
    match
      Scanf.sscanf_opt str "%04d%c%02d%c%02d%c%02d%c%02d%c%02d"
        (fun year _ month _ day _ hour _ min _ sec ->
          ((hour, min, sec), year, month, day))
    with
    | None -> Data.Validation.fail_with ~given:str "Invalid date format"
    | Some (time, year, month, day) -> make ~time ~year ~month ~day ()

  let validate_from_date_str str =
    let str = String.trim str in
    match
      Scanf.sscanf_opt str "%04d%c%02d%c%02d" (fun year _ month _ day ->
          (year, month, day))
    with
    | None -> Data.Validation.fail_with ~given:str "Invalid date format"
    | Some (year, month, day) -> make ~year ~month ~day ()

  let validate =
    let open Data.Validation in
    string & (validate_from_datetime_str / validate_from_date_str)

  let month_to_int = function
    | Jan -> 1
    | Feb -> 2
    | Mar -> 3
    | Apr -> 4
    | May -> 5
    | Jun -> 6
    | Jul -> 7
    | Aug -> 8
    | Sep -> 9
    | Oct -> 10
    | Nov -> 11
    | Dec -> 12

  let month_to_string = function
    | Jan -> "jan"
    | Feb -> "feb"
    | Mar -> "mar"
    | Apr -> "apr"
    | May -> "may"
    | Jun -> "jun"
    | Jul -> "jul"
    | Aug -> "aug"
    | Sep -> "sep"
    | Oct -> "oct"
    | Nov -> "nov"
    | Dec -> "dec"

  let dow_to_int = function
    | Mon -> 0
    | Tue -> 1
    | Wed -> 2
    | Thu -> 3
    | Fri -> 4
    | Sat -> 5
    | Sun -> 6

  let dow_to_string = function
    | Mon -> "mon"
    | Tue -> "tue"
    | Wed -> "wed"
    | Thu -> "thu"
    | Fri -> "fri"
    | Sat -> "sat"
    | Sun -> "sun"

  let compare_date a b =
    let cmp = Int.compare a.year b.year in
    if Int.equal cmp 0 then
      let cmp = Int.compare (month_to_int a.month) (month_to_int b.month) in
      if Int.equal cmp 0 then Int.compare a.day b.day else cmp
    else cmp

  let compare_time a b =
    let cmp = Int.compare a.hour b.hour in
    if Int.equal cmp 0 then
      let cmp = Int.compare a.min b.min in
      if Int.equal cmp 0 then Int.compare a.sec b.sec else cmp
    else cmp

  let compare a b =
    let cmp = compare_date a b in
    if Int.equal cmp 0 then compare_time a b else cmp

  let equal a b = Int.equal 0 (compare a b)

  let pp_date ppf { year; month; day; _ } =
    Format.fprintf ppf "%04d-%02d-%02d" year (month_to_int month) day

  let pp_time ppf { hour; min; sec; _ } =
    Format.fprintf ppf "%02d:%02d:%02d" hour min sec

  let pp ppf dt = Format.fprintf ppf "%a %a" pp_date dt pp_time dt

  let month_value = function
    | Jan -> 0
    | Feb -> 3
    | Mar -> 3
    | Apr -> 6
    | May -> 1
    | Jun -> 4
    | Jul -> 6
    | Aug -> 2
    | Sep -> 5
    | Oct -> 0
    | Nov -> 3
    | Dec -> 5

  let day_of_week { year; month; day; _ } =
    let yy = year mod 100 in
    let cc = (year - yy) / 100 in
    let c_code = [| 6; 4; 2; 0 |].(cc mod 4) in
    let y_code = (yy + (yy / 4)) mod 7 in
    let m_code =
      let v = month_value month in
      if is_leap year && (month = Jan || month = Feb) then v - 1 else v
    in
    let index = (c_code + y_code + m_code + day) mod 7 in
    [| Sun; Mon; Tue; Wed; Thu; Fri; Sat |].(index)

  let normalize ({ year; month; day; hour; min; sec } as dt) =
    let has_time = not (Int.equal (compare_time dt dummy_date) 0) in
    let datetime_repr = Format.asprintf "%a" pp dt in
    let date_repr = Format.asprintf "%a" pp_date dt in
    let time_repr = Format.asprintf "%a" pp_time dt in
    let day_of_week = day_of_week dt in
    let open Data in
    record
      [
        ("year", int year)
      ; ("month", int (month_to_int month))
      ; ("day", int day)
      ; ("hour", int hour)
      ; ("min", int min)
      ; ("sec", int sec)
      ; ("has_time", bool has_time)
      ; ("day_of_week", int (dow_to_int day_of_week))
      ; ( "repr"
        , record
            [
              ("month", string (month_to_string month))
            ; ("datetime", string datetime_repr)
            ; ("date", string date_repr)
            ; ("time", string time_repr)
            ; ("day_of_week", string (dow_to_string day_of_week))
            ] )
      ]

  module Infix = struct
    let ( = ) = equal
    let ( <> ) x y = not (equal x y)
    let ( > ) x y = compare x y > 0
    let ( >= ) x y = compare x y >= 0
    let ( < ) x y = compare x y < 0
    let ( <= ) x y = compare x y <= 0
  end

  let min a b = if Infix.(b > a) then a else b
  let max a b = if Infix.(a < b) then a else b

  include Infix
end

module Page = struct
  let entity_name = "Page"

  class type t = object
    method page_title : string option
    method page_charset : string option
    method description : string option
    method tags : string list
  end

  class page ?title ?description ?charset ?(tags = []) () =
    object (_ : #t)
      method page_title = title
      method page_charset = charset
      method description = description
      method tags = tags
    end

  let title p = p#page_title
  let charset p = p#page_charset
  let description p = p#description
  let tags p = p#tags
  let neutral = Result.ok @@ new page ()

  let validate_page fields =
    let open Data.Validation in
    let+ title = optional fields "page_title" string
    and+ description = optional fields "description" string
    and+ charset = optional fields "page_charset" string
    and+ tags = optional_or fields ~default:[] "tags" (list_of string) in
    new page ?title ?description ?charset ~tags ()

  let validate =
    let open Data.Validation in
    record validate_page

  let to_meta name = function
    | None -> []
    | Some x ->
        [ Data.(record [ ("name", string name); ("content", string x) ]) ]

  let to_meta_kwd = function
    | [] -> []
    | tags ->
        [
          Data.(
            record
              [
                ("name", string "keywords")
              ; ("content", string @@ String.concat ", " tags)
              ])
        ]

  let meta_list p =
    to_meta "charset" p#page_charset
    @ to_meta "description" p#description
    @ to_meta_kwd p#tags

  let normalize_parameters obj =
    Data.
      [
        ("page_title", option string obj#page_title)
      ; ("description", option string obj#description)
      ; ("page_charset", option string obj#page_charset)
      ; ("tags", list_of string obj#tags)
      ; ("has_tags", bool (not (is_empty_list obj#tags)))
      ; ("has_page_title", bool @@ Option.is_some obj#page_title)
      ; ("has_description", bool @@ Option.is_some obj#description)
      ; ("has_page_charset", bool @@ Option.is_some obj#page_charset)
      ]

  let normalize_meta obj = Data.[ ("meta", list @@ meta_list obj) ]
  let normalize obj = normalize_parameters obj @ normalize_meta obj
end

module Article = struct
  let entity_name = "Article"

  class type t = object
    inherit Page.t
    method title : string
    method synopsis : string option
    method date : Datetime.t
  end

  class article page ?synopsis ~title ~date () =
    let page_title = alt_opt page#page_title (Some title) in
    let description = alt_opt page#description synopsis in
    object (_ : #t)
      inherit
        Page.page
          ?title:page_title ?description ?charset:page#page_charset
            ~tags:page#tags ()

      method title = title
      method synopsis = synopsis
      method date = date
    end

  let page a = (a :> Page.t)
  let title a = a#title
  let synopsis a = a#synopsis
  let date a = a#date

  let neutral =
    Data.Validation.fail_with ~given:"null" "Cannot be null"
    |> Result.map_error (fun error ->
           Required.Validation_error { entity = entity_name; error })

  let validate =
    let open Data.Validation in
    record (fun fields ->
        let+ page = Page.validate_page fields
        and+ title = required fields "title" string
        and+ synopsis = optional fields "synopsis" string
        and+ date = required fields "date" Datetime.validate in
        new article page ?synopsis ~title ~date ())

  let normalize obj =
    Page.normalize obj
    @ Data.
        [
          ("title", string obj#title)
        ; ("synopsis", option string obj#synopsis)
        ; ("date", Datetime.normalize obj#date)
        ; ("has_synopsis", bool @@ Option.is_some obj#synopsis)
        ]
end

module Articles = struct
  class type t = object
    inherit Page.t
    method articles : (Path.t * Article.t) list
  end

  class articles page articles =
    object (_ : #t)
      inherit
        Page.page
          ?title:page#page_title ?description:page#description
            ?charset:page#page_charset ~tags:page#tags ()

      method articles = articles
    end

  let from_page articles page = new articles page articles

  let sort_by_date ?(increasing = false) articles =
    List.sort
      (fun (_, articleA) (_, articleB) ->
        let r = Datetime.compare articleA#date articleB#date in
        if increasing then r else ~-r)
      articles

  let fetch (module P : Required.DATA_PROVIDER) ?increasing
      ?(filter = fun x -> x) ?(on = `Source) ~where ~compute_link path =
    Task.from_effect (fun () ->
        let open Eff in
        let* files = read_directory ~on ~only:`Files ~where path in
        let+ articles =
          List.traverse
            (fun file ->
              let url = compute_link file in
              let+ metadata, _content =
                Eff.read_file_with_metadata (module P) (module Article) ~on file
              in
              (url, metadata))
            files
        in
        articles |> sort_by_date ?increasing |> filter)

  let compute_index (module P : Required.DATA_PROVIDER) ?increasing
      ?(filter = fun x -> x) ?(on = `Source) ~where ~compute_link path =
    let open Task in
    (fun x -> (x, ()))
    |>> second
          (fetch (module P) ?increasing ~filter ~on ~where ~compute_link path)
    >>| fun (page, articles) -> from_page articles page

  let normalize_article (ident, article) =
    let open Data in
    record (("url", string @@ Path.to_string ident) :: Article.normalize article)

  let normalize obj =
    let open Data in
    ("articles", list_of normalize_article obj#articles)
    :: ("has_articles", bool @@ is_empty_list obj#articles)
    :: Page.normalize obj
end
