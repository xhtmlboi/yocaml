### unreleased

#### Yocaml

- Add `Toc.traverse` for building your own TOC string [gr-im](https://github.com/gr-im)

#### Yocaml_markdown

- Reintroduce the package to have a strong way to deal with Markdown and Syntax Highlighting (It probably made `yocaml_omd` and `yocaml_cmarkit` obsolete) [gr-im](https://github.com/gr-im)

#### Yocaml_cmarkit

- Add a regular function to compute TOC [gr-im](https://github.com/gr-im)

### v2.4.0 2025-08-11 Nantes (France)

#### Yocaml

- Add `Log.src` for logging (by [xvw](https://xvw.lol))
- Add template chain (by [xvw](https://xvw.lol))
- Add Sexp control (by [xvw](https://xvw.lol))
- Add `field` and some combinators for validating record field (that unify `required`, `optional` and `optional_or`) (by [xvw](https://xvw.lol))
- Support snapshots (by [xhtmlboi](https://github.com/xhtmlboi))
- Small improvement of unicode special char for slug (by [xvw](https://xvw.lol))

#### Yocaml_cmarkit

- Intermediate Task added to progressively build a document and apply arbitrary arrows. (by [xhtmlboi](https://github.com/xhtmlboi))

#### Yocaml_jingoo

- Support snapshots (by [xhtmlboi](https://github.com/xhtmlboi))

#### Yocaml_mustache

- Support snapshots (by [xhtmlboi](https://github.com/xhtmlboi))

### v2.3.0 2025-05-25 Nantes (France)

#### Yocaml

- Fix `Yocaml.Datetime.max` (by [xvw](https://xvw.lol))
- Remove occurences of `gitlab` (and outdated repositories) in examples (by [xhtmlboi](https://github.com/xhtmlboi))
- Be kind about `eio` dependencies (by [xhtmlboi](https://github.com/xhtmlboi))
- A better support for conditionals Task execution (by [xvw](https://xvw.lol))

### v2.2.0 2025-03-22 Brussels (Belgium)

#### Yocaml

- Some minor fixes (by [xvw](https://xvw.lol))
- Fix `Nel` representation (by [xvw](https://xvw.lol))
- Restore DOC-ci (by [xvw](https://xvw.lol))
- Add more helpers for dealing with dynamic dependencies (by [xvw](https://xvw.lol))

#### Yocaml_git

- Update to git-kv 1.0.2 and work around last modified behavior inside a `Git_kv.change_and_push` call (by [reynir](https://reyn.ir))
- Update `git` dependencies (by [xvw](https://xvw.lol))


### v2.1.0 2024-12-14 Nantes (France)

- Support for OCaml `5.3.0` (by [kit-ty-kate](https://github.com/kit-ty-kate))


### v2.0.1 2024-10-20 Nantes (France)

#### yocaml

- Fix Table of contents computation when the first index is lower than followers by [xvw](https://github.com/xvw)
- Remove `charset` of the computed `meta` (since it does not follow the form `name => content`) by [xvw](https://github.com/xvw)
- Move some modules (`Datetime` and `Toc`) at the Toplevel of `Yocaml` by [xvw](https://github.com/xvw)


### v2.0.0 2024-10-04 Nantes (France)

#### yocaml

- Complete reconstruction of the YOCaml core (by [xhtmlboi](https://github.com/xhtmlboi), [xvw](https://github.com/xvw), [gr-im](https://github.com/gr-im), [mspwn](https://github.com/mspwn), [dinosaure](https://github.com/dinosaure), [maiste](https://github.com/maiste) and [hakimba](https://github.com/Hakimba))

#### yocaml_cmarkit

- Second release (by [maiste](https://github.com/maiste) and [xvw](https://github.com/xvw))

#### yocaml_eio

- First release (by [xvw](https://github.com/xvw), [dinosaure](https://github.com/dinosaure), [hannesm](https://github.com/hannesm), and [xhtmlboi](https://github.com/xhtmlboi))

#### yocaml_git

- First release (by [dinosaure](https://github.com/dinosaure) and [xhtmlboi](https://github.com/xhtmlboi))


#### yocaml_jingoo

- Second release (by [xhtmlboi](https://github.com/xhtmlboi), [mspwn](https://github.com/mspwn) and [xvw](https://github.com/xvw))

#### yocaml_mustache

- Second release (by [xhtmlboi](https://github.com/xhtmlboi), [mspwn](https://github.com/mspwn) and [xvw](https://github.com/xvw))

#### yocaml_omd

- Second release (by [xhtmlboi](https://github.com/xhtmlboi), [mspwn](https://github.com/mspwn) and [xvw](https://github.com/xvw))

#### yocaml_otoml

- First release (by [xvw](https://github.com/xvw))

#### yocaml_syndication

- Second release (by [xvw](https://github.com/xvw), [mspwn](https://github.com/mspwn), [gr-im](https://github.com/gr-im) and [tim-ats-d](https://github.com/Tim-ats-d))

#### yocaml_unix

- Second release (by [xvw](https://github.com/xvw), [dinosaure](https://github.com/dinosaure), [hannesm](https://github.com/hannesm), and [xhtmlboi](https://github.com/xhtmlboi))

#### yocaml_yaml

- Second release (by [xhtmlboi](https://github.com/xhtmlboi), [mspwn](https://github.com/mspwn) and [xvw](https://github.com/xvw))

### v1.0.0 2023-11-15 Paris (France)

- First release of YOCaml
