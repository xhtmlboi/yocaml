module Validable = struct
  let from_string str =
    let open Yocaml in
    Result.map_error (function `Msg e -> Error.Yaml e)
    $ Yaml.of_string str
    |> Yocaml.Validate.from_try
  ;;

  include Yocaml.Key_value.Jsonm_validator
end

let read_file_with_metadata
    (type a)
    (module R : Yocaml.Metadata.READABLE with type t = a)
    path
  =
  Yocaml.Build.read_file_with_metadata (module Validable) (module R) path
;;

let read_metadata
    (type a)
    (module R : Yocaml.Metadata.READABLE with type t = a)
    path
  =
  let open Yocaml.Build in
  read_file_with_metadata (module Validable) (module R) path
  >>^ Preface.Pair.fst
;;

include Validable
