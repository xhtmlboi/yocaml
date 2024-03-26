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

(** Testable for use with {{:https://ocaml.org/p/alcotest/latest} Alcotest}. *)

val fs : Fs.t Alcotest.testable
val fs_item : Fs.item Alcotest.testable
val sexp : Yocaml.Sexp.t Alcotest.testable

val csexp_result :
     unit
  -> ( Yocaml.Sexp.t
     , [> `Nonterminated_atom of int
       | `Expected_number_or_colon of char * int
       | `Expected_number of char * int
       | `Unexepected_character of char * int
       | `Premature_end_of_atom of int * int
       | `Nonterminated_node of int ] )
     result
     Alcotest.testable

val nel : 'a Alcotest.testable -> 'a Yocaml.Nel.t Alcotest.testable
val deps : Yocaml.Deps.t Alcotest.testable
val path : Yocaml.Path.t Alcotest.testable

val from_sexp :
     'a Alcotest.testable
  -> ( 'a
     , [> `Invalid_sexp of Yocaml.Sexp.t * [> `Path | `Deps | `Cache ] ] )
     result
     Alcotest.testable

val cache : Yocaml.Cache.t Alcotest.testable
val data : Yocaml.Data.t Alcotest.testable

val value_error :
     ?custom_handler:
       (Format.formatter -> Yocaml.Data.Validation.custom_error -> unit)
       * (   Yocaml.Data.Validation.custom_error
          -> Yocaml.Data.Validation.custom_error
          -> bool)
  -> unit
  -> Yocaml.Data.Validation.value_error Alcotest.testable

val record_error :
     ?custom_handler:
       (Format.formatter -> Yocaml.Data.Validation.custom_error -> unit)
       * (   Yocaml.Data.Validation.custom_error
          -> Yocaml.Data.Validation.custom_error
          -> bool)
  -> unit
  -> Yocaml.Data.Validation.record_error Alcotest.testable

val validated_value :
     ?custom_handler:
       (Format.formatter -> Yocaml.Data.Validation.custom_error -> unit)
       * (   Yocaml.Data.Validation.custom_error
          -> Yocaml.Data.Validation.custom_error
          -> bool)
  -> 'a Alcotest.testable
  -> 'a Yocaml.Data.Validation.validated_value Alcotest.testable

val validated_record :
     ?custom_handler:
       (Format.formatter -> Yocaml.Data.Validation.custom_error -> unit)
       * (   Yocaml.Data.Validation.custom_error
          -> Yocaml.Data.Validation.custom_error
          -> bool)
  -> 'a Alcotest.testable
  -> 'a Yocaml.Data.Validation.validated_record Alcotest.testable

val with_metadata : (string option * string) Alcotest.testable
