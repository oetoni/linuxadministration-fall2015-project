Command to show open ports:
netstat -lntu<br />
<br />
-l = only services which are listening on some port<br />
-n = show port number, don't try to resolve the service name<br />
-t = tcp ports<br />
-u = udp ports<br />
-p = name of the program<br />
<br />
This command will list open network ports and the processes that own them:<br />
netstat -lnptu