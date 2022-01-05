let execute program = Yocaml.Runtime.execute (module Runtime) program

let serve ~filepath ~port task =
  Logs.info (fun pp ->
      pp "Server running [http://localhost:%d], serving [%s]" port filepath);
  Server.server filepath port task
;;

include Runtime
