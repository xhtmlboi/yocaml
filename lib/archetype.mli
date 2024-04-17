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

(** Archetypes are pre-designed, validatable and injectable models for rapid
    blog bootstrapping. However, as Yocaml is very generic... it's worth using
    it as an example rather than a concrete model. *)

module Datetime : sig
  (** Describes a date associated with a time. The "default" date format is
      [yyyy-mm-dd HH:mm-ss]. In addition to describing data as injectable or
      readable, the module provides a naive date processing API that seems to be
      useful for describing a blog. *)

  (** {1 Types}

      Types used to describe a date. *)

  (** Type describing a month *)
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

  type year = private int
  (** Type describing a year (positive int, Because let's face it, we're not
      going to publish blogs during antiquity, are we?). *)

  type day = private int
  (** Type describing a day. A number from 1 to 31 (depending on the month). *)

  type hour = private int
  (** Type describing an hour. A number from 0 to 23. *)

  type min = private int
  (** Type describing a minut. A number from 0 to 59. *)

  type sec = private int
  (** Type describing a second. A number from 0 to 59. *)

  type t = {
      year : year
    ; month : month
    ; day : day
    ; hour : hour
    ; min : min
    ; sec : sec
  }
  (** Describes a complete date. As all potentially different values are
      private, the type must not be abstract (or private), as it must go through
      validation phases. *)

  (** {1 Building date} *)

  val make :
       ?time:int * int * int
    -> year:int
    -> month:int
    -> day:int
    -> unit
    -> t Data.Validation.validated_value
  (** [make ?time ~year ~month ~day ()] Builds a date when all data and
      validates all data.*)

  val validate : Data.t -> t Data.Validation.validated_value
  (** [validate data] try to read a date from a generic representation.*)

  (** {1 Dealing with date as metadata} *)

  val normalize : t -> (string * Data.t) list
  (** [normalize datetime] render data generically (with additional fields).
      Here is the list of fields:
      - [year: int] the year value
      - [month: int] the month value
      - [day: int] the day value
      - [hour: int] the hour value
      - [min: int] the min value
      - [sec: int] the sec value
      - [has_time: bool] true if time is different than [0,0,0], false otherwise
      - [day_of_week: int] a number that represent the day of week (0: Monday,
        6: Sunday)
      - [repr: record] some representation of the date

      Representation of a date (field [repr]) :
      - [repr.month: string] a three-letters ident for the month
      - [repr.day_of_week: string] a three-letters ident for the day of the week
      - [repr.datetime: string] a string representation of the date
        [YYYY-mm-dd HH:mm:ss]
      - [repr.date: string] a string representation of the date [YYYY-mm-dd]
      - [repr.time: string] a string representation of the date [HH:mm:ss]

      Generating so much data may seem strange, but it allows the user to decide
      precisely, in his template, how to use/represent a date, which, in my
      opinion, is a good thing. No ? *)

  (** {1 Infix operators} *)

  module Infix : sig
    (** A collection of infix operators for comparing dates. *)

    val ( = ) : t -> t -> bool
    (** [a = b] returns [true] if [a] equal [b], [false] otherwise. *)

    val ( <> ) : t -> t -> bool
    (** [a <> b] returns [true] if [a] is not equal to [b], [false] otherwise. *)

    val ( > ) : t -> t -> bool
    (** [a > b] returns [true] if [a] is greater than [b], [false] otherwise. *)

    val ( >= ) : t -> t -> bool
    (** [a > b] returns [true] if [a] is greater or equal to [b], [false]
        otherwise. *)

    val ( < ) : t -> t -> bool
    (** [a > b] returns [true] if [a] is smaller than [b], [false] otherwise. *)

    val ( <= ) : t -> t -> bool
    (** [a > b] returns [true] if [a] is smaller or equal to [b], [false]
        otherwise. *)
  end

  include module type of Infix
  (** @inline*)

  (** {1 Util} *)

  val compare : t -> t -> int
  (** Comparison between datetimes. *)

  val equal : t -> t -> bool
  (** Equality between datetime. *)

  val min : t -> t -> t
  (** [min a b] returns the smallest [a] or [b]. *)

  val max : t -> t -> t
  (** [max a b] returns the greatest [a] or [b]. *)

  val pp : Format.formatter -> t -> unit
  (** Pretty printer for date. *)
end
