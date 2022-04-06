module R = Yocaml.Runtime.Make (Runtime)

let execute program = R.execute program

let serve ~filepath ~port task =
  Logs.info (fun pp ->
      pp "Server running [http://localhost:%d], serving [%s]" port filepath);
  Server.server filepath port task
;;

include Runtime
