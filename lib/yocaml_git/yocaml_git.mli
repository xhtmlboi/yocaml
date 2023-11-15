(** Allows you to define a Runtime that uses Git as a compilation target. *)

(** {1 API} *)

(** Executes a YOCaml program using a given Runtime for processing with
    [Source] and using a [Git Store] as compilation target. What the YOCaml
    progam generates is compared with what you can view from the given remote
    repository and updated with a new Git commit. Then, we [push] these
    changes to the remote repository.

    [ctx] contains multiple informations needed to initiate a communication
    with the given remote repository. See [Git_unix.ctx] for more details. *)
val execute
  :  (module Runtime.RUNTIME)
  -> (module Mirage_clock.PCLOCK)
  -> ctx:Mimic.ctx
  -> ?author:string
  -> ?email:string
  -> ?comment:string
  -> string
  -> 'a Yocaml.Effect.t
  -> ('a, [> `Msg of string ]) result Lwt.t
