#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='dcuser' 
PASSWORD='nE&e3Q*ptK8' 
HOST='192.168.255.129' 
PORT='9020' 
BUNDLE_PATH='/home/ute/ADMIN_CLI/bundle.js'
OUTPUT_FILE='/home/ute/ADMIN_CLI/getSystemModuleList.txt'
DATA='{"requestId":1,"parameters":{"name":"getSystemModuleList"}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --debug=debug.log   --bts-port=$PORT --data=$DATA --format='human' --output-json=$OUTPUT_FILE
#--output-file='scf.xml'

