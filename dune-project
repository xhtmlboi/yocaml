(lang dune 3.18)

(name yocaml)
(version dev)
(generate_opam_files true)
(using mdx 0.4)
(maintenance_intent "(latest)")

(source (github xhtmlboi/yocaml))
(license GPL-3.0-or-later)
(authors "The XHTMLBoy <xhtmlboi@gmail.com>")
(maintainers "The XHTMLBoy <xhtmlboi@gmail.com>")

(package
  (name yocaml)
  (synopsis "Core engine of the YOCaml Static Site Generator")
  (description "YOCaml is a build system dedicated to generate static document")
  (depends
   (ocaml (>= 5.1.1))
   (logs (>= 0.7.0))
   (odoc :with-doc)
   (sherlodoc :with-doc)
   (fmt :with-test)
   (alcotest (and :with-test (>= 1.3.0)))
   (qcheck :with-test)
   (qcheck-alcotest :with-test)
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (ocamlformat :with-dev-setup)
   (ocp-indent :with-dev-setup)
   (merlin :with-dev-setup)
   (utop :with-dev-setup)))

 (package
  (name yocaml_runtime)
  (synopsis "Tool for describing runtimes (using Logs and Digestif)")
  (depends
   (ocaml (>= 5.1.1))
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (yocaml (= :version))
   (cohttp (>= 5.3.11))
   (magic-mime (>= 1.3.1))
   (logs (>= 0.7.0))
   (fmt (>= 0.9.0))
   (digestif (>= 1.2.0))))

 (package
   (name yocaml_eio)
   (synopsis "The Eio runtime YOCaml")
   (depends
    (ocaml (>= 5.1.1))
    ppx_expect
    (mdx (and :with-test (>= 2.5.0)))
    (yocaml (= :version))
    (yocaml_runtime (= :version))
    (eio (>= 1.1))
    (eio_main (>= 1.1))
    (cohttp-eio (>= 6.0.0~beta2))))

(package
  (name yocaml_unix)
  (synopsis "The Unix runtime for YOCaml")
  (depends
   (ocaml (>= 5.1.1))
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (httpcats (>= 0.0.1))
   (yocaml (= :version))
   (yocaml_runtime (= :version))))

(package
  (name yocaml_yaml)
  (synopsis "Yocaml plugin for dealing with Yaml as metadata provider")
  (depends
   (ocaml (>= 5.1.1))
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (yocaml (= :version))
   (yaml (>= 3.2.0))))

(package
 (name yocaml_otoml)
 (synopsis "Yocaml plugin for dealing with TOML as metadata provider")
 (depends
  (ocaml (>= 5.1.1))
  ppx_expect
  (mdx (and :with-test (>= 2.5.0)))
  (yocaml (= :version)) 
  (otoml (>= 1.0.5))))
 

(package
  (name yocaml_omd)
  (synopsis "Yocaml plugin for using Markdown (via OMD package) as a Markup language")
  (depends
   (ocaml (>= 5.1.1))
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (yocaml (= :version))
   (omd (>= 2.0.0~alpha4))))

(package
  (name yocaml_cmarkit)
  (synopsis "Yocaml plugin for using Markdown (via Cmarkit package) as a Markup language")
  (depends
   (ocaml (>= 5.1.1))
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (yocaml (= :version))
    cmarkit))

(package
 (name yocaml_markdown)
 (synopsis "The recommended plugin for processing Markdown documents (based on Cmarkit)")
 (depends
  (ocaml (>= 5.1.1))
   ppx_expect
  (mdx (and :with-test (>= 2.5.0)))
  (yocaml (= :version))
   cmarkit
  (hilite (>= 0.5.0))
   textmate-language))

(package
  (name yocaml_jingoo)
  (synopsis "Yocaml plugin for using Jingoo as a template language")
  (depends
   (ocaml (>= 5.1.1))
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (yocaml (= :version))
   (jingoo (>= 1.5.0))))

(package
  (name yocaml_mustache)
  (synopsis "Yocaml plugin for using Mustache as a template language")
  (depends
   (ocaml (>= 5.1.1))
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (yocaml (= :version))
   (mustache (>= 3.3.0))))

(package
  (name yocaml_liquid)
  (synopsis "Yocaml plugin for using Liquid as a template language")
  (depends
    (ocaml (>= 5.1.1))
    (dune (>= 3.18))
    ppx_expect
    (mdx (and (>= 2.5.0) :with-test))
    (yocaml (= :version))
    (liquid_ml (>= 0.1.0))
    (odoc :with-doc)))

(package
  (name yocaml_syndication)
  (synopsis "Yocaml plugin for dealing with RSS and Atom feed")
  (depends
   (ocaml (>= 5.1.1))
   (yocaml (= :version))
   (fmt :with-test)
   (alcotest (and :with-test (>= 1.3.0)))
   (qcheck :with-test)
   (qcheck-alcotest :with-test)
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))))

(package
  (name yocaml_git)
  (synopsis "Yocaml plugins for generating Yocaml program into a Git repository")
  (depends
   (ocaml (>= 5.1.1))
   ppx_expect
   (mdx (and :with-test (>= 2.5.0)))
   (lwt (>= 5.7.0))
   (mimic (>= 0.0.9))
   (cstruct (>= 6.2.0))
   (git-kv (>= 0.2.0))
   (git-net (>= 0.2.0))
   (mirage-clock (>= 4.2.0))
   (mirage-crypto-rng (>= 1.2.0))
   (yocaml (= :version))
   (yocaml_runtime (= :version))))
