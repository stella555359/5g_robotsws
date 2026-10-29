#!/usr/bin/expect
set timeout 300
spawn ssh toor4nsn@10.57.131.110
sleep 5
expect "*Password:"
send "oZPS0POrRieRtu\r"
sleep 5
expect "Last login:*"
send "rm -rf  /user/toor4nsn/.ssh/known_hosts\r"
sleep 5
send "lxc-attach -n 0x1018\r"
sleep 5
send "ssh root@172.22.48.162\r"
sleep 5
send "yes\r"
sleep 5
expect "root@172.22.48.162's password:"
sleep 5
send "asmr\r"
sleep 5
send "tcpdump -i any -c 6500 -w /tmp/tcpdump_ru.pcap\r"
sleep 5
expect "tcpdump:*"
sleep 120
send "exit\r"
expect "*Connection to 172.22.48.162 closed."
sleep 5
send "scp root@172.22.48.162:/tmp/tcpdump_ru.pcap ~\r"
expect "root@172.22.48.162's password:"
sleep 5
send "asmr\r"
expect "tcpdump_ru.pcap*"
sleep 20
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 20
interact
