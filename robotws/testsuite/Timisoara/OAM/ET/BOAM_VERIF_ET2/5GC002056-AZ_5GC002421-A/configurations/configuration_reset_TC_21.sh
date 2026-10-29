
#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='443'
BUNDLE_PATH='/home/ute/ADMIN_CLI/bundle.js'
#DATA='{"requestId":1,"parameters":{"name":"commission"}}'
#DATA='{"requestId":100,"parameters":{"name":"configurationReset","parameters":{"removedSiteId":false,"removeSecurityCredentials":false}}}'
DATA='{"requestId":100,"parameters":{"name":"configurationReset","parameters":{"removeSiteId":false,"removeSecurityCredentials":false}}}'
#DATA='{"requestId":82831,"parameters":{"name":"commission","parameters":{"skipParameterRelationErrors":true,"distName":"MRBTS-10558","value":"test","parameterName":"btsName","operation":"update","shouldBeActivated":true}}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --insecure=false --debug=debug.log  --bundle-path=$BUNDLE_PATH
