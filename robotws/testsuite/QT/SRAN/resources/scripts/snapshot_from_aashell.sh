#!/usr/bin/expect

# Variables
set IP [lindex ${argv} 0]
set TELNET_PORT [lindex ${argv} 1]
set SNAPSHOT [lindex ${argv} 2]
set DEST_PATH [lindex ${argv} 3]
set TIMEOUT [lindex ${argv} 4]
set SSH_USER toor4nsn
set SSH_PASS oZPS0POrRieRtu

# SSH connection
#spawn wanna_connect.sh
spawn sshpass -p ${SSH_PASS} ssh ${SSH_USER}@${IP}
expect -re "root.*>"
send "uptime\r"
expect >

# Telnet to AaShell and execute shapshot
set timeout ${TIMEOUT}
send "telnet 127.0.0.1 ${TELNET_PORT}\r"
expect AaShell
send "log -z ${SNAPSHOT}\r"
expect "AaSysComUserDeregister succeed!"

# Get snapshot file
set timeout 15
spawn sshpass -p ${SSH_PASS} scp ${SSH_USER}@${IP}:/tmp/${SNAPSHOT} ${DEST_PATH}
expect 100%
spawn ls -l ${DEST_PATH}/${SNAPSHOT}
expect ${SNAPSHOT}

# Execution example
# expect ./snapshot_from_aashell.sh 192.168.255.129 15007 snap.zip /home/ute/Downloads 90
# expect ./snapshot_from_aashell.sh 192.168.255.7 15007 snap.zip /home/ute/Downloads 90
