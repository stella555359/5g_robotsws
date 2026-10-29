#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='dcuser' 
PASSWORD='nE&e3Q*ptK8' 
HOST='192.168.255.129' 
PORT='9020' 
BUNDLE_PATH='/home/ute/ADMIN_CLI/bundle.js'
OUTPUT_FILE='/home/ute/ADMIN_CLI/resetAllRADDebugParameters.txt'
DATA='{"requestId":1,"parameters":{"name":"resetAllRADDebugParameters"}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --insecure=false --output-json=$OUTPUT_FILE --debug=debug.log  --bundle-path=$BUNDLE_PATH
