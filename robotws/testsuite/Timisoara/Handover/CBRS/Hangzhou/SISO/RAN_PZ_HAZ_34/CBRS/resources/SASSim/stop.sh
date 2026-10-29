#!/bin/sh

PIDS=`ps -ef | grep SAS_Sim.py | grep -v grep | awk '{print $2}'`

for PID in $PIDS
do
        echo $PID
        kill -9 $PID
done
