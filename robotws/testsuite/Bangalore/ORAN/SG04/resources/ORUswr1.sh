#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='443'
DATA='{"requestId":100,"parameters":{"name":"softwareUpdate","parameters":{"shouldActivate":true,"shouldResetRadios":true}}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human' --input-file=ORU_package_1_1.zip

