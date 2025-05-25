(* YOCaml a static blog generator.
   Copyright (C) 2024 The Funkyworkers and The YOCaml's developers

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

open Test_lib

let test_conditional_1 =
  let open Alcotest in
  test_case "Some [when] usage - 1" `Quick (fun () ->
      let fs =
        Fs.(
          from_list
            [
              dir "."
                [
                  dir "projects"
                    [
                      dir "project_a"
                        [
                          file "desc" "A description"
                        ; file "content" "A content"
                        ]
                    ; dir "project_b" [ file "desc" "B description" ]
                    ; dir "project_c"
                        [
                          file "desc" "C description"
                        ; file "content" "C content"
                        ]
                    ]
                ]
            ])
      in
      let task file =
        let open Yocaml in
        let open Yocaml.Task in
        let desc = Path.(file / "desc") and content = Path.(file / "content") in
        Pipeline.read_file desc
        &&& when_
              (Pipeline.file_exists content)
              (Pipeline.read_file content)
              (Task.const "no-content")
        >>| fun (d, c) -> (d, d ^ ": " ^ c)
      in
      let program cache =
        let open Yocaml in
        let open Yocaml.Eff.Infix in
        Eff.return cache
        >>= Action.batch ~only:`Directories
              Path.(rel [ "projects" ])
              (fun file ->
                let target =
                  file
                  |> Path.move ~into:(Path.rel [ "_build"; "projects" ])
                  |> Path.change_extension "html"
                in
                Action.Static.write_file_with_metadata target (task file))
      in
      let trace = Fs.create_trace ~time:0 fs in
      let first_cache = Yocaml.Cache.empty in
      let trace, cache = Fs.run ~trace program first_cache in
      let fs = Fs.trace_system trace in
      check string "Ensure project_a content"
        (Fs.cat fs "./_build/projects/project_a.html")
        "A description: A content";
      check string "Ensure project_b content"
        (Fs.cat fs "./_build/projects/project_b.html")
        "B description: no-content";
      check string "Ensure project_c content"
        (Fs.cat fs "./_build/projects/project_c.html")
        "C description: C content";
      (* We double the test for ensuring that dependencies are not broken. *)
      let trace, _cache = Fs.run ~trace program cache in
      let fs = Fs.trace_system trace in
      check string "Ensure project_a content"
        (Fs.cat fs "./_build/projects/project_a.html")
        "A description: A content";
      check string "Ensure project_b content"
        (Fs.cat fs "./_build/projects/project_b.html")
        "B description: no-content";
      check string "Ensure project_c content"
        (Fs.cat fs "./_build/projects/project_c.html")
        "C description: C content")

let cases = ("Yocaml.conditionals", [ test_conditional_1 ])
