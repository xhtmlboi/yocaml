### unreleased

#### Yocaml
- Improve pretty-printing of validation errors (by [Linda-Njau](https://github.com/Linda-Njau))
- Fix typos and improve logs display (by [clementd](https://clementd.wtf))

### v2.8.0 2025-12-17 Nantes (France)

#### Yocaml 

- Add `Action.remove_residuals` for erasing residuals files (by [xvw](https://xvw.lol))
- Add `Yocaml.Data.Validation.sub_record` for validating a complete structure as a record field (by [xvw](https://xvw.lol))
- Add `Batch.iter_tree` and `Batch.fold_tree` (by [gr-im](https://github.com/gr-im))

#### Yocaml_git

- Add `Action.remove_residuals` for erasing residuals files (by [xvw](https://xvw.lol))

#### Yocaml_unix

- Add `Action.remove_residuals` for erasing residuals files (by [xvw](https://xvw.lol))

#### Yocaml_eio

- Add `Action.remove_residuals` for erasing residuals files (by [xvw](https://xvw.lol))

#### Yocaml_runtime

- Serve .xml, .rss, .atom, .feed files as application/xml (by [reynir](https://reyn.ir/))

### v2.7.0 2025-11-18 Nantes (France)

#### Yocaml_git

- A more robust metric for `is_file` and `is_directory` in Git context (by [dinosaure](https://github.com/dinosaure))

#### Yocaml_liquid

- ⁠First release - Add support for Shopify Liquid templating language (by [Dev-JoyA](https://github.com/Dev-JoyA))

#### Yocaml
- Add `Action.with_cache` helper to simplify working with cached actions (by [Abiola-Zeenat](https://github.com/Abiola-Zeenat))
- Introduce type aliases `converter`, `validator`, and `validable` to simplify the Validation API (by [Linda-Njau](https://github.com/Linda-Njau))
- Add module signatures `S` in `Yocaml.Data` and `Yocaml.Data.Validation` to standardize conversion and validation (by [Linda-Njau](https://github.com/Linda-Njau))
- Add `Yocaml.Data.into` and `Yocaml.Data.Validation.from` helpers for easier module use (by [Linda-Njau](https://github.com/Linda-Njau))
- Add `Yocaml.Metadata.Injectable` and `Yocaml.Metadata.Readable` functors to simplify creation of injectable and readable modules (by [Linda-Njau](https://github.com/Linda-Njau))
- Add `Yocaml.Data.Validation.String`, a set of validator for `String` (by [Okhuomon Ajayi](https://github.com/six-shot))
- Add missing test coverage for `Nel.equal` and `Nel.append` functions (by [Bill Njoroge](https://github.com/Bnjoroge1))
- Add `to_data` and `from_data` for Archetypes  (by [gr-im](https://github.com/xvw))
- Add `Yocaml.Data.Validation.Int` and `Float`, a set of validator for `Int` and `Float`  (by [gr-im](https://github.com/gr-im))


### v2.6.0 2025-09-23 Nantes (France)

#### Yocaml

- Add missing `snapshot` flag for reading files (by [gr-im](https://github.com/gr-im))
- Some small `Path` improvement  (by [gr-im](https://github.com/gr-im))

### v2.5.0 2025-09-18 Nantes (France)

#### Yocaml

- Add `Pipeline.read_template` to have a better fit with Applicative API (by [gr-im](https://github.com/gr-im))
- Fix table of content order for deeply nested elements (by [gr-im](https://github.com/gr-im))
- Add a Applicative Helpers for Archetypes (by [gr-im](https://github.com/gr-im))
- Improve `Archetype.Articles.fetch` (by [xhtmlboi](https://github.com/xhtmlboi))
- Add `Pipeline.fetch` and `Pipeline.fetch_some` (by [gr-im](https://github.com/gr-im))
- Add a new effect to define if a Path is a file (in order to disambiguate file and path for `Yocaml_git`) (by [xvw](https://xvw.lol))

#### Yocaml_jingoo

- Add `read_template` to have a better fit with Applicative API (by [gr-im](https://github.com/gr-im))
- Add `read_templates` to have a better fit with Applicative API when chaining templates (by [gr-im](https://github.com/gr-im))

#### Yocaml_mustache

- Add `read_template` to have a better fit with Applicative API (by [gr-im](https://github.com/gr-im))
- Add `read_templates` to have a better fit with Applicative API when chaining templates (by [gr-im](https://github.com/gr-im))

#### Yocaml_unix

- Adapt runtime to `is_file` (by [xvw](https://xvw.lol))

#### Yocaml_eio

- Adapt runtime to `is_file` (by [xvw](https://xvw.lol))

#### Yocaml_git

- Adapt runtime to `is_file` (by [xvw](https://xvw.lol))

### v2.4.1 2025-09-01 Nantes (France)

#### Yocaml

- Add `Toc.traverse` for building your own TOC string (by [gr-im](https://github.com/gr-im))

#### Yocaml_markdown

- Reintroduce the package to have a strong way to deal with Markdown and Syntax Highlighting (It probably made `yocaml_omd` and `yocaml_cmarkit` obsolete) (by [gr-im](https://github.com/gr-im))

#### Yocaml_cmarkit

- Add a regular function to compute TOC (by [gr-im](https://github.com/gr-im))

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
