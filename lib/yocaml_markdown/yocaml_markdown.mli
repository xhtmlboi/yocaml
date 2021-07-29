(** Describing documents using a Markup language is very common in the
    {i Blogosphere} (rather than describing all the formatting of document
    content in HTML, using <p>, <strong> and co).

    [Markdown] is a very popular markup language (did you get the joke,
    up/down) and, fortunately, OCaml has several very good libraries for
    turning Markdown into HTML. This library is a wrapper around
    {{:https://github.com/ocaml/omd} omd}, an excellent Markdown conversion
    library. *)

(** {1 API} *)

(** An arrow that produces an HTML (as a String) from a String in Markdown.*)
val to_html : (string, string) Yocaml.Build.t

(** Since it is pretty common to deal with document and Metadata, which are
    generally a pair of [Metadata] and [the content of the document],
    [content_to_html] is a function that produce an arrow which apply the
    Markdown conversion on the second element (the content).

    [content_to_html ()] is equivalent of [Yocaml.Build.snd to_html]. *)
val content_to_html : unit -> ('a * string, 'a * string) Yocaml.Build.t
