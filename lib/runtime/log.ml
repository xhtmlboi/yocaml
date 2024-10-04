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

type level = [ `App | `Error | `Warning | `Info | `Debug ]

let level_to_logs = function
  | `App -> Logs.App
  | `Error -> Logs.Error
  | `Warning -> Logs.Warning
  | `Info -> Logs.Info
  | `Debug -> Logs.Debug

let msg level message =
  let level = level_to_logs level in
  Logs.msg level (fun print -> print "%s" message)

let setup ?level () =
  match level with
  | None -> ()
  | Some level ->
      let level = level_to_logs level in
      let header = Logs_fmt.pp_header in
      let () = Fmt_tty.setup_std_outputs () in
      let () = Logs.set_reporter Logs_fmt.(reporter ~pp_header:header ()) in
      Logs.set_level (Some level)
