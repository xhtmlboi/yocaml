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

let%expect_test "validation - prints source and entity" =
  let source = Path.rel [ "content"; "posts"; "example.md" ] in
  let entity = "post" in
  let validation_error =
    Data.Validation.Invalid_shape { expected = "string"; given = Data.int 42 }
  in
  let exn =
    Eff.Provider_error
      {
        source = Some source
      ; target = None
      ; error = Required.Validation_error { entity; error = validation_error }
      }
  in
  Format.asprintf "%a"
    (Yocaml.Diagnostic.exception_to_diagnostic ~in_exception_handler:false
       ~custom_error:custom_printer)
    exn
  |> print_endline;
  [%expect
    {|
    --- Oh dear, an error has occurred ---
    Validation error in: ./content/posts/example.md
    Entity: `post`

    Invalid shape:
      Expected: string
      Given: `42`---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
  |}]

let%expect_test "required metadata - prints source and entity" =
  let source = Path.rel [ "content"; "posts"; "example.md" ] in
  let entity = "post" in
  let exn =
    Eff.Provider_error
      {
        source = Some source
      ; target = None
      ; error = Required.Required_metadata { entity }
      }
  in
  Format.asprintf "%a"
    (fun ppf exn ->
      Yocaml.Diagnostic.exception_to_diagnostic ~in_exception_handler:false ppf
        exn)
    exn
  |> print_endline;
  [%expect
    {|
    --- Oh dear, an error has occurred ---
    Required metadata in: ./content/posts/example.md
    Entity: `post`

    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
  |}]

let%expect_test "parsing error - prints source and message" =
  let source = Path.rel [ "content"; "posts"; "broken.md" ] in
  let given = {|author linda
age: 21
|} in
  let message =
    "Yaml: error calling parser: could not find expected ':' character"
  in
  let exn =
    Eff.Provider_error
      {
        source = Some source
      ; target = None
      ; error = Required.Parsing_error { given; message }
      }
  in
  Format.asprintf "%a"
    (fun ppf exn ->
      Yocaml.Diagnostic.exception_to_diagnostic ~in_exception_handler:false ppf
        exn)
    exn
  |> print_endline;
  [%expect
    {|
    --- Oh dear, an error has occurred ---
    Parsing error in: ./content/posts/broken.md

    Given:
    author linda
    age: 21

    Message: `Yaml: error calling parser: could not find expected ':' character`
    ---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified. |}]

let%expect_test "validation - prints target, source and entity" =
  let source = Path.rel [ "content"; "posts"; "example.md" ] in
  let target = Path.rel [ "_www"; "posts"; "example.html" ] in
  let entity = "post" in
  let validation_error =
    Data.Validation.Invalid_shape { expected = "string"; given = Data.int 42 }
  in
  let exn =
    Eff.Provider_error
      {
        source = Some source
      ; target = Some target
      ; error = Required.Validation_error { entity; error = validation_error }
      }
  in
  Format.asprintf "%a"
    (Yocaml.Diagnostic.exception_to_diagnostic ~in_exception_handler:false
       ~custom_error:custom_printer)
    exn
  |> print_endline;
  [%expect
    {|
    --- Oh dear, an error has occurred ---
    Unable to write to target ./_www/posts/example.html:
    Validation error in: ./content/posts/example.md
    Entity: `post`

    Invalid shape:
      Expected: string
      Given: `42`---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]

let%expect_test "validation - prints label and entity without target or source"
    =
  let entity = "post" in
  let validation_error =
    Data.Validation.Invalid_shape { expected = "string"; given = Data.int 42 }
  in
  let exn =
    Eff.Provider_error
      {
        source = None
      ; target = None
      ; error = Required.Validation_error { entity; error = validation_error }
      }
  in
  Format.asprintf "%a"
    (Yocaml.Diagnostic.exception_to_diagnostic ~in_exception_handler:false
       ~custom_error:custom_printer)
    exn
  |> print_endline;
  [%expect
    {|
    --- Oh dear, an error has occurred ---
    Validation error:
    Entity: `post`

    Invalid shape:
      Expected: string
      Given: `42`---
    The backtrace is not available because the function is called (according to the [in_exception_handler] parameter) outside an exception handler. This makes the trace unspecified.
    |}]
