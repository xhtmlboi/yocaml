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
