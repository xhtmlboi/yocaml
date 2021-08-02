# ![logo](misc/logo.png) YOCaml

The logo and name are the brainchild of [Biloumaster](https://github.com/BilouMaster).

> **YOCaml** is a static site generator, mostly written in OCaml. The project
> was started to offer some rather naive examples of how to use the
> [Preface](https://github.com/xvw/preface/) library. The generator is
> relatively flexible and is intended to be as generic as possible. To learn
> more about its construction, I redirect you to [the documentation
> page](https://yocaml.github.io/doc/yocaml/index.html).

- [Main page of the project](https://yocaml.github.io/doc/yocaml/index.html)
- [API Documentation](https://yocaml.github.io/doc/yocaml/Yocaml/index.html)
- [Tutorials and examples](https://yocaml.github.io/doc/yocaml/index.html#tutorial)
- [Credits](https://yocaml.github.io/doc/yocaml/index.html#credits)
- [Alternatives](https://yocaml.github.io/doc/yocaml/index.html#alternatives)

## Installation

Until [Preface](https://github.com/xvw/preface/) is released on
[OPAM](http://opam.ocaml.org/), **YOCaml** is only available by manual
installation using `pin`.
And in the `dune` file of your executable:

```common-lisp
(executable
 (name my_site)
 (promote (until-clean))
 (libraries yocaml yocaml_yaml yocaml_markdown yocaml_unix))
```

## Websites using YOCaml

| Url                                              | Author        | Sources                                       |
| ------------------------------------------------ | ------------- | --------------------------------------------- |
| [xhtmlboi.github.io](https://xhtmlboi.github.io) | **@xhtmlboi** | [Github](https://github.com/xhtmlboi/blogger) |
