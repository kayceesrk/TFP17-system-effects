type 'a _promise =
  | Done of 'a
  | Error of exn
  | Waiting of ('a, unit) continuation list

type 'a promise = 'a _promise ref

effect Async : ('a -> 'b) * 'a -> 'b promise
effect Await : 'a promise -> 'a

let async f v = perform (Async (f,v))
let await p = perform (Await p)

(** Poll to see if the file descriptor is available to read. *)
let poll_rd fd =
  let r,_,_ = Unix.select [fd] [] [] 0. in
  match r with
  | [] -> false
  | _ -> true

(***********************************************)

let run main v =
  let run_q = Queue.create () in
  let enqueue f = Queue.push f run_q in
  let run_next () =
    if Queue.is_empty run_q then ()
    else Queue.pop run_q ()
  in
  let rec fork : 'a 'b. 'a promise -> ('b -> 'a) -> 'b -> unit =
    fun p f v ->
      match f v with
      | v ->
          let Waiting l = !p in
          List.iter (fun k -> enqueue (fun () -> continue k v)) l;
          p := Done v;
          run_next ()
      | exception e ->
          let Waiting l = !p in
          List.iter (fun k -> enqueue (fun () -> discontinue k e)) l;
          p := Error e;
          run_next ()
      | effect (Async (f',v')) k ->
          let p' = ref (Waiting []) in
          enqueue (fun () -> continue k p');
          fork p' f' v'
      | effect (Await p) k ->
          match !p with
          | Done v -> continue k v
          | Error e -> discontinue k e
          | Waiting l -> p := Waiting (k::l); run_next ()
  in
  fork (ref (Waiting [])) main v

open Unix

let buffer = failwith "not implemented"
let buf_size = 1024

let rec echo_server sock =
	let sent = ref 0 in
  let msg_len = (* receive message *)
    try recv sock buffer 0 buf_size [] with
    | _ -> 0 (* Treat exceptions as 0 length message *)
  in
  if msg_len > 0 then begin
    (* echo message *)
    (try while !sent < msg_len do
      let write_count =
        send sock buffer !sent (msg_len - !sent) [] in
      sent := write_count + !sent
    done with _ -> ()); (* ignore send failures *)
    echo_server sock
  end else close sock (* client left, close connection *)

let r = ref 0

let ref v = r
