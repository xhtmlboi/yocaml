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

type ('a, 'b) t = { dependencies : Deps.t; action : 'a -> 'b Eff.t }

let make dependencies action = { dependencies; action }

let lift f =
  let dependencies = Deps.empty in
  let action x = Eff.return (f x) in
  { dependencies; action }

let id =
  let dependencies = Deps.empty in
  let action = Eff.return in
  { dependencies; action }

let dimap f g { dependencies; action } =
  let action x = Eff.map g (action (f x)) in
  { dependencies; action }

let lmap f x = dimap f Fun.id x
let rmap f x = dimap Fun.id f x

let left { dependencies; action } =
  let action = function
    | Either.Left x -> Eff.map Either.left (action x)
    | Either.Right x -> Eff.(map Either.right (return x))
  in
  { dependencies; action }

let right { dependencies; action } =
  let action = function
    | Either.Right x -> Eff.map Either.right (action x)
    | Either.Left x -> Eff.(map Either.left (return x))
  in
  { dependencies; action }

let compose t2 t1 =
  let dependencies = Deps.concat t1.dependencies t2.dependencies in
  let action = Eff.(t1.action >=> t2.action) in
  { dependencies; action }

let rcompose t1 t2 = compose t2 t1
let pre_compose f t = compose (lift f) t
let post_compose t f = compose t (lift f)
let pre_rcompose f t = rcompose (lift f) t
let post_rcompose t f = rcompose t (lift f)
let choose t1 t2 = rcompose (left t1) (right t2)

let fan_in t1 t2 =
  post_rcompose (choose t1 t2) (function
    | Either.Left x -> x
    | Either.Right x -> x)

let first { dependencies; action } =
  let action (x, y) = Eff.map (fun x -> (x, y)) (action x) in
  { dependencies; action }

let second { dependencies; action } =
  let action (x, y) = Eff.map (fun y -> (x, y)) (action y) in
  { dependencies; action }

let split t1 t2 = rcompose (first t1) (second t2)
let uncurry t = rmap (fun (f, x) -> f x) (first t)
let fan_out t1 t2 = pre_rcompose (fun x -> (x, x)) (split t1 t2)

module Infix = struct
  let ( <<< ) = compose
  let ( >>> ) = rcompose
  let ( |<< ) = pre_compose
  let ( <<| ) = post_compose
  let ( |>> ) = pre_rcompose
  let ( >>| ) = post_rcompose
  let ( +++ ) = choose
  let ( ||| ) = fan_in
  let ( *** ) = split
  let ( &&& ) = fan_out
end

include Infix
