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

type 'a t = ( :: ) of ('a * 'a list)

let singleton x = [ x ]
let cons x (y :: z) = x :: y :: z

let init len f =
  if len < 1 then raise (Invalid_argument "Nel.init")
  else f 0 :: List.init (pred len) (fun i -> f (succ i))

let from_list = function List.[] -> None | List.(x :: xs) -> Some (x :: xs)

let from_seq seq =
  match seq () with
  | Seq.Nil -> None
  | Seq.Cons (x, xs) -> Some (x :: List.of_seq xs)

let is_singleton (_ :: xs) = match xs with List.[] -> true | _ -> false
let length (_ :: xs) = succ (List.length xs)
let to_list (x :: xs) = List.cons x xs
let to_seq (x :: xs) = Seq.cons x @@ List.to_seq xs
let equal e (x :: xs) (y :: ys) = e x y && List.equal e xs ys
let hd (x :: _) = x
let tl (_ :: xs) = xs

let rev (x :: xs) =
  let rec aux acc first = function
    | List.[] -> first :: acc
    | List.(x :: xs) -> aux (first :: acc) x xs
  in
  aux [] x xs

let rev_with_length (x :: xs) =
  let rec aux i acc first = function
    | List.[] -> (i, first :: acc)
    | List.(x :: xs) -> aux (succ i) (first :: acc) x xs
  in
  aux 0 [] x xs

let rev_append (x :: xs) nel2 =
  let rec aux acc first = function
    | List.[] -> first :: acc
    | List.(x :: xs) -> aux (first :: acc) x xs
  in
  aux (to_list nel2) x xs

let append (x :: xs) ys = x :: List.(append xs (to_list ys))
let concat ((x :: xs) :: rest) = x :: (xs @ List.concat_map to_list rest)

let iter f (x :: xs) =
  let () = f x in
  List.iter f xs

let iteri f (x :: xs) =
  let () = f 0 x in
  List.iteri (fun i elt -> f (succ i) elt) xs

let map f (x :: xs) = f x :: List.map f xs
let mapi f (x :: xs) = f 0 x :: List.mapi (fun i x -> f (succ i) x) xs

let rev_map f (x :: xs) =
  let rec aux acc first = function
    | List.[] -> first :: acc
    | List.(x :: xs) -> aux (first :: acc) (f x) xs
  in
  aux [] (f x) xs

let rev_mapi f (x :: xs) =
  let rec aux i acc first = function
    | List.[] -> first :: acc
    | List.(x :: xs) -> aux (succ i) (first :: acc) (f i x) xs
  in
  aux 1 [] (f 0 x) xs

let concat_map f nel = concat (map f nel)
let flat_map = concat_map
let concat_mapi f nel = concat (mapi f nel)
let fold_left f default (x :: xs) = List.fold_left f (f default x) xs
let fold_right f nel default = List.fold_right f (to_list nel) default

let fold_lefti f default (x :: xs) =
  let rec aux i acc = function
    | List.[] -> acc
    | List.(x :: xs) -> aux (succ i) (f i acc x) xs
  in
  aux 1 (f 0 default x) xs

let fold_righti f nel default =
  let len, nel = rev_with_length nel in
  fold_lefti (fun i x acc -> f (len - i) acc x) default nel

let pp ?pp_sep pp_elt ppf (x :: xs) =
  Format.(fprintf ppf "%a" (Format.pp_print_list ?pp_sep pp_elt))
  @@ List.cons x xs
