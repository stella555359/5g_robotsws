#!/usr/bin/expect
set timeout 60
spawn ssh cli@10.101.38.40
sleep 5
expect "Username:"
send "admin\r"
sleep 5
expect "*Password:"
send "Admin@1830\r"
sleep 5
expect "Last Login:*"
send "Y\r"
sleep 5
send "show sync 1 sync0 detail\r"
sleep 5
send "logout\r"
sleep 10
interact
