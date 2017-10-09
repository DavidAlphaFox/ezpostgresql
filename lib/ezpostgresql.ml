type connection = Postgresql.connection

let connect ~conninfo =
  Lwt_preemptive.detach (fun () ->
      new Postgresql.connection ~conninfo ()
    )

let one ~query ?(params=[||]) conn =
  Lwt_preemptive.detach (fun (c : connection) ->
      let result = c#exec ~expect:[Postgresql.Tuples_ok] ~params query in
      result#get_tuple 0
    ) conn

let all ~query ?(params=[||]) conn =
  Lwt_preemptive.detach (fun (c : connection) ->
      let result = c#exec ~expect:[Postgresql.Tuples_ok] ~params query in
      result#get_all
    ) conn

module Pool = struct

  let create ~conninfo ~size () =
    Lwt_pool.create size (connect ~conninfo)

  let one ~query ?(params=[||]) pool =
    Lwt_pool.use pool (one ~query ~params)

  let all ~query ?(params=[||]) pool =
    Lwt_pool.use pool (all ~query ~params)

end
