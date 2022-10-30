(** Allows you to define a Runtime that uses an Irmin [Store] (e.g. Git) as a
    compilation target. *)

(** {1 API} *)

(** Executes a YOCaml program using a given Runtime for processing with
    [Source] and using an [Irmin Store] as compilation target. *)
val execute
  :  (module Runtime.RUNTIME)
  -> (module Mirage_clock.PCLOCK)
  -> ctx:Mimic.ctx
  -> string
  -> 'a Yocaml.Effect.t
  -> 'a Lwt.t
