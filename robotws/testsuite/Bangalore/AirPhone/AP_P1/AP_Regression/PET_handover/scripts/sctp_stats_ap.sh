#!/bin/bash
netstat -anp >sctp_assocs_ap.txt
while :
do
date >>sctp_assocs_ap.txt
cat /proc/net/sctp/assocs >> sctp_assocs_ap.txt
sleep 5
done
