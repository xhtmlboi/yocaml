let () =
  let port, resolver, file = Server_error.setup () in
  Yocaml_unix.serve ~target:resolver#target ~port
    (Server_error.program resolver file)
