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


def start_wireshark_log(connection, namespace, pod_name, container_name, protocol, interface,
                        container_log_dir="/tmp", timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to start to collect wireshark logs from a container inside a pod.
        - To use this keyword, the container must already have the tcpdump tool installed.
    *Author:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - pod_name:
        - container_name:
        - protocol:
        - interface:
        - timeout:
    """
    full_pod_name = f"{pod_name}-0"
    log_name = f"{namespace}_{container_name}_wireshark.pcap"
    log_path = os.path.join(container_log_dir, log_name)
    pod_prefix = get_pod_name_prefix(connection, namespace)
    cmd_kubectl = f"kubectl exec -it {pod_prefix}{full_pod_name} " \
                  f"-n {namespace} -c ctr-{container_name}"
    cmd_tcpdump = f"tcpdump -i {interface} {protocol} -s 0 -w {log_path}"
    full_cmd = f"{cmd_kubectl} -- {cmd_tcpdump}"
    print(f"The command to collect wireshark log: {full_cmd}")
    output = ssh_connector.send_command(connection, full_cmd, timeout=timeout)
    print(output)


def stop_wireshark_log(connection, namespace, pod_name, container_name, timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to stop collecting wireshark logs.
    *Author:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - pod_name:
        - container_name:
        - protocol:
        - interface:
        - timeout:
    """
    tool_name = "tcpdump"
    full_pod_name = f"{pod_name}-0"
    pod_prefix = get_pod_name_prefix(connection, namespace)
    cmd_kubectl = f"kubectl exec -it {pod_prefix}{full_pod_name} " \
                  f"-n {namespace} -c ctr-{container_name}"
    cmd_tcpdump = f"pkill -f {tool_name}"
    stop_cmd_1 = f"{cmd_kubectl} -- {cmd_tcpdump}"
    print(f"stop_cmd_1: {stop_cmd_1}")
    output = ssh_connector.execute_command(connection, stop_cmd_1, timeout=timeout)
    stop_cmd_2 = ("ps -ef|grep " + tool_name +
                  " |grep " + full_pod_name +
                  " |grep -v grep|awk '{print $2}'|xargs -r kill -9")
    print(f"stop_cmd_2: {stop_cmd_2}")
    output = ssh_connector.execute_command(connection, stop_cmd_2, timeout=timeout)


def start_wireshark_log_with_container_pid(connection, namespace, pod_name, container_name, protocol, interface,
                                           container_log_dir="/tmp", timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to start to collect wireshark logs from a container inside a pod.
        - This keyword is for the container that does not have the tcpdump tool installed.
    *Author:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - pod_name:
        - container_name:
        - protocol:
        - interface:
        - timeout:
    """
    pass


def stop_wireshark_log_with_container_pid(connection, namespace, pod_name, container_name, protocol, interface,
                                          log_dir="/tmp", timeout="10"):
    pass


def copy_wireshark_log_from_container_to_host(connection, namespace, pod_name, container_name,
                                              container_log_dir="/tmp", host_log_dir="/tmp",
                                              copy_way="cat", timeout="100"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to copy wireshark logs from a container inside a pod to the host.
        -
    *Author:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - pod_name:
        - container_name:
        - protocol:
        - interface:
        - timeout:
    """
    full_pod_name = f"{pod_name}-0"
    pod_prefix = get_pod_name_prefix(connection, namespace)
    cmd_kubectl = f"kubectl exec -it {pod_prefix}{full_pod_name} " \
                  f"-n {namespace} -c ctr-{container_name}"
    log_name = f"{namespace}_{container_name}_wireshark.pcap"
    container_log_path = os.path.join(container_log_dir, log_name)
    host_log_path = os.path.join(host_log_dir, log_name)
    cmd_copy = _generate_copy_command(copy_way, container_log_path, host_log_path)
    full_cmd = f"{cmd_kubectl} -- {cmd_copy}"
    print(f"The copy command is: {full_cmd}")
    if ssh_connector.file_exists(connection, host_log_path, timeout=timeout):
        cmd_remove = f"rm -rf {host_log_path}"
        output = ssh_connector.execute_command(connection, cmd_remove, timeout=timeout)
        print(f"The remove command output is: {output}")
    output = ssh_connector.execute_command(connection, full_cmd, timeout=timeout)
    time.sleep(5)
    does_file_exist = ssh_connector.file_exists(connection, host_log_path, timeout=timeout)
    print(f"Does the wireshark log exist in the host {host_log_path}? {does_file_exist}")
    return host_log_path


def _generate_copy_command(copy_way, container_log_path, host_log_path):
    """
    *Usage:*
        - Used to generate a copy command according to the copy way.
    *Author:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - copy_way: support cat and gzip
        - container_log_path:
        - host_log_path:
    """
    cmd_copy = ""
    if copy_way == "cat":
        cmd_copy = f"cat {container_log_path} >{host_log_path}"
    if copy_way == "gzip":
        cmd_copy = f"/bin/gzip -c {container_log_path} |gunzip >{host_log_path}"
    return cmd_copy
