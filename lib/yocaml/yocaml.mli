(** Here is the list of modules exposed by the YOCaml library. The concept
    behind this project is to offer, as a library, a set of tools to build
    pages. In other words, the end user, in this case me, would only have to
    build a new project in which Preface and YOCaml would be dependencies and
    then easily create his own static blog generator. It's likely that it
    won't be efficient or ergonomic, but it's a fun project to do in your
    spare time.

    Please refer to {{:../index.html#tutorial} the documentation index} for an
    example. *)

(** {1 Build system}

    [Build] is the main module of {e YOCaml}. It is used to describe rules
    attached to dependencies. A static site generator is a collection of
    ordered rules. (So it is probably not useful to use this project and it
    would be better to write everything with [make], [sed] and [awk]). *)

module Build = Build
module Deps = Deps

(** {1 Handling}

    {2 Effects Handling}

    In order to take advantage of {{:httsp://github.com/xvw/preface} Preface}
    (for fun and profit) YOCaml describes a list of effects to manage. As for
    errors, executable effects are centralised. *)

module Effect = Effect

(** {2 Errors Handling}

    Errors handling is mainly based on a biased version of [Result] and
    [Validation] offered by {{:httsp://github.com/xvw/preface} Preface}. *)

module Error = Error
module Try = Try
module Validate = Validate

(** {1 Runtime}

    A YOCaml program is a pure application that has, a priori, no dependence
    on the operating system. These dependencies are provided when a program is
    run (as declared in the [yocaml_unix] package). *)

module Runtime = Runtime

(** {1 Misc}

    Modules serving only internal interests. They are documented (and public)
    only for the purpose of clarifying the documentation. *)

module Lexicon = Lexicon
module Aliases = Aliases
module Util = Util
module Metadata = Metadata
module Key_value = Key_value
module Template = Template

(** {1 Included general stuff}

    {2 Included common util}

    There are always lots of little unreadable tools that I want to use...
    sometimes it improves readability... sometimes not. *)

include module type of Util (** @closed *)

(** {2 Included Effect plumbery}

    A page generation process usually involves composing and executing
    effects, so rather than constantly forcing the [Effect] module into user
    space, the module is injected into the high-level API. *)

include module type of Effect (** @closed *)
