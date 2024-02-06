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

type 'a stat = { name : string; mtime : int; content : 'a }

type item = File of string stat | Dir of t stat
and t = item list

let name { name; _ } = name
let content { content; _ } = content
let mtime { mtime; _ } = mtime
let name_of = function File { name; _ } | Dir { name; _ } -> name
let mtime_of = function File { mtime; _ } | Dir { mtime; _ } -> mtime

let compare_item a b =
  (* A slightly naive comparison function, to be consistent when modifying file
     systems. *)
  match (a, b) with
  | File a, File b -> String.compare (name a) (name b)
  | Dir a, Dir b -> String.compare (name a) (name b)
  | Dir _, File _ -> 1
  | File _, Dir _ -> -1

let dir_content_of stat = stat |> content |> List.sort compare_item

let rec equal_item a b =
  (* A slightly naive equality function to implement the [testable] value of
     [Alcotest]. *)
  match (a, b) with
  | File a, File b ->
      String.equal (name a) (name b)
      && String.equal (content a) (content b)
      && Int.equal (mtime a) (mtime b)
  | Dir a, Dir b ->
      String.equal (name a) (name b)
      && Int.equal (mtime a) (mtime b)
      && List.equal equal_item (dir_content_of a) (dir_content_of b)
  | _ -> false

let rec pp_item ppf = function
  | File f ->
      Format.fprintf ppf "└─⟢ %s (mtime: %d) -> \"%s\"" (name f) (mtime f)
        (content f)
  | Dir d ->
      Format.fprintf ppf "└─⟤ %s/@[<v -10>@;%a@]" (name d)
        (Format.pp_print_list pp_item)
        (content d)

let pp ppf = Format.(fprintf ppf "@,%a@." (pp_print_list pp_item))
let equal = List.equal equal_item
let testable = Alcotest.testable pp equal
let testable_item = Alcotest.testable pp_item equal_item
let from_list x = x |> List.sort compare_item
let file ?(mtime = 1) name content = File { name; mtime; content }

let dir ?mtime name content =
  let mtime =
    Option.value
      ~default:
        (List.fold_left (fun p child -> max p (mtime_of child)) 0 content)
      mtime
  in
  Dir { name; mtime; content = content |> from_list }

let rec get fs path =
  match (fs, path) with
  | item :: xs, [ fragment ] ->
      if String.equal (name_of item) fragment then Some item else get xs path
  | Dir { name; content; _ } :: xs, fragment :: path_xs ->
      if String.equal name fragment then get content path_xs else get xs path
  | _ :: xs, path -> get xs path
  | [], _ -> None

let ( .%{} ) fs path = get fs @@ String.split_on_char '/' path

let split_path_and_target path =
  let rec aux acc = function
    | [ target ] -> Some (List.rev acc, target)
    | x :: xs -> aux (x :: acc) xs
    | [] -> None
  in
  aux [] path

let update fs path callback =
  match split_path_and_target path with
  | None -> fs
  | Some (path, target) ->
      let rec aux acc fs path =
        match (fs, path) with
        | [], [] ->
            callback ~target ~previous_item:None
            |> Option.fold ~none:acc ~some:(fun x -> x :: acc)
            |> from_list
        | item :: fs_xs, [] ->
            if String.equal (name_of item) target then
              let new_acc = acc @ fs_xs in
              callback ~target ~previous_item:(Some item)
              |> Option.fold ~none:new_acc ~some:(fun x -> x :: new_acc)
              |> from_list
            else aux (item :: acc) fs_xs []
        | (Dir { name; content; _ } as cdir) :: fs_xs, fragment :: path_xs ->
            if String.equal name fragment then
              let new_dir = dir name (aux [] content path_xs) in
              new_dir :: (acc @ fs_xs) |> from_list
            else aux (cdir :: acc) fs_xs path
        | [], fragment :: path_xs ->
            let new_dir = dir fragment (aux [] [] path_xs) in
            new_dir :: acc |> from_list
        | x :: fs_xs, path -> aux (x :: acc) fs_xs path
      in
      aux [] fs path

let ( .%{}<- ) fs path callback =
  update fs (String.split_on_char '/' path) callback

let rename name = function
  | File f -> File { f with name }
  | Dir d -> Dir { d with name }
