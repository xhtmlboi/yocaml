open Wordpress

let simple_file_copy =
  let open Alcotest in
  test_case
    "Simple copying using [read_file] when the target is not present"
    `Quick
  @@ fun () ->
  let dummy =
    Dummy.(
      make
        ~filesystem:
          [ file
              ~mtime:10
              ~content:"Hello World, Hello Wordpress!"
              "source.txt"
          ])
      ()
  in
  let () =
    check
      bool
      "the target should not exists before handling"
      false
      (Dummy.file_exists dummy "target.build")
  in
  let arrow = Build.read_file "source.txt" in
  let deps =
    Build.dependencies arrow |> Deps.to_list |> List.map Deps.to_filepath
  in
  check (list string) "the deps should be equal" [ "source.txt" ] deps;
  Dummy.handle dummy (Build.run "target.build" arrow);
  check
    bool
    "the target should exists after handling"
    true
    (Dummy.file_exists dummy "target.build");
  check
    (option string)
    "target's content should be equal to source's content"
    (Some "Hello World, Hello Wordpress!")
    (Dummy.get_file_content dummy "target.build")
;;

let simple_file_copy_with_multiple_deps =
  let open Alcotest in
  test_case
    "Simple copying using [read_file] with multiple dependencies when the \
     target is not present"
    `Quick
  @@ fun () ->
  let dummy =
    Dummy.(
      make
        ~filesystem:
          [ file
              ~mtime:1
              ~content:"Hello World, Hello Wordpress!"
              "source1.txt"
          ; file ~mtime:10 ~content:"Foo" "source2.txt"
          ; file ~mtime:1 ~content:"Bar" "source3.txt"
          ])
      ()
  in
  let () =
    check
      bool
      "the target should not exists before handling"
      false
      (Dummy.file_exists dummy "target.build")
  in
  let arrow =
    let open Build in
    read_file "source1.txt"
    >>> concat_content ~separator:"\t" "source2.txt"
    >>> concat_content ~separator:"\t" "source3.txt"
  in
  let deps =
    Build.dependencies arrow |> Deps.to_list |> List.map Deps.to_filepath
  in
  check
    (list string)
    "the deps should be equal"
    [ "source1.txt"; "source2.txt"; "source3.txt" ]
    deps;
  Dummy.handle dummy (Build.run "target.build" arrow);
  check
    bool
    "the target should exists after handling"
    true
    (Dummy.file_exists dummy "target.build");
  check
    (option string)
    "target's content should be equal to source's content"
    (Some "Hello World, Hello Wordpress!\tFoo\tBar")
    (Dummy.get_file_content dummy "target.build")
;;

let cases = "Build", [ simple_file_copy; simple_file_copy_with_multiple_deps ]
