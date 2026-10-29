#!/usr/bin/expect
set timeout 200
spawn sudo ssh toor4nsn@10.57.131.110
sleep 5
expect "*Password:"
send "oZPS0POrRieRtu\r"
sleep 5
send "rm -rf  /user/toor4nsn/.ssh/known_hosts\r"
sleep 5
send "lxc-attach -n 0x1018\r"
sleep 5
send "ssh rfsw@172.22.48.162\r"
sleep 5
send "yes\r"
sleep 5
expect "rfsw@172.22.48.162's password:"
sleep 5
send "ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=\r"
sleep 5
send "sudo su\r"
sleep 1
send "haxer 4500:0 show SynchronizationModeConf\r"
sleep 5
expect "*SYNCE_PTP*"
sleep 5
send "exit\r"
sleep 1
send "exit\r"
expect "*Connection to 172.22.48.162 closed."
sleep 5
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 10
interact
