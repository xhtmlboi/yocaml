open Yocaml
open Util
open Common_test

let pp_dow ppf d = Format.fprintf ppf "%s" $ Date.day_of_week_to_string d

let eq_dow a b =
  let open Date in
  match a, b with
  | Mon, Mon | Tue, Tue | Wed, Wed | Thu, Thu | Fri, Fri | Sat, Sat | Sun, Sun
    -> true
  | _ -> false
;;

let validable_dow = validate_testable pp_dow eq_dow

let make1 =
  let open Alcotest in
  test_case "Date.make 1" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> make ~time:(12, 20, 32) 2021 Oct 3)
  and expected = valid "2021-10-03 12:20:32" in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let make2 =
  let open Alcotest in
  test_case "Date.make 2" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> make 2012 Feb 29)
  and expected = valid "2012-02-29" in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let from_string1 =
  let open Alcotest in
  test_case "Date.from_string 1" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> from_string "2012-02-29")
  and expected = valid "2012-02-29" in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let from_string2 =
  let open Alcotest in
  test_case "Date.from_string 2" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> from_string "2012-02-29 20:58:59")
  and expected = valid "2012-02-29 20:58:59" in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let make_invalid =
  let open Alcotest in
  test_case "Date.make invalid 1" `Quick
  $ fun () ->
  let open Validate in
  let open Applicative in
  let computed = Date.(to_string <$> make ~time:(34, -9, 62) 2021 Oct 3)
  and expected =
    let open Preface.Nonempty_list in
    Validate.invalid
      (Error.Invalid_range (34, 0, 24)
      :: Error.Invalid_range (-9, 0, 60)
      :: Last (Error.Invalid_range (62, 0, 60)))
  in
  check
    (validate_testable Format.pp_print_string String.equal)
    "should be equal"
    computed
    expected
;;

let make_day_of_week_1 =
  let open Alcotest in
  List.map
    (fun (day, date) ->
      test_case
        (Format.asprintf "dow: %a" (Validate.pp Date.pp) date)
        `Quick
        (fun () ->
          let open Validate in
          let open Applicative in
          let computed_day = Date.day_of_week <$> date
          and expected = valid day in
          check validable_dow "Should be equal" computed_day expected))
    Date.
      [ Wed, make 2021 Jul 14
      ; Tue, make 1789 Jul 14
      ; Wed, make 2021 Aug 11
      ; Thu, make 2021 Aug 12
      ; Fri, make 2021 Aug 13
      ; Sat, make 2021 Aug 14
      ; Sun, make 2021 Aug 15
      ; Mon, make 2021 Aug 16
      ; Tue, make 2021 Aug 17
      ; Wed, make 2021 Aug 18
      ; Thu, make 2021 Aug 19
      ; Fri, make 2021 Aug 20
      ; Sat, make 2021 Aug 21
      ; Sun, make 2021 Aug 22
      ; Mon, make 2021 Aug 23
      ; Tue, make 2021 Aug 24
      ; Wed, make 2021 Aug 25
      ; Thu, make 2021 Aug 26
      ; Fri, make 2021 Aug 27
      ; Sat, make 2021 Aug 28
      ; Sun, make 2021 Aug 29
      ; Mon, make 2021 Aug 30
      ; Tue, make 2021 Aug 31
      ; Wed, make 2021 Sep 1
      ; Thu, make 2021 Sep 2
      ; Fri, make 2021 Sep 3
      ; Sat, make 2021 Sep 4
      ; Sun, make 2021 Sep 5
      ; Mon, make 2021 Sep 6
      ; Tue, make 2021 Sep 7
      ; Wed, make 2021 Sep 8
      ; Thu, make 2021 Sep 9
      ; Fri, make 2021 Sep 10
      ; Sat, make 2021 Sep 11
      ; Sun, make 2021 Sep 12
      ; Mon, make 2021 Sep 13
      ; Tue, make 2021 Sep 14
      ; Wed, make 2021 Sep 15
      ; Thu, make 2021 Sep 16
      ; Fri, make 2021 Sep 17
      ; Sat, make 2021 Sep 18
      ; Sun, make 2021 Sep 19
      ; Mon, make 2021 Sep 20
      ; Tue, make 2021 Sep 21
      ; Wed, make 2021 Sep 22
      ; Mon, make 1600 Jan 10
      ; Tue, make 1600 Jan 11
      ; Wed, make 1600 Jan 12
      ; Thu, make 1600 Jan 13
      ; Fri, make 1600 Jan 14
      ; Sat, make 1600 Jan 15
      ; Sun, make 1600 Jan 16
      ; Mon, make 1600 Jan 17
      ; Tue, make 1600 Jan 18
      ; Wed, make 1600 Jan 19
      ; Thu, make 1600 Jan 20
      ; Fri, make 1600 Jan 21
      ; Sat, make 1600 Jan 22
      ; Sun, make 1600 Jan 23
      ; Mon, make 1600 Jan 24
      ; Tue, make 1600 Jan 25
      ; Wed, make 1600 Jan 26
      ; Thu, make 1600 Jan 27
      ; Fri, make 1600 Jan 28
      ; Sat, make 1600 Jan 29
      ; Sun, make 1600 Jan 30
      ; Mon, make 1600 Jan 31
      ; Tue, make 1600 Feb 1
      ; Wed, make 1600 Feb 2
      ; Thu, make 1600 Feb 3
      ; Fri, make 1600 Feb 4
      ; Sat, make 1600 Feb 5
      ; Sun, make 1600 Feb 6
      ; Mon, make 1600 Feb 7
      ; Tue, make 1600 Feb 8
      ; Wed, make 1600 Feb 9
      ; Thu, make 1600 Feb 10
      ; Fri, make 1600 Feb 11
      ; Sat, make 1600 Feb 12
      ; Sun, make 1600 Feb 13
      ; Mon, make 1600 Feb 14
      ; Tue, make 1600 Feb 15
      ; Wed, make 1600 Feb 16
      ; Thu, make 1600 Feb 17
      ; Fri, make 1600 Feb 18
      ; Sat, make 1600 Feb 19
      ; Sun, make 1600 Feb 20
      ; Mon, make 1600 Feb 21
      ; Tue, make 1600 Feb 22
      ; Wed, make 1600 Feb 23
      ; Thu, make 1600 Feb 24
      ; Fri, make 1600 Feb 25
      ; Sat, make 1600 Feb 26
      ; Sun, make 1600 Feb 27
      ; Mon, make 1600 Feb 28
      ; Tue, make 1600 Feb 29
      ; Wed, make 1600 Mar 1
      ; Thu, make 1600 Mar 2
      ; Fri, make 1600 Mar 3
      ; Sat, make 1600 Mar 4
      ; Sun, make 1600 Mar 5
      ; Mon, make 1600 Mar 6
      ; Tue, make 1600 Mar 7
      ; Wed, make 1600 Mar 8
      ; Thu, make 1600 Mar 9
      ; Fri, make 1600 Mar 10
      ; Sat, make 1600 Mar 11
      ; Sun, make 1600 Mar 12
      ; Mon, make 1600 Mar 13
      ; Tue, make 1600 Mar 14
      ; Wed, make 1600 Mar 15
      ; Thu, make 1600 Mar 16
      ; Fri, make 1600 Mar 17
      ; Sat, make 1600 Mar 18
      ; Sun, make 1600 Mar 19
      ; Mon, make 1600 Mar 20
      ; Tue, make 1600 Mar 21
      ; Wed, make 1600 Mar 22
      ; Thu, make 1600 Mar 23
      ; Fri, make 1600 Mar 24
      ; Sat, make 1600 Mar 25
      ; Sun, make 1600 Mar 26
      ; Mon, make 1600 Mar 27
      ; Tue, make 1600 Mar 28
      ; Wed, make 1600 Mar 29
      ; Thu, make 1600 Mar 30
      ; Fri, make 1600 Mar 31
      ; Sat, make 1600 Apr 1
      ; Sun, make 1600 Apr 2
      ; Mon, make 1600 Apr 3
      ; Tue, make 1600 Apr 4
      ; Wed, make 1600 Apr 5
      ; Thu, make 1600 Apr 6
      ; Fri, make 1600 Apr 7
      ; Wed, make 1999 Oct 13
      ; Thu, make 1999 Oct 14
      ; Fri, make 1999 Oct 15
      ; Sat, make 1999 Oct 16
      ; Sun, make 1999 Oct 17
      ; Mon, make 1999 Oct 18
      ; Tue, make 1999 Oct 19
      ; Wed, make 1999 Oct 20
      ; Thu, make 1999 Oct 21
      ; Fri, make 1999 Oct 22
      ; Sat, make 1999 Oct 23
      ; Sun, make 1999 Oct 24
      ; Mon, make 1999 Oct 25
      ; Tue, make 1999 Oct 26
      ; Wed, make 1999 Oct 27
      ; Thu, make 1999 Oct 28
      ; Fri, make 1999 Oct 29
      ; Sat, make 1999 Oct 30
      ; Sun, make 1999 Oct 31
      ; Mon, make 1999 Nov 1
      ; Tue, make 1999 Nov 2
      ; Wed, make 1999 Nov 3
      ; Thu, make 1999 Nov 4
      ; Fri, make 1999 Nov 5
      ; Sat, make 1999 Nov 6
      ; Sun, make 1999 Nov 7
      ; Mon, make 1999 Nov 8
      ; Tue, make 1999 Nov 9
      ; Wed, make 1999 Nov 10
      ; Thu, make 1999 Nov 11
      ; Fri, make 1999 Nov 12
      ; Sat, make 1999 Nov 13
      ; Sun, make 1999 Nov 14
      ; Mon, make 1999 Nov 15
      ; Tue, make 1999 Nov 16
      ; Wed, make 1999 Nov 17
      ; Thu, make 1999 Nov 18
      ; Fri, make 1999 Nov 19
      ; Sat, make 1999 Nov 20
      ; Sun, make 1999 Nov 21
      ; Mon, make 1999 Nov 22
      ; Tue, make 1999 Nov 23
      ; Wed, make 1999 Nov 24
      ; Thu, make 1999 Nov 25
      ; Fri, make 1999 Nov 26
      ; Sat, make 1999 Nov 27
      ; Sun, make 1999 Nov 28
      ; Mon, make 1999 Nov 29
      ; Tue, make 1999 Nov 30
      ; Wed, make 1999 Dec 1
      ; Thu, make 1999 Dec 2
      ; Fri, make 1999 Dec 3
      ; Sat, make 1999 Dec 4
      ; Sun, make 1999 Dec 5
      ; Mon, make 1999 Dec 6
      ; Tue, make 1999 Dec 7
      ; Wed, make 1999 Dec 8
      ; Thu, make 1999 Dec 9
      ; Fri, make 1999 Dec 10
      ; Sat, make 1999 Dec 11
      ; Sun, make 1999 Dec 12
      ; Mon, make 1999 Dec 13
      ; Tue, make 1999 Dec 14
      ; Wed, make 1999 Dec 15
      ; Thu, make 1999 Dec 16
      ; Fri, make 1999 Dec 17
      ; Sat, make 1999 Dec 18
      ; Sun, make 1999 Dec 19
      ; Mon, make 1999 Dec 20
      ; Tue, make 1999 Dec 21
      ; Wed, make 1999 Dec 22
      ; Thu, make 1999 Dec 23
      ; Fri, make 1999 Dec 24
      ; Sat, make 1999 Dec 25
      ; Sun, make 1999 Dec 26
      ; Mon, make 1999 Dec 27
      ; Tue, make 1999 Dec 28
      ; Wed, make 1999 Dec 29
      ; Thu, make 1999 Dec 30
      ; Fri, make 1999 Dec 31
      ; Sat, make 2000 Jan 1
      ; Sun, make 2000 Jan 2
      ; Mon, make 2000 Jan 3
      ; Tue, make 2000 Jan 4
      ; Wed, make 2000 Jan 5
      ; Thu, make 2000 Jan 6
      ; Fri, make 2000 Jan 7
      ; Sat, make 2000 Jan 8
      ; Sun, make 2000 Jan 9
      ; Mon, make 2000 Jan 10
      ; Tue, make 2000 Jan 11
      ; Wed, make 2000 Jan 12
      ; Thu, make 2000 Jan 13
      ; Fri, make 2000 Jan 14
      ; Sat, make 2000 Jan 15
      ; Sun, make 2000 Jan 16
      ; Mon, make 2000 Jan 17
      ; Tue, make 2000 Jan 18
      ; Wed, make 2000 Jan 19
      ; Thu, make 2000 Jan 20
      ; Fri, make 2000 Jan 21
      ; Sat, make 2000 Jan 22
      ; Wed, make 3000 Jan 1
      ; Thu, make 3000 Jan 2
      ; Fri, make 3000 Jan 3
      ; Sat, make 3000 Jan 4
      ; Sun, make 3000 Jan 5
      ; Mon, make 3000 Jan 6
      ; Tue, make 3000 Jan 7
      ; Wed, make 3000 Jan 8
      ; Thu, make 3000 Jan 9
      ; Fri, make 3000 Jan 10
      ; Sat, make 3000 Jan 11
      ; Sun, make 3000 Jan 12
      ; Mon, make 3000 Jan 13
      ; Tue, make 3000 Jan 14
      ; Wed, make 3000 Jan 15
      ; Thu, make 3000 Jan 16
      ; Fri, make 3000 Jan 17
      ; Sat, make 3000 Jan 18
      ; Sun, make 3000 Jan 19
      ; Mon, make 3000 Jan 20
      ; Tue, make 3000 Jan 21
      ; Wed, make 3000 Jan 22
      ; Thu, make 3000 Jan 23
      ; Fri, make 3000 Jan 24
      ; Sat, make 3000 Jan 25
      ; Sun, make 3000 Jan 26
      ; Mon, make 3000 Jan 27
      ; Tue, make 3000 Jan 28
      ; Wed, make 3000 Jan 29
      ; Thu, make 3000 Jan 30
      ; Fri, make 3000 Jan 31
      ; Sat, make 3000 Feb 1
      ; Sun, make 3000 Feb 2
      ; Mon, make 3000 Feb 3
      ; Tue, make 3000 Feb 4
      ; Wed, make 3000 Feb 5
      ; Thu, make 3000 Feb 6
      ; Fri, make 3000 Feb 7
      ; Sat, make 3000 Feb 8
      ; Sun, make 3000 Feb 9
      ; Mon, make 3000 Feb 10
      ; Tue, make 3000 Feb 11
      ; Wed, make 3000 Feb 12
      ; Thu, make 3000 Feb 13
      ; Fri, make 3000 Feb 14
      ; Sat, make 3000 Feb 15
      ; Sun, make 3000 Feb 16
      ; Mon, make 3000 Feb 17
      ; Tue, make 3000 Feb 18
      ; Wed, make 3000 Feb 19
      ; Thu, make 3000 Feb 20
      ; Fri, make 3000 Feb 21
      ; Sat, make 3000 Feb 22
      ; Sun, make 3000 Feb 23
      ; Mon, make 3000 Feb 24
      ; Tue, make 3000 Feb 25
      ; Wed, make 3000 Feb 26
      ; Thu, make 3000 Feb 27
      ; Fri, make 3000 Feb 28
      ; Sat, make 3000 Mar 1
      ; Sun, make 3000 Mar 2
      ; Mon, make 3000 Mar 3
      ; Tue, make 3000 Mar 4
      ; Wed, make 3000 Mar 5
      ; Thu, make 3000 Mar 6
      ; Fri, make 3000 Mar 7
      ; Sat, make 3000 Mar 8
      ; Sun, make 3000 Mar 9
      ; Mon, make 3000 Mar 10
      ; Tue, make 3000 Mar 11
      ; Wed, make 3000 Mar 12
      ; Thu, make 3000 Mar 13
      ; Fri, make 3000 Mar 14
      ; Sat, make 3000 Mar 15
      ; Sun, make 3000 Mar 16
      ; Mon, make 3000 Mar 17
      ; Tue, make 3000 Mar 18
      ; Wed, make 3000 Mar 19
      ; Thu, make 3000 Mar 20
      ; Fri, make 3000 Mar 21
      ; Sat, make 3000 Mar 22
      ; Sun, make 3000 Mar 23
      ; Mon, make 3000 Mar 24
      ; Tue, make 3000 Mar 25
      ; Wed, make 3000 Mar 26
      ; Thu, make 3000 Mar 27
      ; Fri, make 3000 Mar 28
      ; Sat, make 3000 Mar 29
      ; Sun, make 3000 Mar 30
      ; Mon, make 3000 Mar 31
      ; Tue, make 3000 Apr 1
      ; Wed, make 3000 Apr 2
      ; Thu, make 3000 Apr 3
      ; Fri, make 3000 Apr 4
      ; Sat, make 3000 Apr 5
      ; Sun, make 3000 Apr 6
      ; Mon, make 3000 Apr 7
      ; Tue, make 3000 Apr 8
      ; Wed, make 3000 Apr 9
      ; Thu, make 3000 Apr 10
      ; Fri, make 3000 Apr 11
      ; Sat, make 3000 Apr 12
      ; Sun, make 3000 Apr 13
      ; Mon, make 3000 Apr 14
      ; Tue, make 3000 Apr 15
      ; Wed, make 3000 Apr 16
      ; Thu, make 3000 Apr 17
      ; Fri, make 3000 Apr 18
      ; Sat, make 3000 Apr 19
      ; Sun, make 3000 Apr 20
      ; Mon, make 3000 Apr 21
      ; Tue, make 3000 Apr 22
      ; Wed, make 3000 Apr 23
      ; Thu, make 3000 Apr 24
      ; Fri, make 3000 Apr 25
      ; Sat, make 3000 Apr 26
      ; Sun, make 3000 Apr 27
      ; Mon, make 3000 Apr 28
      ; Tue, make 3000 Apr 29
      ; Wed, make 3000 Apr 30
      ; Thu, make 3000 May 1
      ; Fri, make 3000 May 2
      ; Sat, make 3000 May 3
      ; Sun, make 3000 May 4
      ; Mon, make 3000 May 5
      ; Tue, make 3000 May 6
      ; Wed, make 3000 May 7
      ; Thu, make 3000 May 8
      ; Fri, make 3000 May 9
      ; Sat, make 3000 May 10
      ; Sun, make 3000 May 11
      ; Mon, make 3000 May 12
      ; Tue, make 3000 May 13
      ; Wed, make 3000 May 14
      ; Thu, make 3000 May 15
      ; Fri, make 3000 May 16
      ; Sat, make 3000 May 17
      ; Sun, make 3000 May 18
      ; Mon, make 3000 May 19
      ; Tue, make 3000 May 20
      ; Wed, make 3000 May 21
      ; Thu, make 3000 May 22
      ; Fri, make 3000 May 23
      ; Sat, make 3000 May 24
      ; Sun, make 3000 May 25
      ; Mon, make 3000 May 26
      ; Tue, make 3000 May 27
      ; Wed, make 3000 May 28
      ; Thu, make 3000 May 29
      ; Fri, make 3000 May 30
      ; Sat, make 3000 May 31
      ; Sun, make 3000 Jun 1
      ; Mon, make 3000 Jun 2
      ; Tue, make 3000 Jun 3
      ; Wed, make 3000 Jun 4
      ; Thu, make 3000 Jun 5
      ; Fri, make 3000 Jun 6
      ; Sat, make 3000 Jun 7
      ; Sun, make 3000 Jun 8
      ; Mon, make 3000 Jun 9
      ; Tue, make 3000 Jun 10
      ; Wed, make 3000 Jun 11
      ; Thu, make 3000 Jun 12
      ; Fri, make 3000 Jun 13
      ; Sat, make 3000 Jun 14
      ; Sun, make 3000 Jun 15
      ; Mon, make 3000 Jun 16
      ; Tue, make 3000 Jun 17
      ; Wed, make 3000 Jun 18
      ; Thu, make 3000 Jun 19
      ; Fri, make 3000 Jun 20
      ; Sat, make 3000 Jun 21
      ; Sun, make 3000 Jun 22
      ; Mon, make 3000 Jun 23
      ; Tue, make 3000 Jun 24
      ; Wed, make 3000 Jun 25
      ; Thu, make 3000 Jun 26
      ; Fri, make 3000 Jun 27
      ; Sat, make 3000 Jun 28
      ; Sun, make 3000 Jun 29
      ; Mon, make 3000 Jun 30
      ; Tue, make 3000 Jul 1
      ; Wed, make 3000 Jul 2
      ; Thu, make 3000 Jul 3
      ; Fri, make 3000 Jul 4
      ; Sat, make 3000 Jul 5
      ; Sun, make 3000 Jul 6
      ; Mon, make 3000 Jul 7
      ; Tue, make 3000 Jul 8
      ; Wed, make 3000 Jul 9
      ; Thu, make 3000 Jul 10
      ; Fri, make 3000 Jul 11
      ; Sat, make 3000 Jul 12
      ; Sun, make 3000 Jul 13
      ; Mon, make 3000 Jul 14
      ; Tue, make 3000 Jul 15
      ; Wed, make 3000 Jul 16
      ; Thu, make 3000 Jul 17
      ; Fri, make 3000 Jul 18
      ; Sat, make 3000 Jul 19
      ; Sun, make 3000 Jul 20
      ; Mon, make 3000 Jul 21
      ]
;;

let cases =
  ( "Date"
  , [ make1; make2; from_string1; from_string2; make_invalid ]
    @ make_day_of_week_1 )
;;
