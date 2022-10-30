module R = Yocaml.Runtime.Make (Runtime)

let execute program = R.execute program

let serve ~filepath ?(ipaddr = Ipaddr.V4.Prefix.loopback) ~port task =
  Logs.info (fun pp ->
      pp
        "Server running [http://%a:%d], serving [%s]"
        Ipaddr.V4.Prefix.pp
        ipaddr
        port
        filepath);
  let open Lwt.Syntax in
  let* stack =
    Tcpv4v6_socket.connect ~ipv4_only:false ~ipv6_only:false ipaddr None
  in
  Server.server filepath stack port task
;;

include Runtime
