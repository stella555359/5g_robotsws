

#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='443'
BUNDLE_PATH='/home/ute/ADMIN_CLI/bundle.js'
DATA='{"requestId":71795,"parameters":{"name":"recommission","parameters":{"planObjects":[{"distName":"MRBTS-1","operation":"update","parameters":[{"parameterName":"btsName","operation":"update","value":"Alecu2"}]}],"skipParameterRelationErrors":true,"shouldBeActivated":true,"outputFileContent":""}}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --insecure=false --debug=debug.log  --bundle-path=$BUNDLE_PATH

