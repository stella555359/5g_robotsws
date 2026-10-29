#!/bin/bash
echo "`sudo netstat -anp`" >sctp_assocs_wts.txt
while :
do
echo "`date`" >>sctp_assocs_wts.txt
echo "`sudo cat /proc/net/sctp/assocs`" >> sctp_assocs_wts.txt
sleep 5
done
