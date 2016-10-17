
type ballot = {
  ballot_weight : int;
  ballot_preferences : int array
}

type blt_ctx =
  | No_header
  | Voting of int * int * ballot list
  | Candidate_names of int * int * ballot list * string array

exception Only_ints (* string must be space separated ints *)
exception Invalid_header (* not two ints *)
exception No_zero_terminator
exception Empty_line
exception Invalid_stop_code
exception Non_positive_pref of int
exception Non_consecutive_prefs
exception Duplicate_candidate_name of string
exception Incomplete
exception Too_many_preferences of int array

let int_array_of_string s =
  List.map int_of_string (Str.split (Str.regexp " ") s) |> Array.of_list

let safe_int_array_of_string s =
  let values =
    try int_array_of_string s
    with Failure _ -> raise Only_ints
  in
    values

let check_preferences prefs =
  prefs |> Array.iter (
    fun pref -> if pref < 1 then raise (Non_positive_pref pref) else ()
  );
  let sorted = Array.to_list prefs |> List.sort compare |> Array.of_list in
  let len = Array.length prefs in
  let last_pref = sorted.(len - 1) in
    if last_pref <> len
    then raise Non_consecutive_prefs
    else ()

let check_ballot_size max_size ballot =
  if max_size < Array.length ballot.ballot_preferences
  then raise (Too_many_preferences ballot.ballot_preferences)
  else ()

let extract_name line =
     let len = String.length line in
       if len < 2
       then line
       else if line.[0] = '"' && line.[len - 1] = '"'
            then String.sub line 1 (len - 2)
            else line

let array_mem needle haystack = haystack |> Array.to_list |> List.mem needle

let create_context () = No_header

let handle_line line = function
  | No_header ->
     let values = safe_int_array_of_string line in
       (match values with
       | [| hd ; tl |] -> Voting (hd, tl, [])
       | _ -> raise Invalid_header)

  | Voting (candidates, seats, ballots) ->
     let values = safe_int_array_of_string line in
     let len = Array.length values in
       (match len with
       | 0 -> raise Empty_line
       | 1 ->
          if values.(0) = 0
          then Candidate_names (candidates, seats, ballots, [||])
          else raise Invalid_stop_code
       | _ ->
          let final = values.(len - 1) in
            if final <> 0
            then raise No_zero_terminator
            else let ballot = {
                   ballot_weight = values.(0);
                   ballot_preferences = Array.sub values 1 (len - 2)
                 } in
                   check_preferences ballot.ballot_preferences;
                   Voting (candidates, seats, [ballot])
       )

  | Candidate_names (candidates, seats, ballots, names) ->
     let new_name = extract_name line in
       if array_mem new_name names
       then raise (Duplicate_candidate_name new_name)
       else Candidate_names (candidates, seats, ballots,
                             Array.append names [| new_name |])

       
let check_consistency = function
  | Candidate_names (candidates, seats, ballots, names) ->
     let check_size = check_ballot_size candidates in
       if candidates <= seats
       then failwith "Enough seats for all candidates; no need for election"
       else if Array.length names <> candidates
            then failwith "Number of candidates doesn't match names"
            else ballots |> List.iter check_size
  | _ -> raise Incomplete
