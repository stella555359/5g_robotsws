#!/bin/bash

cd /ffs/run/simmode/

line_number=$(sed -n "/<L1Bypass>true<\/L1Bypass>/=" new_iphy.xml)

if [[ -z $line_number ]]; then
    space='               '
    number=$(sed -n "/<\/GeneralSettings>/=" new_iphy.xml)
    sed -i "${number}i\ ${space}<L1Bypass>true</L1Bypass>" new_iphy.xml
fi

ln -sf new_iphy.xml iphy.xml
