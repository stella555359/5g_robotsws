

#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='443'
BUNDLE_PATH='/home/ute/ADMIN_CLI/bundle.js'
#DATA='{"requestId":100,"parameters":{"name":"remoteSnapshot","parameters":{"coverage":"Full","networkCellDNs":["MRBTS-10558/NRBTS-1/NRCELL-1"]}}}'
#DATA='{"requestId":100,"parameters":{"name":"getBtsInformation"}}'71795
#DATA='{"requestId":71795,"parameters":{"nameaaa":"recommission","parameters":{"planObjects":[{"distName":"MRBTS-10558/NRBTS-1","operation":"update","parameters":[{"parameterName":"x2Uplane","operation":"update","value":[{"ipV4AddressDN1":"MRBTS-10558/TNLSVC-1/TNL-1/IPNO-1/IPIF-5/IPADDRESSV4-1"}]}]}],"skipParameterRelationErrors":true,"shouldBeActivated":true,"outputFileContent":""}}}'
#DATA='{"requestId":1,"parameters":{"name":"commission"}}'
DATA='{"requestId":82831,"parameters":{"name":"commission","parameters":{"skipParameterRelationErrors":true,"distName":"MRBTS-1","value":"Alecu","parameterName":"btsName","operation":"update","shouldBeActivated":true}}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --insecure=false --debug=debug.log  --bundle-path=$BUNDLE_PATH
