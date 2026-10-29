*** Settings ***
Documentation		The basic operattion for WMP lte.
...			author: BLR1 Framework
...			contact: Automation Frmaework
...			in case of changes please contact author,
...			do not modify without permission

Library    taf.transport.ssh

*** Test Cases ***
EgenCollection
	connect_to    10.53.188.152    root   BT5l@bus3rl0g1n   alias=egen
	Execute      Cd /root/eGen/release    connection=egen
	${egen_params}  Set Variable  --cores 1-8 --port 0000:03:00.1 --port 0000:03:00.0 --capture FJTTest_2.pcap --save-n-and-quit 5000
	Execute     /root/eGen/release/egen ${egen_params}    connection=egen
	sleep    40
	Download File    /root/eGen/release/FJTTest_2.pcap    /home/ute/results/test.pcap    connection=egen