#!/usr/bin/sh
root=/home/ute/MN/UTE/robotws
current_dir=`pwd`
robot_file=`readlink -f $0`
if [ $# -lt 1 ] ; then
    echo "\nInvalid parameter number!"
    echo "\nUsage example:"
    echo "$0 /tmp/mon.0.emil.5gm"
    exit 1
fi
while [ $# != 0 ];do
echo "\nconverting for" $1
    cd $current_dir
    emil_file=`readlink -f $1`
    cd ${root} && robot --pythonpath ${root} -v emil_file:$emil_file $robot_file;
shift
done
exit


*** Settings ***

Resource          ${EXECDIR}/testsuite/Beijing/ET/common/resources/emil_to_txt.robot


*** Test Cases ***

EMIL CONVERT TEST


    Connect To Emil
    Log To Console       Connected to Emil done

    Log To Console       Converting Emil file
    ${emil_output_file}     Convert Emil To Text    source=${emil_file}    emil_protocol=5G


