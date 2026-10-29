#!/usr/bin/expect
set timeout 300
spawn sudo ssh toor4nsn@10.57.131.110
sleep 5
expect "*Password:"
send "oZPS0POrRieRtu\r"
sleep 5
expect "Last login:*"
send "cat /ffs/run/config/FRIps.txt\r"
sleep 5
send "lxc-attach -n 0x1018\r"
sleep 5
send "ssh root@172.22.48.162\r"
expect "root@172.22.48.162's password:"
sleep 5
send "asmr\r"
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
send "scp root@172.22.48.162:/run/full.zip ~\r"
expect "root@172.22.48.162's password:"
sleep 5
send "asmr\r"
expect "full.zip*"
sleep 20
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 10
interact
