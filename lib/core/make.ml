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

module Data_reader (DP : Required.DATA_PROVIDER) = struct
  module Eff = struct
    let read_file_with_metadata (type a)
        (module R : Required.DATA_READABLE with type t = a) ?extraction_strategy
        ?snapshot ~on path =
      Eff.read_file_with_metadata
        (module DP)
        (module R)
        ?extraction_strategy ?snapshot ~on path

    let read_file_as_metadata (type a)
        (module R : Required.DATA_READABLE with type t = a) ?snapshot ~on path =
      Eff.read_file_as_metadata (module DP) (module R) ?snapshot ~on path
  end

  module Pipeline = struct
    let read_file_with_metadata (type a)
        (module R : Required.DATA_READABLE with type t = a) ?extraction_strategy
        ?snapshot path =
      Pipeline.read_file_with_metadata
        (module DP)
        (module R)
        ?extraction_strategy ?snapshot path

    let read_file_as_metadata (type a)
        (module R : Required.DATA_READABLE with type t = a) ?snapshot path =
      Pipeline.read_file_as_metadata (module DP) (module R) ?snapshot path
  end

  include DP
end

module Runtime = Runtime.Make
