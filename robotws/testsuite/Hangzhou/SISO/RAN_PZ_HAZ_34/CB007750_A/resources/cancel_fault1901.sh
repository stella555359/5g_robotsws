#!/usr/bin/expect
set timeout 300
spawn ssh toor4nsn@10.71.209.232
sleep 3
expect "*Password:"
send "oZPS0POrRieRtu\r"
sleep 3
expect "Last login:*"
send "rm -rf  /user/toor4nsn/.ssh/known_hosts\r"
sleep 3
send "lxc-attach -n 0x1018\r"
sleep 3
send "ssh root@172.16.73.129\r"
sleep 3
expect "Are you*"
sleep 3
send "yes\r"
sleep 5
send "cd /mnt/factory/configs/unit\r"
sleep 3
send "mv calibration_dlpath1_bk.bin calibration_dlpath1.bin\r"
sleep 3
send "mv calibration_dlpath1_bk.bin.md5 calibration_dlpath1.bin.md5\r"
sleep 3
send "reboot\r"
sleep 5
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 5
interact