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

   In order to be used from an Unix and an Eio runtime, the following functor
   build only the [process_all] function.
*)

module Make_with_target (S : sig
  val source : Path.t
  val target : Path.t
end) =
struct
  (* Firstly, we're going to create resolvers to facilitate access to files and to
     describe the targets to which we want to create these files. Paths are
     described using the [Yocaml.Path] module. (Which, broadly speaking, makes it
     easy to transform a list into a filesystem path).*)

  (* As the generator will be invoked from the root of the project, we create a
     path which describes the concrete path to take us from the root to the
     directory. *)
  let source_root = S.source

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
    let target_root = S.target

    (* To deal with dynamic dependencies, you need to maintain a state in a cache.
       For ease of use, this cache is stored in the target directory. *)
    let cache = Path.(target_root / "cache")

    (* Pages will be generated in the root of the generated blog. *)
    let pages = target_root

    (* Articles will be generated in [_build/articles]. *)
    let articles = Path.(target_root / "articles")

    (* Path for RSS1 feed. *)
    let rss1 = Path.(target_root / "rss1.xml")

    (* Path for RSS2 feed. *)
    let rss2 = Path.(target_root / "rss2.xml")

    (* Path for Atom feed. *)
    let atom = Path.(target_root / "atom.xml")

    (* As we often process markdown files that we want to transform into html
       files, this function acts as a helper to quickly relocate a given file name
       in a given directory and change its extension to [.html]. *)
    let as_html into file =
      file |> Path.move ~into |> Path.change_extension "html"
  end

  (* Export the target for being used outside of the library. *)
  let target = Target.target_root

  (* Now that we have utility functions for our targets and our sources, we can
     build rules that will copy files from the source to the target and transform
     files from the source and save them in the target. *)

  (* As we just want to move the entire directory of our CSS style sheets, we
     don't need to bother, we can just copy the CSS directory into our target! *)
  let process_css_files =
    Action.copy_directory ~into:Target.target_root Source.css

  (* Now that we can handle CSS files, we will handle pages using the description
     of a generic page described in the Archetype module. Like for CSS files, we
     will start by describing the task to build a single page, then we will handle
     batching the action! *)

  (* Building pages or articles generally follows the same pattern:
     - We construct a file using Action.Static.write_file_with_metadata
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

    (* Now, we can write the file using the [Static.write_file_with_metadata]
       action, which will execute a task. We use [Static.write_file_with_metadata]
       because in our example, constructing a page involves no dynamic dependencies.

       The operators for composing tasks are found in the Task module, Hence its
       opening. *)
    let open Task in
    Action.Static.write_file_with_metadata file_target
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
            (Source.template "layout.html"))

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

    (* As for Pages, we can write the file using the
       [Static.write_file_with_metadata] action,
       which will execute a task. We use [Static.write_file_with_metadata]
       because in our example, constructing a page involves no dynamic
       dependencies. *)
    let open Task in
    Action.Static.write_file_with_metadata file_target
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
      >>> Yocaml_omd.content_to_html_with_toc Archetype.Article.with_toc
      (* We apply the cascade of templates starting with that of an article.*)
      >>> Yocaml_jingoo.Pipeline.as_template
            (module Archetype.Article)
            (Source.template "article.html")
      (* We can apply the general template, which is possible because an Article
         inherits from a page. *)
      >>> Yocaml_jingoo.Pipeline.as_template
            (module Archetype.Article)
            (Source.template "layout.html"))

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

    let open Task in
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

    (* As for Pages and articles, we can write the file using the
       [Static.write_file_with_metadata] action, which will execute a task.
       We use [Static.write_file_with_metadata] because in our example, constructing
       the index involves no dynamic dependencies (because of a small trick). *)
    Action.Static.write_file_with_metadata file_target
      ((* As for Pages, we want to track the binary. But we're also going to track
          the directory containing the articles. Normally, the processing of
          articles seems to be a dynamic dependency (because we would
          theoretically have to read all the articles to decide whether or not to
          rebuild the index). But in fact, all the subtlety lies in the function
          that gives the modification date of a file/directory. The primitive that
          returns the [mtime] has a slightly special behaviour in the case of
          directories. It returns the 'largest' modification date of a directory's
          children. This makes it possible to statically track all the articles,
          trivially speaking.*)
       Pipeline.track_files [ Source.binary; Source.articles ]
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
            (Source.template "layout.html"))

  (* Now we're going to create the feeds. For the flex, we're going to create 3,
     Rss1, Rss2 and Atom (in real life, this isn't very useful :D).

     First, we'll describe some of the variables we'll be using in our three
     feeds:
  *)

  let feed_title = "My simple blog"
  let site_url = "https://yocaml.example"
  let feed_description = "My personnal simple blog written using YOCaml"

  (* Next, we're going to use an arrow very similar to [compute_index] (which is
     also used in the [compute_index] function), the [fetch] arrow, which allows
     us to fetch all our articles, without having to worry about injecting them
     into a page. Here we only want to use the list of articles to build feeds. So
     there's no need for page generation logic etc.


     As we know that we'll want to track the articles (and the binary) every time,
     we can pre-compose our arrow with a watcher.
  *)

  let fetch_articles =
    let open Task in
    Pipeline.track_files [ Source.binary; Source.articles ]
    >>> Archetype.Articles.fetch
          (module Yocaml_yaml)
          ~where:(Path.has_extension "md")
          ~compute_link:(Target.as_html @@ Path.abs [ "articles" ])
          Source.articles

  (* Now we'll simply use the different arrows offered by the Yocaml_syndication
     plugin. Now we're simply going to use the different arrows offered by the
     Yocaml_syndication plugin in the action of writing a static file! *)

  let rss1 =
    let open Task in
    Action.Static.write_file Target.rss1
      (fetch_articles
      >>> Yocaml_syndication.Rss1.from_articles ~title:feed_title ~site_url
            ~description:feed_description ~feed_url:"http://mysite.com/rss1.xml"
            ())

  (* Now we can repeat the same process for Rss2. *)

  let rss2 =
    let open Task in
    Action.Static.write_file Target.rss2
      (fetch_articles
      >>> Yocaml_syndication.Rss2.from_articles ~title:feed_title ~site_url
            ~description:feed_description ~feed_url:"http://mysite.com/rss2.xml"
            ())

  (* And finally Atom, which requires a little more plumbing (because it's a more
     flexible syndication format). *)

  let atom =
    let open Task in
    let authors =
      Yocaml.Nel.singleton
      @@ Yocaml_syndication.Person.make "The YOCaml community group"
    in
    Action.Static.write_file Target.atom
      (fetch_articles
      >>> Yocaml_syndication.Atom.(
            from_articles ~site_url ~authors ~title:(text feed_title)
              ~feed_url:"http://mysite.com/atom.xml" ()))

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
    Action.restore_cache ~on:`Source Target.cache
    (* Now we can execute all the batches of actions we had previously defined.
       The order here doesn't matter; they will be executed sequentially. *)
    >>= process_css_files
    >>= process_pages
    >>= process_articles
    >>= process_index
    >>= rss1
    >>= rss2
    >>= atom
    (* Once we have processed all our files, our cache will be passed from action
       to action, being updated. So, we can save our cache to be used in the next
       run of our generator! *)
    >>= Action.store_cache ~on:`Source Target.cache
end

module Make (S : sig
  val source : Path.t
end) =
Make_with_target (struct
  include S

  let target = Path.(source / "_build")
end)
