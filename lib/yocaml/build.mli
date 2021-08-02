(** Description of a build rule. *)

open Aliases

(** {1 Type}

    [('a, 'b) Build.t] describes a special case of a function. Indeed, it is a
    function of ['a -> b Effect.t] to which a dependency link ({!type:Deps.t})
    is attached. *)

type ('a, 'b) t

(** {1 Action on rules} *)

(** [get_dependencies rule] returns the dependencies of the [rule]. *)
val get_dependencies : ('a, 'b) t -> Deps.t

(** [get_task rule] returns the task of the [rule]. *)
val get_task : ('a, 'b) t -> 'a -> 'b Effect.t

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

(** Read a file and parse metadata in the header. If the metadata is invalid,
    the arrow will throw an error. The first module defines how to go from
    string to structured object (for example the module [Yocaml_yaml] which
    process Yaml) and the second one describes the parsed metadata (see:
    {!module:Metadata}). *)
val read_file_with_metadata
  :  (module Metadata.VALIDABLE)
  -> (module Metadata.READABLE with type t = 'a)
  -> filepath
  -> (unit, 'a * string) t

(** Applies a file as a template. (and replacing the metadata). Once the
    content has been transformed, the arrow returns a pair containing the
    metadata and the file content injected into the template. The first module
    describes how to make a metadata compliant with a template language (e.g.
    Mustache) and the second describes how to apply the template with
    variables.*)
val apply_as_template
  :  (module Metadata.INJECTABLE with type t = 'a)
  -> (module Metadata.RENDERABLE)
  -> ?strict:bool
  -> filepath
  -> ('a * string, 'a * string) t

(** When a template should be applied without body. *)
val without_body : 'a -> 'a * string

(**Sometimes it is necessary to calculate a page according to other pages, for
   example to make an index of articles. With [collection] you can separate
   this procedure into 3 steps.

   - First, it executes an effect that acts on a list
   - Then it goes through the list of collected data and applies an arbitrary
     arrow to it.
   - Finally, it applies an aggregate function to the collected list.

   For example, let's build our index by projecting the list of articles into
   the Articles metadata:

   {[
     let index =
       let open Build in
       let* articles =
         collection
           (read_child_files "articles/" (with_extension "md"))
           (fun source ->
             track_binary_update
             >>> Yocaml_yaml.read_file_with_metadata
                   (module Metadata.Article)
                   source
             >>^ fun (x, _) -> x, article_destination source)
           (fun x meta content ->
             x
             |> Metadata.Articles.make
                  ?title:(Metadata.Page.title meta)
                  ?description:(Metadata.Page.description meta)
             |> Metadata.Articles.sort_articles_by_date
             |> fun x -> x, content)
       in
       create_file
         (into destination "index.html")
         (track_binary_update
         >>> Yocaml_yaml.read_file_with_metadata
               (module Metadata.Page)
               "index.md"
         >>> Yocaml_markdown.content_to_html ()
         >>> articles
         >>> Yocaml_mustache.apply_as_template
               (module Metadata.Articles)
               "templates/list.html"
         >>> Yocaml_mustache.apply_as_template
               (module Metadata.Articles)
               "templates/layout.html"
         >>^ Stdlib.snd)
     ;;
   ]} *)
val collection
  :  'a list Effect.t
  -> ('a -> (unit, 'b) t)
  -> ('b list -> 'c -> 'd -> 'e)
  -> ('c * 'd, 'e) t Effect.t

(** {1 Included Arrow combinators}

    A [build rule] respects the interface of an [Arrow Choice] (which implies
    [Category] and [Arrow], by construction), for ergonomic reasons, the
    combinators of the three classes are included in the module toplevel. *)

include Preface.Specs.ARROW_CHOICE with type ('a, 'b) t := ('a, 'b) t
