# YOCaml

> YOCaml is a static site generator, written in OCaml.

## Dev setup

We suggest creating a local switch to create a sandboxed development
environment.

```ocaml
opam update
opam switch create . --deps-only --with-doc --with-test --with-dev-setup -y
eval $(opam env)
```

When the environment is prepared, `dune build` should build the project.
