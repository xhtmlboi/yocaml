(lang dune 3.0)

(name yocaml)
(version dev)
(generate_opam_files true)

(source (gitlab funkywork/yocaml))
(license GPL-3.0-or-later)
(authors "The XHTMLBoy")
(maintainers "The Funkyworkers")

(package
  (name yocaml)
  (synopsis "Core engine of the YOCaml Static Site Generator")
  (description "YOCaml is a build system dedicated to generate static document")
  (depends
   (ocaml (>= 5.1.1))
   (dune (>= 3.0.0))
   (odoc :with-doc)
   (alcotest :with-test)
   (qcheck :with-test)
   (qcheck-alcotest :with-test)
   (ocamlformat :with-dev-setup)
   (ocp-indent :with-dev-setup)
   (merlin :with-dev-setup)
   (utop :with-dev-setup)))
