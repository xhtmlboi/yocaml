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

let () =
  Alcotest.run "Yocaml test"
    [
      Fs_test.cases
    ; Path_test.cases
    ; Csexp_test.cases
    ; Eff_test.cases
    ; Deps_test.cases
    ; Cache_test.cases
    ; Pipeline_test.cases
    ; Action_test.cases
    ]
