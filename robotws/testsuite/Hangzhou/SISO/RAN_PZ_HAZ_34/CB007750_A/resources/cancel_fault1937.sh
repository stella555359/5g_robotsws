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
send "ssh root@172.16.73.128\r"
sleep 3
expect "Are you*"
sleep 3
send "yes\r"
sleep 5
send "echo \'/ action create ConfigAccess /CI/ConfigAccess_Module /module\'|frmonShellClient 127.0.0.1 2000\r"
sleep 3
send "echo \'/CI/ConfigAccess_Module action fetch DECODED \"tcs.bin\" \"/var/tmp/tcs.json\"\'|frmonShellClient 127.0.0.1 2000\r"
sleep 3
send "sed -i \'s/\"Tdanger\": 10.0,/\"Tdanger\": 120.0,/g\' /var/tmp/tcs.json\r"
sleep 3
send "touch /mnt/runtime/runtime_config.txt\r"
sleep 3
send "echo \'/CI/ConfigAccess_Module action store PERMANENT DECODED \"tcs.bin\" \"/var/tmp/tcs.json\"\'|frmonShellClient 127.0.0.1 2000\r"
sleep 3
send "echo \'/CI/ConfigAccess_Module action update\'|frmonShellClient 127.0.0.1 2000\r"
sleep 5
send "reboot\r"
sleep 5
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 5
send "exit\r"
sleep 5
interact