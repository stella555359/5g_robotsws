#!/bin/bash
ADMIN_CLI='/home/ute/CB007944/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
OUTPUT_FILE='/home/ute/CB007944/outputFullCheck.txt'
HOST='192.168.255.1'
PORT='443'
BUNDLE_PATH='/home/ute/CB007944/bundle.js'
SW_FILE="/tmp/SBTS00_testpackage.zip"
DATA='{"requestId":100,"requestType":"procedure","parameters":{"name":"softwarePrecheck","parameters":{"precheckType":"FullCheck"}}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human' --input-file=$SW_FILE --output-json=$OUTPUT_FILE --bundle-path=$BUNDLE_PATH
