let execute
  :  (module Runtime.RUNTIME) -> (module Mirage_clock.PCLOCK) -> ctx:Mimic.ctx
  -> string -> 'a Yocaml.Effect.t -> ('a, [> `Msg of string ]) result Lwt.t
  =
 fun (module Source) (module Pclock) ~ctx remote program ->
  let open Lwt.Syntax in
  let* store = Git_kv.connect ctx remote in
  let module Store = Git_kv.Make (Pclock) in
  Store.change_and_push store
  @@ fun store ->
  let module R0 =
    Runtime.Make (Source) (Pclock)
      (struct
        let store = store
      end)
  in
  let module R1 = Yocaml.Runtime.Make (R0) in
  R1.execute program
;;
