(** Description of a build rule. *)

open Aliases

(** {1 Type}

    [('a, 'b) Build.t] describes a special case of a function. Indeed, it is a
    function of ['a -> b Effect.t] to which a dependency link ({!type:Deps.t})
    is attached. *)

type ('a, 'b) t

(** {1 Action on rules} *)

(** [dependencies rule] returns the dependencies of the [rule]. *)
val dependencies : ('a, 'b) t -> Deps.t

(** [task rule] returns the task of the [rule]. *)
val task : ('a, 'b) t -> 'a -> 'b Effect.t

(** {1 Building rules}

    Combiners to build rules (increasingly complex, to infinity and beyond). *)

(** [watch file] generates an Arrow that adds a file to the dependency list
    without reading it. It can be useful for making file generation dependent
    on other files. For example :

    {[ let track_binary_update = watch Sys.argv.(0) ]}

    Which adds the generating binary to the list of dependencies. *)
val watch : filepath -> (unit, unit) t

(** [create_file target build_rule] executes the [build_rule] task if the
    dependencies are not up-to-date for [target] (or [target] does not exist). *)
val create_file : filepath -> (unit, string) t -> unit Effect.t

val fold_dependencies
  :  ('a, 'b) t list
  -> (('c -> 'd Effect.t) -> ('c, 'd) t) * ('a -> 'b Effect.t) list

(** Copy files from a destination to a source, taking account of dependencies. *)
val copy_file : ?new_name:string -> filepath -> into:filepath -> unit Effect.t

(** Arrow version of a file reader. *)
val read_file : filepath -> (unit, string) t

(** Pipe an arrow to an other and concat the results. *)
val pipe_content : ?separator:string -> filepath -> (string, string) t

(** Concat two files. *)
val concat_files
  :  ?separator:string
  -> filepath
  -> filepath
  -> (unit, string) t

(** Process a string as a Markdown document. The markdown generation uses the
    excellent {{:https://github.com/ocaml/omd} OMD} library. *)
val process_markdown : (string, string) t

(** Read a file and parse metadata in the header. If the metadata is invalid,
    the arrow will throw an error. The Arrow uses
    {{:https://github.com/avsm/ocaml-yaml} ocaml-yaml} for defining metadata.
    See {!module:Metadata}. *)
val read_file_with_metadata
  :  (module Metadata.PARSABLE with type t = 'a)
  -> filepath
  -> (unit, 'a * string) t

(** Applies a file as a template. (and replacing the metadata). Once the
    content has been transformed, the arrow returns a pair containing the
    metadata and the file content injected into the template. The Arrow uses
    {{:https://github.com/rgrinberg/ocaml-mustache} ocaml-mustache} as
    template engine. *)
val apply_as_template
  :  (module Metadata.INJECTABLE with type t = 'a)
  -> ?strict:bool
  -> filepath
  -> ('a * string, 'a * string) t

(** When a template should be applied without body. *)
val without_body : 'a -> 'a * string

(** {1 Included Arrow combinators}

    A [build rule] respects the interface of an [Arrow Choice] (which implies
    [Category] and [Arrow], by construction), for ergonomic reasons, the
    combinators of the three classes are included in the module toplevel. *)

include Preface.Specs.ARROW_CHOICE with type ('a, 'b) t := ('a, 'b) t
