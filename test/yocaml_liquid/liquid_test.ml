(* Test for yocaml_liquid plugin *)
open Yocaml_liquid
open Liquid_ml.Exports

let test_basic_rendering () =
  Printf.printf "=== Testing Basic Liquid Rendering ===\n";
  
  (* Test with simple liquid values directly *)
  let template_content = "Hello {{ name }}! You are {{ age }} years old." in
  let parameters = [
    ("name", String "Alice");
    ("age", Number 30.0)
  ] in
  let result = render parameters template_content in
  Printf.printf "Template: %s\n" template_content;
  Printf.printf "Result: %s\n" result;
  Printf.printf "\n"

let test_with_objects () =
  Printf.printf "=== Testing Object Access ===\n";
  
  let template_content = "{{ user.name }} works at {{ user.company }}" in
  let user_obj = Object.empty
    |> Object.add "name" (String "Bob")
    |> Object.add "company" (String "Tech Corp") in
  let parameters = [("user", Object user_obj)] in
  let result = render parameters template_content in
  Printf.printf "Template: %s\n" template_content;
  Printf.printf "Result: %s\n" result;
  Printf.printf "\n"

let test_with_lists () =
  Printf.printf "=== Testing List Iteration ===\n";
  
  let template_content = "{% for item in items %}{{ item }} {% endfor %}" in
  let items = List [String "apple"; String "banana"; String "cherry"] in
  let parameters = [("items", items)] in
  let result = render parameters template_content in
  Printf.printf "Template: %s\n" template_content;
  Printf.printf "Result: %s\n" result;
  Printf.printf "\n"

let test_conditionals () =
  Printf.printf "=== Testing Conditionals ===\n";
  
  let template_content = "{% if user_logged_in %}Welcome back!{% else %}Please log in{% endif %}" in
  let parameters1 = [("user_logged_in", Bool true)] in
  let parameters2 = [("user_logged_in", Bool false)] in
  
  let result1 = render parameters1 template_content in
  let result2 = render parameters2 template_content in
  
  Printf.printf "Template: %s\n" template_content;
  Printf.printf "When true: %s\n" result1;
  Printf.printf "When false: %s\n" result2;
  Printf.printf "\n"

let test_error_handling () =
  Printf.printf "=== Testing Error Handling ===\n";
  
  let template_content = "{{ undefined_variable }}" in
  let parameters = [] in
  
  (* Test with strict mode *)
  let result_strict = 
    try 
      Some (render ~strict:true parameters template_content)
    with 
    | _ -> None in
  
  (* Test with non-strict mode *)
  let result_non_strict = render ~strict:false parameters template_content in
  
  Printf.printf "Template: %s\n" template_content;
  Printf.printf "Strict mode result: %s\n" 
    (match result_strict with Some s -> s | None -> "ERROR (as expected)");
  Printf.printf "Non-strict mode result: %s\n" result_non_strict;
  Printf.printf "\n"

let () =
  Printf.printf "Running YoCaml_liquid tests...\n\n";
  test_basic_rendering ();
  test_with_objects ();
  test_with_lists ();
  test_conditionals ();
  test_error_handling ();
  Printf.printf "All tests completed!\n"