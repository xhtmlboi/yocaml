let execute
    : type repo.
      (module Runtime.RUNTIME)
      -> (module Mirage_clock.PCLOCK)
      -> (module Irmin.S
            with type Schema.Branch.t = string
             and type Schema.Path.t = string list
             and type Schema.Contents.t = string
             and type repo = repo)
      -> ?branch:string
      -> ?author:string
      -> ?author_email:string
      -> repo
      -> 'a Yocaml.Effect.t
      -> 'a Lwt.t
  =
 fun (module Source)
     (module Pclock)
     (module Store)
     ?branch
     ?author
     ?author_email
     repository
     program ->
  let module R0 =
    Runtime.Make (Source) (Pclock) (Store)
      (struct
        type nonrec repo = repo

        let branch = Option.value ~default:"master" branch
        let author = author
        let author_email = author_email
        let repository = repository
      end)
  in
  let module R1 = Yocaml.Runtime.Make (R0) in
  R1.execute program
;;
