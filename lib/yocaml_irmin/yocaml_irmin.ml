let execute
    (module Source : Runtime.RUNTIME)
    (module Store : Irmin.S
      with type Schema.Branch.t = string
       and type Schema.Path.t = string list
       and type Schema.Contents.t = string)
    ?branch
    ?author
    ?author_email
    config
    program
  =
  let module R0 =
    Runtime.Make (Source) (Store)
      (struct
        let config = config
        let branch = Option.value ~default:"master" branch
        let author = author
        let author_email = author_email
      end)
  in
  let module R1 = Yocaml.Runtime.Make (R0) in
  R1.execute program
;;
