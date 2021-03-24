type date = int * int * int

class type mustacheable =
  object
    method to_mustache : [ `O of (string * Mustache.Json.value) list ]
  end

module Base : sig
  class obj : ?page_title:string -> unit -> mustacheable

  val validate : Yaml.value -> obj Validate.t
end

module Article : sig
  class obj :
    ?page_title:string
    -> ?tags:string list
    -> date
    -> string
    -> string
    -> mustacheable

  val validate : Yaml.value -> obj Validate.t
end
