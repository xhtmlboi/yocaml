(** {1 High-level API}

    The YOCaml high-level API. It is mainly these combiners that should be
    used to build static pages.

    {2 Composing and performing effects} *)

(** Runs a YOCaml program with the default handler. *)
val execute : 'a Yocaml.Effect.t -> 'a
