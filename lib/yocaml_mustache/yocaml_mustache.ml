module Renderable = struct
  include Yocaml.Key_value.Jsonm_descriptor

  let to_string ?(strict = true) variables tpl =
    let layout = Mustache.of_string tpl in
    Mustache.render ~strict layout (`O variables)
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
