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

let%expect_test "generate toc - from xvw.lol articles - 3" =
  print_toc_str ~check_label:false
  @@ from_markdown_title
       [
         "### Mise en contexte"
       ; "#### Simple, mais pas sur tous les aspects"
       ; "#### Découverte des règles via Internet"
       ; "## Le Tetra Master"
       ; "### Les cartes dans l'histoire"
       ; "### La collecte des cartes"
       ; "#### Une brève note sur l'aléatoire"
       ; "### Les règles selon le manuel"
       ; "#### Défier un adversaire"
       ; "#### Règles basiques"
       ; "##### Gagner une carte"
       ; "##### Récompenses et pénalités"
       ; "#### Nombre limite de cartes et menu"
       ; "#### Conclusion de la lecture du manuel"
       ; "### Règles détaillées"
       ; "#### Initiation d'une partie"
       ; "#### Plateau de jeu"
       ; "#### Prise de cartes simple"
       ; "#### Bataille"
       ; "##### Batailles multiples"
       ; "##### Anatomie d'une carte"
       ; "##### Lire les statistiques d'une carte"
       ; "##### Interprétation des statistiques hexadécimales"
       ; "##### Déroulé de la bataille, toujours plus d'aléas"
       ; "##### Calcul des probabilités de victoire en duel"
       ; "##### Les combos"
       ; "#### Pré-conclusion sur les règles"
       ; "### Expérience et évolution des cartes"
       ; "#### Evolution de l'attaque et des défenses"
       ; "#### Evolution du type de cartes"
       ; "#### Liste des cartes"
       ; "### Le niveau de collectionneur"
       ; "#### Les différents niveaux"
       ; "#### Sur la distinction des cartes"
       ; "#### Les points attribués par cartes"
       ; "##### Note sur les permutations de motifs"
       ; "#### La cerise sur le gateau"
       ; "## Pour conclure, enfin"
       ; "### Qu'en tirer"
       ; "### La suite"
       ; "### Remerciements"
       ; "### L'ultime mot de la fin"
       ];
  [%expect
    {|
    TOC:
    1-Mise en contexte
    1.1-Simple, mais pas sur tous les aspects
    1.2-Découverte des règles via Internet
    2-Le Tetra Master
    2.1-Les cartes dans l'histoire
    2.2-La collecte des cartes
    2.2.1-Une brève note sur l'aléatoire
    2.3-Les règles selon le manuel
    2.3.1-Défier un adversaire
    2.3.2-Règles basiques
    2.3.2.1-Gagner une carte
    2.3.2.2-Récompenses et pénalités
    2.3.3-Nombre limite de cartes et menu
    2.3.4-Conclusion de la lecture du manuel
    2.4-Règles détaillées
    2.4.1-Initiation d'une partie
    2.4.2-Plateau de jeu
    2.4.3-Prise de cartes simple
    2.4.4-Bataille
    2.4.4.1-Batailles multiples
    2.4.4.2-Anatomie d'une carte
    2.4.4.3-Lire les statistiques d'une carte
    2.4.4.4-Interprétation des statistiques hexadécimales
    2.4.4.5-Déroulé de la bataille, toujours plus d'aléas
    2.4.4.6-Calcul des probabilités de victoire en duel
    2.4.4.7-Les combos
    2.4.5-Pré-conclusion sur les règles
    2.5-Expérience et évolution des cartes
    2.5.1-Evolution de l'attaque et des défenses
    2.5.2-Evolution du type de cartes
    2.5.3-Liste des cartes
    2.6-Le niveau de collectionneur
    2.6.1-Les différents niveaux
    2.6.2-Sur la distinction des cartes
    2.6.3-Les points attribués par cartes
    2.6.3.1-Note sur les permutations de motifs
    2.6.4-La cerise sur le gateau
    3-Pour conclure, enfin
    3.1-Qu'en tirer
    3.2-La suite
    3.3-Remerciements
    3.4-L'ultime mot de la fin
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
    {| <ul><li><a href="#ocaml-en-tant-que-langage" data-toc-target="ocaml-en-tant-que-langage">OCaml en tant que langage</a><ul><li><a href="#sur-la-verification-statique-des-types" data-toc-target="sur-la-verification-statique-des-types">Sur la vérification statique des types</a></li><li><a href="#fonctionnalites-du-langage" data-toc-target="fonctionnalites-du-langage">Fonctionnalités du _langage_</a><ul><li><a href="#un-langage-multi-paradigmes" data-toc-target="un-langage-multi-paradigmes">Un langage _multi-paradigmes_</a></li></ul></li></ul></li></ul> |}]

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
    {| <ul><li><a href="#avant-propos" data-toc-target="avant-propos">Avant propos</a><ul><li><a href="#ressources" data-toc-target="ressources">Ressources</a></li></ul></li><li><a href="#ocaml-en-tant-que-langage" data-toc-target="ocaml-en-tant-que-langage">OCaml en tant que langage</a><ul><li><a href="#sur-la-verification-statique-des-types" data-toc-target="sur-la-verification-statique-des-types">Sur la vérification statique des types</a></li><li><a href="#fonctionnalites-du-langage" data-toc-target="fonctionnalites-du-langage">Fonctionnalités du _langage_</a><ul><li><a href="#un-langage-multi-paradigmes" data-toc-target="un-langage-multi-paradigmes">Un langage _multi-paradigmes_</a><ul><li><a href="#syntaxe-a-la-ml" data-toc-target="syntaxe-a-la-ml">Syntaxe _à la ML_</a></li><li><a href="#etroitement-lie-a-la-recherche" data-toc-target="etroitement-lie-a-la-recherche">Étroitement lié à la recherche</a></li></ul></li><li><a href="#types-algebriques" data-toc-target="types-algebriques">Types algébriques</a></li><li><a href="#programmation-modulaires-et-langage-de-modules" data-toc-target="programmation-modulaires-et-langage-de-modules">Programmation modulaires et langage de modules</a></li><li><a href="#injection-et-inversion-de-dependances" data-toc-target="injection-et-inversion-de-dependances">Injection et inversion de dépendances</a></li></ul></li><li><a href="#concernant-le-futur" data-toc-target="concernant-le-futur">Concernant le futur</a></li><li><a href="#points-faibles" data-toc-target="points-faibles">Points faibles</a></li><li><a href="#pour-conclure-sur-le-langage" data-toc-target="pour-conclure-sur-le-langage">Pour conclure sur le langage</a></li></ul></li><li><a href="#ocaml-en-tant-qu-ecosysteme" data-toc-target="ocaml-en-tant-qu-ecosysteme">OCaml en tant qu'écosystème</a><ul><li><a href="#compilation-runtimes-et-cibles-additionnelles" data-toc-target="compilation-runtimes-et-cibles-additionnelles">Compilation, _runtimes_, et cibles additionnelles</a><ul><li><a href="#un-petit-detour-par-mirageos" data-toc-target="un-petit-detour-par-mirageos">Un petit détour par MirageOS</a></li></ul></li><li><a href="#la-plateforme-ocaml" data-toc-target="la-plateforme-ocaml">La plateforme OCaml</a><ul><li><a href="#opam-le-gestionnaire-de-paquets" data-toc-target="opam-le-gestionnaire-de-paquets">OPAM, le gestionnaire de paquets</a></li><li><a href="#dune-le-build-system" data-toc-target="dune-le-build-system">Dune, le _build-system_</a><ul><li><a href="#sur-le-choix-des-s-expression" data-toc-target="sur-le-choix-des-s-expression">Sur le choix des S-expression</a></li><li><a href="#contribution-a-l-etat-de-l-art-selective-applicative-functor" data-toc-target="contribution-a-l-etat-de-l-art-selective-applicative-functor">Contribution à l'état de l'art: Selective Applicative Functor</a></li><li><a href="#alternatives" data-toc-target="alternatives">Alternatives</a></li></ul></li><li><a href="#lsp-et-merlin-pour-les-editeurs" data-toc-target="lsp-et-merlin-pour-les-editeurs">LSP et Merlin pour les éditeurs</a><ul><li><a href="#avenement-de-vscode-lsp-comme-standard" data-toc-target="avenement-de-vscode-lsp-comme-standard">Avènement de VSCode, LSP comme standard</a></li></ul></li><li><a href="#odoc-le-generateur-de-documentation" data-toc-target="odoc-le-generateur-de-documentation">Odoc, le générateur de documentation</a></li></ul></li><li><a href="#bibliotheques-disponibles" data-toc-target="bibliotheques-disponibles">Bibliothèques disponibles</a><ul><li><a href="#aparte-sur-la-bibliotheque-standard" data-toc-target="aparte-sur-la-bibliotheque-standard">Aparté sur la bibliothèque standard</a></li></ul></li><li><a href="#conclusion-de-l-ecosysteme" data-toc-target="conclusion-de-l-ecosysteme">Conclusion de l'écosystème</a></li></ul></li><li><a href="#sur-la-communaute" data-toc-target="sur-la-communaute">Sur la communauté</a></li><li><a href="#quelques-mythes-lies-a-ocaml" data-toc-target="quelques-mythes-lies-a-ocaml">Quelques mythes liés à OCaml</a><ul><li><a href="#ocaml-et-fsharp" data-toc-target="ocaml-et-fsharp">OCaml et FSharp</a></li><li><a href="#les-operateurs-doubles-pour-les-flottants" data-toc-target="les-operateurs-doubles-pour-les-flottants">Les opérateurs doublés pour les flottants</a></li><li><a href="#sur-la-separation-entre-ml-et-mli" data-toc-target="sur-la-separation-entre-ml-et-mli">Sur la séparation entre `ml` et `mli`</a><ul><li><a href="#gerer-l-encapsulation-sans-mli" data-toc-target="gerer-l-encapsulation-sans-mli">Gérer l'encapsulation sans `mli`</a></li><li><a href="#exprimer-l-interface-depuis-le-ml" data-toc-target="exprimer-l-interface-depuis-le-ml">Exprimer l'interface depuis le `ml`</a></li><li><a href="#pour-conclure-sur-la-separation" data-toc-target="pour-conclure-sur-la-separation">Pour conclure sur la séparation</a></li></ul></li></ul></li><li><a href="#pour-conclure" data-toc-target="pour-conclure">Pour conclure</a></li></ul> |}]

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
  [%expect
    {| <ol><li><a href="#avant-propos" data-toc-target="avant-propos">Avant propos</a><ol><li><a href="#ressources" data-toc-target="ressources">Ressources</a></li></ol></li><li><a href="#ocaml-en-tant-que-langage" data-toc-target="ocaml-en-tant-que-langage">OCaml en tant que langage</a><ol><li><a href="#sur-la-verification-statique-des-types" data-toc-target="sur-la-verification-statique-des-types">Sur la vérification statique des types</a></li><li><a href="#fonctionnalites-du-langage" data-toc-target="fonctionnalites-du-langage">Fonctionnalités du _langage_</a><ol><li><a href="#un-langage-multi-paradigmes" data-toc-target="un-langage-multi-paradigmes">Un langage _multi-paradigmes_</a><ol><li><a href="#syntaxe-a-la-ml" data-toc-target="syntaxe-a-la-ml">Syntaxe _à la ML_</a></li><li><a href="#etroitement-lie-a-la-recherche" data-toc-target="etroitement-lie-a-la-recherche">Étroitement lié à la recherche</a></li></ol></li><li><a href="#types-algebriques" data-toc-target="types-algebriques">Types algébriques</a></li><li><a href="#programmation-modulaires-et-langage-de-modules" data-toc-target="programmation-modulaires-et-langage-de-modules">Programmation modulaires et langage de modules</a></li><li><a href="#injection-et-inversion-de-dependances" data-toc-target="injection-et-inversion-de-dependances">Injection et inversion de dépendances</a></li></ol></li><li><a href="#concernant-le-futur" data-toc-target="concernant-le-futur">Concernant le futur</a></li><li><a href="#points-faibles" data-toc-target="points-faibles">Points faibles</a></li><li><a href="#pour-conclure-sur-le-langage" data-toc-target="pour-conclure-sur-le-langage">Pour conclure sur le langage</a></li></ol></li><li><a href="#ocaml-en-tant-qu-ecosysteme" data-toc-target="ocaml-en-tant-qu-ecosysteme">OCaml en tant qu'écosystème</a><ol><li><a href="#compilation-runtimes-et-cibles-additionnelles" data-toc-target="compilation-runtimes-et-cibles-additionnelles">Compilation, _runtimes_, et cibles additionnelles</a><ol><li><a href="#un-petit-detour-par-mirageos" data-toc-target="un-petit-detour-par-mirageos">Un petit détour par MirageOS</a></li></ol></li><li><a href="#la-plateforme-ocaml" data-toc-target="la-plateforme-ocaml">La plateforme OCaml</a><ol><li><a href="#opam-le-gestionnaire-de-paquets" data-toc-target="opam-le-gestionnaire-de-paquets">OPAM, le gestionnaire de paquets</a></li><li><a href="#dune-le-build-system" data-toc-target="dune-le-build-system">Dune, le _build-system_</a><ol><li><a href="#sur-le-choix-des-s-expression" data-toc-target="sur-le-choix-des-s-expression">Sur le choix des S-expression</a></li><li><a href="#contribution-a-l-etat-de-l-art-selective-applicative-functor" data-toc-target="contribution-a-l-etat-de-l-art-selective-applicative-functor">Contribution à l'état de l'art: Selective Applicative Functor</a></li><li><a href="#alternatives" data-toc-target="alternatives">Alternatives</a></li></ol></li><li><a href="#lsp-et-merlin-pour-les-editeurs" data-toc-target="lsp-et-merlin-pour-les-editeurs">LSP et Merlin pour les éditeurs</a><ol><li><a href="#avenement-de-vscode-lsp-comme-standard" data-toc-target="avenement-de-vscode-lsp-comme-standard">Avènement de VSCode, LSP comme standard</a></li></ol></li><li><a href="#odoc-le-generateur-de-documentation" data-toc-target="odoc-le-generateur-de-documentation">Odoc, le générateur de documentation</a></li></ol></li><li><a href="#bibliotheques-disponibles" data-toc-target="bibliotheques-disponibles">Bibliothèques disponibles</a><ol><li><a href="#aparte-sur-la-bibliotheque-standard" data-toc-target="aparte-sur-la-bibliotheque-standard">Aparté sur la bibliothèque standard</a></li></ol></li><li><a href="#conclusion-de-l-ecosysteme" data-toc-target="conclusion-de-l-ecosysteme">Conclusion de l'écosystème</a></li></ol></li><li><a href="#sur-la-communaute" data-toc-target="sur-la-communaute">Sur la communauté</a></li><li><a href="#quelques-mythes-lies-a-ocaml" data-toc-target="quelques-mythes-lies-a-ocaml">Quelques mythes liés à OCaml</a><ol><li><a href="#ocaml-et-fsharp" data-toc-target="ocaml-et-fsharp">OCaml et FSharp</a></li><li><a href="#les-operateurs-doubles-pour-les-flottants" data-toc-target="les-operateurs-doubles-pour-les-flottants">Les opérateurs doublés pour les flottants</a></li><li><a href="#sur-la-separation-entre-ml-et-mli" data-toc-target="sur-la-separation-entre-ml-et-mli">Sur la séparation entre `ml` et `mli`</a><ol><li><a href="#gerer-l-encapsulation-sans-mli" data-toc-target="gerer-l-encapsulation-sans-mli">Gérer l'encapsulation sans `mli`</a></li><li><a href="#exprimer-l-interface-depuis-le-ml" data-toc-target="exprimer-l-interface-depuis-le-ml">Exprimer l'interface depuis le `ml`</a></li><li><a href="#pour-conclure-sur-la-separation" data-toc-target="pour-conclure-sur-la-separation">Pour conclure sur la séparation</a></li></ol></li></ol></li><li><a href="#pour-conclure" data-toc-target="pour-conclure">Pour conclure</a></li></ol> |}]
