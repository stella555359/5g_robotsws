#!/bin/bash

cd /ffs/run/simmode/

iphy_file_name=$(ls -l /ffs/run/simmode | awk -F'->' '{print $2}' | tr -d ' ')
echo $iphy_file_name

line_number=$(sed -n "/<L1Bypass>true<\/L1Bypass>/=" $iphy_file_name)
echo $line_number

if [[ -z $line_number ]]; then
    space='               '
    number=$(sed -n "/<\/GeneralSettings>/=" $iphy_file_name)
    sed -i "${number}i\ ${space}<L1Bypass>true</L1Bypass>" $iphy_file_name
fi
check_result=$(grep -i "L1Bypass" $iphy_file_name)
echo $check_result

ln -sf $iphy_file_name iphy.xml
