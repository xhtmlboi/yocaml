module type CONFIG = sig
  val store : Git_kv.t
end

module type RUNTIME = Yocaml.Runtime.RUNTIME with type 'a t = 'a

module Make
  (Source : RUNTIME)
  (Pclock : Mirage_clock.PCLOCK)
  (Config : CONFIG) : Yocaml.Runtime.RUNTIME with type 'a t = 'a Lwt.t
