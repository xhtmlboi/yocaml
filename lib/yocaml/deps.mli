(** [Deps] is an attempt to represent (without much effort) a set of
    dependencies to build a file. *)

(** {1 Types} *)

(** Describes a collection of dependencies (where each dependency is a value
    of type {!type:kind}. For the moment, a dependency collection is described
    as a Set on Kinds. *)
type t

(**A [Deps] can take many forms. For the moment, I only handle the case where
   the dependency is a file. *)
type kind = File of Filepath.t

(** {1 Helpers} *)

(** [file path] turns a {!type:Filepath.t} into a {!type:kind}. *)
val file : Filepath.t -> kind

(** [to_list deps] turns a {!type:t} into a [List] of {!type:kind}. *)
val to_list : t -> kind list

(** Translate [kind] to [Filepath.t]. *)
val to_filepath : kind -> Filepath.t

(** {1 Effects Helpers}

    As working with a list of dependencies usually involves running effects,
    helpers for this are not a luxury! *)

(** Perfrom the effect [File_exists] on a {!type:kind}. *)
val kind_exists : kind -> bool Effect.t

(** Perfrom the effect [Get_modification_time] on a {!type:kind}. *)
val get_modification_time : kind -> int Try.t Effect.t

(** Perform the effect [Get_modification_time] to find the largest change date
    included in the dependencies.. *)
val get_max_modification_time : t -> int option Try.t Effect.t

(** Defines whether a {!type:Aliases.Filepath.t} should be updated according
    to a {!type:t} using the effects management logic.*)
val need_update
  :  t
  -> Filepath.t
  -> [ `Need_creation | `Need_update | `Up_to_date ] Try.t Effect.t

(** {1 Implementations} *)

(** A [Deps.t] is a [Monoid].*)
module Monoid : Preface_specs.MONOID with type t = t

(** {1 Included Set operations} *)

include Set.S with type t := t and type elt = kind
