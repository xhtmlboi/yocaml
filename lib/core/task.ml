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

type (-'a, 'b) t = {
    has_dynamic_dependencies : bool
  ; dependencies : Deps.t
  ; action : 'a -> 'b Eff.t
}

type 'a ct = (unit, 'a) t

let make ?(has_dynamic_dependencies = true) dependencies action =
  { dependencies; action; has_dynamic_dependencies }

let from_effect ?has_dynamic_dependencies action =
  make ?has_dynamic_dependencies Deps.empty action

let dependencies_of { dependencies; _ } = dependencies
let action_of { action; _ } = action

let has_dynamic_dependencies { has_dynamic_dependencies; _ } =
  has_dynamic_dependencies

let destruct { dependencies; action; has_dynamic_dependencies } =
  (dependencies, action, has_dynamic_dependencies)

let lift ?has_dynamic_dependencies f =
  let dependencies = Deps.empty in
  let action x = Eff.return (f x) in
  make ?has_dynamic_dependencies dependencies action

let id =
  let dependencies = Deps.empty in
  let action = Eff.return in
  { dependencies; action; has_dynamic_dependencies = true }

let dimap f g { dependencies; action; has_dynamic_dependencies } =
  let action x = Eff.map g (action (f x)) in
  { dependencies; action; has_dynamic_dependencies }

let lmap f x = dimap f Fun.id x
let rmap f x = dimap Fun.id f x

let left { dependencies; action; has_dynamic_dependencies } =
  let action = function
    | Either.Left x -> Eff.map Either.left (action x)
    | Either.Right x -> Eff.(map Either.right (return x))
  in
  { dependencies; action; has_dynamic_dependencies }

let right { dependencies; action; has_dynamic_dependencies } =
  let action = function
    | Either.Right x -> Eff.map Either.right (action x)
    | Either.Left x -> Eff.(map Either.left (return x))
  in
  { dependencies; action; has_dynamic_dependencies }

let compose t2 t1 =
  let dependencies = Deps.concat t1.dependencies t2.dependencies in
  let action = Eff.(t1.action >=> t2.action) in
  let has_dynamic_dependencies =
    t1.has_dynamic_dependencies || t2.has_dynamic_dependencies
  in
  { dependencies; action; has_dynamic_dependencies }

let rcompose t1 t2 = compose t2 t1
let pre_compose f t = compose (lift f) t
let post_compose t f = compose t (lift f)
let pre_rcompose f t = rcompose (lift f) t
let post_rcompose t f = rcompose t (lift f)
let choose t1 t2 = rcompose (left t1) (right t2)

let compose_with_dynamic_deps_merge t2 t1 =
  let dependencies = Deps.concat t1.dependencies t2.dependencies in
  let action x =
    let open Eff.Syntax in
    let* v, adeps = t1.action x in
    let* r, bdeps = t2.action v in
    Eff.return (r, Deps.concat adeps bdeps)
  in
  let has_dynamic_dependencies =
    t1.has_dynamic_dependencies || t2.has_dynamic_dependencies
  in
  { dependencies; action; has_dynamic_dependencies }

let rcompose_with_dynamic_deps_merge t1 t2 =
  compose_with_dynamic_deps_merge t2 t1

let fan_in t1 t2 =
  post_rcompose (choose t1 t2) (function
    | Either.Left x -> x
    | Either.Right x -> x)

let first { dependencies; action; has_dynamic_dependencies } =
  let action (x, y) = Eff.map (fun x -> (x, y)) (action x) in
  { dependencies; action; has_dynamic_dependencies }

let second { dependencies; action; has_dynamic_dependencies } =
  let action (x, y) = Eff.map (fun y -> (x, y)) (action y) in
  { dependencies; action; has_dynamic_dependencies }

let split t1 t2 = rcompose (first t1) (second t2)
let uncurry t = rmap (fun (f, x) -> f x) (first t)
let fan_out t1 t2 = pre_rcompose (fun x -> (x, x)) (split t1 t2)

let apply =
  let has_dynamic_dependencies = true in
  let dependencies = Deps.empty in
  (* the apply is a little bit controversial since, logically, it does not
     handle dependecies of underlying arrow. An issue related to dynamic
     dependencies. *)
  let action ({ action; _ }, x) = action x in

  { dependencies; action; has_dynamic_dependencies }

let pure x = lift (fun _ -> x)
let map f x = post_rcompose x f
let ap t1 t2 = pre_compose (fun (f, x) -> f x) (fan_out t1 t2)

let select f t =
  rcompose f
    (fan_in
       (post_rcompose
          (pre_rcompose (fun x -> ((), x)) (first t))
          (fun (f, x) -> f x))
       (lift (fun x -> x)))

let branch s l r =
  select
    (select
       (map Either.(map_right left) s)
       (map (fun f x -> Either.right @@ f x) l))
    r

let replace x t = map (fun _ -> x) t
let void t = replace () t
let zip t1 t2 = ap (map (fun a b -> (a, b)) t1) t2
let map2 fu a b = ap (map fu a) b
let map3 fu a b c = ap (map2 fu a b) c
let map4 fu a b c d = ap (map3 fu a b c) d
let map5 fu a b c d e = ap (map4 fu a b c d) e
let map6 fu a b c d e f = ap (map5 fu a b c d e) f
let map7 fu a b c d e f g = ap (map6 fu a b c d e f) g
let map8 fu a b c d e f g h = ap (map7 fu a b c d e f g) h

let no_dynamic_deps t =
  let a = rcompose t (lift (fun x -> (x, Deps.empty))) in
  { a with has_dynamic_dependencies = false }

let drop_first () = lift Stdlib.snd
let drop_second () = lift Stdlib.fst

let with_dynamic_dependencies files =
  let set = Deps.from_list files in
  lift (fun x -> (x, set))

let empty_body () = lift (fun x -> (x, ""))
let const k = lift (fun _ -> k)

module Infix = struct
  let ( <<< ) = compose
  let ( >>> ) = rcompose
  let ( <+< ) = compose_with_dynamic_deps_merge
  let ( >+> ) = rcompose_with_dynamic_deps_merge
  let ( *<< ) f t = make Deps.empty f <<< t
  let ( <<* ) t f = t <<< make Deps.empty f
  let ( |<< ) = pre_compose
  let ( <<| ) = post_compose
  let ( *>> ) f t = make Deps.empty f >>> t
  let ( >>* ) t f = t >>> make Deps.empty f
  let ( |>> ) = pre_rcompose
  let ( >>| ) = post_rcompose
  let ( +++ ) = choose
  let ( ||| ) = fan_in
  let ( *** ) = split
  let ( &&& ) = fan_out
  let ( <$> ) = map
  let ( <*> ) = ap
  let ( <*? ) = select
  let ( ||> ) x f = f x
end

module Syntax = struct
  let ( let+ ) x f = map f x
  let ( and+ ) = zip
end

include Infix
include Syntax

module Static = struct
  let on_content arr = second arr
  let on_metadata arr = first arr
  let keep_content = drop_first
  let empty_body = empty_body
end

module Dynamic = struct
  let on_content arr = first (Static.on_content arr)
  let on_metadata arr = first (Static.on_metadata arr)
  let on_static arr = first arr
  let on_dependencies arr = second arr
  let keep_content () = lift (fun ((_, c), d) -> (c, d))
  let empty_body () = lift (fun (x, d) -> ((x, ""), d))
end
