(* YOCaml a static blog generator.
   Copyright (C) 2024 The Funkyworkers and The YOCaml's developers

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

open Yocaml

(* Here's an example of a minimalist blog that takes advantage of the Archetypes
   exposed by YOCaml to quickly bootstrap an application. The code is
   extensively commented to help you understand the different stages.

   In general, you can, of course, split your programme into different modules
   (and different files). But for the sake of simplicity in this example, we'll
   stick to a single file.
*)

(* Currently, the generator code lives in a sub-folder of the YOCaml Project,
   but it has been designed to work from the root of the project (where the opam
   files are located) via the command:
   [dune exec examples/simple-blog/bin/simple_blog.exe]

   The generated site will be located in [examples/simple-blog/_build]. *)

(* The blog will support articles (logic!), pages (for example to describe an
   [about] page) and an index (the home page). And here's a representation of
   the file system:

   yocaml/examples/simple-blog/
      |- bin       - The directory containing the generator sources
      |- articles  - The directory where markdown articles are written
      |- pages     - The directory containing the pages, written in markdown
      |- templates - The directory where the templates are located
      |- index.md  - A special page that deal with indexing stuff
      |_ _build    - The directory where the blog will be created
         |- css        - Where the css style sheets will be copied
         |- articles   - Where articles will be generated (in html)
         |- Pages will be generated in [_build], at the root
         |_ index.html


   It's a fairly common organisation. There are other artefacts that are not
   documented (such as the cache) which, for reasons of simplicity, will also be
   generated in the [_build] directory (at the root of the generated site).
*)

(* Firstly, we're going to create resolvers to facilitate access to files and to
   describe the targets to which we want to create these files. Paths are
   described using the [Yocaml.Path] module. (Which, broadly speaking, makes it
   easy to transform a list into a filesystem path).*)

(* As the generator will be invoked from the root of the project, we create a
   path which describes the concrete path to take us from the root to the
   directory. *)
let source_root = Path.rel [ "examples"; "simple-blog" ]

(* Now, for the sake of convenience, we're going to build two modules, [Source]
   and [Target], which will describe the source paths (where to find the files
   that will be used to build artifacts) and the targets (which will be used to
   describe the paths to the artifacts). *)

module Source = struct
  (* Describes the source paths. *)

  (* The directory containing the CSS files (which should be copied to the
     [_build/css] directory). *)
  let css = Path.(source_root / "css")

  (* The directory containing pages in Markdown. *)
  let pages = Path.(source_root / "pages")

  (* The directory containing articles in Markdown. *)
  let articles = Path.(source_root / "articles")

  (* The location of the index (a kind of page for indexing articles). *)
  let index = Path.(source_root / "index.md")

  (* The directory containing templates files. *)
  let templates = Path.(source_root / "templates")

  (* An helper to quickly reference template *)
  let template file = Path.(templates / file)

  (* Reference the binary that runs the program, which can be used to be tracked
     as a dependency in a task (rebuild the blog if the binary has changed). *)
  let binary = Path.rel [ Sys.argv.(0) ]
end

module Target = struct
  (* Describes the paths where things will be generated. *)

  (* As the target directory is in the source directory, we start by describing
     a target root. *)
  let target_root = Path.(source_root / "_build")

  (* To deal with dynamic dependencies, you need to maintain a state in a cache.
     For ease of use, this cache is stored in the target directory. *)
  let cache = Path.(target_root / "cache")

  (* CSS files will be copied into [_build/css]. *)
  let css = Path.(target_root / "css")

  (* Pages will be generated in the root of the generated blog. *)
  let pages = target_root

  (* Articles will be generated in [_build/articles]. *)
  let articles = Path.(target_root / "articles")

  (* As we often process markdown files that we want to transform into html
     files, this function acts as a helper to quickly relocate a given file name
     in a given directory and change its extension to [.html]. *)
  let as_html into file =
    file |> Path.move ~into |> Path.change_extension "html"
end

(* Now that we have utility functions for our targets and our sources, we can
   build rules that will copy files from the source to the target and transform
   files from the source and save them in the target. *)

(* Let's start with CSS. There is no particular process, we just want to copy a
   CSS file from the source to the target, so we can use the file copy action,
   which proceeds without ceremony to a copy-paste. *)
let process_css_file = Action.copy_file ~into:Target.css

(* Now that we can copy/paste ONE file, let's batch the action to copy/paste all
   CSS files from our source to our target.

   - only: Allows specifying that we only want to act on files.
   - where: Allows specifying that the batched action
     will only be executed on files with the ".css" extension *)
let process_css_files =
  Action.batch ~only:`Files ~where:(Path.has_extension "css") Source.css
    process_css_file

(* Now that we can handle CSS files, we will handle pages using the description
   of a generic page described in the Archetype module. Like for CSS files, we
   will start by describing the task to build a single page, then we will handle
   batching the action! *)

(* Building pages or articles generally follows the same pattern:
   - We construct a file using Action.write_static_file
     (because the file will have no dynamic dependencies)
   - The task will add the binary to the dependencies (so that rewriting
     the generator triggers a modification)
   - We read the file and its metadata
   - We modify what needs to be modified; in the case of pages and articles,
     we transform the Markdown read into HTML
   - We apply, in cascade, the succession of templates
   - We keep only the content (by dropping the metadata)
*)

(* Unlike style sheets, it's not enough to "copy the file"; we need to write a
   new file. *)
let process_page file =
  (* Firstly, we calculate its new name using the [as_html] function, informing
     it that we will write the file to the root of our target. *)
  let file_target = Target.(as_html pages file) in

  (* Now, we can write the file using the [write_static_file] action, which will
     execute a task. We use [write_static_file] because in our example,
     constructing a page involves no dynamic dependencies.

     The operators for composing tasks are found in the Task module, Hence its
     opening. *)
  let open Task in
  Action.write_static_file file_target
    ((* We add the binary to the dependencies because we assume that if the
        binary changes, we would want to replay the task. Building a task simply
        involves composing (often with [>>>]) smaller tasks, and it's these
        tasks that build a dependency tree. *)
     Pipeline.track_file Source.binary
    (* Now we read the file and its metadata. We pass the module that describes
       the expected metadata (Archetype.Page) to ensure validation, and this
       step will return a pair containing as the first element the metadata and
       as the second element the file content. *)
    >>> Yocaml_yaml.Pipeline.read_file_with_metadata
          (module Archetype.Page)
          file
    (* Now, we will transform the file content from Markdown to HTML. The
       [content_to_html] function operates on the second element of the previous
       task. At this stage, we will still have a pair, except that the content
       of our file will have been converted from Markdown to HTML.*)
    >>> Yocaml_omd.content_to_html ()
    (* Now we can apply a template. Just as we read and validate metadata using
       the Archetype.Page module, we will use it to inject them into a Jingoo
       template. And we can use our utility function in Source to easily
       retrieve the template. At this stage, we will still have a pair, except
       that the content of our file will have been injected into a template. *)
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Page)
          (Source.template "page.html")
    (* Now that our content has been injected into our page template, we can
       insert this page into the template of the general layout. The idea is to
       apply the templates in cascade. (However, the order may depend on how the
       template is constructed). *)
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Page)
          (Source.template "layout.html")
    (* At this stage, we have a pair with our metadata and the complete content
       of our file. However, since our document has been injected into the
       template with its metadata, we no longer need the metadata (as the
       [write_static_file] action writes a string). We can use [drop_first()]
       which will keep only the content of our file. *)
    >>> drop_first ())

(* Now that we can process a page, we can batch all our pages in the same way we
   proceeded to process CSS files, using [batch]. This time, we will also
   iterate only over files. However, we will only handle files with the [.md]
   extension to process only Markdown files. *)
let process_pages =
  Action.batch ~only:`Files ~where:(Path.has_extension "md") Source.pages
    process_page

(* Now, let's focus on articles. We will be much less verbose as we will quickly
   realize that, in broad strokes, it's quite similar to what we did for pages.
   Like with CSS and pages, we'll first handle a single case, the processing of
   an article, which will construct a static file following the same logic as
   for building a page. *)

let process_article file =
  (* We start by calculating the filename where the article page will be
     constructed, just like for the pages. *)
  let file_target = Target.(as_html articles file) in

  (* As for Pages, we can write the file using the [write_static_file] action,
     which will execute a task. We use [write_static_file] because in our
     example, constructing a page involves no dynamic dependencies. *)
  let open Task in
  Action.write_static_file file_target
    ((* As for Pages, we want to track the binary.  *)
     Pipeline.track_file Source.binary
    (* Just like with pages, we read the file and its metadata. This time we use
       the Article archetype, which exposes minimum fields to construct articles
       (a title, a synopsis, a date, etc.). The process is exactly the same as
       before, for pages. *)
    >>> Yocaml_yaml.Pipeline.read_file_with_metadata
          (module Archetype.Article)
          file
    (* We convert the Markdown content to HTML. *)
    >>> Yocaml_omd.content_to_html ()
    (* We apply the cascade of templates starting with that of an article.*)
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Article)
          (Source.template "article.html")
    (* We can apply the general template, which is possible because an Article
       inherits from a page. *)
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Article)
          (Source.template "layout.html")
    (* We can finish by dropping our metadata! *)
    >>> drop_first ())

(* Now we can batch our article processing on all files with the [.md] extension
   in the directory of our articles, and that's it. *)
let process_articles =
  Action.batch ~only:`Files ~where:(Path.has_extension "md") Source.articles
    process_article

(* Now we're going to build a slightly more complex page: the Index. This page
   differs from the previous ones in that it depends on the contents of a
   directory. Archetypes provide a fairly simple way of building an article
   index using the [Archetype.Articles] module. Let's see how to use the utility
   functions. *)
let process_index =
  (* Firstly, we're going to specify the source (our [index.md]) and the target,
     our [index.html] which will be built at the root of our generated blog.
     It's not very different from what we did in previous actions.*)
  let file = Source.index in
  let file_target = Target.(as_html pages file) in

  (* Next, you need to read all the articles in the [articles/] directory.
     Fortunately, the [Archetype.Articles] module provides a task (which acts on
     metadata) to transform page metadata into article metadata. The function
     takes :
     - A module for reading metadata. Here we use the [Yocaml_yaml] module.
     - A file path predicate. Here we only want markdown files
     - A function for calculating a URL from a file, here we're just going to reuse
       our `as_html` function except that we're going to tell it that it's pointing
       to ["/articles"] (so the URL is absolute)
     - directory where to look for the articles.

     The function can be configured more finely, but please refer to its
     documentation for more information. *)
  let compute_index =
    Archetype.Articles.compute_index
      (module Yocaml_yaml)
      ~where:(Path.has_extension "md")
      ~compute_link:(Target.as_html @@ Path.abs [ "articles" ])
      Source.articles
  in
  (* Now that we have a task that allows us to process our metadata and read
     our articles, the rest of the pipeline is quite similar to what we were
     doing before. *)
  let open Task in
  (* We use `write_dynamic_file` because, as we will see, we will need to
     specify to our generator that sometimes it should compute an effect to
     determine whether a file should be updated or not. *)
  Action.write_dynamic_file file_target
    ((* As for Pages, we want to track the binary.  *)
     Pipeline.track_file Source.binary
    (* We read a file with its metadata, as our index is a regular page, we read
       it as if it were a page. *)
    >>> Yocaml_yaml.Pipeline.read_file_with_metadata
          (module Archetype.Page)
          file
    (* We convert the Markdown content to HTML. *)
    >>> Yocaml_omd.content_to_html ()
    (* And here, we want to modify our metadata, which is currently of type
       [Page.t], to metadata of type [Articles.t] (to have the list of our
       articles). We will apply our task [compute_index] only to our metadata
       (thus to the first element of the pair that we maintain in our pipeline),
       using the function [first]: *)
    >>> first compute_index
    (* Now we can apply our cascade of templates. We start with the index
       template *)
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Articles)
          (Source.template "index.html")
    (* Then we apply the general template, just like in the previous examples *)
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Articles)
          (Source.template "layout.html")
    (* We can finish by dropping our metadata! *)
    >>> drop_first ()
    (* But since we are building a 'dynamic' file and not a 'static' one, we
       need to return, in addition to the content, a set of 'dynamic'
       dependencies. Normally, we could ask our task to dynamically calculate
       these dependencies, but here, we know that it's the directory where our
       articles are located (to rebuild the index if we add a new file) [1] *)
    >>> with_dynamic_dependencies [ Source.articles ])

(* Now, we can group all our processes together! Each Action (process_xxxx) is
   actually a function that takes a cache as an argument and returns an effect
   that acts on the cache. But the cache is hidden in our actions because the
   order in which the arguments are defined allows us to compose tasks without
   worrying about the cache.

   So, the idea is to first "open the cache" (if it doesn't exist, the cache
   will be empty), then pipe each action using [>>=], and finally end by saving
   the cache.
*)
let process_all () =
  (* The operators for composing effects are found in the Eff module (Effect is,
     in fact a reserved module for OCaml 5 Effect Handling), Hence its
     opening. *)
  let open Eff in
  (* First, we will load the cache. If it does not exist, the function will
     return an empty cache (wrapped in an effect). *)
  Action.restore_cache Target.cache
  (* Now we can execute all the batches of actions we had previously defined.
     The order here doesn't matter; they will be executed sequentially. *)
  >>= process_css_files
  >>= process_pages
  >>= process_articles
  >>= process_index
  (* Once we have processed all our files, our cache will be passed from action
     to action, being updated. So, we can save our cache to be used in the next
     run of our generator! *)
  >>= Action.store_cache Target.cache

(* We're almost done! Now that we have a function that "builds" our blog, all we
   need to do is pass it to a Runtime for it to execute "concretely." It's as
   simple as that. *)
let () = Yocaml_unix.run process_all

(* And there you have it, our blog is now finished. To be able to build your
   site from scratch, with even more flexibility, we invite you to read through
   the various templates to understand how we interact with the blog's UI, and
   of course, the Archetype module to understand how to create your own data
   models! (However, be warned, the Archetype module is a bit dense, to allow by
   default for handling a wide range of "classic" use cases when building a
   blog.) *)

(* [1] In fact, the index could be resolved statically because we realize that
   the [compute_index] task does not return any dependencies. So the
   dependencies of the task, here, the [Source.articles] directory are known
   statically. This is possible because the [Eff.mtime] function is a bit
   smarter than the Unix one (by treating the modification date of a directory
   as the greatest modification date of its children, recursively). However, if
   the dependencies of a target had been calculated from reading a file, for
   example, our task would not have been able to add it 'at the end'. We will
   write examples taking advantage of this approach in the near future. *)
