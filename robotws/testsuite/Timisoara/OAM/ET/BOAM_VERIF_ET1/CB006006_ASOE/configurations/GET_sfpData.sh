#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='443'
#OUTPUT_FILE=output.txt
BUNDLE_PATH='/home/ute/ADMIN_CLI/bundle.js'
#DATA='{"requestId":100,"parameters":{"name":"sfpData","parameters":{"coverage":"Fullda","networkCellDNs":["MRBTS-10558/NRBTS-1/NRCELL-1"]}}}'
DATA='{"requestId":100,"parameters":{"name":"sfpData"}}'
#DATA='{"requestId":1,"parameters":{"name":"sfpData"}}'
$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human' --debug=debug.log --bundle-path=$BUNDLE_PATH
#$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human' --output-json=$OUTPUT_FILE
