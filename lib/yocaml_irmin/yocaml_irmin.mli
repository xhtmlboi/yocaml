(** Allows you to define a Runtime that uses an Irmin [Store] (e.g. Git) as a
    compilation target. *)

(** {1 API} *)

(** Executes a YOCaml program using a given Runtime for processing with
    [Source] and using an [Irmin Store] as compilation target. *)
val execute
  :  (module Yocaml.Runtime.RUNTIME)
  -> (module Irmin.S
        with type branch = string
         and type key = string list
         and type contents = string)
  -> ?branch:string
  -> ?author:string
  -> ?author_email:string
  -> Irmin.config
  -> 'a Yocaml.Effect.t
  -> 'a
