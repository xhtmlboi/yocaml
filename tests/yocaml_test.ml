let () =
  let open Alcotest in
  run
    "YOCaml test"
    [ Build_test.cases
    ; Deps_test.cases
    ; Util_test.cases
    ; Key_value_test.cases
    ; Metadata_test.cases
    ]
;;
