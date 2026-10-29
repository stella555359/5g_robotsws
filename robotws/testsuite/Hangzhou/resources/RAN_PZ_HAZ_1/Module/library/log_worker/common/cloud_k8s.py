# -*- coding: utf-8 -*-
"""
Author: Liu, Renhui
Contacts: renhui-david.liu@nokia-sbell.com
Description: this script is used to collect logs from the kubernetes platform.
"""

from ssh_connect import ssh_connect
import os

ssh_connector = ssh_connect()


def start_syslog_log(connection, namespace, host_log_dir, timeout="300"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to start to collect syslog from vdu or vcu.
    *Contact:*
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
    syslog_url = get_syslog_url(connection, namespace, log_filter="/log_data")
    log_service_pod_name = get_log_service_pod_name(connection, namespace)
    log_processor_container_name = get_log_processor_container_name(connection, namespace, log_service_pod_name)

    host_log_path = collect_syslog_by_url(connection, namespace, log_service_pod_name, log_processor_container_name,
                                          syslog_url, host_log_dir, timeout=timeout)
    return host_log_path


# ---------------------Supported--------------------------------------------------------------------------
def collect_syslog_by_url(connection, namespace, log_service_pod_name, log_processor_container_name, syslog_url,
                          host_log_dir, log_name="syslog.txt.zip", timeout="300"):
    """
    *Usage:*
        - used to start to collect wireshark logs from a container inside a pod.
    *Contact:*
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
    collect_log_by_url(connection, namespace, log_service_pod_name, log_processor_container_name, syslog_url,
                       host_log_dir, log_name, timeout=timeout)
    return os.path.join(host_log_dir, log_name)


def collect_log_by_url(connection, namespace, log_service_pod_name, log_processor_container_name, log_url,
                       host_log_dir, log_name, timeout="300"):
    """
    *Usage:*
        - used to start to collect wireshark logs from a container inside a pod.
    *Contact:*
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
    cmd = f'kubectl exec -n {namespace} {log_service_pod_name} -c {log_processor_container_name} ' \
          f'-- curl -H "Accept-Encoding: gzip" "{log_url}" > {os.path.join(host_log_dir, log_name)}'
    output = ssh_connector.execute(connection, cmd, timeout=timeout).strip()
    print("The output of collecting log by url:\n", output)


def get_syslog_url(connection, namespace, log_filter="/log_data", timeout="10"):
    """
    *Usage:*
        - used to start to collect wireshark logs from a container inside a pod.
    *Contact:*
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
    return get_log_url(connection, namespace, log_filter, timeout=timeout)


def get_log_service_pod_name(connection, namespace, pod_type="logservice", timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get the log service pod's name.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - pod_type:
        - timeout:
    """
    return get_pod_name(connection, namespace, pod_type, timeout=timeout)


def get_log_processor_container_name(connection, namespace, log_service_pod_name, container_type="logprocessor",
                                     timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get the log service pod's name.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - log_service_pod_name:
        - timeout:
    """
    return get_container_name(connection, namespace, log_service_pod_name, container_type, timeout=timeout)


def get_log_url(connection, namespace, log_filter, timeout="10"):
    """
    *Usage:*
        - used to start to collect logs url.
    *Contact:*
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
    lwsd_pod_name = get_pod_name(connection, namespace, "lwsd")
    lwsd_container_name = get_container_name(connection, namespace, lwsd_pod_name, "lwsd")

    cmd = f"kubectl exec -n {namespace} {lwsd_pod_name} -c {lwsd_container_name}" \
          f" -- lwsd get-services | grep 'url' | awk -F '\"' '{{print $4}}' | grep '{log_filter}'"
    log_url = ssh_connector.execute(connection, cmd, timeout=timeout).strip()
    if len(log_url) == 0:
        raise ValueError("The log_url is empty.")
    return log_url


def get_pod_name(connection, namespace, pod_type, timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get a pod's name.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - pod_name:
        - timeout:
    """
    cmd = f"kubectl -n {namespace} get pod | grep {pod_type} | awk '{{print $1}}'"
    pod_name = ssh_connector.execute(connection, cmd, timeout=timeout).strip()
    if len(pod_name) == 0:
        raise ValueError("The pod_name is empty.")
    return pod_name


def get_container_name(connection, namespace, pod_name, container_type, timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get a container's name.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - pod_name:
        - container_type:
        - timeout:
    """
    cmd = f"kubectl -n {namespace} get pod {pod_name} -o json | " \
          f"jq -r '.spec.containers[] | select(.name | contains(\"{container_type}\")) | .name'"
    container_name = ssh_connector.execute(connection, cmd, timeout=timeout).strip()
    if len(container_name) == 0:
        raise ValueError("The container_name is empty.")
    return container_name


def get_active_pod_name(connection, namespace, pod_name, container_name, timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used for vcu with its init config ${CNF_LAYOUT} == "redundant".
    *Contact:*
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


def get_pod_name_prefix(connection, namespace, timeout="10"):
    """
    *Usage:*
        - Keyword
        - This keyword is used to get pod name's prefix.
    *Contact:*
        - renhui-david.liu@nokia-sbell.com
    *Args:*
        - connection: an alias for ssh connection
        - namespace:
        - timeout:
    """
    cmd = f"kubectl -n {namespace} get pod | grep oam | awk '{{print $1}}'| head -n 1"
    pod_name = ssh_connector.execute(connection, cmd, timeout=timeout).strip()
    if len(pod_name) == 0:
        raise ValueError("The pod_name is empty.")
    pod_prefix = pod_name.split('-')[0] + "-"
    return pod_prefix


def collect_k8s_log(pod_name, namespace, container_name, tmp_log_dir, conn=None, timeout="10", duration="1h"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - pod_name: see `collect log in which pod `
            - container_name: see `collect log in which container `

        *Command:* `` kubectl logs -n cran1 po-cran1-oam-0 --all-containers=True  --since=1h >
        /tmp/testResult/oam_all_container_journal.log``

        *Returns:*
            - output
    """

    prefix = get_pod_name_prefix(conn, namespace)
    pod_prefix = prefix + namespace
    container_prefix = "ctr-" + namespace
    tmp_log_dir = tmp_log_dir.rstrip("/") + "/"
    if container_name == 'All':
        all_container_cmd = ("kubectl logs " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" +
                             " --all-containers=True --since=" + duration + " > " + tmp_log_dir + pod_name +
                             "_all_container_journal.log")
        print(all_container_cmd)
        output = sshlib.execute(all_container_cmd, connection=conn, timeout=timeout)
        print(output)
        remote_log_dir = tmp_log_dir + pod_name + "_all_container_journal.log"
        return remote_log_dir
    else:
        container_cmd = (
                "kubectl logs " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" +
                " -c " + container_prefix + "-" + container_name + " --since=" + duration + " > "
                + tmp_log_dir + container_name + "_journal.log")
        print(container_cmd)
        output = sshlib.execute(container_cmd, connection=conn, timeout=timeout)
        print(output)
        remote_log_dir = tmp_log_dir + container_name + "_journal.log"
        return remote_log_dir


if __name__ == "__main__":
    ssh_connector.connect_to_server(connection="liang_test", hostname="10.110.9.194",
                                    username="core", password="system123")
    log_dir = collect_k8s_log(pod_name="cpif", namespace="cran18", container_name="cpif",
                              tmp_log_dir="/tmp/", conn="liang_test")
    local_path = "/home/ute/results/Liang_Kw_Test_20241112081710/T031_k8s_Vdu_vcu_20241112081710/vdu-k8s/liang.log"
    ssh_connector.download_file(connection="liang_test", remote_path=log_dir, local_path=local_path)
