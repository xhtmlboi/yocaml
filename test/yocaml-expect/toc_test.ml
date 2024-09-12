(* YOCaml a static blog generator.
   Copyright (C) 2024 The Funkyworkers and The YOCaml's developers

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

open Yocaml

let print_toc_str ?(check_label = true) toc =
  let () = print_endline "TOC:" in
  toc
  |> Markup.Toc.from_list
  |> Markup.Toc.to_labelled_list
  |> List.iter (fun (i, elt) ->
         let i = i |> List.map string_of_int |> String.concat "." in
         let suffix =
           if check_label then " : " ^ string_of_bool @@ String.equal i elt
           else ""
         in
         i ^ "-" ^ elt ^ suffix |> print_endline)

let hashes_title x =
  match String.split_on_char ' ' x with
  | hashes :: rest when String.for_all (Char.equal '#') hashes ->
      Some (String.length hashes, String.concat " " rest)
  | _ -> None

let from_markdown_title = List.filter_map hashes_title

let print_html ?ol toc =
  toc
  |> List.filter_map (fun x ->
         x |> hashes_title |> Option.map (fun (i, l) -> (i, (Slug.from l, l))))
  |> Markup.Toc.from_list
  |> Markup.Toc.to_html ?ol (fun x -> x)
  |> Option.value ~default:"<div class='hidden'></div>"
  |> print_endline

let%expect_test "generate toc on an empty list" =
  print_toc_str [];
  [%expect {| TOC: |}]

let%expect_test "generate toc on a singleton" =
  print_toc_str [ (1, "1") ];
  [%expect {|
    TOC:
    1-1 : true
    |}]

let%expect_test "generate toc - 1" =
  print_toc_str [ (1, "1"); (1, "2"); (1, "3") ];
  [%expect {|
    TOC:
    1-1 : true
    2-2 : true
    3-3 : true
    |}]

let%expect_test "generate toc - 2" =
  print_toc_str [ (1, "1"); (1, "2"); (2, "2.1"); (1, "3"); (1, "4") ];
  [%expect
    {|
    TOC:
    1-1 : true
    2-2 : true
    2.1-2.1 : true
    3-3 : true
    4-4 : true
    |}]

let%expect_test "generate toc - 3" =
  print_toc_str
    [
      (1, "1")
    ; (3, "1.1")
    ; (1, "2")
    ; (2, "2.1")
    ; (5, "2.1.1")
    ; (5, "2.1.2")
    ; (2, "2.2")
    ; (1, "3")
    ; (1, "4")
    ];
  [%expect
    {|
    TOC:
    1-1 : true
    1.1-1.1 : true
    2-2 : true
    2.1-2.1 : true
    2.1.1-2.1.1 : true
    2.1.2-2.1.2 : true
    2.2-2.2 : true
    3-3 : true
    4-4 : true
    |}]

let%expect_test "generate toc - from xvw.lol articles - 1" =
  print_toc_str ~check_label:false
  @@ from_markdown_title
       [
         "### Thématiques et navigation"
       ; "### Technologies"
       ; "#### Génération statique: YOCaml"
       ; "##### Greffons utilisés"
       ; "##### Greffons implémentés"
       ; "#### Infrastructure"
       ; "#### Client et technologies _front-end_"
       ; "##### CSS et intégration"
       ; "##### Coloration syntaxique"
       ; "##### Nightmare"
       ; "#### Commentaires"
       ; "#### Web3 et Tezos"
       ; "#### Conclusion sur la pile technologique"
       ; "### Développement et production de contenu"
       ; "#### Développement"
       ; "#### Éléments visuels"
       ; "##### Typographies"
       ; "### Conclusion"
       ];
  [%expect
    {|
    TOC:
    1-Thématiques et navigation
    2-Technologies
    2.1-Génération statique: YOCaml
    2.1.1-Greffons utilisés
    2.1.2-Greffons implémentés
    2.2-Infrastructure
    2.3-Client et technologies _front-end_
    2.3.1-CSS et intégration
    2.3.2-Coloration syntaxique
    2.3.3-Nightmare
    2.4-Commentaires
    2.5-Web3 et Tezos
    2.6-Conclusion sur la pile technologique
    3-Développement et production de contenu
    3.1-Développement
    3.2-Éléments visuels
    3.2.1-Typographies
    4-Conclusion
    |}]

let%expect_test "generate toc - from xvw.lol articles - 2" =
  print_toc_str ~check_label:false
  @@ from_markdown_title
       [
         "## OCaml en tant que langage"
       ; "### Sur la vérification statique des types"
       ; "### Fonctionnalités du _langage_"
       ; "#### Un langage _multi-paradigmes_"
       ; "##### Syntaxe _à la ML_"
       ; "##### Étroitement lié à la recherche"
       ; "#### Types algébriques"
       ; "#### Programmation modulaires et langage de modules"
       ; "#### Injection et inversion de dépendances"
       ; "### Concernant le futur"
       ; "### Points faibles"
       ; "### Pour conclure sur le langage"
       ; "## OCaml en tant qu'écosystème"
       ; "### Compilation, _runtimes_, et cibles additionnelles"
       ; "#### Un petit détour par MirageOS"
       ; "### La plateforme OCaml"
       ; "#### OPAM, le gestionnaire de paquets"
       ; "#### Dune, le _build-system_"
       ; "##### Sur le choix des S-expression"
       ; "##### Contribution à l'état de l'art: Selective Applicative Functor"
       ; "##### Alternatives"
       ; "#### LSP et Merlin pour les éditeurs"
       ; "##### Avènement de VSCode, LSP comme standard"
       ; "#### Odoc, le générateur de documentation"
       ; "### Bibliothèques disponibles"
       ; "#### Aparté sur la bibliothèque standard"
       ; "### Conclusion de l'écosystème"
       ; "## Sur la communauté"
       ; "## Quelques mythes liés à OCaml"
       ; "### OCaml et FSharp"
       ; "### Les opérateurs doublés pour les flottants"
       ; "### Sur la séparation entre `ml` et `mli`"
       ; "#### Gérer l'encapsulation sans `mli`"
       ; "#### Exprimer l'interface depuis le `ml`"
       ; "#### Pour conclure sur la séparation"
       ; "## Pour conclure"
       ];
  [%expect
    {|
    TOC:
    1-OCaml en tant que langage
    1.1-Sur la vérification statique des types
    1.2-Fonctionnalités du _langage_
    1.2.1-Un langage _multi-paradigmes_
    1.2.1.1-Syntaxe _à la ML_
    1.2.1.2-Étroitement lié à la recherche
    1.2.2-Types algébriques
    1.2.3-Programmation modulaires et langage de modules
    1.2.4-Injection et inversion de dépendances
    1.3-Concernant le futur
    1.4-Points faibles
    1.5-Pour conclure sur le langage
    2-OCaml en tant qu'écosystème
    2.1-Compilation, _runtimes_, et cibles additionnelles
    2.1.1-Un petit détour par MirageOS
    2.2-La plateforme OCaml
    2.2.1-OPAM, le gestionnaire de paquets
    2.2.2-Dune, le _build-system_
    2.2.2.1-Sur le choix des S-expression
    2.2.2.2-Contribution à l'état de l'art: Selective Applicative Functor
    2.2.2.3-Alternatives
    2.2.3-LSP et Merlin pour les éditeurs
    2.2.3.1-Avènement de VSCode, LSP comme standard
    2.2.4-Odoc, le générateur de documentation
    2.3-Bibliothèques disponibles
    2.3.1-Aparté sur la bibliothèque standard
    2.4-Conclusion de l'écosystème
    3-Sur la communauté
    4-Quelques mythes liés à OCaml
    4.1-OCaml et FSharp
    4.2-Les opérateurs doublés pour les flottants
    4.3-Sur la séparation entre `ml` et `mli`
    4.3.1-Gérer l'encapsulation sans `mli`
    4.3.2-Exprimer l'interface depuis le `ml`
    4.3.3-Pour conclure sur la séparation
    5-Pour conclure
    |}]

let%expect_test "from toc to html" =
  print_html [];
  [%expect {| <div class='hidden'></div> |}]

let%expect_test "from toc to html" =
  print_html
    [
      "## OCaml en tant que langage"
    ; "### Sur la vérification statique des types"
    ; "### Fonctionnalités du _langage_"
    ; "#### Un langage _multi-paradigmes_"
    ];
  [%expect
    {| <ul><li><a href="#ocaml-en-tant-que-langage">OCaml en tant que langage</a><ul><li><a href="#sur-la-v-rification-statique-des-types">Sur la vérification statique des types</a></li><li><a href="#fonctionnalit-s-du-langage">Fonctionnalités du _langage_</a><ul><li><a href="#un-langage-multi-paradigmes">Un langage _multi-paradigmes_</a></li></ul></li></ul></li></ul> |}]

let%expect_test "from toc to html" =
  print_html
    [
      "## Avant propos"
    ; "### Ressources"
    ; "## OCaml en tant que langage"
    ; "### Sur la vérification statique des types"
    ; "### Fonctionnalités du _langage_"
    ; "#### Un langage _multi-paradigmes_"
    ; "##### Syntaxe _à la ML_"
    ; "##### Étroitement lié à la recherche"
    ; "#### Types algébriques"
    ; "#### Programmation modulaires et langage de modules"
    ; "#### Injection et inversion de dépendances"
    ; "### Concernant le futur"
    ; "### Points faibles"
    ; "### Pour conclure sur le langage"
    ; "## OCaml en tant qu'écosystème"
    ; "### Compilation, _runtimes_, et cibles additionnelles"
    ; "#### Un petit détour par MirageOS"
    ; "### La plateforme OCaml"
    ; "#### OPAM, le gestionnaire de paquets"
    ; "#### Dune, le _build-system_"
    ; "##### Sur le choix des S-expression"
    ; "##### Contribution à l'état de l'art: Selective Applicative Functor"
    ; "##### Alternatives"
    ; "#### LSP et Merlin pour les éditeurs"
    ; "##### Avènement de VSCode, LSP comme standard"
    ; "#### Odoc, le générateur de documentation"
    ; "### Bibliothèques disponibles"
    ; "#### Aparté sur la bibliothèque standard"
    ; "### Conclusion de l'écosystème"
    ; "## Sur la communauté"
    ; "## Quelques mythes liés à OCaml"
    ; "### OCaml et FSharp"
    ; "### Les opérateurs doublés pour les flottants"
    ; "### Sur la séparation entre `ml` et `mli`"
    ; "#### Gérer l'encapsulation sans `mli`"
    ; "#### Exprimer l'interface depuis le `ml`"
    ; "#### Pour conclure sur la séparation"
    ; "## Pour conclure"
    ];
  [%expect
    {| <ul><li><a href="#avant-propos">Avant propos</a><ul><li><a href="#ressources">Ressources</a></li></ul></li><li><a href="#ocaml-en-tant-que-langage">OCaml en tant que langage</a><ul><li><a href="#sur-la-v-rification-statique-des-types">Sur la vérification statique des types</a></li><li><a href="#fonctionnalit-s-du-langage">Fonctionnalités du _langage_</a><ul><li><a href="#un-langage-multi-paradigmes">Un langage _multi-paradigmes_</a><ul><li><a href="#syntaxe-la-ml">Syntaxe _à la ML_</a></li><li><a href="#troitement-li-la-recherche">Étroitement lié à la recherche</a></li></ul></li><li><a href="#types-alg-briques">Types algébriques</a></li><li><a href="#programmation-modulaires-et-langage-de-modules">Programmation modulaires et langage de modules</a></li><li><a href="#injection-et-inversion-de-d-pendances">Injection et inversion de dépendances</a></li></ul></li><li><a href="#concernant-le-futur">Concernant le futur</a></li><li><a href="#points-faibles">Points faibles</a></li><li><a href="#pour-conclure-sur-le-langage">Pour conclure sur le langage</a></li></ul></li><li><a href="#ocaml-en-tant-qu-cosyst-me">OCaml en tant qu'écosystème</a><ul><li><a href="#compilation-runtimes-et-cibles-additionnelles">Compilation, _runtimes_, et cibles additionnelles</a><ul><li><a href="#un-petit-d-tour-par-mirageos">Un petit détour par MirageOS</a></li></ul></li><li><a href="#la-plateforme-ocaml">La plateforme OCaml</a><ul><li><a href="#opam-le-gestionnaire-de-paquets">OPAM, le gestionnaire de paquets</a></li><li><a href="#dune-le-build-system">Dune, le _build-system_</a><ul><li><a href="#sur-le-choix-des-s-expression">Sur le choix des S-expression</a></li><li><a href="#contribution-l-tat-de-l-art-selective-applicative-functor">Contribution à l'état de l'art: Selective Applicative Functor</a></li><li><a href="#alternatives">Alternatives</a></li></ul></li><li><a href="#lsp-et-merlin-pour-les-diteurs">LSP et Merlin pour les éditeurs</a><ul><li><a href="#av-nement-de-vscode-lsp-comme-standard">Avènement de VSCode, LSP comme standard</a></li></ul></li><li><a href="#odoc-le-g-n-rateur-de-documentation">Odoc, le générateur de documentation</a></li></ul></li><li><a href="#biblioth-ques-disponibles">Bibliothèques disponibles</a><ul><li><a href="#apart-sur-la-biblioth-que-standard">Aparté sur la bibliothèque standard</a></li></ul></li><li><a href="#conclusion-de-l-cosyst-me">Conclusion de l'écosystème</a></li></ul></li><li><a href="#sur-la-communaut">Sur la communauté</a></li><li><a href="#quelques-mythes-li-s-ocaml">Quelques mythes liés à OCaml</a><ul><li><a href="#ocaml-et-fsharp">OCaml et FSharp</a></li><li><a href="#les-op-rateurs-doubl-s-pour-les-flottants">Les opérateurs doublés pour les flottants</a></li><li><a href="#sur-la-s-paration-entre-ml-et-mli">Sur la séparation entre `ml` et `mli`</a><ul><li><a href="#g-rer-l-encapsulation-sans-mli">Gérer l'encapsulation sans `mli`</a></li><li><a href="#exprimer-l-interface-depuis-le-ml">Exprimer l'interface depuis le `ml`</a></li><li><a href="#pour-conclure-sur-la-s-paration">Pour conclure sur la séparation</a></li></ul></li></ul></li><li><a href="#pour-conclure">Pour conclure</a></li></ul> |}]

let%expect_test "from toc to html with ol" =
  print_html ~ol:true
    [
      "## Avant propos"
    ; "### Ressources"
    ; "## OCaml en tant que langage"
    ; "### Sur la vérification statique des types"
    ; "### Fonctionnalités du _langage_"
    ; "#### Un langage _multi-paradigmes_"
    ; "##### Syntaxe _à la ML_"
    ; "##### Étroitement lié à la recherche"
    ; "#### Types algébriques"
    ; "#### Programmation modulaires et langage de modules"
    ; "#### Injection et inversion de dépendances"
    ; "### Concernant le futur"
    ; "### Points faibles"
    ; "### Pour conclure sur le langage"
    ; "## OCaml en tant qu'écosystème"
    ; "### Compilation, _runtimes_, et cibles additionnelles"
    ; "#### Un petit détour par MirageOS"
    ; "### La plateforme OCaml"
    ; "#### OPAM, le gestionnaire de paquets"
    ; "#### Dune, le _build-system_"
    ; "##### Sur le choix des S-expression"
    ; "##### Contribution à l'état de l'art: Selective Applicative Functor"
    ; "##### Alternatives"
    ; "#### LSP et Merlin pour les éditeurs"
    ; "##### Avènement de VSCode, LSP comme standard"
    ; "#### Odoc, le générateur de documentation"
    ; "### Bibliothèques disponibles"
    ; "#### Aparté sur la bibliothèque standard"
    ; "### Conclusion de l'écosystème"
    ; "## Sur la communauté"
    ; "## Quelques mythes liés à OCaml"
    ; "### OCaml et FSharp"
    ; "### Les opérateurs doublés pour les flottants"
    ; "### Sur la séparation entre `ml` et `mli`"
    ; "#### Gérer l'encapsulation sans `mli`"
    ; "#### Exprimer l'interface depuis le `ml`"
    ; "#### Pour conclure sur la séparation"
    ; "## Pour conclure"
    ];
  [%expect {| <ol><li><a href="#avant-propos">Avant propos</a><ol><li><a href="#ressources">Ressources</a></li></ol></li><li><a href="#ocaml-en-tant-que-langage">OCaml en tant que langage</a><ol><li><a href="#sur-la-v-rification-statique-des-types">Sur la vérification statique des types</a></li><li><a href="#fonctionnalit-s-du-langage">Fonctionnalités du _langage_</a><ol><li><a href="#un-langage-multi-paradigmes">Un langage _multi-paradigmes_</a><ol><li><a href="#syntaxe-la-ml">Syntaxe _à la ML_</a></li><li><a href="#troitement-li-la-recherche">Étroitement lié à la recherche</a></li></ol></li><li><a href="#types-alg-briques">Types algébriques</a></li><li><a href="#programmation-modulaires-et-langage-de-modules">Programmation modulaires et langage de modules</a></li><li><a href="#injection-et-inversion-de-d-pendances">Injection et inversion de dépendances</a></li></ol></li><li><a href="#concernant-le-futur">Concernant le futur</a></li><li><a href="#points-faibles">Points faibles</a></li><li><a href="#pour-conclure-sur-le-langage">Pour conclure sur le langage</a></li></ol></li><li><a href="#ocaml-en-tant-qu-cosyst-me">OCaml en tant qu'écosystème</a><ol><li><a href="#compilation-runtimes-et-cibles-additionnelles">Compilation, _runtimes_, et cibles additionnelles</a><ol><li><a href="#un-petit-d-tour-par-mirageos">Un petit détour par MirageOS</a></li></ol></li><li><a href="#la-plateforme-ocaml">La plateforme OCaml</a><ol><li><a href="#opam-le-gestionnaire-de-paquets">OPAM, le gestionnaire de paquets</a></li><li><a href="#dune-le-build-system">Dune, le _build-system_</a><ol><li><a href="#sur-le-choix-des-s-expression">Sur le choix des S-expression</a></li><li><a href="#contribution-l-tat-de-l-art-selective-applicative-functor">Contribution à l'état de l'art: Selective Applicative Functor</a></li><li><a href="#alternatives">Alternatives</a></li></ol></li><li><a href="#lsp-et-merlin-pour-les-diteurs">LSP et Merlin pour les éditeurs</a><ol><li><a href="#av-nement-de-vscode-lsp-comme-standard">Avènement de VSCode, LSP comme standard</a></li></ol></li><li><a href="#odoc-le-g-n-rateur-de-documentation">Odoc, le générateur de documentation</a></li></ol></li><li><a href="#biblioth-ques-disponibles">Bibliothèques disponibles</a><ol><li><a href="#apart-sur-la-biblioth-que-standard">Aparté sur la bibliothèque standard</a></li></ol></li><li><a href="#conclusion-de-l-cosyst-me">Conclusion de l'écosystème</a></li></ol></li><li><a href="#sur-la-communaut">Sur la communauté</a></li><li><a href="#quelques-mythes-li-s-ocaml">Quelques mythes liés à OCaml</a><ol><li><a href="#ocaml-et-fsharp">OCaml et FSharp</a></li><li><a href="#les-op-rateurs-doubl-s-pour-les-flottants">Les opérateurs doublés pour les flottants</a></li><li><a href="#sur-la-s-paration-entre-ml-et-mli">Sur la séparation entre `ml` et `mli`</a><ol><li><a href="#g-rer-l-encapsulation-sans-mli">Gérer l'encapsulation sans `mli`</a></li><li><a href="#exprimer-l-interface-depuis-le-ml">Exprimer l'interface depuis le `ml`</a></li><li><a href="#pour-conclure-sur-la-s-paration">Pour conclure sur la séparation</a></li></ol></li></ol></li><li><a href="#pour-conclure">Pour conclure</a></li></ol> |}]
