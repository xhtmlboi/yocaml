module type CONFIG = sig
  val config : Irmin.config
  val branch : string
  val author : string option
  val author_email : string option
end

module type LWT_RUN = sig
  val run : 'a Lwt.t -> 'a
end

module Make
    (Source : Yocaml.Runtime.RUNTIME)
    (Store : Irmin.S
               with type branch = string
                and type key = string list
                and type contents = string)
    (Lwt_main : LWT_RUN)
    (Config : CONFIG) : Yocaml.Runtime.RUNTIME
