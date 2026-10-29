# -*- coding: utf-8 -*-
"""
Author: Yang Mengli
Contacts: mengli.yang@nokia-sbell.com
Description: this script is used for collect and download wireshark log to master

"""

import time
import re
from taf.transport.ssh import ssh
import taf.hw.fhgw.cli
from basic import basic
from taf.transport.ssh import ssh
import logging
import os
from command_result import RunResult, ClusterConnectionFailure, TimeoutError

ssh = ssh()


def vcu_master_connect(hostname, username, password, port="22", timeout="10"):
    """
    This keyword is used to connect to vdu master
    *Args:*
        - _ip_: k8s master ip address(mandatory)
        - _user_: user name of k8s master (mandatory)
        - _password_: password of user (mandatory)
        - _port_: k8s master ssh port
        - _timeout_: timeout of login, default is 10s

    *Command:*  None
    *Returns:*
        - connection alias
    *Example:*
    | vdu_master_connect | 10.71.174.254 | user |  password  | 22 |
     """
    conn = ssh.connect_to(hostname=hostname, username=username, password=password, port=port, timeout=timeout)
    return conn


def vcu_master_close(conn=None):
    """
    This keyword is used to close vdu master
    *Command:*  None
    *Returns:*
        - None
    *Example:*
    | vdu_master_close |  |
     """
    self.ssh.disconnect(conn)


def start_log(master_ip, username, password, pod_name, namespace, container_name,
              protocol="sctp", interface="any"):
    """
    *Args:*
        - master_ip: the OE20 cluster ip
        - username: the username that used to login master, it should be tenant username
        - password: the password that used to login master, it should be tenant username
        - pod_name: the pod name that container belongs to
        - container_name: the container name that you want to login

    *Command:* ``kubectl exec -it <pod_name> -c <container_name> -- bash``

    *Returns:*

    *Example:*

    """
    pod_prefix = "po-" + namespace
    container_prefix = "ctr-" + namespace
    sshlib.set_default_configuration(timeout=20)
    sshlib.open_connection(master_ip, prompt='REGEXP:~]\\$')
    res = sshlib.login(username, password, delay='5s')
    # sshlib.set_client_configuration(prompt='REGEXP:(bash.*\\$)|#')
    start_cmd = (
            "kubectl exec -it " + pod_prefix + "-" + pod_name + "-0" + " -n " + namespace + " -c " +
            container_prefix + "-" + container_name + " -- tcpdump -i " + interface + " " +
            protocol + " -s 0 -w " + "/tmp/" + namespace + "_" + container_name + "_wireshark.pcap")
    sshlib.write(start_cmd)
    res = sshlib.read_until_prompt()
    return res


def start_wireshark_log(pod_name, namespace, container_name, conn, timeout="10",
                        protocol="sctp", interface="any"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - pod_name: see `collect log in which pod `
            - container_name: see `collect log in which container `

        *Command:* `` kubectl exec -it po-cran1-up-0 -c ctr-cran1-l1hi -n cran1 -- bash -c
        'cd tmp; dpdk-cli pdump port 1'``

        *Returns:*
            - output

        *Example:*
        | start_wireshark_log |  pod_name=${pod_name} | namespace=${ns} | container_name=${container_name} |
        | pod_prefix=${pod_prefix} | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
        |protocol=${protocol} | interface=${interface} |
    """

    pod_prefix = "po-" + namespace
    container_prefix = "ctr-" + namespace
    start_cmd = (
            "kubectl exec -it " + pod_prefix + "-" + pod_name + "-0" + " -n " + namespace + " -c " +
            container_prefix + "-" + container_name + " -- tcpdump -i " + interface + " " +
            protocol + " -s 0 -w " + "/tmp/" + namespace + "_" + container_name + "_wireshark.pcap")

    print(start_cmd)
    output = ssh.send_command(start_cmd, connection=conn, timeout=timeout)
    print(output)


def start_wireshark_log_for_vdu(namespace, container_name, conn, timeout="10", interface="any"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - pod_name: see `collect log in which pod `
            - container_name: see `collect log in which container `

        *Command:* `` kubectl exec -it po-cran1-up-0 -c ctr-cran1-l1hi -n cran1 -- bash -c
        'cd tmp; dpdk-cli pdump port 1'``

        *Returns:*
            - output

        *Example:*
        | start_wireshark_log |  pod_name=${pod_name} | namespace=${ns} | container_name=${container_name} |
        | pod_prefix=${pod_prefix} | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
        |protocol=${protocol} | interface=${interface} |
    """

    container_prefix = "ctr-" + namespace
    container_id_cmd = ("sudo crictl ps|grep " + container_prefix + "-" + container_name + " -w " +
                        "|awk '{print $1}'")
    container_id_output = execute_command(cmd=container_id_cmd, conn=conn, timeout=timeout)
    container_id = container_id_output.stdout.strip()
    print(container_id)
    pid_id_cmd = (
            "sudo crictl inspect --output yaml " + container_id + "| grep 'pid:'|awk -F ':' '{print $2}'")

    pid_id_output = execute_command(cmd=pid_id_cmd, conn=conn, timeout=timeout)
    pid_id = pid_id_output.stdout.strip()
    print(pid_id)
    start_cmd = (
            "sudo nsenter -r -n -t " + pid_id + " tcpdump -i " + interface + " -s 0 -w " + "/tmp/" + namespace + "_" +
            container_name + "_wireshark.pcap")
    output = ssh.send_command(start_cmd, connection=conn, timeout=timeout)
    print(output)


def start_wireshark_log_for_vcu(namespace, pod_name, conn, ip, core_password="system123",
                                cranuser_password="system123", timeout="10", interface="any"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - pod_name: see `collect log in which pod `
            - container_name: see `collect log in which container `

        *Command:* `` sshpass -p 'system123' ssh -o StrictHostKeyChecking=no core@10.110.10.70
        "kubectl get pod po-cran15-cpif-0 -o yaml -n cran15
        |grep nodeName | awk '{print $2}'" | awk '{print $2}''``

        *Returns:*
            - output

        *Example:*
        | start_wireshark_log |  pod_name=${pod_name} | namespace=${ns} | container_name=${container_name} |
        | pod_prefix=${pod_prefix} | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
        |protocol=${protocol} | interface=${interface} |
    """
    cran_user_name = "cranuser" + namespace.split('n')[-1]
    pod_prefix = "po-" + namespace + "-" + pod_name + "-0"
    container_prefix = "ctr-" + namespace + "-" + pod_name
    com_cmd_core = "sshpass -p '" + core_password + "' ssh -o StrictHostKeyChecking=no core@" + ip
    com_cmd_cranuser = "sshpass -p '" + cranuser_password + "' ssh -o StrictHostKeyChecking=no " + cran_user_name + \
                       "@" + ip
    work_id_cmd = " kubectl get pod " + pod_prefix + " -o yaml -n " + namespace + "|grep nodeName | awk '{print $2}' "
    work_id_output = execute_command(cmd=work_id_cmd, conn=conn, timeout=timeout)
    work_id = work_id_output.stdout.strip()
    print(work_id)
    work_ip_cmd = com_cmd_cranuser + " \"kubectl describe nodes " + work_id + " | grep InternalIP\" "
    work_ip_output = execute_command(cmd=work_ip_cmd, conn=conn, timeout=timeout)
    work_ip = work_ip_output.stdout.strip()
    work_ip = work_ip.split(' ')[-1]
    print(work_ip)
    com_cmd_work = "sshpass -p " + cranuser_password + " ssh -o StrictHostKeyChecking=no " + cran_user_name + \
                   "@" + work_ip
    container_id_cmd = com_cmd_work + " \"sudo crictl ps | grep " + "\\ " + container_prefix + "\\ " + \
                                      " | awk '{print \\$1}' \""
    container_id_output = execute_command(cmd=container_id_cmd, conn=conn, timeout=timeout)
    container_id = container_id_output.stdout.strip()
    print(container_id)
    pid_cmd = com_cmd_work + " \"sudo crictl inspect --output yaml " + container_id + \
                             "| grep 'pid:' | grep -o \"[0-9]*\" \""
    pid_output = execute_command(cmd=pid_cmd, conn=conn, timeout=timeout)
    pid = pid_output.stdout.strip()
    print(pid)
    start_wireshak_log_cmd = com_cmd_work + " \"pwd;sudo nsenter -r -n -t " + pid + " tcpdump -i " + interface + \
                                            " -s 0 -w " + "/tmp/" + namespace + "_" + pod_name + "_wireshark.pcap \""
    output = ssh.send_command(start_wireshak_log_cmd, connection=conn, timeout=timeout)
    time.sleep(5)
    print(output)


def execute_command(cmd, fail_on_error=False, conn=None, timeout='60'):
    """
    This keyword executes command on remote cluster.

    *Args:*
        - _cmd_: command to execute (mandatory)
        - _fail_on_error_: see `Failing on command execution errors`
        - _conn_: connection which returned from helm_master_connect
        - _timeout_: timeout of

    *Returns:*
        - `result object` with command execution results
    """
    try:
        # cmd = "source /etc/profile && source ~/.bash_profile && " + cmd
        # print(cmd)
        ssh.send_command(cmd, connection=conn, timeout=timeout)
        result_stdout = ssh.read_output(connection=conn)
        result_stderr = ssh.read_error(connection=conn)
        result_status = ssh.get_exit_status(connection=conn)
        res = RunResult(stdout=result_stdout, stderr=result_stderr, status=result_status)
        logging.info(str(res))
        check_fail_keyword_on_error_if_needed(fail_on_error, res)
        return res
    except AttributeError:
        raise ClusterConnectionFailure('Ssh connection to cluster does not work.')


def check_fail_keyword_on_error_if_needed(fail_on_error, result):
    if result.status != 0 and str(fail_on_error).lower() == "true":
        raise Exception('Command execution failed:' + str(result))


def stop_wireshark_log(pod_name, namespace, container_name='cpif', conn=None, timeout="10"):
    """
            *Args:*
                - conn: which vDU is connected
                - timeout: see `command timeout `

            *Command:* `` ps -ef|grep dpdk|grep -v grep|awk '{print $2}'``

            *Returns:*
                - output

            *Example:*
            | stop_wireshark_log | conn=None | timeout="10" |
            """
    pod_prefix = "po-" + namespace
    container_prefix = "ctr-" + namespace
    tcpdump_name = pod_prefix + "-" + pod_name + "-0"
    check_process_cmd = ("ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'")
    print(check_process_cmd)
    output = ssh.send_command(check_process_cmd, connection=conn, timeout=timeout)
    print(output)
    stop_cmd = ("pkill -f " + tcpdump_name)
    print(stop_cmd)
    output = ssh.send_command(stop_cmd, connection=conn, timeout=timeout)
    print(output)
    chmod_cmd = (
            "kubectl exec -it " + pod_prefix + "-" + pod_name + "-0" + " -n " + namespace + " -c " +
            container_prefix + "-" + container_name + " -- chmod -R 777 " + "/tmp/" + namespace + "_" +
            container_name + "_wireshark.pcap")

    print(chmod_cmd)
    output = execute_command(cmd=chmod_cmd, conn=conn, timeout=timeout)
    print(output)
    # output = ssh.send_command(start_cmd, connection=conn, timeout=timeout)


def stop_wireshark_forced(conn=None, timeout='60'):
    """
            *Command:* `` ps aux | grep tcpdump | awk '{ print $2}' | xargs -n1 -I {} kill -9 {} ``
            """
    stop_cmd = ("ps aux | grep tcpdump | awk '{ print $2}' | xargs -n1 -I {} kill -9 {} ")
    ssh.send_command(stop_cmd, connection=conn, timeout=timeout)


def download_wireshark_log_to_master(pod_name, namespace, container_name, tmp_log_dir, conn=None, timeout="10"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - pod_name: see `collect log in which pod `
            - container_name: see `collect log in which container `

        *Command:* `` kubectl exec -it po-cran1-up-0 -c ctr-cran1-l1hi -n cran1 -- bash -c
        'cd tmp; dpdk-cli pdump port 1'``

        *Returns:*
            - output

        *Example:*
        | ${pod_name_list} | download_wireshark_log_to_master | pod_name=${pod_name} | namespace=${ns} |
        | container_name=${container_name} | tmp_log_dir=/tmp/wireshark/ | pod_prefix=${pod_prefix} |
        | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
        """
    pod_prefix = "po-" + namespace
    container_prefix = "ctr-" + namespace
    tmp_log_dir = tmp_log_dir.rstrip("/") + "/"
    remote_log_dir = tmp_log_dir + namespace + "_" + container_name + "_wireshark.pcap"
    if os.path.isfile(remote_log_dir):
        rm_cmd = ("rm -rf " + tmp_log_dir)
        output = execute_command(cmd=rm_cmd, conn=conn, timeout=timeout)
    copy_cmd = (
            "kubectl exec " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" + " " +
            "-c" + " " + container_prefix + "-" + container_name + " " + "--" + " " + "/bin/gzip" + " " +
            "-c" + " /tmp/" + namespace + "_" + container_name + "_" + "wireshark.pcap" + " | " + "gunzip "
            + " > " + " /tmp/" + namespace + "_" + container_name + "_" + "wireshark.pcap")
    print(copy_cmd)
    output = execute_command(cmd=copy_cmd, conn=conn, timeout=timeout)
    print(output)
    time.sleep(5)
    result = check_file_exist(remote_log_dir)
    print(result)
    return remote_log_dir


def check_file_exist(filename):
    if not os.path.isfile(filename):
        logging.info("%s not found." % filename)
        return False
    return True
