(** Describes date (supposing naively that everything is in UTC). *)

(** {1 Types} *)

(** Describes a complete date. *)
type t

(** Months. *)
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

(** {2 Aliases}

    Useful aliases for making the doc readable. *)

type year = int
type day = int
type hour = int
type min = int
type sec = int

(** {1 API} *)

(** [Date.make ~time:(hour, min, sec) year month day] tries to create a
    [Date.t]. *)
val make : ?time:hour * min * sec -> year -> month -> day -> t Validate.t

val from_string : string -> t Validate.t

(** {2 Comparison and equality} *)

val equal : t -> t -> bool
val compare : t -> t -> int

(** {2 Pretty Printing} *)

val pp : Format.formatter -> t -> unit
val to_string : t -> string

(** {2 Retreive information} *)

val to_pair : t -> (year * month * day) * (hour * min * sec) option

(** Starts at [1].*)
val month_to_int : month -> int

(** [Date.month_to_string Dec] is equal to ["Dec"]. *)
val month_to_string : month -> string
