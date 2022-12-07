module Renderable = struct
  open Jingoo

  type t = Jg_types.tvalue

  let object_ list = Jg_types.Tobj list
  let list list = Jg_types.Tlist list
  let string str = Jg_types.Tstr str
  let boolean b = Jg_types.Tbool b
  let integer i = Jg_types.Tint i
  let float f = Jg_types.Tfloat f
  let atom s = Jg_types.Tstr s
  let null = Jg_types.Tnull

  let to_string ?(strict = true) variables tpl =
    let env = Jg_types.{ std_env with strict_mode = strict } in
    Jg_template.from_string ~env ~models:variables tpl
  ;;
end

include Renderable

let apply_as_template
  (type a)
  (module I : Yocaml.Metadata.INJECTABLE with type t = a)
  ?(strict = true)
  template
  =
  Yocaml.Build.apply_as_template
    (module I)
    (module Renderable)
    ~strict
    template
;;
