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

let fs = Fs.testable
let fs_item = Fs.testable_item
let sexp = Alcotest.testable Yocaml.Sexp.pp Yocaml.Sexp.equal

let csexp_error_equal a b =
  match (a, b) with
  | `Nonterminated_atom a, `Nonterminated_atom b
  | `Nonterminated_node a, `Nonterminated_node b ->
      Int.equal a b
  | `Expected_number_or_colon (ca, la), `Expected_number_or_colon (cb, lb)
  | `Expected_number (ca, la), `Expected_number (cb, lb)
  | `Unexepected_character (ca, la), `Unexepected_character (cb, lb) ->
      Char.equal ca cb && Int.equal la lb
  | `Premature_end_of_atom (la, ia), `Premature_end_of_atom (lb, ib) ->
      Int.equal la lb && Int.equal ia ib
  | _ -> false

let csexp_error_pp ppf = function
  | `Nonterminated_atom a -> Format.fprintf ppf "`Nonterminated_atom %d" a
  | `Nonterminated_node a -> Format.fprintf ppf "`Nonterminated_node %d" a
  | `Expected_number_or_colon (c, i) ->
      Format.fprintf ppf "`Expected_number_or_colon (%c, %d)" c i
  | `Expected_number (c, i) ->
      Format.fprintf ppf "`Expected_number (%c, %d)" c i
  | `Unexepected_character (c, i) ->
      Format.fprintf ppf "`Unexepected_character (%c, %d)" c i
  | `Premature_end_of_atom (a, b) ->
      Format.fprintf ppf "`Premature_end_of_atom (%d, %d)" a b
  | _ -> Format.fprintf ppf "Unknown error"

let csexp_error () = Alcotest.testable csexp_error_pp csexp_error_equal
let csexp_result () = Alcotest.result sexp (csexp_error ())
let deps = Alcotest.testable Yocaml.Deps.pp Yocaml.Deps.equal

let from_sexp_error_subject_pp ppf = function
  | `Path -> Format.fprintf ppf "`Path"
  | `Deps -> Format.fprintf ppf "`Deps"
  | `Cache -> Format.fprintf ppf "`Cache"
  | _ -> Format.fprintf ppf "Unknown subject"

let from_sexp_error_ppf ppf = function
  | `Invalid_sexp (expr, subject) ->
      Format.fprintf ppf "`Invalid_sexp (%a, %a)" Yocaml.Sexp.pp expr
        from_sexp_error_subject_pp subject
  | _ -> Format.fprintf ppf "Unknown error"

let from_sexp_error_subject_equal a b =
  match (a, b) with
  | `Path, `Path | `Deps, `Deps | `Cache, `Cache -> true
  | _ -> true

let from_sexp_error_equal a b =
  match (a, b) with
  | `Invalid_sexp (expr_a, subject_a), `Invalid_sexp (expr_b, subject_b) ->
      Yocaml.Sexp.equal expr_a expr_b
      && from_sexp_error_subject_equal subject_a subject_b
  | _ -> false

let from_sexp a =
  let err = Alcotest.testable from_sexp_error_ppf from_sexp_error_equal in
  Alcotest.result a err

let path = Alcotest.testable Yocaml.Path.pp Yocaml.Path.equal
let cache = Alcotest.testable Yocaml.Cache.pp Yocaml.Cache.equal
let data = Alcotest.testable Yocaml.Data.pp Yocaml.Data.equal
let pp_list s = Fmt.brackets (Fmt.list ~sep:Fmt.semi s)
let pp_nel s = Fmt.using Yocaml.Nel.to_list (pp_list s)

let nel t =
  let pp = Alcotest.pp t and equal = Alcotest.equal t in
  Alcotest.testable (pp_nel pp) (Yocaml.Nel.equal equal)

let rec pp_value_error cst ppf err =
  let open Yocaml.Data.Validation in
  let open Fmt in
  match err with
  | Custom err ->
      braces
        (record
           [
             field "kind" (Fun.const "custom") string; field "error" Fun.id cst
           ])
        ppf err
  | With_message { given; message } ->
      braces
        (record
           [
             field "kind" (Fun.const "with_message") string
           ; field "given" snd (quote string)
           ; field "message" fst (quote string)
           ])
        ppf (message, given)
  | Invalid_shape { expected; given } ->
      braces
        (record
           [
             field "kind" (Fun.const "Invalid_shape") string
           ; field "expected" fst string
           ; field "given" snd (parens Yocaml.Data.pp)
           ])
        ppf (expected, given)
  | Invalid_list { errors; given } ->
      braces
        (record
           [
             field "kind" (Fun.const "invalid_list") string
           ; field "errors" fst
               (pp_nel
               @@ record
                    [
                      field "index" fst int
                    ; field "error" snd (pp_value_error cst)
                    ])
           ; field "given" snd (pp_list Yocaml.Data.pp)
           ])
        ppf (errors, given)
  | Invalid_record { errors; given } ->
      braces
        (record
           [
             field "kind" (Fun.const "invalid_record") string
           ; field "errors" fst (pp_nel (pp_record_error cst))
           ; field "given" snd
               (pp_list @@ pair ~sep:comma string (parens Yocaml.Data.pp))
           ])
        ppf (errors, given)

and pp_record_error cst ppf err =
  let open Yocaml.Data.Validation in
  let open Fmt in
  match err with
  | Missing_field { field = f } ->
      braces
        (record
           [
             field "kind" (Fun.const "missing_field") string
           ; field "field" id (quote string)
           ])
        ppf f
  | Invalid_field { given; field = f; error } ->
      braces
        (record
           [
             field "kind" (Fun.const "invalid_field") string
           ; field "field" (fun (f, _, _) -> f) (quote string)
           ; field "error" (fun (_, e, _) -> e) (parens (pp_value_error cst))
           ; field "given" (fun (_, _, g) -> g) (parens Yocaml.Data.pp)
           ])
        ppf (f, error, given)

let rec equal_value_error cst a b =
  let open Yocaml.Data.Validation in
  match (a, b) with
  | ( Invalid_shape { expected = ea; given = ga }
    , Invalid_shape { expected = eb; given = gb } ) ->
      String.equal ea eb && Yocaml.Data.equal ga gb
  | ( Invalid_list { errors = ea; given = ga }
    , Invalid_list { errors = eb; given = gb } ) ->
      Yocaml.Nel.equal
        (fun (ia, va) (ib, vb) ->
          Int.equal ia ib && equal_value_error cst va vb)
        ea eb
      && List.equal Yocaml.Data.equal ga gb
  | ( Invalid_record { errors = ea; given = ga }
    , Invalid_record { errors = eb; given = gb } ) ->
      Yocaml.Nel.equal (equal_record_error cst) ea eb
      && List.equal
           (fun (ka, va) (kb, vb) ->
             String.equal ka kb && Yocaml.Data.equal va vb)
           ga gb
  | ( With_message { given = ga; message = ma }
    , With_message { given = gb; message = mb } ) ->
      String.equal ga gb && String.equal ma mb
  | Custom a, Custom b -> cst a b
  | _ -> false

and equal_record_error cst a b =
  let open Yocaml.Data.Validation in
  match (a, b) with
  | Missing_field { field = fa }, Missing_field { field = fb } ->
      String.equal fa fb
  | ( Invalid_field { given = ga; field = fa; error = ea }
    , Invalid_field { given = gb; field = fb; error = eb } ) ->
      String.equal fa fb
      && Yocaml.Data.equal ga gb
      && equal_value_error cst ea eb
  | _ -> false

let default_cst_handler =
  ((fun ppf _ -> Format.fprintf ppf "<abstr>"), fun _ _ -> false)

let value_error ?(custom_handler = default_cst_handler) () =
  let pp_cst, eq_cst = custom_handler in
  Alcotest.testable (pp_value_error pp_cst) (equal_value_error eq_cst)

let record_error ?(custom_handler = default_cst_handler) () =
  let pp_cst, eq_cst = custom_handler in
  Alcotest.testable (pp_record_error pp_cst) (equal_record_error eq_cst)

let validated_value ?(custom_handler = default_cst_handler) t =
  Alcotest.result t (value_error ~custom_handler ())

let validated_record ?(custom_handler = default_cst_handler) t =
  Alcotest.result t (nel @@ record_error ~custom_handler ())

let with_metadata = Alcotest.(pair (option string) string)
