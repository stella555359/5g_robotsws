#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='10.58.239.89'
PORT='443'
DATA='{"requestId":100,"parameters":{"name":"softwareUpdate","parameters":{"shouldActivate":true,"shouldResetRadios":true}}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human' --input-file=FJ-RU-ET1---------0202.FGF.zip

