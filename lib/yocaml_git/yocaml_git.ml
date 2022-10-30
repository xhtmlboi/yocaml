let execute
    :  (module Runtime.RUNTIME) -> (module Mirage_clock.PCLOCK)
    -> ctx:Mimic.ctx -> string -> 'a Yocaml.Effect.t -> 'a Lwt.t
  =
 fun (module Source) (module Pclock) ~ctx repository program ->
  let open Lwt.Infix in
  Git_kv.connect ctx repository
  >>= fun store0 ->
  let module Store = Git_kv.Make (Pclock) in
  Store.batch store0
  @@ fun store1 ->
  let module R0 =
    Runtime.Make (Source) (Pclock)
      (struct
        let store = store1
      end)
  in
  let module R1 = Yocaml.Runtime.Make (R0) in
  R1.execute program
;;
