(** Describing documents using a Markup language is very common in the
    {i Blogosphere} (rather than describing all the formatting of document
    content in HTML, using <p>, <strong> and co).

    [Common Mark] is a very popular markup language (did you get the joke,
    up/down) and, fortunately, OCaml has several one very good libraries for
    turning Common Mark into HTML. This library is a wrapper around
    {{:https://github.com/dbuenzli/cmarkit} cmarkit}, an excellent Common Mark
    conversion library. *)

(** {1 API} *)

(** An arrow that produces an HTML (as a String) from a String in Common Mark.*)
val to_html : strict:bool -> (string, string) Yocaml.Build.t

(** Since it is pretty common to deal with document and Metadata, which are
    generally a pair of [Metadata] and [the content of the document],
    [content_to_html] is a function that produce an arrow which apply the
    Common Mark conversion on the second element (the content).

    [content_to_html ()] is equivalent of [Yocaml.Build.snd to_html]. *)
val content_to_html : ?strict:bool -> unit -> ('a * string, 'a * string) Yocaml.Build.t
