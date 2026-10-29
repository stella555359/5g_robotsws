#!/usr/bin/expect
set timeout 300
spawn sudo ssh toor4nsn@10.57.131.110
sleep 5
expect "*Password:"
send "oZPS0POrRieRtu\r"
sleep 5
send "rm -rf  /user/toor4nsn/.ssh/known_hosts\r"
sleep 5
send "cat /ffs/run/config/FRIps.txt\r"
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
send "cd /run\r"
sleep 5
send "log -a -z full.zip\r"
sleep 10
expect "AaShell>*"
sleep 5
send "exit\r"
expect "*Connection to 172.22.48.162 closed."
sleep 5
send "scp rfsw@172.22.48.162:/run/full.zip ~\r"
expect "rfsw@172.22.48.162's password:"
sleep 5
send "ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=\r"
expect "full.zip*"
sleep 20
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 10
interact
