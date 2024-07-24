# Batching D2 generation

A very simple example that uses [d2](https://d2lang.com/) to generate diagrams
through the arbitrary command execution. The example request **d2 to be locally
installed**.

## Launch of the generation

Generation is designed to be launched from the root of the project with the
command: `dune exec examples/d2/bin/d2.exe` which will generate the
blog content in the following directory: `./examples/d2/_build`. You
can also pass `serve [PORT]` to launch the development server.
