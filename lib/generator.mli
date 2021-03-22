(** Executes the generation effect.*)

(** A generator takes as argument an effect (['a Effect.t]) and executes it
    with the default handler. This has the effect of creating the website. *)

val run : 'a Effect.t -> 'a
