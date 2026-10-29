#!/bin/bash

STOP_SOSREPORT="/opt/wts/latest/stopTest.sh"
START_SOSREPORT="/opt/wts/latest/startTest.sh"
STOP_LOG_FILE="stopTestASIL.log"
START_LOG_FILE="startTestASIL.log"

if [ $1 = "start" ]; then
   echo starting startTest_ASIL.sh script!!!
   nohup $START_SOSREPORT > $START_LOG_FILE 2>&1 &
   sleep 2
else
   echo starting stopTest_ASIL.sh script!!!
   nohup $STOP_SOSREPORT -o > $STOP_LOG_FILE 2>&1 &
   sleep 2
   echo started $1 script in background!!!
fi
