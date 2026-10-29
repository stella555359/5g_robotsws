#!/bin/bash

# Create temporary log folder
rm -rf ran-nic-sw-controller-troubleshooting-logs; mkdir ran-nic-sw-controller-troubleshooting-logs

# Collect vDU version, pods status and RanNicConfig CR status (e.g. vDU namespace is cran1)
vdu_namespace=$1
helm list -n ${vdu_namespace} | tee ./ran-nic-sw-controller-troubleshooting-logs/vDU-build-version.log
kubectl get pod -n ${vdu_namespace} -o wide | tee ./ran-nic-sw-controller-troubleshooting-logs/vDU-pods-status.log
for rnc_name in `kubectl -n ${vdu_namespace} get rannicconfigs --no-headers -o custom-columns=Name:metadata.name`;do
  kubectl -n ${vdu_namespace} get rannicconfigs ${rnc_name} -o yaml | tee ./ran-nic-sw-controller-troubleshooting-logs/rannicconfigs_${rnc_name}.log;done

# Collect RAN NIC SW controller version, pods and RanNicNodeConfig CR status
helm list -n ran-nic-sw-controller | tee ./ran-nic-sw-controller-troubleshooting-logs/RAN-NIC-SW-controller-build-version.log
kubectl get pod -n ran-nic-sw-controller -o wide | tee ./ran-nic-sw-controller-troubleshooting-logs/RAN-NIC-SW-controller-pods-status.log
for rnnc_name in `kubectl -n ran-nic-sw-controller get rannicnodeconfigs --no-headers -o custom-columns=Name:metadata.name`;do
  kubectl -n ran-nic-sw-controller get rannicnodeconfigs ${rnnc_name} -o yaml | tee ./ran-nic-sw-controller-troubleshooting-logs/rannicnodeconfigs_${rnnc_name}.log;done

# Collect RAN NIC SW controller pods and containers logs
for pod_name in `kubectl -n ran-nic-sw-controller get pod --no-headers -o custom-columns=Name:metadata.name`; do
  kubectl -n ran-nic-sw-controller describe pod ${pod_name} | tee ./ran-nic-sw-controller-troubleshooting-logs/${pod_name}-pod.log;done

for pod_name in `kubectl -n ran-nic-sw-controller get pod --no-headers -o custom-columns=Name:metadata.name`;do
  for container_name in `kubectl -n ran-nic-sw-controller get pod ${pod_name} -o jsonpath={.spec.containers[*].name}`; do
    echo "container name is ${container_name}"
    kubectl logs -n ran-nic-sw-controller ${pod_name} -c ${container_name} | tee ./ran-nic-sw-controller-troubleshooting-logs/${pod_name}-pod_${container_name}-container.log
  done
done

for pod_name in `kubectl -n ran-nic-sw-controller get pod --no-headers -o custom-columns=Name:metadata.name`;do
  container_num=`kubectl -n ran-nic-sw-controller get pod ${pod_name} -o json | jq '.status.containerStatuses| length'`
  for ((i=0;i<${container_num};i++));do
    if [[ `kubectl get pod -n ran-nic-sw-controller ${pod_name} -o jsonpath="{.status.containerStatuses[$i].restartCount}"` -ne 0 ]];then
      container_name=`kubectl get pod -n ran-nic-sw-controller ${pod_name} -o jsonpath="{.status.containerStatuses[$i].name}"`
      kubectl logs -p -n ran-nic-sw-controller ${pod_name} -c ${container_name} | tee ./ran-nic-sw-controller-troubleshooting-logs/${pod_name}-pod_${container_name}-container_previous.log
      fi
    done
  done

# Collect RAN NIC host drivers version and status
for mc_name in `kubectl get mc --no-headers -o custom-columns=Name:metadata.name |grep loki-driver-load`; do
  echo -e "\nThe host driver version of machineconfig ${mc_name}:"
  kubectl get mc $mc_name -o jsonpath='{.spec.config.systemd.units[0].contents}' |grep -E "\w+-([0-9]+(\.[0-9]+){2})-" |awk -F"/" '{print $NF}' | awk -F":" '{print $1}' | tee ./ran-nic-sw-controller-troubleshooting-logs/machineconfig-${mc_name}-RAN-NIC-host-driver-version.log;done

for host_name in `kubectl get nodes --no-headers -o custom-columns=Name:metadata.name`; do
  echo -e "\nThe RAN NIC host drivers of ${host_name} node:"
  ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=3 ${host_name} lsmod |grep -E -i "oct|vfio" |tee ./ran-nic-sw-controller-troubleshooting-logs/${host_name}-RAN-NIC-host-drivers-status.log;done

# Collect RAN NIC PF/VF/boot network devices status
for host_name in `kubectl get nodes --no-headers -o custom-columns=Name:metadata.name`; do
  echo -e "\nThe RAN NIC host drivers of ${host_name} node:"
  ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=3 ${host_name} "lspci -D |grep -i cav; echo; ip link show |grep octboot" | tee ./ran-nic-sw-controller-troubleshooting-logs/${host_name}-RAN-NIC-PF-VF-boot-devices-status.log;done

# Collect host journal logs (since 24h ago)
for hostname in `kubectl get nodes --no-headers -o custom-columns=Name:metadata.name`; do
  echo ${hostname}
  ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${hostname} sudo journalctl --since \"24 hour ago\" | tee ./ran-nic-sw-controller-troubleshooting-logs/${hostname}-kubelet.log;done

# Collect host kernel dmesg logs
for hostname in `kubectl get nodes --no-headers -o custom-columns=Name:metadata.name`; do
  echo ${hostname}
  ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${hostname} dmesg -T | tee ./ran-nic-sw-controller-troubleshooting-logs/${hostname}-dmesg.log;done

# Collect K8S API server logs (OCP)
for pod_name in `kubectl -n openshift-kube-apiserver get pod --no-headers -o custom-columns=Name:metadata.name | grep kube-apiserver | grep -v guard`;do
  kubectl -n openshift-kube-apiserver logs ${pod_name} -c kube-apiserver | tee ./ran-nic-sw-controller-troubleshooting-logs/${pod_name}-pod_kube-apiserver-container.log;done

# Collect K8S scheduler logs (OCP)
for pod_name in `kubectl -n openshift-kube-scheduler get pod --no-headers -o custom-columns=Name:metadata.name | grep kube-scheduler | grep -v guard`;do
  kubectl -n openshift-kube-scheduler logs ${pod_name} -c kube-scheduler | tee ./ran-nic-sw-controller-troubleshooting-logs/${pod_name}-pod_kube-scheduler-container.log;done

# Collect all logs from the log folder
tar -cvzf ran-nic-sw-controller-troubleshooting-logs.tgz ran-nic-sw-controller-troubleshooting-logs