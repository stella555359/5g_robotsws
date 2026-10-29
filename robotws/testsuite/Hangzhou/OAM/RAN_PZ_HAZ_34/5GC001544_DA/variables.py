ps_cmd = "ps | grep CCSDaemonExe | awk '{print $1}' | xargs -n1"
Killcmd = "ps | grep CCSDaemonExe | awk '{print $1}' | xargs kill -9 $1"
