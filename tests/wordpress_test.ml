let () =
  let open Alcotest in
  run "Wordpress test" [ Build_test.cases; Deps_test.cases; Util_test.cases ]
;;
