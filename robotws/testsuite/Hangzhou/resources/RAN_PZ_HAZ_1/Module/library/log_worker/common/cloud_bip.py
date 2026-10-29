# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
Description: this script is used to collect wireshark logs from cloudRAN products.
"""

import os
import time
from cloud_k8s import get_pod_name_prefix
from ssh_connect import ssh_connect

ssh_connector = ssh_connect()


def copy_bip_log_from_container_to_host(connection, namespace, pod_name, container_name,
                                        host_log_dir="/tmp/bip/", timeout="100"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to copy bip logs from a container inside a pod to the host.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - namespace: the tenant namespace which pod created in
        - pod_name: see `collect log in which pod `
        - container_name: see `collect log in which container `
    """
    full_pod_name = f"{pod_name}-0"
    pod_prefix = get_pod_name_prefix(connection, namespace)
    cmd_kubectl_bash = f"kubectl exec -i {pod_prefix}{namespace}-{full_pod_name} -c ctr-{namespace}-{container_name}" \
                       f" -n {namespace} -- bash -c "
    cmd_cp = f"kubectl cp -n {namespace} {pod_prefix}{namespace}-{full_pod_name}"
    cmd_cp_postfix = f" -c ctr-{namespace}-{container_name}"

    remote_log_dir = host_log_dir.rstrip("/") + "/"
    cmd_clear_host_log = "rm -r " + remote_log_dir + "*"
    ssh_connector.execute_command(connection, cmd_clear_host_log, timeout=timeout)

    cmd_list_bip_log = cmd_kubectl_bash + "'ls -alh /tmp/dpdkdump'"
    ssh_connector.execute_command(connection, cmd_list_bip_log, timeout=timeout)

    # rename a bip log to a specific name
    log_dir_in_container = ":tmp/dpdkdump/"
    tem_bip_log_name = "tmp-bip.pcap"
    cmd_part_1 = log_dir_in_container + tem_bip_log_name
    bip_log_path = os.path.join(remote_log_dir, tem_bip_log_name)
    cmd_rename = "'mv /tmp/dpdkdump/*.pcap /tmp/dpdkdump/{}'".format(tem_bip_log_name)
    cmd_rename_bip_log = cmd_kubectl_bash + cmd_rename
    ssh_connector.execute_command(connection, cmd_rename_bip_log, timeout=timeout)

    start_bip_log_name = "start_bip.log"
    start_bip_log_path = os.path.join(remote_log_dir, start_bip_log_name)
    cmd_part_2 = log_dir_in_container + start_bip_log_name
    cmd_copy_log_file = cmd_cp + cmd_part_2 + " " + start_bip_log_path + cmd_cp_postfix
    ssh_connector.execute_command(connection, cmd_copy_log_file, timeout=timeout)

    cmd_copy_bip_log = cmd_cp + cmd_part_1 + " " + bip_log_path + cmd_cp_postfix
    ssh_connector.execute_command(connection, cmd_copy_bip_log, timeout=timeout)

    # clear bip log in the pod
    cmd_clear_pod_log = cmd_kubectl_bash + "'rm -r /tmp/dpdkdump/*'"
    ssh_connector.execute_command(connection, cmd_clear_pod_log, timeout=timeout)
    return remote_log_dir
