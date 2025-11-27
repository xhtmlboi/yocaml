module R = Yocaml.Runtime.Make (Runtime)

let program () =
  let on = `Target in
  let target = Yocaml.Path.rel [ "residuals_build" ] in
  let cache = Yocaml.Path.(target / "cache") in
  let open Yocaml.Eff in
  Yocaml.Action.with_cache ~on cache
    (Yocaml.Batch.iter_files
       (Yocaml.Path.rel [ "residuals" ])
       (Yocaml.Action.copy_file ~into:target)
    >=> Yocaml.Action.remove_residuals ~target)

let () =
  let () = Array.iter print_endline Sys.argv in
  let () = Yocaml_runtime.Log.setup ~level:`Debug () in
  R.run program
