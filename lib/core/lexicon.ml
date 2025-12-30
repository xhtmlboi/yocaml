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
  Format.asprintf "`%a` is already up-to-date" Path.pp target

let target_need_to_be_built target =
  Format.asprintf "`%a` need to be built" Path.pp target

let target_is_written target =
  Format.asprintf "`%a` will be written" Path.pp target

let target_was_written target =
  Format.asprintf "`%a` has been written" Path.pp target

let target_hash_is_unchanged target =
  Format.asprintf
    "`%a` always has the same hash as in the cache, already up-to-date" Path.pp
    target

let target_hash_is_changed target =
  Format.asprintf "`%a` has a different hash, need to be built" Path.pp target

let found_dynamic_dependencies target =
  Format.asprintf "`%a` has dynamic dependencies" Path.pp target

let cache_invalid_csexp target =
  Format.asprintf "Cache located in `%a` is invalid Csexp" Path.pp target

let cache_invalid_repr target =
  Format.asprintf "Cache located in `%a` is invalid representation" Path.pp
    target

let cache_restored target =
  Format.asprintf "Cache restored from `%a`" Path.pp target

let cache_initiated target =
  Format.asprintf "Cache initiated in `%a`" Path.pp target

let cache_stored target = Format.asprintf "Cache stored in `%a`" Path.pp target

let copy_file ?new_name ~into source =
  let with_new_name =
    Option.fold ~none:""
      ~some:(Format.asprintf " (with new name `%s`)")
      new_name
  in
  Format.asprintf "Copy file `%a` into `%a`%s" Path.pp source Path.pp into
    with_new_name

let copy_directory ?new_name ~into source =
  let with_new_name =
    Option.fold ~none:""
      ~some:(Format.asprintf " (with new name `%s`)")
      new_name
  in
  Format.asprintf "Copy directory `%a` into `%a`%s" Path.pp source Path.pp into
    with_new_name

let pp_filesystem ppf = function
  | `Source -> Format.fprintf ppf "source"
  | `Target -> Format.fprintf ppf "target"

let backtrace_not_available =
  "The backtrace is not available because the function is called (according to \
   the [in_exception_handler] parameter) outside an exception handler. This \
   makes the trace unspecified."

let there_is_an_error ppf () =
  Format.fprintf ppf "Oh dear, an error has occurred"

let unknown_error ppf exn =
  Format.fprintf ppf
    "No idea what error is. This is very annoying. It's probably a bug and you \
     should report the error here: <%s> : @[<1>%s;@ %s@]"
    bug_tracker
    (Printexc.exn_slot_name exn)
    (Printexc.to_string exn)

let file_not_exists source path ppf () =
  Format.fprintf ppf "The file `%a` (on `%a`) does not exist" Path.pp path
    pp_filesystem source

let invalid_path source path ppf () =
  Format.fprintf ppf "The path `%a` (on `%a`) is invalid" Path.pp path
    pp_filesystem source

let file_is_a_directory source path ppf () =
  Format.fprintf ppf
    "The following path: `%a` (on `%a`) is a directory (and attempts to be \
     used as a file)"
    pp_filesystem source Path.pp path

let directory_is_a_file source path ppf () =
  Format.fprintf ppf
    "The following path: `%a` (on `%a`) is a file (and attempts to be used as \
     a directory)"
    pp_filesystem source Path.pp path

let directory_not_exists source path ppf () =
  Format.fprintf ppf
    "The following directory: `%a` (on `%a`) does not exist (or is maybe a \
     file and not a directory)"
    Path.pp path pp_filesystem source
