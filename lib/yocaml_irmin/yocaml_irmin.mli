(** Allows you to define a Runtime that uses an Irmin [Store] (e.g. Git) as a
    compilation target. *)

(** {1 API} *)

(** Executes a YOCaml program using a given Runtime for processing with
    [Source] and using an [Irmin Store] as compilation target. *)
val execute
  :  (module Runtime.RUNTIME)
  -> (module Irmin.S
        with type Schema.Branch.t = string
         and type Schema.Path.t = string list
         and type Schema.Contents.t = string)
  -> ?branch:string
  -> ?author:string
  -> ?author_email:string
  -> Irmin.config
  -> 'a Yocaml.Effect.t
  -> 'a Lwt.t
