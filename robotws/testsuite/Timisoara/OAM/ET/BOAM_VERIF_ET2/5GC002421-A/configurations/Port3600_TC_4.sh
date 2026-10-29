

#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='3600'
BUNDLE_PATH='/home/ute/ADMIN_CLI/bundle.js'
#DATA='{"requestId":100,"parameters":{"name":"remoteSnapshot","parameters":{"coverage":"Fullda","networkCellDNs":["MRBTS-10558/NRBTS-1/NRCELL-1"]}}}'
DATA='{"requestId":1,"parameters":{"name":"getBtsInformation"}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --insecure=false --debug=debug.log  --bundle-path=$BUNDLE_PATH
