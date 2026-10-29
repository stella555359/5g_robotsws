#!/bin/bash
result=$( hostname | grep -- -2 )
host=$( hostname )
if [[ $result == $host ]]
then
  echo "you are in second node you dummy, go to primary node"
else
  label=$(cat '/opt/ute/reservation.context.json' |     python3 -c "import sys, json; print(json.load(sys.stdin)['CM_TOPOLOGY']['name'])")
  . /opt/ute/agent_env/bin/activate; agent_gve_common repair -l $label -b $1 -o /home/ute/output -R /home/ute/testline_repair_results/
fi
