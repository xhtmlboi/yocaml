# ![logo](misc/logo.png) YOCaml

The logo and name are the brainchild of [Biloumaster](https://github.com/BilouMaster).

> **YOCaml** is a static site generator, mostly written in OCaml. The project
> was started to offer some rather naive examples of how to use the
> [Preface](https://github.com/xvw/preface/) library. The generator is
> relatively flexible and is intended to be as generic as possible. To learn
> more about its construction, I redirect you to [the documentation
> page](https://xhtmlboi.github.io/yocaml/doc/yocaml/index.html).

- [Main page of the project](https://xhtmlboi.github.io/yocaml/doc/yocaml/index.html)
- [API Documentation](https://xhtmlboi.github.io/yocaml/doc/yocaml/Yocaml/index.html)
- [Tutorials and examples](https://xhtmlboi.github.io/yocaml/doc/yocaml/index.html#tutorial)
- [Credits](https://xhtmlboi.github.io/yocaml/doc/yocaml/index.html#credits)
- [Alternatives](https://xhtmlboi.github.io/yocaml/doc/yocaml/index.html#alternatives)

## Installation

Until [Preface](https://github.com/xvw/preface/) is released on
[OPAM](http://opam.ocaml.org/), **YOCaml** is only available by manual
installation:

```shell
opam pin add preface git+ssh://git@github.com/xvw/preface.git
opam pin add yocaml git+ssh://git@github.com/xhtmlboi/yocaml.git
opam pin add yocaml_unix git+ssh://git@github.com/xhtmlboi/yocaml.git
```

And in the `dune`` file of your executable:

```common-lisp
(executable
 (name my_site)
 (promote (until-clean))
 (libraries yocaml yocaml_unix))
```

## Website using YOCaml

| Url                                              | Author        | Sources                                       |
| ------------------------------------------------ | ------------- | --------------------------------------------- |
| [xhtmlboi.github.io](https://xhtmlboi.github.io) | **@xhtmlboi** | [Github](https://github.com/xhtmlboi/blogger) |
