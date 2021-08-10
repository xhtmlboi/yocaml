open Util

module Validable_option =
  Preface.Option.Applicative.Traversable (Validate.Applicative)

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

type year = int
type day = int
type hour = int
type min = int
type sec = int

type t =
  { year : year
  ; month : month
  ; day : day
  ; time : (hour * min * sec) option
  }

let is_leap year =
  if year mod 100 = 0 then year mod 400 = 0 else year mod 4 = 0
;;

let days_in_month year month =
  match month with
  | Jan | Mar | May | Jul | Aug | Oct | Dec -> 31
  | Feb -> if is_leap year then 29 else 28
  | _ -> 30
;;

let try_day year month day =
  let days = days_in_month year month in
  if day < 1 || day > days
  then Try.error $ Error.Invalid_day day
  else Try.ok day
;;

let try_year year =
  if year < 0 then Try.error $ Error.Invalid_year year else Try.ok year
;;

let in_range min_bound_incl max_bound_excl x =
  if x < min_bound_incl || x >= max_bound_excl
  then Validate.error $ Error.Invalid_range (x, min_bound_incl, max_bound_excl)
  else Validate.valid x
;;

let make_date year month day =
  let open Try.Monad in
  let aux =
    let* y = try_year year in
    let* d = try_day year month day in
    return (y, month, d)
  in
  Validate.from_try aux
;;

let make_time (h, m, s) =
  let open Validate.Applicative in
  (fun h m s -> h, m, s)
  <$> in_range 0 24 h
  <*> in_range 0 60 m
  <*> in_range 0 60 s
;;

let make ?time year month day =
  let open Validate.Applicative in
  (fun time (year, month, day) -> { year; month; day; time })
  <$> (Validable_option.sequence $ Option.map make_time time)
  <*> make_date year month day
;;

let month_equal x y =
  match x, y with
  | Jan, Jan
  | Feb, Feb
  | Mar, Mar
  | Apr, Apr
  | May, May
  | Jun, Jun
  | Jul, Jul
  | Aug, Aug
  | Sep, Sep
  | Oct, Oct
  | Nov, Nov
  | Dec, Dec -> true
  | _ -> false
;;

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
;;

let month_to_string = function
  | Jan -> "Jan"
  | Feb -> "Feb"
  | Mar -> "Mar"
  | Apr -> "Apr"
  | May -> "May"
  | Jun -> "Jun"
  | Jul -> "Jul"
  | Aug -> "Aug"
  | Sep -> "Sep"
  | Oct -> "Oct"
  | Nov -> "Nov"
  | Dec -> "Dec"
;;

let month_from_int x =
  if x > 0 && x <= 12
  then
    Validate.valid
      [| Jan; Feb; Mar; Apr; May; Jun; Jul; Aug; Sep; Oct; Nov; Dec |].(x - 1)
  else Validate.error $ Error.Invalid_month x
;;

let equal a b =
  Int.equal a.year b.year
  && month_equal a.month b.month
  && Int.equal a.day b.day
  && Option.equal
       (fun (a, b, c) (x, y, z) ->
         Int.equal a x && Int.equal b y && Int.equal c z)
       a.time
       b.time
;;

let compare a b =
  let f (x, y, z) = (x * 10000) + (y * 100) + z in
  let g x =
    let a = f (x.year, month_to_int x.month, x.day)
    and b = f $ Option.value ~default:(0, 0, 0) x.time in
    (a * 1000000) + b
  in
  Int.compare (g a) (g b)
;;

let pp ppf t =
  Format.fprintf
    ppf
    "%04d-%02d-%02d%s"
    t.year
    (month_to_int t.month)
    t.day
    (Option.fold
       ~none:""
       ~some:(fun (h, m, s) -> Format.asprintf " %02d:%02d:%02d" h m s)
       t.time)
;;

let to_string = Format.asprintf "%a" pp

let from_string s =
  try
    Scanf.sscanf
      (String.trim s)
      "%04d-%02d-%02d %02d:%02d:%02d"
      (fun y m d hour min sec ->
        let open Validate.Monad in
        month_from_int m
        >>= fun month -> make ~time:(hour, min, sec) y month d)
  with
  | _ ->
    (try
       Scanf.sscanf (String.trim s) "%04d-%02d-%02d" (fun y m d ->
           let open Validate.Monad in
           month_from_int m >>= fun month -> make y month d)
     with
    | _ -> Validate.error $ Error.Invalid_date s)
;;

let to_pair date = (date.year, date.month, date.day), date.time
