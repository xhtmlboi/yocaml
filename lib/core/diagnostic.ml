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

let pp_blankline ppf () = Format.fprintf ppf "@,@,"
let pp_newline ppf () = Format.fprintf ppf "@,"

let rec pp_validation_error custom_error ppf = function
  | Data.Validation.Invalid_shape { expected; given } ->
      Format.fprintf ppf "@[<v 2>Invalid shape:@,Expected: %s@,Given: `%a`@]"
        expected Data.pp given
  | Data.Validation.With_message { message; given } ->
      Format.fprintf ppf "@[<v 2>Message:@,Message: %s@,Given: `%s`@]" message
        given
  | Data.Validation.Custom custom ->
      Format.fprintf ppf "@[<v 2>Custom error:@,%a@]" custom_error custom
  | Data.Validation.Invalid_list { errors; given } ->
      Format.fprintf ppf "@[<v 2>Invalid list:@,";

      Format.fprintf ppf "Errors (%d):@," (Nel.length errors);

      Nel.iteri
        (fun i (index, err) ->
          if i > 0 then pp_blankline ppf ();
          Format.fprintf ppf "@[<v 2>%d) At index %d:@,%a@]" (i + 1) index
            (pp_validation_error custom_error)
            err)
        errors;

      pp_blankline ppf ();

      Format.fprintf ppf "@[<v 2>Given list:@,";

      List.iteri
        (fun i v ->
          Format.fprintf ppf "[%d] = `%a`" i Data.pp v;
          pp_newline ppf ())
        given;

      Format.fprintf ppf "@]@]"
  | Data.Validation.Invalid_record { errors; given } ->
      Format.fprintf ppf "@[<v 2>Invalid record:@,";

      Format.fprintf ppf "Errors (%d):@," (Nel.length errors);

      Nel.iteri
        (fun i err ->
          if i > 0 then pp_blankline ppf ();
          Format.fprintf ppf "%d) %a" (i + 1) (pp_record_error custom_error) err)
        errors;

      pp_blankline ppf ();

      Format.fprintf ppf "@[<v 2>Given record:@,";

      Format.pp_print_list
        ~pp_sep:(fun ppf () -> pp_newline ppf ())
        (fun ppf (k, v) -> Format.fprintf ppf "%s = `%a`" k Data.pp v)
        ppf given;

      Format.fprintf ppf "@]@]"

and pp_record_error custom_error ppf = function
  | Data.Validation.Missing_field { field } ->
      Format.fprintf ppf "Missing field `%s`" field
  | Data.Validation.Invalid_field { field; error; given = _ } ->
      Format.fprintf ppf "@[<v 2>Invalid field `%s`:@,%a@]" field
        (pp_validation_error custom_error)
        error
  | Data.Validation.Invalid_subrecord error ->
      Format.fprintf ppf "@[<v 2>Invalid subrecord:@,%a@]"
        (pp_validation_error custom_error)
        error

let pp_provider_error custom_error ppf = function
  | Required.Parsing_error { given; message } ->
      Format.fprintf ppf "Parsing error:@,Given: `%s`@,Message: `%s`" given
        message
  | Required.Required_metadata { entity } ->
      Format.fprintf ppf "Required metadata: `%s`" entity
  | Required.Validation_error { entity; error } ->
      Format.fprintf ppf "Validation error: `%s`@,@[%a@]" entity
        (pp_validation_error custom_error)
        error

let glob_pp p v backtrace ppf =
  Format.fprintf ppf "--- %a ---@,%a@,---@,%s" Lexicon.there_is_an_error () p v
    backtrace

let exception_to_diagnostic
    ?(custom_error = fun ppf _ -> Format.fprintf ppf "Custom Validation Error")
    ?(in_exception_handler = true) ppf exn =
  let backtrace =
    if in_exception_handler then Printexc.get_backtrace ()
    else Lexicon.backtrace_not_available
  in
  let glob_pp p v = glob_pp p v backtrace ppf in
  match exn with
  | Eff.File_not_exists (source, path) ->
      glob_pp (Lexicon.file_not_exists source path) ()
  | Eff.Invalid_path (source, path) ->
      glob_pp (Lexicon.invalid_path source path) ()
  | Eff.File_is_a_directory (source, path) ->
      glob_pp (Lexicon.file_is_a_directory source path) ()
  | Eff.Directory_not_exists (source, path) ->
      glob_pp (Lexicon.directory_not_exists source path) ()
  | Eff.Directory_is_a_file (source, path) ->
      glob_pp (Lexicon.directory_is_a_file source path) ()
  | Eff.Provider_error error -> glob_pp (pp_provider_error custom_error) error
  | exn -> glob_pp Lexicon.unknown_error exn

let runtime_error_to_diagnostic ppf message =
  let backtrace = Lexicon.backtrace_not_available in
  glob_pp Format.pp_print_string message backtrace ppf
