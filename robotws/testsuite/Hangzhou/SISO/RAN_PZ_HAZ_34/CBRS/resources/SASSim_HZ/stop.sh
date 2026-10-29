#!/bin/sh
if  [ $# -eq 0 ] ;then
    PIDS=`ps -efww | grep SAS_Sim.py | grep -v grep | awk '{print $2}'`
else
    PIDS=`ps -efww | grep SAS_Sim.py | grep $1 | grep -v grep | awk '{print $2}'`
fi

for PID in $PIDS
do
        echo $PID
        kill -9 $PID
done
