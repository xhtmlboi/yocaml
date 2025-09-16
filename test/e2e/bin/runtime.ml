include Yocaml_unix.Runtime

let read_dir ~on path =
  path |> read_dir ~on |> Result.map (List.sort String.compare)
