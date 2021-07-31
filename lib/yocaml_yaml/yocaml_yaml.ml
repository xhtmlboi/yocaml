module X = struct
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
    (module M : Yocaml.Metadata.PARSABLE with type t = a)
    path
  =
  Yocaml.Build.read_file_with_metadata (module X) (module M) path
;;

include X
