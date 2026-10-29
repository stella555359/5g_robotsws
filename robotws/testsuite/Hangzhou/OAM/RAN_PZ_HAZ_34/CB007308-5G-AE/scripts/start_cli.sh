#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD=$2
HOST=$1
PORT='443'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --cli-port='9001' --bts-port=$PORT --debug='/home/ute/logs/5GC000915_2021_03_17'
