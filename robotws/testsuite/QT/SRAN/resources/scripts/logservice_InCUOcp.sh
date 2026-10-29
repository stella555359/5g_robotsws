#!/bin/bash

namespace=$1
dir=$2

sudo rm -rf $dir

pvc_logservice=`kubectl get pvc -n $namespace | grep -i logservice-syslog |awk '{print $3}'`

echo "pvc_logservice is: "$pvc_logservice

uid_logservice=`kubectl get pod -n $namespace |grep -i logservice |awk '{print $1}' |xargs kubectl get pod -n $namespace -o yaml| grep -i uid | tail -1 |awk '{print $2}'`

echo "uid_logservice is: "$uid_logservice

node_logservice=`kubectl get pods -n $namespace |awk '{print $1}' |grep logservice |xargs kubectl get pod -n $namespace -o wide |awk '{print $7}' |tail -1`

echo "node_logservice is:"$node_logservice

ssh $node_logservice -o StrictHostKeyChecking=no << remotessh
sudo rm -rf Logservice_b

sudo ls /var/lib/kubelet/pods/$uid_logservice/volumes/kubernetes.io~csi/$pvc_logservice

sudo cp -r /var/lib/kubelet/pods/$uid_logservice/volumes/kubernetes.io~csi/$pvc_logservice ./Logservice_b

sudo chmod -R 777 Logservice_b

exit

remotessh

scp -r $node_logservice:/var/home/core/Logservice_b/ $dir


if [ -d $dir ];
then
    echo "### logservice logs were collected successfully. ###"
else
    echo "### logservice logs were collected failed. ###" && exit
fi
