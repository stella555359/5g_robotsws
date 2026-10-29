#!/bin/bash

echo "WA for the RedHat ticket-https://access.redhat.com/support/cases/#/case/03257205"

echo "start to delete released pv"
for pv in `oc get pv | grep -i Released | awk '{print $1}'`; do
    disk="$disk `oc get pv $pv -o jsonpath='{.spec.local.path}'`"
    oc delete pv $pv
    $disk > /dev/null 2>&1
done

echo $disk

echo "start to restart crio"
sudo systemctl restart crio

echo "start to restart kubelet"
sudo systemctl restart kubelet
sleep 60s

function releasePV {
echo "start to clean up the problematic pv storage"
disks=$disk
for disk in $disks; do
    sudo mkfs -F $disk
    sudo wipefs -a $disk
done
}

releasePV > res.txt 2>&1
result=`cat res.txt |grep -E "error | busy | failed" |wc -l`
echo "result is :" $result

if [ $result -ne 0 ];then
    echo "start to restart kubelet"
    sudo systemctl restart kubelet
    sleep 20s
    releasePV
else
    exit;
fi
