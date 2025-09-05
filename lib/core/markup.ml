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

  let from_list labels =
    let rec aux depth = function
      | [] -> ([], [])
      | (level, content) :: xs when level < depth -> ([], (level, content) :: xs)
      | (level, content) :: xs when level = depth ->
          let children, rest = aux (depth + 1) xs in
          let node = { content; children } in
          let siblings, rest = aux depth rest in
          (node :: siblings, rest)
      | (_level, _) :: _ as xs -> aux (depth + 1) xs
    in
    let rec loop labels =
      match labels with
      | [] -> []
      | (level, _) :: _ ->
          let block, rest = aux level labels in
          block @ loop rest
    in
    loop labels

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

  let traverse ~on_list ~on_item:li ~on_link toc =
    let rec aux = function
      | [] -> None
      | xs ->
          xs
          |> List.map (fun { content = id, title; children } ->
                 let content = on_link ~id ~title in
                 let children =
                   Option.fold ~none:"" ~some:on_list (aux children)
                 in
                 li @@ content ^ children)
          |> Option.some
    in
    aux toc |> Option.map on_list

  let to_html ?(ol = false) f toc =
    let ul x = if ol then "<ol>" ^ x ^ "</ol>" else "<ul>" ^ x ^ "</ul>" in
    traverse
      ~on_list:(fun x ->
        let r = String.concat "" x in
        ul r)
      ~on_item:(fun x -> "<li>" ^ x ^ "</li>")
      ~on_link:(fun ~id ~title ->
        Format.asprintf {|<a href="#%s" data-toc-target="%s">%s</a>|} id id
          (f title))
      toc
end
