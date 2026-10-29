#!/bin/sh

#Command line arguments
while getopts c:w: option
do
case "${option}"
in
c) COMMAND=${OPTARG};;
w) WRITE=${OPTARG};;
esac
done

#Variables
host='localhost'
egate_port='20000'
_exit='exit'

#Main function
execute_epcsim_command () {
( echo open ${host} ${egate_port}
sleep 1
echo ${COMMAND}
sleep 1
echo ${_exit}
sleep 1
) | telnet
}

if [ -z $WRITE ]; then
    execute_epcsim_command
else
    echo "Output from" $COMMAND "command will be written to the" $WRITE "file."
    execute_epcsim_command > $WRITE
fi

#Execution examples
#/home/ute/sbts_qt/epcsim_scripts/epc_execute_command.sh -c state
#/home/ute/sbts_qt/epcsim_scripts/epc_execute_command.sh -c state -w /tmp/epc_output.txt
