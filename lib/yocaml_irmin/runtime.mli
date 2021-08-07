module type CONFIG = sig
  val config : Irmin.config
  val branch : string
  val author : string option
  val author_email : string option
end

module Make
    (Source : Yocaml.Runtime.RUNTIME)
    (Store : Irmin.S
               with type branch = string
                and type key = string list
                and type contents = string)
    (Config : CONFIG) : Yocaml.Runtime.RUNTIME
