module type CONFIG = sig
  val config : Irmin.config
  val branch : string
  val author : string option
  val author_email : string option
end

module type RUNTIME = Yocaml.Runtime.RUNTIME with type 'a t = 'a

module Make
    (Source : RUNTIME)
    (Store : Irmin.S
               with type Schema.Branch.t = string
                and type Schema.Path.t = string list
                and type Schema.Contents.t = string)
    (Config : CONFIG) : Yocaml.Runtime.RUNTIME with type 'a t = 'a Lwt.t
