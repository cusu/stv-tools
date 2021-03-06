(*
  STV Tools, a reference implementation of STV, by Martin Keegan

  Copyright (C) 2016-2017  Martin Keegan

  This programme is free software; you may redistribute and/or modify
  it under the terms of the GNU Affero General Public Licence as published by
  the Free Software Foundation, either version 3 of said Licence, or
  (at your option) any later version.
*)

type t =
  | Elected of Candidate.t
  | Excluded of Candidate.t
  | Distribute_surplus of Candidate.t
  | Distribute_excluded of Candidate.t

let string_of = function
  | Elected e -> "elected"
  | Excluded e -> "excluded"
  | Distribute_surplus cc -> "distribute-surplus"
  | Distribute_excluded cc -> "distribute-excluded"
