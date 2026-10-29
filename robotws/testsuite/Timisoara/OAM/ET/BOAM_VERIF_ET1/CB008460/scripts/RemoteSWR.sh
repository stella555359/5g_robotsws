#!/bin/bash
ADMIN_CLI=./admin-cli.sh
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='443'
DATA='{"requestId":100,"parameters":{"name":"softwareUpdate","parameters":{"fileServerUrl":"https://10.5.25.105:8443/webdav/Remotepackage/bts_sw/","targetBd":"TargetBD_general.xml","shouldActivate":true}}}'


$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human'
