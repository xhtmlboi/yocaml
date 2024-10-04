# A Webring

A very simple example of a Webring built using **YOCaml**. The example is much
less documented than [Simple blog](../simple-blog) (which can be used as a
tutorial) but it shows how to use `yocaml_syndication` to create an
[OPML](http://opml.org/spec2.opml#1629041888000) subscription list and how to
build your own data model without relying solely on those proposed by the
archetypes.

## Information

The example serves as an illustration of how to build more exotic projects with
**YOCaml** and no particular OPAM set-up is required (if the development
environment is properly set up) and should be used _only_ to understand how to
build stuff.

## Launch of the webring

Generation is designed to be launched from the root of the project with the
command: `dune exec examples/webring-unix/bin/webring_unix.exe` which will
generate the blog content in the following directory:
`./examples/webring-unix/_build`. You can also pass `serve [PORT]` to launch the
development server.
