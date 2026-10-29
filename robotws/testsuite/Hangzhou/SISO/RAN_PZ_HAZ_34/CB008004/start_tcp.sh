#!/usr/bin/expect
set timeout 300
spawn ssh toor4nsn@10.101.49.82
sleep 5
expect "*Password:"
send "oZPS0POrRieRtu\r"
sleep 5
expect "Last login:*"
send "rm -rf  /user/toor4nsn/.ssh/known_hosts\r"
sleep 5
send "lxc-attach -n 0x2018\r"
sleep 5
send "ssh rfsw@172.22.0.2\r"
sleep 5
send "yes\r"
sleep 5
expect "rfsw@172.22.0.2's password:"
sleep 5
send "gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=\r"
sleep 5
send "sudo su\r"
sleep 1
send "tcpdump -i any -c 6500 -w /run/tcpdump_ru.pcap\r"
sleep 5
expect "tcpdump:*"
sleep 120
send "exit\r"
expect "exit\r"
send "exit\r"
expect "*Connection to 172.22.0.2 closed."
sleep 5
send "scp rfsw@172.22.0.2:/run/tcpdump_ru.pcap ~\r"
expect "rfsw@172.22.0.2's password:"
sleep 5
send "gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=\r"
expect "tcpdump_ru.pcap*"
sleep 20
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 20
interact
