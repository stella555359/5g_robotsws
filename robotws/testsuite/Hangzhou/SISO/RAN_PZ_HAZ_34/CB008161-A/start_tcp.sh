#!/usr/bin/expect
set timeout 300
spawn ssh toor4nsn@10.68.90.68
sleep 5
expect "*Password:"
send "oZPS0POrRieRtu\r"
sleep 5
expect "Last login:*"
send "rm -rf  /user/toor4nsn/.ssh/known_hosts\r"
sleep 5
send "lxc-attach -n 0x1018\r"
sleep 5
send "ssh rfsw@172.22.0.2\r"
sleep 5
send "yes\r"
sleep 5
expect "rfsw@172.22.0.2's password:"
sleep 5
send "ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=\r"
sleep 5
send "sudo su\r"
sleep 1
send "tcpdump -i any -c 6500 -w /run/tcpdump_ru.pcap\r"
sleep 5
expect "tcpdump:*"
sleep 120
send "sudo chmod 777 /run/tcpdump_ru.pcap\r"
sleep 5
send "exit\r"
expect "exit\r"
send "exit\r"
expect "*Connection to 172.22.0.2 closed."
sleep 5
send "scp rfsw@172.22.0.2:/run/tcpdump_ru.pcap ~\r"
expect "rfsw@172.22.0.2's password:"
sleep 5
send "ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=\r"
expect "tcpdump_ru.pcap*"
sleep 20
send "exit\r"
expect "exit\r"
sleep 5
send "exit\r"
sleep 20
interact
