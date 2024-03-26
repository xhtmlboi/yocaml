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

type t = Atom of string | Node of t list

let atom x = Atom x
let node x = Node x

let rec equal a b =
  match (a, b) with
  | Atom a, Atom b -> String.equal a b
  | Node a, Node b -> List.equal equal a b
  | _ -> false

let rec pp ppf = function
  | Atom x -> Format.fprintf ppf {|Atom "%s"|} x
  | Node x -> Format.fprintf ppf {|Node [ %a ]|} (Format.pp_print_list pp) x

let rec pp_pretty ppf = function
  | Atom x -> Format.fprintf ppf "%s" x
  | Node x -> Format.fprintf ppf "(@[<hov 1>%a@])" pp_pretty_list x

and pp_pretty_list ppf = function
  | x :: (_ :: _ as xs) ->
      let () = Format.fprintf ppf "%a@ " pp_pretty x in
      pp_pretty_list ppf xs
  | x :: xs ->
      let () = Format.fprintf ppf "%a" pp_pretty x in
      pp_pretty_list ppf xs
  | [] -> ()

let to_string = Format.asprintf "%a" pp_pretty
let char_to_int c = int_of_char c - int_of_char '0'

module Canonical = struct
  let length sexp =
    let rec aux acc = function
      | Node x -> 2 + List.fold_left aux acc x
      | Atom x ->
          let len = String.length x in
          let ilen = String.length (Int.to_string len) in
          acc + ilen + 1 + len
    in
    aux 0 sexp

  let to_buffer buf sexp =
    let rec aux = function
      | Atom x ->
          let len = String.length x |> Int.to_string in
          let () = Buffer.add_string buf len in
          let () = Buffer.add_char buf ':' in
          Buffer.add_string buf x
      | Node x ->
          let () = Buffer.add_char buf '(' in
          let () = List.iter aux x in
          Buffer.add_char buf ')'
    in
    aux sexp

  let to_string sexp =
    let len = length sexp in
    let buf = Buffer.create len in
    let () = to_buffer buf sexp in
    Buffer.contents buf

  let collect_string len seq =
    let buf = Buffer.create len in
    let rec aux i seq =
      if i = len then Ok (atom @@ Buffer.contents buf, seq)
      else
        match Seq.uncons seq with
        | None -> Error (`Premature_end_of_atom (len, i))
        | Some (c, xs) ->
            let () = Buffer.add_char buf c in
            aux (i + 1) xs
    in
    aux 0 seq

  let parse_atom lex_pos seq =
    let rec aux lex_pos acc seq =
      match (Seq.uncons seq, acc) with
      | None, _ -> Error (`Nonterminated_atom lex_pos)
      | Some (':', xs), Some x ->
          Result.map (fun (a, xs) -> (a, lex_pos + x, xs)) (collect_string x xs)
      | Some (('0' .. '9' as c), xs), acc ->
          let acc = (Option.value ~default:0 acc * 10) + char_to_int c in
          aux (lex_pos + 1) (Some acc) xs
      | Some (c, _), Some _ -> Error (`Expected_number_or_colon (c, lex_pos))
      | Some (c, _), None -> Error (`Expected_number (c, lex_pos))
    in
    aux lex_pos None seq

  let from_seq seq =
    let rec aux level lex_pos acc seq =
      match Seq.uncons seq with
      | None ->
          if level = 0 then Ok (List.rev acc, lex_pos, Seq.empty)
          else Error (`Nonterminated_node lex_pos)
      | Some (('0' .. '9' as c), xs) ->
          Result.bind
            (parse_atom lex_pos (Seq.cons c xs))
            (fun (a, lex_pos, xs) -> aux level (lex_pos + 1) (a :: acc) xs)
      | Some (')', xs) -> Ok (List.rev acc, lex_pos + 1, xs)
      | Some ('(', xs) ->
          Result.bind
            (aux (level + 1) lex_pos [] xs)
            (fun (n, lex_pos, x) -> aux level (lex_pos + 1) (node n :: acc) x)
      | Some (c, _) -> Error (`Unexepected_character (c, lex_pos))
    in
    Result.map
      (fun (r, _, _) -> match r with [ e ] -> e | _ -> node r)
      (aux 0 0 [] seq)

  let from_string str = str |> String.to_seq |> from_seq
end
