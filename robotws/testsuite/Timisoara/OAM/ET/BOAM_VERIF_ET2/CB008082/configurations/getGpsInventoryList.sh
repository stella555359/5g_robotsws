Create getGpsInventoryList.sh :
#!/bin/bash
ADMIN_CLI='/home/ute/ADMIN_CLI/admin-cli.sh'
USERNAME='Nemuadmin'
PASSWORD='nemuuser'
HOST='192.168.255.129'
PORT='443'
GPSLIST='GpsList.txt'
DATA='{"requestId":100,"parameters":{"name":"getGpsInventoryList"}}'

$ADMIN_CLI --bts-username=$USERNAME --bts-password=$PASSWORD --bts-host=$HOST --bts-port=$PORT --data=$DATA --format='human'  --output-json=$GPSLIST
