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

(** A [Nel], for [Non Empty List], is a list that ensures it has at least one
    element, which is very useful for describing, for example, error lists,
    where if there is an error, we ensure that there is at least one error. *)

(** {1 Types} *)

(** A non-empty list is nothing more than a pair of a value and a list.*)
type 'a t = ( :: ) of 'a * 'a list

(** {1 Creating lists} *)

val singleton : 'a -> 'a t
(** [singleton x] constructs a list with one element.*)

val cons : 'a -> 'a t -> 'a t
(** [cons x xs] constructs a non-empty list whose head is [x] and whose tail is
    [xs]. *)

val init : int -> (int -> 'a) -> 'a t
(** [init len f] is [f 0; f 1; ...; f (len-1)], evaluated left to right.
    @raise Invalid_argument if [len < 1]. *)

val from_list : 'a list -> 'a t option
(** [from_list l] convert a regular list to a non-empty one, if the given list
    is empty the function returns [None]. *)

val from_seq : 'a Seq.t -> 'a t option
(** [from_seq l] convert a regular seq to a non-empty one, if the given seq is
    empty the function returns [None]. *)

(** {1 Conversion} *)

val to_list : 'a t -> 'a list
(** [to_list nel] Converts a non-empty list into a regular list. *)

val to_seq : 'a t -> 'a Seq.t
(** [to_seq nel] Converts a non-empty list into a sequence. *)

(** {1 Fact about size} *)

val length : 'a t -> int
(** [length nel] returns the list of the non-empty list. *)

val is_singleton : 'a t -> bool
(** [is_singleton x] returns [true] if the non-empty list has just one element,
    [false] otherwise. *)

(** {1 Misc functions} *)

val hd : 'a t -> 'a
(** [hd nel] returns the head of the non-empty list. Since the list can't be
    empty, the function never fail. *)

val tl : 'a t -> 'a list
(** [tl nel] returns the tail of the non-empty list. Since the list can't be
    empty, the function never fail. *)

val rev : 'a t -> 'a t
(** [rev nel] reverse the non-empty-list. *)

val rev_append : 'a t -> 'a t -> 'a t
(** [rev_append nel1 nelt2] reverses [nel1] and concatenates it with [nel2].
    This is equivalent to [(Nel.rev nel1) @ nel2].*)

val append : 'a t -> 'a t -> 'a t
(** [append nel1 nel2] is the concatenation of [nel1] and [nel2]. *)

val concat : 'a t t -> 'a t
(** [concat nel] Concatenate a non-empty list of non-empty lists. The elements
    of the argument are all concatenated together (in the same order) to give
    the result.*)

(** {1 Iterators} *)

val iter : ('a -> unit) -> 'a t -> unit
(** [iter f nel] applies [f] on each element of [nel]. *)

val iteri : (int -> 'a -> unit) -> 'a t -> unit
(** [iteri f nel] same as {!val:iter} but the function is applied to the index
    of the element as first argument (counting from 0), and the element itself
    as second argument. *)

val map : ('a -> 'b) -> 'a t -> 'b t
(** [map f nel] build a new non-empty list applying [f] on each element of the
    non-empty list. *)

val mapi : (int -> 'a -> 'b) -> 'a t -> 'b t
(** [mapi f nel] same as {!val:map} but the function is applied to the index of
    the element as first argument (counting from 0), and the element itself as
    second argument. *)

val rev_map : ('a -> 'b) -> 'a t -> 'b t
(** [rev_map f nel] is a more efficient way of making [Nel.(rev (map f nel))].
*)

val rev_mapi : (int -> 'a -> 'b) -> 'a t -> 'b t
(** [rev_mapi f nel] same as {!val:rev_map} but the function is applied to the
    index of the element as first argument (counting from 0), and the element
    itself as second argument. *)

val concat_map : ('a -> 'b t) -> 'a t -> 'b t
(** [concat_map f nel] is [Nel.concat (Nel.map f nel)]. *)

val flat_map : ('a -> 'b t) -> 'a t -> 'b t
(** [flat_map f nel] same as {!val:concat_map} (present for convention reason).
*)

val concat_mapi : (int -> 'a -> 'b t) -> 'a t -> 'b t
(** [concat_mapi f nel] same as {!val:concat_map} but the function is applied to
    the index of the element as first argument (counting from 0), and the
    element itself as second argument. *)

val fold_left : ('acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** [fold_left reducer default nel] is
    [fold_left f init [b1; ...; bn] is f (... (f (f init b1) b2) ...) bn]. *)

val fold_lefti : (int -> 'acc -> 'a -> 'acc) -> 'acc -> 'a t -> 'acc
(** [fold_lefti f default nel] same as {!val:fold_left} but the function is
    applied to the index of the element as first argument (counting from 0), and
    the element itself as second argument. *)

val fold_right : ('a -> 'acc -> 'acc) -> 'a t -> 'acc -> 'acc
(** [fold_right f nel default] is
    [fold_right f [a1; ...; an] init is f a1 (f a2 (... (f an init) ...))]. *)

val fold_righti : (int -> 'a -> 'acc -> 'acc) -> 'a t -> 'acc -> 'acc
(** [fold_righti f nel default] same as {!val:fold_right} but the function is
    applied to the index of the element as first argument (counting from 0), and
    the element itself as second argument. *)

(** {1 Prettty-printers and equality} *)

val pp :
     ?pp_sep:(Format.formatter -> unit -> unit)
  -> (Format.formatter -> 'a -> unit)
  -> Format.formatter
  -> 'a t
  -> unit
(** Pretty-printer based on [Format.pp_print_list]. *)

val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
(** Equality between non-empty lists. *)
