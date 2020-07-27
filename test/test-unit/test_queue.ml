open Base

let should_run_job _ () =
  let now = Ptime_clock.now () in
  let job =
    Sihl.Queue.create_job ~name:"foo"
      ~input_to_string:(fun () -> None)
      ~string_to_input:(fun _ -> Ok ())
      ~handle:(fun _ ~input:_ -> Lwt_result.return ())
      ~failed:(fun _ -> Lwt_result.return ())
      ()
    |> Sihl.Queue.set_max_tries 3
    |> Sihl.Queue.set_retry_delay Sihl.Utils.Time.OneMinute
  in
  let job_instance =
    Sihl.Queue.Core.JobInstance.create ~input:() ~delay:None ~now job
  in
  let actual = Sihl.Queue.Core.JobInstance.should_run ~job_instance ~now in
  Alcotest.(check bool) "pending job should run" true actual;
  let delay = Some Sihl.Utils.Time.OneDay in
  let job_instance =
    Sihl.Queue.Core.JobInstance.create ~input:() ~delay ~now job
  in
  let actual = Sihl.Queue.Core.JobInstance.should_run ~job_instance ~now in
  Alcotest.(check bool)
    "pending job with start_at in the future should not run" false actual;
  let job_instance =
    Sihl.Queue.Core.JobInstance.create ~input:() ~delay:None ~now job
    |> Sihl.Queue.Core.JobInstance.incr_tries
    |> Sihl.Queue.Core.JobInstance.incr_tries
  in
  let actual = Sihl.Queue.Core.JobInstance.should_run ~job_instance ~now in
  Alcotest.(check bool)
    "pending job with tries < max_tries should not run" true actual;
  let job_instance =
    Sihl.Queue.Core.JobInstance.create ~input:() ~delay:None ~now job
    |> Sihl.Queue.Core.JobInstance.incr_tries
    |> Sihl.Queue.Core.JobInstance.incr_tries
    |> Sihl.Queue.Core.JobInstance.incr_tries
  in
  let actual = Sihl.Queue.Core.JobInstance.should_run ~job_instance ~now in
  Alcotest.(check bool)
    "pending job with tries = max_tries should not run" false actual;
  let job_instance =
    Sihl.Queue.Core.JobInstance.create ~input:() ~delay:None ~now job
    |> Sihl.Queue.Core.JobInstance.set_failed
  in
  let actual = Sihl.Queue.Core.JobInstance.should_run ~job_instance ~now in
  Alcotest.(check bool) "failed job should not run" false actual;
  let job_instance =
    Sihl.Queue.Core.JobInstance.create ~input:() ~delay:None ~now job
    |> Sihl.Queue.Core.JobInstance.set_succeeded
  in
  let actual = Sihl.Queue.Core.JobInstance.should_run ~job_instance ~now in
  Alcotest.(check bool) "succeeded job should not run" false actual;
  let job_instance =
    Sihl.Queue.Core.JobInstance.create ~input:() ~delay:None ~now job
    |> Sihl.Queue.Core.JobInstance.set_last_ran_at now
  in
  let actual = Sihl.Queue.Core.JobInstance.should_run ~job_instance ~now in
  Alcotest.(check bool)
    "job that hasn't cooled down should not run" false actual;
  Lwt.return ()
