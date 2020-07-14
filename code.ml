
type tree = Leaf of int | Branch of tree * tree

let rec iter f t = match t with
  | Leaf n -> f n
  | Branch (a, b) -> iter f a; iter f b

effect Next : int -> unit
let to_gen t =
  let step = ref (fun () -> assert false) in
  let first_step () =
    match
      iter (fun x -> perform (Next x)) t
    with
    | () -> None
    | effect (Next v) k ->
      step := continue k;
      Some v in
  step := first_step;
  fun () -> !step ()

(*
let to_gen t =
  let rec next : (unit -> int option) ref =
    ref (fun () ->
     match
       iter (fun x -> perform (Next x)) t
     with
     | () -> None
     | effect (Next x) k ->
        next := (fun () -> continue k ()); Some x) in
  fun () -> !next ()
1
*)

let rec run_gen f =
  match f () with
  | Some n -> Printf.printf "%d\n" n; run_gen f
  | None -> ()

let () = run_gen (to_gen (Branch (Branch (Leaf 1, Leaf 2), Branch (Leaf 3, Leaf 4))))


effect Yield : unit
effect Fork : (unit -> unit) -> unit
let run_q = Queue.create ()
let rec dequeue () =
  if Queue.is_empty run_q then ()
  else continue (Queue.pop run_q) ()
let rec spawn f =
  match f () with
  | () -> dequeue ()
  | effect Yield k ->
      Queue.push k run_q; dequeue ()
  | effect (Fork f) k ->
      Queue.push k run_q; spawn f
