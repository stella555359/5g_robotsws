#!/usr/bin/expect
set timeout 30
spawn sudo passwd coam
expect "New password:"
send "zO&n1W*ktp7\r"
expect "Retype new password:"
send "zO&n1W*ktp7\r"
interact
