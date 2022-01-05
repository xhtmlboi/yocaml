open Yocaml

let destination = "_build"
let track_binary_update = Build.watch Sys.argv.(0)

let task =
  process_files [ "pages/" ] (with_extension "html") (fun file ->
      let target = basename file |> into destination in
      let open Build in
      create_file
        target
        (track_binary_update
        >>> read_file "templates/header.html"
        >>> pipe_content file
        >>> pipe_content "templates/footer.html"))
;;

let () =
  Logs.set_level ~all:true (Some Logs.Debug);
  Logs.set_reporter (Logs_fmt.reporter ())
;;

let () = Yocaml_unix.execute task
