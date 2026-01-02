open Yocaml

type Data.Validation.custom_error += Test_custom_error

let custom_printer ppf = function
  | Test_custom_error -> Format.fprintf ppf "test custom error"
  | _ -> ()

let validation_error_to_string err =
  Format.asprintf "%a"
    (Yocaml.Diagnostic.pp_validation_error custom_printer)
    err

let%expect_test "validation - invalid shape" =
  let err =
    Data.Validation.Invalid_shape { expected = "string"; given = Data.int 10 }
  in
  print_endline (validation_error_to_string err);
  [%expect {|
Invalid shape:
  Expected: string
  Given: `10`
|}]

let%expect_test "validation - with_message" =
  let err =
    Data.Validation.With_message
      { message = "value is not allowed here"; given = "42" }
  in
  print_endline (validation_error_to_string err);
  [%expect {|
Message:
  Message: value is not allowed here
  Given: `42`
|}]

let%expect_test "validation - custom error" =
  let err = Data.Validation.Custom Test_custom_error in
  print_endline (validation_error_to_string err);
  [%expect {|
Custom error:
  test custom error
|}]

let%expect_test "validation - record with one error" =
  let err =
    Data.Validation.Invalid_record
      {
        given = [ ("title", Data.int 1) ]
      ; errors =
          Nel.singleton (Data.Validation.Missing_field { field = "name" })
      }
  in
  print_endline (validation_error_to_string err);
  [%expect
    {|
Invalid record:
  Errors (1):
  1) Missing field `name`
  
  Given record:
    title = `1`
|}]

let%expect_test "validation - record with multiple errors" =
  let err =
    Data.Validation.Invalid_record
      {
        given = [ ("title", Data.int 1); ("age", Data.int 2) ]
      ; errors =
          Nel.from_list
            [
              Data.Validation.Invalid_field
                {
                  field = "title"
                ; given = Data.int 1
                ; error =
                    Data.Validation.Invalid_shape
                      { expected = "string"; given = Data.int 1 }
                }
            ; Data.Validation.Missing_field { field = "name" }
            ]
          |> Option.get
      }
  in
  print_endline (validation_error_to_string err);
  [%expect
    {|
    Invalid record:
      Errors (2):
      1) Invalid field `title`:
           Invalid shape:
             Expected: string
             Given: `1`

      2) Missing field `name`

      Given record:
        title = `1`
        age = `2`
  |}]

let%expect_test "validation - nested record" =
  let err =
    Data.Validation.Invalid_record
      {
        given = [ ("author", Data.record [ ("name", Data.int 1) ]) ]
      ; errors =
          Nel.singleton
            (Data.Validation.Invalid_subrecord
               (Data.Validation.Invalid_record
                  {
                    given = [ ("name", Data.int 1) ]
                  ; errors =
                      Nel.singleton
                        (Data.Validation.Invalid_field
                           {
                             field = "name"
                           ; given = Data.int 1
                           ; error =
                               Data.Validation.Invalid_shape
                                 { expected = "string"; given = Data.int 1 }
                           })
                  }))
      }
  in
  print_endline (validation_error_to_string err);
  [%expect
    {|
    Invalid record:
      Errors (1):
      1) Invalid subrecord:
           Invalid record:
             Errors (1):
             1) Invalid field `name`:
                  Invalid shape:
                    Expected: string
                    Given: `1`

             Given record:
               name = `1`

      Given record:
        author = `{"name": 1}`
  |}]

let%expect_test "validation - invalid list with one error" =
  let err =
    Data.Validation.Invalid_list
      {
        given = [ Data.string "ok"; Data.int 42; Data.string "also ok" ]
      ; errors =
          Nel.singleton
            ( 1
            , Data.Validation.Invalid_shape
                { expected = "string"; given = Data.int 42 } )
      }
  in
  print_endline (validation_error_to_string err);
  [%expect
    {|
    Invalid list:
      Errors (1):
      1) At index 1:
        Invalid shape:
          Expected: string
          Given: `42`

      Given list:
        [0] = `"ok"`
        [1] = `42`
        [2] = `"also ok"`
  |}]

let%expect_test "validation - invalid list with nested record" =
  let err =
    Data.Validation.Invalid_list
      {
        given =
          [
            Data.int 1
          ; Data.record [ ("title", Data.int 2) ]
          ; Data.int 3
          ; Data.string "ok"
          ]
      ; errors =
          Nel.from_list
            [
              ( 0
              , Data.Validation.Invalid_shape
                  { expected = "string"; given = Data.int 1 } )
            ; ( 1
              , Data.Validation.Invalid_record
                  {
                    given = [ ("title", Data.int 2) ]
                  ; errors =
                      Nel.singleton
                        (Data.Validation.Missing_field { field = "name" })
                  } )
            ; ( 2
              , Data.Validation.Invalid_shape
                  { expected = "string"; given = Data.int 3 } )
            ]
          |> Option.get
      }
  in
  print_endline (validation_error_to_string err);
  [%expect
    {|
    Invalid list:
      Errors (3):
      1) At index 0:
        Invalid shape:
          Expected: string
          Given: `1`

      2) At index 1:
        Invalid record:
          Errors (1):
          1) Missing field `name`

          Given record:
            title = `2`

      3) At index 2:
        Invalid shape:
          Expected: string
          Given: `3`

      Given list:
        [0] = `1`
        [1] = `{"title": 2}`
        [2] = `3`
        [3] = `"ok"`
  |}]
