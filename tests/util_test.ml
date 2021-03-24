open Wordpress

let split_metadata_no_metadata1 =
  let open Alcotest in
  test_case "split_metadate - no metadata 1" `Quick
  $ fun () ->
  let str = "" in
  let computed = split_metadata str in
  let expected = None, "" in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_no_metadata2 =
  let open Alcotest in
  test_case "split_metadate - no metadata 2" `Quick
  $ fun () ->
  let str =
    {|Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in vehicula lorem. Etiam erat libero, scelerisque eu placerat a, varius ut lorem. Nunc non erat id libero facilisis volutpat quis eget arcu. Pellentesque mattis congue velit non fringilla. Nulla facilisi. Vestibulum iaculis, augue at elementum fermentum, libero orci porta erat, a mattis magna magna nec leo. Vivamus felis massa, pellentesque vel suscipit ut, venenatis at metus. Nam a vehicula nunc, in ultricies purus. Cras rutrum orci leo, id ornare elit aliquam nec. Maecenas pellentesque malesuada nunc, eu elementum ipsum tincidunt in.|}
  in
  let computed = split_metadata str in
  let expected = None, str in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_no_metadata3 =
  let open Alcotest in
  test_case "split_metadate - no metadata 3" `Quick
  $ fun () ->
  let str =
    {|---Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in vehicula lorem. Etiam erat libero, scelerisque eu placerat a, varius ut lorem. Nunc non erat id libero facilisis volutpat quis eget arcu. Pellentesque mattis congue velit non fringilla. Nulla facilisi. Vestibulum iaculis, augue at elementum fermentum, libero orci porta erat, a mattis magna magna nec leo. Vivamus felis massa, pellentesque vel suscipit ut, venenatis at metus. Nam a vehicula nunc, in ultricies purus. Cras rutrum orci leo, id ornare elit aliquam nec. Maecenas pellentesque malesuada nunc, eu elementum ipsum tincidunt in.|}
  in
  let computed = split_metadata str in
  let expected = None, str in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_no_metadata4 =
  let open Alcotest in
  test_case "split_metadate - no metadata 4" `Quick
  $ fun () ->
  let str = {|---|} in
  let computed = split_metadata str in
  let expected = None, str in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_no_metadata5 =
  let open Alcotest in
  test_case "split_metadate - no metadata 5" `Quick
  $ fun () ->
  let str = {|---
no terminaison
|} in
  let computed = split_metadata str in
  let expected = None, str in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_no_metadata6 =
  let open Alcotest in
  test_case "split_metadate - no metadata 6" `Quick
  $ fun () ->
  let str = {|--
no terminaison
---
|} in
  let computed = split_metadata str in
  let expected = None, str in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_with_metadata1 =
  let open Alcotest in
  test_case "split_metadate - with metadata 1" `Quick
  $ fun () ->
  let str = {|---
foo;s
---|} in
  let computed = split_metadata str in
  let expected = Some "foo;s\n", "" in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_with_metadata2 =
  let open Alcotest in
  test_case "split_metadate - with metadata 2" `Quick
  $ fun () ->
  let str = {|---
foo;s
---
ok ok ok

|} in
  let computed = split_metadata str in
  let expected = Some "foo;s\n", "\nok ok ok\n\n" in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_with_metadata3 =
  let open Alcotest in
  test_case "split_metadate - with metadata 3" `Quick
  $ fun () ->
  let str =
    {|---
foo;s -------
hello
--
fooo ---
bar    
---test
ok ok ok

|}
  in
  let computed = split_metadata str in
  let expected =
    Some "foo;s -------\nhello\n--\nfooo ---\nbar    \n", "test\nok ok ok\n\n"
  in
  check (pair (option string) string) "should be equal" computed expected
;;

let split_metadata_with_metadata4 =
  let open Alcotest in
  test_case "split_metadate - with metadata 4" `Quick
  $ fun () ->
  let str =
    {|--- A discared text
foo;s -------
hello
--
fooo ---
bar    
---test
ok ok ok

|}
  in
  let computed = split_metadata str in
  let expected =
    Some "foo;s -------\nhello\n--\nfooo ---\nbar    \n", "test\nok ok ok\n\n"
  in
  check (pair (option string) string) "should be equal" computed expected
;;

let cases =
  ( "Util"
  , [ split_metadata_no_metadata1
    ; split_metadata_no_metadata2
    ; split_metadata_no_metadata3
    ; split_metadata_no_metadata4
    ; split_metadata_no_metadata5
    ; split_metadata_no_metadata6
    ; split_metadata_with_metadata1
    ; split_metadata_with_metadata2
    ; split_metadata_with_metadata3
    ; split_metadata_with_metadata4
    ] )
;;
