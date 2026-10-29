#!/bin/bash

export https_proxy=http://10.158.100.6:8080
export http_proxy=http://10.158.100.6:8080

echo "Downloading Build and Starting Scan"
python2 build_download_and_update.py -b $1
python2 qualysguard_scan.py --profile $2 --name $3
sh VAMS_Export.sh
