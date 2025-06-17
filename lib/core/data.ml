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

type t =
  | Null
  | Bool of bool
  | Int of int
  | Float of float
  | String of string
  | List of t list
  | Record of (string * t) list

type ezjsonm =
  [ `Null
  | `Bool of bool
  | `Float of float
  | `String of string
  | `A of ezjsonm list
  | `O of (string * ezjsonm) list ]

let null = Null
let bool b = Bool b
let int i = Int i
let float f = Float f
let string s = String s
let list v = List v
let list_of f l = list @@ List.map f l
let record fields = Record fields
let option some = Option.fold ~none:null ~some
let path p = string (Path.to_string p)

let sum f value =
  let k, v = f value in
  record [ ("constr", string k); ("value", v) ]

let pair fst snd (a, b) = record [ ("fst", fst a); ("snd", snd b) ]
let triple f g h (a, b, c) = pair f (pair g h) (a, (b, c))
let quad f g h i (w, x, y, z) = pair f (triple g h i) (w, (x, y, z))

let either left right =
  sum (function
    | Either.Left x -> ("left", left x)
    | Either.Right x -> ("right", right x))

let rec equal a b =
  match (a, b) with
  | Null, Null -> true
  | Bool a, Bool b -> Bool.equal a b
  | Int a, Int b -> Int.equal a b
  | Float a, Float b -> Float.equal a b
  | String a, String b -> String.equal a b
  | List a, List b -> List.equal equal a b
  | Record a, Record b ->
      List.equal
        (fun (ka, va) (kb, vb) -> String.equal ka kb && equal va vb)
        a b
  | _, _ -> false

let pp_delim ppf () = Format.fprintf ppf ", @,"

let rec pp ppf = function
  | Null -> Format.fprintf ppf "null"
  | Bool x -> Format.fprintf ppf "%b" x
  | Int x -> Format.fprintf ppf "%d" x
  | Float x -> Format.fprintf ppf "%f" x
  | String x -> Format.fprintf ppf {|"%s"|} x
  | List x ->
      Format.fprintf ppf "@[[%a]@]" (Format.pp_print_list ~pp_sep:pp_delim pp) x
  | Record x ->
      Format.fprintf ppf "@[{%a}@]"
        (Format.pp_print_list ~pp_sep:pp_delim (fun ppf (key, value) ->
             Format.fprintf ppf {|"%s":@, %a|} key pp value))
        x

let rec to_sexp = function
  | Null -> Sexp.atom "null"
  | Bool x -> Sexp.atom (string_of_bool x)
  | Int x -> Sexp.atom (string_of_int x)
  | Float x -> Sexp.atom (string_of_float x)
  | String x -> Sexp.atom x
  | List x ->
      Sexp.node
        (Stdlib.List.concat_map (function Null -> [] | x -> [ to_sexp x ]) x)
  | Record xs ->
      Sexp.node
        (Stdlib.List.concat_map
           (fun (k, v) ->
             match v with
             | Null -> []
             | v -> [ Sexp.(node [ atom k; to_sexp v ]) ])
           xs)

let rec to_ezjsonm = function
  | Null -> `Null
  | Bool b -> `Bool b
  | Int x -> `Float (float_of_int x)
  | Float x -> `Float x
  | String x -> `String x
  | List x -> `A (List.map to_ezjsonm x)
  | Record x -> `O (List.map (fun (k, v) -> (k, to_ezjsonm v)) x)

let rec from_ezjsonm = function
  | `Null -> Null
  | `Bool x -> Bool x
  | `Float x -> Float x
  | `String x -> String x
  | `A x -> List (List.map from_ezjsonm x)
  | `O x -> Record (List.map (fun (k, v) -> (k, from_ezjsonm v)) x)

module Validation = struct
  let find_assoc given_key list =
    List.find_map
      (fun (k, value) -> if String.equal given_key k then Some value else None)
      list

  type custom_error = ..

  type value_error =
    | Invalid_shape of { expected : string; given : t }
    | Invalid_list of { errors : (int * value_error) Nel.t; given : t list }
    | Invalid_record of {
          errors : record_error Nel.t
        ; given : (string * t) list
      }
    | With_message of { given : string; message : string }
    | Custom of custom_error

  and record_error =
    | Missing_field of { field : string }
    | Invalid_field of { given : t; field : string; error : value_error }

  type 'a validated_value = ('a, value_error) result
  type 'a validated_record = ('a, record_error Nel.t) result

  let invalid_shape expected given = Error (Invalid_shape { expected; given })
  let fail_with ~given message = Error (With_message { given; message })
  let fail_with_custom err = Error (Custom err)

  let null = function
    | Null -> Ok ()
    | invalid_value -> invalid_shape "null" invalid_value

  let bool = function
    | Bool b -> Ok b
    | invalid_value -> invalid_shape "bool" invalid_value

  let int = function
    | Int i -> Ok i
    | Float f ->
        (* Mandatory case since Ezjsonm does not support integer (because of
           JavaScript). *)
        Ok (int_of_float f)
    | invalid_value -> invalid_shape "int" invalid_value

  let float = function
    | Float f -> Ok f
    | Int i ->
        (* Mandatory case since Ezjsonm does not support integer (because of
           JavaScript). *)
        Ok (float_of_int i)
    | invalid_value -> invalid_shape "float" invalid_value

  let string ?(strict = true) = function
    | String s -> Ok s
    | other -> (
        if strict then invalid_shape "strict-string" other
        else
          match other with
          | Bool b -> Ok (string_of_bool b)
          | Int i -> Ok (string_of_int i)
          | Float f -> Ok (string_of_float f)
          | invalid_value -> invalid_shape "non-strict-string" invalid_value)

  let const x _ = Ok x

  let positive x =
    if x < 0 then fail_with ~given:(string_of_int x) "should be positive"
    else Ok x

  let positive' x =
    if x < 0.0 then fail_with ~given:(string_of_float x) "should be positive"
    else Ok x

  let bounded ~min ~max x =
    let min = Stdlib.min min max and max = Stdlib.max min max in
    if x < min || x > max then
      fail_with ~given:(string_of_int x)
      @@ Format.asprintf "not included into [%d; %d]" min max
    else Ok x

  let bounded' ~min ~max x =
    let min = Stdlib.min min max and max = Stdlib.max min max in
    if x < min || x > max then
      fail_with ~given:(string_of_float x)
      @@ Format.asprintf "not included into [%f; %f]" min max
    else Ok x

  let non_empty = function
    | [] -> fail_with ~given:"[]" "list should not be empty"
    | x -> Ok x

  let mk_pp = function
    | None -> fun ppf _ -> Format.fprintf ppf "*"
    | Some pp -> fun ppf x -> Format.fprintf ppf "%a" pp x

  let equal ?pp ?(equal = ( = )) x y =
    if not (equal x y) then
      let pp = mk_pp pp in
      fail_with ~given:(Format.asprintf "%a" pp y)
      @@ Format.asprintf "should be equal to %a" pp x
    else Ok y

  let not_equal ?pp ?(equal = ( = )) x y =
    if equal x y then
      let pp = mk_pp pp in
      fail_with ~given:(Format.asprintf "%a" pp y)
      @@ Format.asprintf "should not be equal to %a" pp x
    else Ok y

  let gt ?pp ?(compare = Stdlib.compare) x y =
    if compare y x <= 0 then
      let pp = mk_pp pp in
      fail_with ~given:(Format.asprintf "%a" pp y)
      @@ Format.asprintf "should be greater than %a" pp x
    else Ok y

  let ge ?pp ?(compare = Stdlib.compare) x y =
    if compare y x < 0 then
      let pp = mk_pp pp in
      fail_with ~given:(Format.asprintf "%a" pp y)
      @@ Format.asprintf "should be greater or equal to %a" pp x
    else Ok y

  let lt ?pp ?(compare = Stdlib.compare) x y =
    if compare y x >= 0 then
      let pp = mk_pp pp in
      fail_with ~given:(Format.asprintf "%a" pp y)
      @@ Format.asprintf "should be lesser than %a" pp x
    else Ok y

  let le ?pp ?(compare = Stdlib.compare) x y =
    if compare y x > 0 then
      let pp = mk_pp pp in
      fail_with ~given:(Format.asprintf "%a" pp y)
      @@ Format.asprintf "should be lesser or equal to %a" pp x
    else Ok y

  let one_of ?pp ?(equal = ( = )) li value =
    match List.find_opt (equal value) li with
    | None ->
        let pp = mk_pp pp in
        fail_with ~given:(Format.asprintf "%a" pp value)
        @@ Format.asprintf "not included in [%a]"
             (Format.pp_print_list
                ~pp_sep:(fun ppf () -> Format.fprintf ppf "; ")
                pp)
             li
    | Some x -> Ok x

  let where ?pp ?message predicate x =
    if not (predicate x) then
      let pp = mk_pp pp in
      let f =
        Option.value ~default:(fun _ -> "unsatisfied predicate") message
      in
      fail_with ~given:(Format.asprintf "%a" pp x) (f x)
    else Ok x

  let sum branch x =
    let str_expectation () =
      branch
      |> List.map (fun (k, _) -> String.capitalize_ascii k ^ " <abstr>")
      |> String.concat " | "
    in
    match x with
    | Record [ ("constr", String k); ("value", v) ] as repr ->
        let pval = find_assoc k branch in
        Option.fold
          ~none:(invalid_shape (str_expectation ()) repr)
          ~some:(fun validator -> validator v)
          pval
    | repr -> invalid_shape (str_expectation ()) repr

  let either left right =
    sum
      [
        ("left", fun x -> x |> left |> Result.map Either.left)
      ; ("right", fun x -> x |> right |> Result.map Either.right)
      ]

  let option v = function Null -> Ok None | x -> v x |> Result.map Option.some

  let merge_list_values i acc value =
    (* yes, I know, coupled with fold_left... which is done on [list_of] it is a
       kind of traverse *)
    match (acc, value) with
    | Ok xs, Ok x -> Ok (x :: xs)
    | Error a, Error b -> Error (Nel.cons (i, b) a)
    | Error a, Ok _ -> Error a
    | Ok _, Error a -> Error (Nel.singleton (i, a))

  let list_of validator = function
    | List li ->
        List.fold_left
          (fun (i, acc) x ->
            let acc = merge_list_values i acc @@ validator x in
            (succ i, acc))
          (0, Ok []) li
        |> snd
        |> Result.map List.rev
        |> Result.map_error (fun errors -> Invalid_list { errors; given = li })
    | invalid_value -> invalid_shape "list" invalid_value

  let record validator = function
    | Record li ->
        validator li
        |> Result.map_error (fun errors ->
               Invalid_record { errors; given = li })
    | invalid_value -> invalid_shape "record" invalid_value

  let optional assoc field validator =
    match find_assoc field assoc with
    | None | Some Null -> Ok None
    | Some x ->
        x
        |> validator
        |> Result.map Option.some
        |> Result.map_error (fun error ->
               Nel.singleton @@ Invalid_field { given = x; error; field })

  let required assoc field validator =
    let opt = optional assoc field validator in
    Result.bind opt (function
      | Some x -> Ok x
      | None ->
          (* In case or the validator is an optional one. *)
          Null
          |> validator
          |> Result.map_error (fun _ ->
                 Nel.singleton @@ Missing_field { field }))

  let optional_or assoc field ~default validator =
    let opt = optional assoc field validator in
    Result.bind opt (function Some x -> Ok x | None -> Ok default)

  module Infix = struct
    let ( & ) l r x = Result.bind (l x) r
    let ( / ) l r x = Result.fold ~ok:Result.ok ~error:(fun _ -> r x) (l x)
    let ( $ ) l f x = Result.map f (l x)
  end

  module Syntax = struct
    let ( let+ ) v f = Result.map f v
    let ( let* ) v f = Result.bind v f

    let ( and+ ) a b =
      match (a, b) with
      | Ok x, Ok y -> Ok (x, y)
      | Error a, Error b -> Error (Nel.append a b)
      | Error a, _ | _, Error a -> Error a
  end

  include Infix
  include Syntax

  let pair f g = function
    | Record [ _; _ ] as r ->
        record
          (fun assoc ->
            let+ x = required assoc "fst" f and+ y = required assoc "snd" g in
            (x, y))
          r
    | r -> invalid_shape "pair" r

  let triple f g h x =
    x |> pair f (pair g h) |> Result.map (fun (x, (y, z)) -> (x, y, z))

  let quad f g h i x =
    x
    |> pair f (triple g h i)
    |> Result.map (fun (w, (x, y, z)) -> (w, x, y, z))

  let path = string $ Path.from_string
end
