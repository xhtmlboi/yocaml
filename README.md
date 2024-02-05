# YOCaml

> YOCaml is a static site generator, mostly written in OCaml.

## Dev setup

We suggest creating a local switch to create a sandboxed development
environment.

```ocaml
opam update
opam switch create . ocaml-base-compiler.5.1.1 --deps-only -y
eval $(opam env)
opam install . --deps-only --with-doc --with-test --with-dev-setup -y
```

When the environment is prepared, `dune build` should build the project.
