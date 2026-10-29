#!/bin/bash
# small script to check how many resets are performed, activate by command: ktoryreset x
# variable x (int) is optional, if you set this variable script will print x last performed resets with their timestamps on your terminal
HOW_MANY=1
FILE=~/reset_console.txt
if [[ ! -a $FILE ]]; then FILE=~/logs/console_reset.txt
fi
if [[ $1 ]]; then HOW_MANY=$1
fi
cat $FILE | grep -e '- RESET' | tail -n$HOW_MANY
