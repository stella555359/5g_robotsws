#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='443'
DATA='{"requestId":1,"parameters":{"name":"unlock","parameters":{"distName":"MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1"}}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human'
