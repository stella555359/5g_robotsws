#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 6 ]; then
    echo "Usage: $0 <feature_name> <release> <test_name> <date> <number_of_tests> <sw_version>"
    exit 1
fi

# Assign arguments to variables
feature_name=$1
release=$2
test_name=$3
date=$4
number_of_tests=$5
sw_version=$6

# Create the directory structure
target_dir="/home/ute/rotta/5G_3/tdabrows/regression/${feature_name}/${release}/${test_name}/${date}"
mkdir -p "$target_dir"

# Copy the log file to the latest regression directory
log_files=$(ls /home/ute/test_logs/Regression* | sort -r | head -n ${number_of_tests})
cp "/home/ute/test_logs/log.html" $log_files "$target_dir"

# Send the report using ute_reporting_portal
ute_reporting_portal send -ie -ro "/home/ute/test_logs/output.xml" -tl "7_16_UTE5GCLOUDT310" \
    --file_path "testsuite/Wroclaw/RRM/WRO_5/regression/regression_8950.robot" \
    --sw_version ${sw_version} --username "tdabrows" \
    -l "CLOUD_5G_CLASSICAL_FULLRACK_ASIM_ABIP_3xAHLOB_3xAVHA_3xAHFII_3xAVQQA" \
    --log_link "file://eseefsn50.emea.nsn-net.net/rotta4internal/${target_dir#/home/ute/rotta/}"
