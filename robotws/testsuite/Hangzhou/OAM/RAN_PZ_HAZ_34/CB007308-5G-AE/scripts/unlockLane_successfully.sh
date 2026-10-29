#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD=$3
HOST=$2
PORT='443'


DATA="{\"requestId\":1,\"parameters\":\
{\"name\":\"unlock\",\"parameters\":{\"distNames\":[\"MRBTS-$1/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1\"]}}}"
echo $DATA
$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human'
