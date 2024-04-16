(lang dune 3.14)

(name yocaml)
(version dev)
(generate_opam_files true)
(using mdx 0.4)

(source (gitlab funkywork/yocaml))
(license GPL-3.0-or-later)
(authors "The XHTMLBoy <xhtmlboi@gmail.com>")
(maintainers "The Funkyworkers")

(package
  (name yocaml)
  (synopsis "Core engine of the YOCaml Static Site Generator")
  (description "YOCaml is a build system dedicated to generate static document")
  (depends
   (ocaml (>= 5.1.1))
   (dune (>= 3.0.0))
   (odoc :with-doc)
   (fmt :with-test)
   (alcotest :with-test)
   (qcheck :with-test)
   (qcheck-alcotest :with-test)
   (mdx (and :with-test (= 2.4.1)))
   (ocamlformat :with-dev-setup)
   (ocp-indent :with-dev-setup)
   (merlin :with-dev-setup)
   (utop :with-dev-setup)))

 (package
   (name yocaml_unix)
   (synopsis "The Unix runtime for using YOCaml on a Unix file system!")
   (depends
    (ocaml (>= 5.1.1))
    (dune (>= 3.0.0))
    (yocaml (= :version))
    (logs (>= 0.7.0))
    (fmt (>= 0.9.0))
    (digestif (>= 1.2.0))))

(package
  (name yocaml_yaml)
  (synopsis "Yocaml plugin for dealing with Yaml as metadata provider")
  (depends
   (ocaml (>= 5.1.1))
   (dune (>= 3.0.0))
   (yocaml (= :version))
   (yaml (>= 3.2.0))))

(package
  (name yocaml_omd)
  (synopsis "Yocaml plugin for using Markdown (via OMD package) as a Markup language")
  (depends
   (ocaml (>= 5.1.1))
   (dune (>= 3.0.0))
   (yocaml (= :version))
   (omd (>= 2.0.0~alpha4))))

(package
  (name yocaml_jingoo)
  (synopsis "Yocaml plugin for using Jingoo as a template language")
  (depends
   (ocaml (>= 5.1.1))
   (dune (>= 3.0.0))
   (yocaml (= :version))
   (jingoo (>= 1.5.0))))
