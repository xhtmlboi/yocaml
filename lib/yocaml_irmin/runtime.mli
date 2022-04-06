module type CONFIG = sig
  type repo

  val branch : string
  val author : string option
  val author_email : string option
  val repository : repo
end

module type RUNTIME = Yocaml.Runtime.RUNTIME with type 'a t = 'a

module Make
    (Source : RUNTIME)
    (Pclock : Mirage_clock.PCLOCK)
    (Store : Irmin.S
               with type Schema.Branch.t = string
                and type Schema.Path.t = string list
                and type Schema.Contents.t = string)
    (Config : CONFIG with type repo = Store.repo) :
  Yocaml.Runtime.RUNTIME with type 'a t = 'a Lwt.t
