# -*- coding: utf-8 -*-
"""
Author: Yang Mengli
Contacts: mengli.yang@nokia-sbell.com
Description: this script is used for collect k8s log

"""

import time
import re
from robot.api import logger
from taf.transport.ssh import ssh
from command_result import RunResult, ClusterConnectionFailure, TimeoutError
import logging
from basic import basic

sshlib = ssh()


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

        *Example:*
        | ${pod_name_list} | collect_k8s_log | pod_name=${pod_name} | namespace=${ns} |
        | container_name=${container_name} | tmp_log_dir=/tmp/wireshark/ | pod_prefix=${pod_prefix} |
        | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
    """
    pod_prefix = "po-" + namespace
    container_prefix = "ctr-" + namespace
    tmp_log_dir = tmp_log_dir.rstrip("/") + "/"
    mkdir_cmd = ("mkdir -p /tmp/k8s")
    print(mkdir_cmd)
    output = sshlib.send_command(mkdir_cmd, connection=conn, timeout=timeout)
    print(output)
    if container_name == 'All':
        all_container_cmd = ("kubectl logs " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" +
                             " --all-containers=True --since=" + duration + " > " + tmp_log_dir + pod_name +
                             "_all_container_journal.log")
        print(all_container_cmd)
        output = sshlib.send_command(all_container_cmd, connection=conn, timeout=timeout)
        print(output)
    else:
        # container_cmd = (
        #             "kubectl logs " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" +
        #             " -c " + container_prefix + "-" + container_name + " --since=" + duration +
        #             " > " + tmp_log_dir + container_name + "_journal.log")
        container_cmd = (
                "kubectl logs " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0" +
                " -c " + container_prefix + "-" + container_name + " --since=" + duration + " > "
                + tmp_log_dir + container_name + "_journal.log")
        print(container_cmd)
        output = sshlib.send_command(container_cmd, connection=conn, timeout=timeout)
        print(output)
        remote_log_dir = tmp_log_dir + container_name + "_journal.log"
        return remote_log_dir


def get_dl_tput_from_k8s_log(log_path, cell_id=None):
    """This keyword is used to get dl t-put from l2rt log
    | Input Parameters | Man. | Description |
    |  log path | Yes |  l2rt log local path  |
    |  cell_id  | No  |  global cell id, default is None |

    *RETURN VALUE*
    dl t-put

    Example
    |  get_dl_tput_from_k8s_log     |  ${log_dir}l2rt.log    |
    """
    tb_list = list()
    with open(log_path, 'r') as f:
        lines = f.readlines()
        if cell_id is not None:
            for line in lines:
                if "DataPdu" in line and cell_id in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'\|DataPdu:\s*\d+\|', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("dl tb_size is {}".format(tb_list))
        if cell_id is None:
            for line in lines:
                if "DataPdu" in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'\|DataPdu:\s*\d+\|', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("dl tb_size is {}".format(tb_list))
        if tb_list:
            ave_dl_tput = float(sum(tb_list)) / len(tb_list) * 8 / 1024 / 1024
            max_dl_tput = float(max(tb_list)) * 8 / 1024 / 1024
            min_dl_tput = float(min(tb_list)) * 8 / 1024 / 1024
        else:
            ave_dl_tput = 0
            max_dl_tput = 0
            min_dl_tput = 0

    return ave_dl_tput, max_dl_tput, min_dl_tput


def get_ul_tput_from_k8s_log(log_path, cell_id=None):
    """This keyword is used to get ul t-put from l2rt log
    | Input Parameters | Man. | Description |
    |  log path | Yes |  l2rt log local path  |
    |  cell_id  | No  |  global cell id, default is None |

    *RETURN VALUE*
    ul t-put

    Example
    |  get_ul_tput_from_k8s_log     |  ${log_dir}l2rt.log    |
    """
    tb_list = list()
    with open(log_path, 'r') as f:
        lines = f.readlines()
        if cell_id is not None:
            for line in lines:
                if "UlCounterUpdate" in line and cell_id in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'/UL:\s*\d+\s*Bytes received', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("ul tb_size is {}".format(tb_list))
        if cell_id is None:
            for line in lines:
                if "UlCounterUpdate" in line:
                    timestamp = re.findall(r' <.*>', line)
                    tb_size = re.findall(r'/UL:\s*\d+\s*Bytes received', line)
                    tb_size = re.findall(r'\d+', tb_size[0])
                    tb_list.append(int(tb_size[0]))
            logger.info("ul tb_size is {}".format(tb_list))
        if tb_list:
            ave_ul_tput = float(sum(tb_list)) / len(tb_list) * 8 / 1024 / 1024
            max_ul_tput = float(max(tb_list)) * 8 / 1024 / 1024
            min_ul_tput = float(min(tb_list)) * 8 / 1024 / 1024
        else:
            ave_ul_tput = 0
            max_ul_tput = 0
            min_ul_tput = 0
    return ave_ul_tput, max_ul_tput, min_ul_tput


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
        sshlib.send_command(cmd, connection=conn, timeout=timeout)
        result_stdout = sshlib.read_output(connection=conn)
        result_stderr = sshlib.read_error(connection=conn)
        result_status = sshlib.get_exit_status(connection=conn)
        res = RunResult(stdout=result_stdout, stderr=result_stderr, status=result_status)
        logging.info(str(res))
        check_fail_keyword_on_error_if_needed(fail_on_error, res)
        return res
    except AttributeError:
        raise ClusterConnectionFailure('Ssh connection to cluster does not work.')


def check_fail_keyword_on_error_if_needed(fail_on_error, result):
    if result.status != 0 and str(fail_on_error).lower() == "true":
        raise Exception('Command execution failed:' + str(result))


def remove_sys_log(namespace, conn=None, timeout="10", duration="1h"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
        *Command:*kubectl exec -it po-cran19-logservice-ffcc49648-7nh6r -c ctr-cran19-logstorageserver\
             -n cran19 -- bash -c "rm /var/log/syslog/syslog*"
        *Returns:*
            - Non return
        *Example:*
        | namespace=${ns} | conn=${conn} | timeout=${timeout} |
    """
    cmd_get_syspod = "kubectl get pods -n {cran} | grep logservice | awk '{awk1}'"\
        .format(cran=namespace, awk1='{print $1}')
    syspod = execute_command(cmd=cmd_get_syspod, conn=conn, timeout=timeout).stdout.strip()
    cmd_show_syslogs = "kubectl exec -it {syspod} -c ctr-{cran}-logstorageserver -n {cran}\
         -- bash -c \"ls /var/log/syslog/ 2> /dev/null\" ".format(syspod=syspod, cran=namespace)
    syslogs = execute_command(cmd=cmd_show_syslogs, conn=conn, timeout=timeout).stdout.strip()
    logging.info(syslogs)
    cmd_remv_syslog = "kubectl exec -it {syspod} -c ctr-{cran}-logstorageserver -n {cran}\
         -- bash -c \"rm /var/log/syslog/syslog*\" ".format(syspod=syspod, cran=namespace)
    output = execute_command(cmd=cmd_remv_syslog, conn=conn, timeout=timeout).stdout.strip()
    time.sleep(5)
    syslogs = execute_command(cmd=cmd_show_syslogs, conn=conn, timeout=timeout).stdout.strip()
    logging.info(syslogs)


def collect_sys_log(namespace, tmp_log_dir, syslog_name, conn=None, timeout="10", duration="1h"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - tmp_log_dir: the directory to save the collected syslogs.
            - syslog_name: the name syslog should be saved.
        *Command:* kubectl exec -it po-cran11-logservice-5f666d9d49-fr4c6 -c ctr-cran11-logstorageserver\
             -n cran -- bash -c \"cat /var/log/syslog/syslog 2> /dev/null
        *Returns:*
            - the fullname of the syslog file collected.
        *Example:*
        | collect_sys_log | namespace=${namespace} |
        | tmp_log_dir=/tmp/syslog/ | syslog_name = syslog.txt |
        | conn=${conn} | timeout=${timeout} | duration=${duration}
    """
    cmd_get_syspod = "kubectl get pods -n {cran} | grep logservice | awk '{awk1}'"\
        .format(cran=namespace, awk1='{print $1}')
    syspod = execute_command(cmd=cmd_get_syspod, conn=conn, timeout=timeout).stdout.strip()
    cmd_show_syslogs = "kubectl exec -it {syspod} -c ctr-{cran}-logstorageserver -n {cran} \
        -- bash -c \"cat /var/log/syslog/syslog 2> /dev/null \"".format(syspod=syspod, cran=namespace)
    syslog = execute_command(cmd=cmd_show_syslogs, conn=conn, timeout=timeout).stdout.strip()
    tmp_log_dir = tmp_log_dir.rstrip('/')
    syslog_file = "{tmp_log_dir}/{syslog_name}".format(tmp_log_dir=tmp_log_dir, syslog_name=syslog_name)
    with open(syslog_file, 'w+', encoding='utf-8') as f:
        f.write(syslog)
    return "{tmp_log_dir}/{syslog_name}".format(tmp_log_dir=tmp_log_dir, syslog_name=syslog_name)


def get_dcap_controller_white_list(namespace, pod_name, container_name, connection=None):
    connect_to_container_cmd = "kubectl -n " + namespace + " exec -it " + pod_name + " -c " + container_name
    get_white_list_cmd = "/opt/nokia/bin/dataprovidercli show | grep 'IP addresses' -A 7"

    get_cmd = connect_to_container_cmd + ' -- ' + get_white_list_cmd
    logging.debug('get_cmd is: {}'.format(get_cmd))
    sshlib.send_command(get_cmd, connection=connection)
    white_list_info = sshlib.read_output(connection=connection)
    logging.debug('stdout_info is: {}'.format(white_list_info))

    return white_list_info


def add_dcap_controller_white_list(namespace, pod_name, container_name, dcap_ip, connection=None):
    connect_to_container_cmd = "kubectl -n " + namespace + " exec -it " + pod_name + " -c " + container_name
    add_white_list_cmd = "/opt/nokia/bin/dataprovidercli add -u " + dcap_ip
    confirm_cmd = "echo y | "

    white_list_info = get_dcap_controller_white_list(namespace, pod_name, container_name, connection)

    if dcap_ip in white_list_info:
        logging.info('DCAP collectorcontroller white list already exists, no need to add it again!')
        return

    add_and_confirm_cmd = confirm_cmd + connect_to_container_cmd + ' -- ' + add_white_list_cmd
    logging.debug('add_and_confirm_cmd is: {}'.format(add_and_confirm_cmd))
    logging.info('Add DCAP collectorcontroller white list')
    sshlib.send_command(add_and_confirm_cmd, connection=connection)
    stdout_info = sshlib.read_output(connection=connection)
    logging.debug('stdout_info after add and confirm cmd is: {}'.format(stdout_info))

    white_list_info = get_dcap_controller_white_list(namespace, pod_name, container_name, connection)
    assert dcap_ip in white_list_info, 'Add DCAP collectorcontroller white list failed!'


def delete_dcap_controller_white_list(namespace, pod_name, container_name, dcap_ip, connection=None):
    connect_to_container_cmd = "kubectl -n " + namespace + " exec -it " + pod_name + " -c " + container_name
    delete_white_list_cmd = "/opt/nokia/bin/dataprovidercli delete -u " + dcap_ip

    white_list_info = get_dcap_controller_white_list(namespace, pod_name, container_name, connection)

    if dcap_ip not in white_list_info:
        logging.info('this DCAP IP is not in white list, no need to delete it!')
        return

    delete_cmd = connect_to_container_cmd + ' -- ' + delete_white_list_cmd
    logging.debug('delete_cmd is: {}'.format(delete_cmd))
    logging.info('Delete DCAP collectorcontroller white list')
    sshlib.send_command(delete_cmd, connection=connection)
    stdout_info = sshlib.read_output(connection=connection)
    logging.debug('stdout_info after delete cmd is: {}'.format(stdout_info))

    white_list_info = get_dcap_controller_white_list(namespace, pod_name, container_name, connection)
    assert dcap_ip not in white_list_info, 'Delete DCAP collectorcontroller white list failed!'
