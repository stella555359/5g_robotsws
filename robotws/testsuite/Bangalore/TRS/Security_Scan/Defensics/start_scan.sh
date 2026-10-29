#!/bin/bash

export https_proxy=http://10.158.100.6:8080
export http_proxy=http://10.158.100.6:8080

echo "Downloading Build and Updating BTS"
python build_download_and_update.py -b $1
echo "Starting Scan"
python defensics_suite.py $2 $3
python sendmail.py 
