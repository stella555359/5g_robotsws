#!/bin/bash

cd /ffs/run/simmode/

iphy_file_name=$(ls -l /ffs/run/simmode | awk -F'->' '{print $2}' | tr -d ' ')
echo iphy_file_name=$iphy_file_name

line_number=$(sed -n "/<L1Bypass>true<\/L1Bypass>/=" $iphy_file_name)
echo line_number=$line_number

check_result=$(grep -i "L1Bypass" $iphy_file_name)
echo "Before change: "$check_result

sed -i '/<L1Bypass>true<\/L1Bypass>/d' $iphy_file_name

check_result=$(grep -i "L1Bypass" $iphy_file_name)
echo "After change: "$check_result

ln -sf $iphy_file_name iphy.xml

