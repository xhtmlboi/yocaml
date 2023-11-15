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

**YOCaml** is only available by manual installation using `pin`.
And in the `dune` file of your executable:

```common-lisp
(executable
 (name my_site)
 (promote (until-clean))
 (libraries yocaml yocaml_yaml yocaml_markdown yocaml_unix))
```

## Websites using YOCaml

| Url                                                                          | Author                                                     | Sources                                                           |
|------------------------------------------------------------------------------|------------------------------------------------------------|-------------------------------------------------------------------|
| [Angry Cusine Nerd](https://bastienduplessier.github.io/angry_cuisine_nerd/) | [@bastienDuplessier](https://github.com/BastienDuplessier) | [Github](https://github.com/BastienDuplessier/angry_cuisine_nerd) |
| [XHTMLBoy's Website](https://xhtmlboi.github.io/)                            | [@xhtmlboi](https://github.com/xhtmlboi)                   | [Github](https://github.com/xhtmlboi/blogger)                     |
| [LambdaLille History](https://github.com/lambdalille/talks)                  | [@xvw](https://github.com/xvw)                             | [Github](https://github.com/lambdalille/history)                  |
| [blog.osau.re](https://blog.osau.re)                                         | [@dinosaure](https://github.com/dinosaure)                 | [Github](https://github.com/dinosaure/blogger)                    |
| [xvw.lol](https://xvw.lol)                                                   | [@xvw](https://github.com/xvw)                             | [Github](https://github.com/xvw/capsule)                          |
| [Oxywa](https://hakimba.github.io/oxywa/)                                    | [@hakimba](https://github.com/Hakimba)                     | [Github](https://github.com/Hakimba/oxywa)                        |
| [Guillaume Petiot](https://guillaumepetiot.com/)                             | [@gpetiot](https://github.com/gpetiot/)                    | [Github](https://github.com/gpetiot/blogger)                      |
| [gemini://heyplzlookat.me/](https://www.heyplzlookat.me/)                    | [@Psi-prod](https://github.com/Psi-Prod/)                  | [Github](https://github.com/Psi-Prod/Capsule)                     |
| [Robur.coop](https://blog.robur.coop/)                                       | [@robur-coop](https://github.com/robur-coop)               | [git.robur.coop](https://git.robur.coop/robur/blog.robur.coop)                                                                  |
