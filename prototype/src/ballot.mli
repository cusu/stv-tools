
type t

exception Duplicate_prefs

val create : Contest.t -> int -> int list -> t
val total_preferences : t -> int
val dump : t -> unit
val dump_named : string list -> t -> unit

