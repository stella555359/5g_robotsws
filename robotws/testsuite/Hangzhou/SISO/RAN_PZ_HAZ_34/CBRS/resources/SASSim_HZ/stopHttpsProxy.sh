#!/bin/sh

PIDS=`ps -efww | grep HttpsProxy.py | grep $1 | grep -v grep | awk '{print $2}'`

for PID in $PIDS
do
        echo $PID
        kill -9 $PID
done
