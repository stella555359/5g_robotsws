#!/bin/bash

namespace=$1
current_dir=$(cd $(dirname $0);pwd)
dir=$current_dir/logservice/$namespace
sudo rm -rf $dir

logservice_HOSTIP=`oc get po -n $namespace -l app.kubernetes.io/name=logservice -o=jsonpath='{..hostIP}'`
logservice_PODIP=`oc get po -n $namespace -l app.kubernetes.io/name=logservice -o=jsonpath='{..podIP}'`

echo "logservice Host IP is:" $logservice_HOSTIP",logservice POD IP is: "$logservice_PODIP
# Create the directory only if it doesn't exist
mkdir -p logservice/$namespace

# Get the current time in the desired format
current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

pod_deploy_time=$(kubectl get pods -n $namespace | grep logservice | awk '{print $5}')

# Convert pod_deploy_time to seconds
if [[ $pod_deploy_time == *m ]]; then
    pod_deploy_seconds=$((${pod_deploy_time%m} * 60))
elif [[ $pod_deploy_time == *h ]]; then
    pod_deploy_seconds=$((${pod_deploy_time%h} * 3600))
elif [[ $pod_deploy_time == *d ]]; then
    pod_deploy_seconds=$((${pod_deploy_time%d} * 86400))
else
    # Default value of 2 hours in seconds
    pod_deploy_seconds=$((2 * 3600))
fi

# Subtract pod_deploy_seconds from the current time
from_time=$(date -u -d "@$(($(date -u +%s) - pod_deploy_seconds - 600))" +"%Y-%m-%dT%H:%M:%SZ")

# Print the from_time
echo "fromTime: $from_time"

sshpass -p system123 ssh $logservice_HOSTIP -o StrictHostKeyChecking=no curl -X GET "$logservice_PODIP:50108/api/trc/v1/log_data?fromTime=$from_time" -H "accept: application/octet-stream" > $dir/syslog.zip

sudo chmod -R 777 $dir

if [ -d $dir ];
then
    echo "### logservice logs were collected successfully. ###"
else
    echo "### logservice logs were collected failed. ###" && exit
fi
