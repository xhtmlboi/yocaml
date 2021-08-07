(** Centralization of the effects that can be performed. *)

(** {1 A bad faith preamble}

    To be beautiful and modern, this project separates the description of the
    programme from its interpretation. But as the composition is not really to
    my taste in Preface, I decided to centralize all the effects, like the
    errors, in one module.

    {e Ugh}, that sounds perfectly stupid... it would be like considering that
    you can only express one family of effects (you could call it ... [IO]).
    Don't panic, the first parameter of type [effect] allows you to make a
    selective choice when defining [Freer]. One could say that one takes
    advantage of the {e non-surjective} aspect of the constructors of a sum
    (thanks to the GADTs!). Well, I'd be lying if I said I was convinced it
    was a good approach, but at least it seems viable. *)

(** {1 Effects list}

    Boy, this type sounds like a hell of a lot of trouble to read! don't read
    it and go a little lower, there are kind of smarts constructors.*)

type (_, 'a) effects =
  | File_exists : Filepath.t -> (< file_exists : unit ; .. >, bool) effects
  | Target_exists :
      Filepath.t
      -> (< target_exists : unit ; .. >, bool) effects
  | Get_modification_time :
      Filepath.t
      -> (< get_modification_time : unit ; .. >, int Try.t) effects
  | Target_modification_time :
      Filepath.t
      -> (< target_modification_time : unit ; .. >, int Try.t) effects
  | Read_file :
      Filepath.t
      -> (< read_file : unit ; .. >, string Try.t) effects
  | Write_file :
      (Filepath.t * string)
      -> (< write_file : unit ; .. >, unit Try.t) effects
  | Read_dir :
      (Filepath.t
      * [< `Files | `Directories | `Both ]
      * Filepath.t Preface.Predicate.t)
      -> (< read_dir : unit ; .. >, Filepath.t list) effects
  | Log : (Log.level * string) -> (< log : unit ; .. >, unit) effects
  | Throw : Error.t -> (< throw : unit ; .. >, 'a) effects
  | Raise : exn -> (< raise_ : unit ; .. >, 'a) effects

(** {1 Global definition}

    Complete mechanism for describing programs by description and providing
    them with handlers (interpreters/runtime) for all effects modelled in type
    [t].
    {e (So absolutely not taking advantage of the slicing capability... It was
       well worth it!)} *)

(** {2 Freer monad over effects}

    All the plumbing for effects description/interpretation resides through a
    Freer monad (thanks Preface). Although this module is included below, I
    have taken the liberty of displaying it... for documentation purposes
    only.*)

module Freer :
  Preface_specs.FREER_MONAD
    with type 'a f =
          ( < file_exists : unit
            ; target_exists : unit
            ; get_modification_time : unit
            ; target_modification_time : unit
            ; read_file : unit
            ; write_file : unit
            ; read_dir : unit
            ; log : unit
            ; throw : unit
            ; raise_ : unit >
          , 'a )
          effects

(** {2 Performing effects}

    Once described (or/and specialised), the effects must be produced in a
    programme description. To transform the description of an effect (a value
    of type {!type:Effect.effect}) into the execution of this effect, thus a
    value of type {!type:Effect.t}), the [perform] function is used.

    {3 Filesystem}

    In generating a static blog, having control over the file system seems to
    be a minimum! *)

(** [file_exists path] should be interpreted as returning [true] if the file
    denoted by the file path [path] exists, [false] otherwise. *)
val file_exists : Filepath.t -> bool Freer.t

(** [target_exists path] should be interpreted as returning [true] if the file
    denoted by the file path [path] exists, [false] otherwise. *)
val target_exists : Filepath.t -> bool Freer.t

(** [get_modification_time path] should be interpreted as returning, as an
    integer, the Unix time ([mtime] corresponding to the modification date of
    the file denoted by the file path [path]. *)
val get_modification_time : Filepath.t -> int Try.t Freer.t

(** [target_modification_time path] should be interpreted as returning, as an
    integer, the Unix time ([mtime] corresponding to the modification date of
    the file denoted by the file path [path]. *)
val target_modification_time : Filepath.t -> int Try.t Freer.t

(** [read_file path] should be interpreted as trying to read the contents of
    the file denoted by the file path [path]. At the moment I'm using strings
    mainly out of laziness, and as I'll probably be the only user of this
    library... it doesn't matter! *)
val read_file : Filepath.t -> string Try.t Freer.t

(** [write_file path content] should be interpreted as trying to write
    [content] to the file denoted by the file path [path]. In my understanding
    of the system, the file will be completely overwritten if it already
    exists. Once again I am using strings, but this time it is not laziness,
    it is to be consistent with [read_file]. *)
val write_file : Filepath.t -> string -> unit Try.t Freer.t

(** Get a list of all children of a path. *)
val read_children
  :  Filepath.t
  -> Filepath.t Preface.Predicate.t
  -> Filepath.t list Freer.t

(** Get a list of all child files of a path (exclude dirs). *)
val read_child_files
  :  Filepath.t
  -> Filepath.t Preface.Predicate.t
  -> Filepath.t list Freer.t

(** Get a list of all child directories of a path (exclude files). *)
val read_child_directories
  :  Filepath.t
  -> Filepath.t Preface.Predicate.t
  -> Filepath.t list Freer.t

(** Same of [read_children] but searching through a list of directories.*)
val collect_children
  :  Filepath.t list
  -> Filepath.t Preface.Predicate.t
  -> Filepath.t list Freer.t

(** Same of [read_child_files] but searching through a list of directories.*)
val collect_child_files
  :  Filepath.t list
  -> Filepath.t Preface.Predicate.t
  -> Filepath.t list Freer.t

(** Same of [read_child_directories] but searching through a list of
    directories.*)
val collect_child_directories
  :  Filepath.t list
  -> Filepath.t Preface.Predicate.t
  -> Filepath.t list Freer.t

(** [process_files path predicate action] performs sequentially [action] on
    each files which satisfies [predicate]. *)
val process_files
  :  Filepath.t list
  -> Filepath.t Preface.Predicate.t
  -> (Filepath.t -> unit Freer.t)
  -> unit Freer.t

(** {3 Logging}

    Even if it would be possible to limit our feedback with the user to simply
    returning an integer ({e El famoso Unix Return})... it would still be more
    convenient to display feedback to the user on the stage the program is in,
    right? *)

(** [log level message] should be interpreted as writing (probably to standard
    output) a message associated with a log level. To look good, the colour
    should change according to the log level, it would look more professional!*)
val log : Log.level -> string -> unit Freer.t

(** [trace message] is an alias of [log Aliases.Trace]. *)
val trace : string -> unit Freer.t

(** [debug message] is an alias of [log Aliases.Debug]. *)
val debug : string -> unit Freer.t

(** [info message] is an alias of [log Aliases.Info]. *)
val info : string -> unit Freer.t

(** [warning message] is an alias of [log Aliases.Warning]. *)
val warning : string -> unit Freer.t

(** [alert message] is an alias of [log Aliases.Alert]. *)
val alert : string -> unit Freer.t

(** {3 Open bar}

    When we are in the context of an IO, ahem, effect execution, it's open
    bar, we can do whatever we want, like throwing exceptions galore! *)

(** [throw error] should be interpreted as... "fire, fire, what to do using an
    Error!". *)
val throw : Error.t -> 'a Freer.t

(** [raise_ exn] should be interpreted as... "fire, fire, what to do using an
    exception!". *)
val raise_ : exn -> 'a Freer.t

(** {3 Effects composition} *)

(** Collapses sequentially YOCaml program. [sequence ps f p] produces a
    program which performs [p] followed by [f ps]. A common usage is
    [p |> sequences ps f]. *)
val sequence
  :  'a list Freer.t
  -> ('a -> 'b -> 'b Freer.t)
  -> 'b Freer.t
  -> 'b Freer.t

(** {2 Included Freer combinators}

    As mentioned above, the plumbing of program description and program
    handling is provided through a Freer Monad, a technique that aims to
    describe a free build over a Left Kan extension. Although the presence of
    {e slicing} allows for the construction of specialised effects handlers,
    in the use case of this blog generator, the effects I propagate turn out
    to be exactly those I have described in my complete effects list.
    Coicindance, I don't think so!

    It therefore seems logical (not to say ergonomic) to introduce the Freer
    interface in the toplevel of the [Effect] module. But as the interface is
    long and tiring to read, I place it at the end of the module! *)

include
  Preface_specs.FREER_MONAD
    with type 'a f = 'a Freer.f
     and type 'a t = 'a Freer.t

module Traverse :
  Preface.Specs.TRAVERSABLE
    with type 'a t = 'a Freer.t
     and type 'a iter = 'a list
