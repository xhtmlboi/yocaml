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

type 'a t = unit -> 'a

let return x () = x
let bind f x = f (x ())
let map f x = bind (fun m -> return @@ f m) x
let join x = bind (fun x -> x) x
let compose f g x = bind g (f x)
let rcompose f g x = bind f (g x)
let apply ft xt = map (ft ()) xt
let zip x y = apply (map (fun a b -> (a, b)) x) y
let replace x e = map (fun _ -> x) e
let void e = replace () e

let select x y =
  bind
    (function
      | Either.Right v -> return v | Either.Left v -> map (fun f -> f v) y)
    x

let branch s l r =
  let a = map Either.(map_right left) s
  and b = map (fun f x -> Either.right (f x)) l in
  select (select a b) r

let map2 fu a b = apply (map fu a) b
let map3 fu a b c = apply (map2 fu a b) c
let map4 fu a b c d = apply (map3 fu a b c) d
let map5 fu a b c d e = apply (map4 fu a b c d) e
let map6 fu a b c d e f = apply (map5 fu a b c d e) f
let map7 fu a b c d e f g = apply (map6 fu a b c d e f) g
let map8 fu a b c d e f g h = apply (map7 fu a b c d e f g) h

module List = struct
  let traverse f l =
    let rec aux acc = function
      | [] -> map Stdlib.List.rev acc
      | x :: xs -> aux (map2 Stdlib.List.cons (f x) acc) xs
    in
    aux (return []) l

  let sequence l = traverse Fun.id l
end

module Infix = struct
  let ( <$> ) = map
  let ( <*> ) = apply
  let ( <*? ) = select
  let ( =<< ) = bind
  let ( >>= ) x f = f =<< x
  let ( >|= ) x f = f <$> x
  let ( =|< ) = map
  let ( >=> ) = compose
  let ( <=< ) = rcompose
end

module Syntax = struct
  let ( let+ ) x f = map f x
  let ( and+ ) = zip
  let ( let* ) x f = bind f x
end

include Infix
include Syntax

type _ Effect.t +=
  | Yocaml_log :
      ([ `App | `Error | `Warning | `Info | `Debug ] * string)
      -> unit Effect.t
  | Yocaml_failwith : exn -> 'a Effect.t
  | Yocaml_file_exists : [ `Target | `Source ] * Path.t -> bool Effect.t
  | Yocaml_read_file : [ `Target | `Source ] * Path.t -> string Effect.t
  | Yocaml_get_mtime : [ `Target | `Source ] * Path.t -> int Effect.t

let perform raw_effect = return @@ Effect.perform raw_effect

let run handler arrow input =
  Effect.Deep.try_with (fun input -> arrow input ()) input handler

exception File_not_exists of Path.t

let log ?(level = `Debug) message = perform @@ Yocaml_log (level, message)
let raise exn = perform @@ Yocaml_failwith exn
let failwith message = perform @@ Yocaml_failwith (Failure message)
let file_exists ~on path = perform @@ Yocaml_file_exists (on, path)

let ensure_file_exists ~on f path =
  let* exists = file_exists ~on path in
  if exists then f path else raise (File_not_exists path)

let read_file ~on =
  ensure_file_exists ~on (fun path -> perform @@ Yocaml_read_file (on, path))

let mtime ~on =
  ensure_file_exists ~on (fun path -> perform @@ Yocaml_get_mtime (on, path))
