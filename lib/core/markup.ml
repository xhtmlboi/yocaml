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

module Toc = struct
  type 'a element = { content : 'a; children : 'a t }
  and 'a t = 'a element list

  let rec from_list labels =
    let rec aux depth acc = function
      | [] -> (List.rev acc, [])
      | (level, _) :: _ as labels when level < depth -> (List.rev acc, labels)
      | (level, content) :: xs when level = depth ->
          let children, xs = aux (succ depth) [] xs in
          let entry = { content; children } in
          let remaining, xs = aux depth (entry :: acc) xs in
          (remaining, xs)
      | labels ->
          let children, xs = aux (succ depth) acc labels in
          let remaining, xs = aux depth children xs in
          (remaining, xs)
    in
    match labels with
    | [] -> []
    | (level, _) :: _ -> (
        match labels |> aux level [] with
        | labels, [] -> labels
        | labels, xs -> labels @ from_list xs)

  let to_labelled_list toc =
    let rec aux current_index elements =
      List.mapi
        (fun i { content; children } ->
          let new_index = current_index @ [ i + 1 ] in
          (new_index, content) :: aux new_index children)
        elements
      |> List.flatten
    in
    aux [] toc

  let to_html ?(ol = false) f toc =
    let ul children =
      let r = String.concat "" children in
      if ol then "<ol>" ^ r ^ "</ol>" else "<ul>" ^ r ^ "</ul>"
    in

    let li children = "<li>" ^ children ^ "</li>" in
    let a = Format.asprintf "<a href=\"#%s\">%s</a>" in
    let rec aux = function
      | [] -> None
      | xs ->
          xs
          |> List.map (fun { content = id, title; children } ->
                 let content = a id (f title) in
                 let children = Option.fold ~none:"" ~some:ul (aux children) in
                 li @@ content ^ children)
          |> Option.some
    in
    aux toc |> Option.map ul
end
