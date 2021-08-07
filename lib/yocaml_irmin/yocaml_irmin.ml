let execute
    (module Source : Yocaml.Runtime.RUNTIME)
    (module Store : Irmin.S
      with type branch = string
       and type key = string list
       and type contents = string)
    ?branch
    ?author
    ?author_email
    config
    program
  =
  let module R =
    Runtime.Make (Source) (Store)
      (struct
        let config = config
        let branch = Option.value ~default:"master" branch
        let author = author
        let author_email = author_email
      end)
  in
  Yocaml.Runtime.execute (module R) program
;;
