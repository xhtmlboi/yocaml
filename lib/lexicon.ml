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

let bug_tracker = "https://github.com/xhtmlboi/yocaml/issues"

let target_already_up_to_date target =
  Eff.logf ~level:`Info "`%a` is already up-to-date" Path.pp target

let target_exists target = Eff.logf ~level:`Info "`%a` exists" Path.pp target

let target_need_to_be_built target =
  Eff.logf ~level:`Info "`%a` need to be built" Path.pp target

let target_is_written target =
  Eff.logf ~level:`Debug "`%a` will be written" Path.pp target

let target_was_written target =
  Eff.logf ~level:`Debug "`%a` has been written" Path.pp target

let target_hash_is_unchanged target =
  Eff.logf ~level:`Info
    "`%a` always has the same hash as in the cache, already up-to-date" Path.pp
    target

let target_hash_is_changed target =
  Eff.logf ~level:`Info "`%a` has a different hash, need to be built" Path.pp
    target

let found_dynamic_dependencies target =
  Eff.logf ~level:`Info "`%a` has dynamic dependencies" Path.pp target

let target_not_in_cache target =
  Eff.logf ~level:`Info "`%a` is not present in the cache" Path.pp target

let cache_invalid_csexp target =
  Eff.logf ~level:`Warning "Cache located in `%a` is invalid Csexp" Path.pp
    target

let cache_invalid_repr target =
  Eff.logf ~level:`Warning "Cache located in `%a` is invalid representation"
    Path.pp target

let cache_restored target =
  Eff.logf ~level:`Info "Cache restored from `%a`" Path.pp target

let cache_stored target =
  Eff.logf ~level:`Info "Cache stored in `%a`" Path.pp target

let pp_filesystem ppf = function
  | `Source -> Format.fprintf ppf "source"
  | `Target -> Format.fprintf ppf "target"

let backtrace_not_available =
  "The backtrace is not available because the function is called (according to \
   the [in_exception_handler] parameter) outside an exception handler. This \
   makes the trace unspecified."

let there_is_an_error ppf () =
  Format.fprintf ppf "Oh dear, an error has occurred"

let unknown_error ppf () =
  Format.fprintf ppf
    "No idea what mistake it is. This is very annoying. It's probably a bug \
     and you should report the error here: <%s>"
    bug_tracker

let file_not_exists source path ppf () =
  Format.fprintf ppf "The file `%a` (on `%a`) does not exists" Path.pp path
    pp_filesystem source

let invalid_path source path ppf () =
  Format.fprintf ppf "The path `%a` (on `%a`) is invalid" Path.pp path
    pp_filesystem source

let file_is_a_directory source path ppf () =
  Format.fprintf ppf
    "The following path: `%a` (on `%a`) is a directory (and attempts to be \
     used as a file)"
    pp_filesystem source Path.pp path

let directory_not_exists source path ppf () =
  Format.fprintf ppf
    "The following directory: `%a` (on `%a`) does not exists (or is maybe a \
     file and not a directory)"
    Path.pp path pp_filesystem source
