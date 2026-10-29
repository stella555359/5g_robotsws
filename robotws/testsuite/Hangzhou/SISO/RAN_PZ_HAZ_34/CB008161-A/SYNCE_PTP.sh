#!/usr/bin/expect
set timeout 200
#spawn ssh toor4nsn@10.57.131.104
spawn ssh toor4nsn@10.71.216.134
sleep 5
expect "*Password:"
send "oZPS0POrRieRtu\r"
sleep 5
expect "Last login:*"
send "rm -rf  /user/toor4nsn/.ssh/known_hosts\r"
sleep 5
send "lxc-attach -n 0x1018\r"
sleep 5
send "ssh rfsw@172.22.0.162\r"
sleep 5
send "yes\r"
sleep 5
expect "rfsw@172.22.0.162's password:"
sleep 5
send "PD6N1DB0lWmwomtNL2qd3ISypbiocdGRy7U+Lipiksk=\r"
sleep 5
send "sudo haxer 4500:0 show SynchronizationModeConf\r"
sleep 5
expect "*SYNCE_PTP*"
sleep 5
send "exit\r"
expect "*Connection to 172.22.0.162 closed."
sleep 5
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 10
interact
