(** Data structures attachable to articles/documents.*)

class virtual mustacheable :
  object
    method virtual to_mustache : [ `O of (string * Mustache.Json.value) list ]
  end

module Base : sig
  type obj

  val from_yaml : Yaml.value -> obj Validate.t
  val equal : obj -> obj -> bool
  val pp : Format.formatter -> obj -> unit
end

module Article : sig
  type obj

  val from_yaml : Yaml.value -> obj Validate.t
  val equal : obj -> obj -> bool
  val pp : Format.formatter -> obj -> unit
end
