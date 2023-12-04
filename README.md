# YOCaml

> YOCaml is a static site generator, mostly written in OCaml. The project was
> started to offer some rather naive examples of how to use the
> [Preface](https://github.com/xvw/yocaml) library. The generator is relatively
> flexible and is intended to be as generic as possible.

## Dev setup

We suggest creating a local switch to create a sandboxed development
environment.

```ocaml
opam update
opam switch create . ocaml-base-compiler.5.1.0 --deps-only -y
eval $(opam env)
opam install . --deps-only --with-doc --with-test --with-dev-setup -y
```

When the environment is prepared, `dune build` should build the project.
