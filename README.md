# YOCaml

> YOCaml is framework for building static site generator, written in
> OCaml.

You will find a comprehensive tutorial on how to use YOCaml on the
[official website](https://yocaml.github.io/tutorial).

## Dev setup

We suggest creating a local switch to create a sandboxed development
environment.

```ocaml
opam update
opam switch create . --deps-only --with-doc --with-test --with-dev-setup -y
eval $(opam env)
```

When the environment is prepared, `dune build` should build the project.

### Useful commands

- `dune fmt` Format the entire code base according to the profile described in the `.ocamlformat` file.
- `dune test` Run the tests (for expectation tests, following the command with `dune promote` will regenerate the tests that produce outputs)

> Ensure that you have run `dune fmt` and `dune test` before waiting
> for your branch to be merged.

## Website using YOCaml

Here is a list of websites that use YOCaml, along with their
repositories. In addition, you will find some basic examples in the
[example](https://github.com/xhtmlboi/yocaml/tree/main/examples) directory.

| Website | Source |
| -- | -- |
| [YOCaml Tutorial](https://yocaml.github.io/tutorial/) | [Repository](https://github.com/yocaml/yocaml-www) |
| [Ring.muhokama](https://ring.muhokama.fun/) | [Repository](https://github.com/muhokama/ring) |
| [Gr-im](https://gr-im.github.io/) | [Repository](https://github.com/gr-im/site) |
| [Xvw](https://xvw.lol) | [Repository](https://github.com/xvw/capsule) |
| [Condor du plateau](https://site.condor-du-plateau.fr/) | [Repository](https://git.sr.ht/~tim-ats-d/site/) |
| [Maiste](https://maiste.fr) | [Repository](https://codeberg.org/maiste/maiste.fr) |
| [UnrealDev](https://unrealdev.xyz) | [Repository](https://github.com/six-shot/yocaml-portfolio) |


Please **feel free** to add your website to this list!
