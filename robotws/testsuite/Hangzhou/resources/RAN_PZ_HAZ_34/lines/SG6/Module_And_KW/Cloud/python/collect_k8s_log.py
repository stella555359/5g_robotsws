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
import copy
from basic import basic

sshlib = ssh()


def get_pod_name_prefix(connection, namespace, timeout="10"):
    cmd = f"kubectl -n {namespace} get pod | grep {namespace} | awk '{{print $1}}'| head -n 1"
    pod_name = sshlib.execute(cmd, connection=connection, timeout=timeout).strip()
    if len(pod_name) == 0:
        raise ValueError("The pod_name is empty.")
    pod_prefix = pod_name.split(namespace)[0]
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

        *Example:*
        | ${pod_name_list} | collect_k8s_log | pod_name=${pod_name} | namespace=${ns} |
        | container_name=${container_name} | tmp_log_dir=/tmp/wireshark/ | pod_prefix=${pod_prefix} |
        | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
    """
    prefix = get_pod_name_prefix(conn, namespace)
    pod_prefix = prefix + namespace
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


def get_pod_name(namespace, pod_type, conn=None):
    get_pod_name_cmd = ("kubectl -n " + namespace + " get pod | grep " + pod_type + " | awk '{print $1}'")
    stdout_info = sshlib.execute(get_pod_name_cmd, connection=conn)
    pod_name = stdout_info.strip()

    return pod_name


def get_container_name(namespace, pod_name, container_type, conn=None):
    get_container_name_cmd = ("kubectl -n " + namespace + " describe pod " + pod_name +
                              " | grep \"Container ID\" -B1 | grep " +
                              "\"\\-" + container_type + ":\" | awk -F\":\" '{print $1}' |sed -e 's/^[ \\t]*//g'")
    stdout_info = sshlib.execute(get_container_name_cmd, connection=conn)
    container_name = stdout_info.strip()

    return container_name


def collect_container_startup_log(namespace, pod_name, container_type_list, log_file_name_prefix,
                                  logs_dir, logs_folder, conn=None):
    """
       this function is used to collect startup log in specified containers in the same pod.

       Parameters:
           namespace(str): Tenant namespace which pod created in.
           pod_name(str): Full pod name.
           container_type_list(list): List of container abbreviations.
           log_file_name_prefix(str): log file name prefix.
           logs_dir(str): Working directory.
           logs_folder(str): folder to save the collected logs.
           conn(str): Unique identifier for a server connections.
    """

    startup_log_path = '/tmp'
    format_zip = 'zip'
    format_xz = 'xz'
    container_name_list = []

    for container_type in container_type_list:
        container_name = get_container_name(namespace, pod_name, container_type, conn=conn)
        if container_name:
            container_name_list.append(container_name)
        else:
            logging.error("Get container name failure of container type " +
                          container_type + " in pod " + pod_name + "\n")
    logging.debug('container_name_list is: {}'.format(container_name_list))

    for container_name in container_name_list:
        log_file_name = log_file_name_prefix + '.log'
        exec_container_cmd = ("kubectl exec -n " + namespace + " " + pod_name + " -c " + container_name)

        # set log_file_name
        for compress_format in format_xz, format_zip:
            if compress_format == format_xz:
                check_filename_exist_cmd = (exec_container_cmd + "  -- [ -e " + startup_log_path + "/"
                                            + log_file_name_prefix + ".log." + compress_format + " ] > /dev/null 2>&1")
                logging.debug('check_filename_exist_cmd is: {}'.format(check_filename_exist_cmd))
                sshlib.execute(check_filename_exist_cmd, connection=conn)
                status = sshlib.get_exit_status(connection=conn)
                if status == 0:
                    log_file_name = log_file_name_prefix + '.log.' + compress_format
                    break
            elif compress_format == format_zip:
                check_filename_exist_cmd = (exec_container_cmd + "  -- [ -e " + startup_log_path + "/"
                                            + log_file_name_prefix + "." + compress_format + " ] > /dev/null 2>&1")
                logging.debug('check_filename_exist_cmd is: {}'.format(check_filename_exist_cmd))
                sshlib.execute(check_filename_exist_cmd, connection=conn)
                status = sshlib.get_exit_status(connection=conn)
                if status == 0:
                    log_file_name = log_file_name_prefix + '.' + compress_format
                    break

        # copy container startup log from container to host
        remote_path = logs_dir + "/" + logs_folder + "/" + pod_name + "-" + container_name + "-" + log_file_name
        cp_file_cmd = ("kubectl cp -n " + namespace + " " + pod_name + ":" + startup_log_path + "/" + log_file_name +
                       " " + remote_path + " -c " + container_name + " > /dev/null 2>&1")
        logging.debug('cp_file_cmd is: {}'.format(cp_file_cmd))
        # can not use send_command since the cp cmd maybe last some time
        sshlib.execute(cp_file_cmd, connection=conn)

        # decompress log file
        exists_output = sshlib.file_exists(remote_path, connection=conn)
        if exists_output:
            if format_xz in log_file_name:
                xz_cmd = ("xz -d -f " + logs_dir + "/" + logs_folder + "/" +
                          pod_name + "-" + container_name + "-" + log_file_name)
                logging.debug('xz_cmd is: {}'.format(xz_cmd))
                sshlib.execute(xz_cmd, connection=conn)
            elif format_zip in log_file_name:
                unzip_cmd = ("unzip " + logs_dir + "/" + logs_folder + "/" +
                             pod_name + "-" + container_name + "-" + log_file_name + " -d " +
                             logs_dir + "/" + logs_folder + "/ > /dev/null 2>&1")
                mv_cmd = ("mv " + logs_dir + "/" + logs_folder + "/" + log_file_name_prefix + ".log" + ' ' +
                          logs_dir + "/" + logs_folder + "/" +
                          pod_name + "-" + container_name + "-" + log_file_name_prefix + ".log")
                rm_cmd = ("rm -f " + logs_dir + "/" + logs_folder + "/" +
                          pod_name + "-" + container_name + "-" + log_file_name)
                logging.debug('unzip_cmd is: {}\n mv_cmd is: {}\n rm_cmd is: {}\n'.format(unzip_cmd, mv_cmd, rm_cmd))
                sshlib.execute(unzip_cmd, connection=conn)
                sshlib.execute(mv_cmd, connection=conn)
                sshlib.execute(rm_cmd, connection=conn)
            else:
                logging.info('No need to decompress!')
        else:
            warn_msg = 'Collect startup log ' + log_file_name + ' of container ' + container_name + \
                       ' in pod ' + pod_name + ' failure'
            logging.warning(warn_msg)
            continue

        logging.info('Collect startup log of container ' + container_name + ' in pod ' + pod_name + ' successfully')


def collect_container_journal_log(namespace, pod_name, container_type_list, logs_dir, logs_folder, conn=None):
    """
       this function is used to collect journal log in specified containers in the same pod.

       Parameters:
           namespace(str): Tenant namespace which pod created in.
           pod_name(str): Full pod name.
           container_type_list(list): List of container abbreviations.
           logs_dir(str): Working directory.
           logs_folder(str): folder to save the collected logs.
           conn(str): Unique identifier for a server connections.
    """
    container_name_list = []
    for container_type in container_type_list:
        container_name = get_container_name(namespace, pod_name, container_type, conn=conn)
        if container_name:
            container_name_list.append(container_name)
        else:
            if container_type != "nwmgmt":
                logging.error("Get container name failure of container type " +
                              container_type + " in pod " + pod_name + "\n")
    logging.debug('container_name_list is: {}'.format(container_name_list))

    for container_name in container_name_list:
        collect_journal_log_cmd = ("kubectl logs -n " + namespace + " " + pod_name + " -c " + container_name +
                                   " > " + logs_dir + "/" + logs_folder + "/" +
                                   pod_name + "-" + container_name + "-journal.log")
        logging.debug('collect_journal_log_cmd is: {}'.format(collect_journal_log_cmd))
        sshlib.execute(collect_journal_log_cmd, connection=conn)
        status = sshlib.get_exit_status(connection=conn)
        if status == 0:
            logging.info('Collect journal log of container ' + container_name + ' in pod ' + pod_name + ' successfully')
        else:
            logging.warning('Collect journal log of container ' + container_name + ' in pod ' + pod_name + ' failure')


def get_pod_container_mapping_dict(cnf_type, log_type):
    vdu_pod_container_mapping_base_dict = {'oamasm': ['oamasm', 'oamembe'],
                                           'oamcm': ['oamcm'],
                                           'oamconfig': ['oamconfig'],
                                           'oamctp': ['oamctp'],
                                           'oamext': ['oamagent', 'oamlssclient'],
                                           'oamfh': ['oamfh'],
                                           'oamfm': ['oamfm'],
                                           'oampm': ['oampm'],
                                           'oambb': ['oambb'],
                                           'oamswm': ['oamswm'],
                                           'oamcalc': ['oamcalc'],
                                           'cprt': ['cprt'],
                                           'l2rt': ['l2rt'],
                                           'l2nrt': ['l2hi']
                                           }

    vcu_pod_container_mapping_base_dict = {'oamconfig': ['oamconfig'],
                                           'oamasm': ['oamasm', 'oamembe'],
                                           'oamcm': ['oamcm'],
                                           'oamfm': ['oamfm'],
                                           'oampm': ['oampm'],
                                           'oamext': ['oamagent', 'oamlssclient'],
                                           'cpue': ['cpue'],
                                           'cpcl': ['cpcl'],
                                           'cpif': ['cpif'],
                                           'cpnb': ['cpnb'],
                                           'cpnrt': ['cpnrt'],
                                           'upue': ['l2hicu']
                                           }

    if cnf_type.lower() == 'vdu' and log_type == 'startup':
        logging.debug('the vdu_startup_dict is: {}'.format(vdu_pod_container_mapping_base_dict))
        return vdu_pod_container_mapping_base_dict
    elif cnf_type.lower() == 'vcu' and log_type == 'startup':
        logging.debug('the vcu_startup_dict is: {}'.format(vcu_pod_container_mapping_base_dict))
        return vcu_pod_container_mapping_base_dict
    elif cnf_type.lower() == 'vdu' and log_type == 'journal':
        vdu_journal_dict = copy.deepcopy(vdu_pod_container_mapping_base_dict)
        vdu_journal_dict['oamconfig'].append('nwmgmt')
        vdu_journal_dict['oamext'].append('nwmgmt')
        vdu_journal_dict['oamext'].append('ipsecmgmt')
        vdu_journal_dict['oamfh'].append('nwmgmt')
        vdu_journal_dict['cprt'].append('ipsecmgmt')
        logging.debug('the vdu_journal_dict is: {}'.format(vdu_journal_dict))
        return vdu_journal_dict
    elif cnf_type.lower() == 'vcu' and log_type == 'journal':
        vcu_journal_dict = copy.deepcopy(vcu_pod_container_mapping_base_dict)
        vcu_journal_dict['oamconfig'].append('nwmgmt')
        vcu_journal_dict['oamext'].append('nwmgmt')
        vcu_journal_dict['oamext'].append('ipsecmgmt')
        vcu_journal_dict['cpif'].append('ipsecmgmt')
        vcu_journal_dict['upue'].append('ipsecmgmt')
        logging.debug('the vcu_journal_dict is: {}'.format(vcu_journal_dict))
        return vcu_journal_dict


def collect_container_log(cnf_type, log_type, namespace, logs_dir, logs_folder, conn=None):
    pod_container_mapping_dict = get_pod_container_mapping_dict(cnf_type.lower(), log_type)
    if log_type == 'startup':
        logging.info('Start startup log collecting\n')
        for pod_type, container_type_list in pod_container_mapping_dict.items():
            pod_name = get_pod_name(namespace, pod_type, conn=conn)
            if pod_type in ['l2rt', 'l2nrt', 'upue']:
                log_file_name_prefix = 'LINUX_startup'
            else:
                log_file_name_prefix = 'startup_DEFAULT'
            logging.debug('log_file_name_prefix is: {}\n'.format(log_file_name_prefix))
            collect_container_startup_log(namespace, pod_name, container_type_list, log_file_name_prefix,
                                          logs_dir, logs_folder, conn=conn)
    elif log_type == 'journal':
        logging.info('Start journal log collecting\n')
        for pod_type, container_type_list in pod_container_mapping_dict.items():
            pod_name = get_pod_name(namespace, pod_type, conn=conn)
            collect_container_journal_log(namespace, pod_name, container_type_list, logs_dir, logs_folder, conn=conn)


def log_compress(logs_dir, logs_folder, logs_folder_postfix, conn=None):
    logging.info('Start log compressing\n')
    tar_logs_cmd = ("cd " + logs_dir +
                    " && tar -czf " + logs_folder + '-' + logs_folder_postfix + ".tgz " + logs_folder)
    logging.debug('tar_logs_cmd is: {}'.format(tar_logs_cmd))
    sshlib.execute(tar_logs_cmd, connection=conn)
    status = sshlib.get_exit_status(connection=conn)
    if status == 0:
        info_msg = 'Total logs ' + logs_folder + '-' + logs_folder_postfix + '.tgz stored in ' +\
                   logs_dir + ' directory\n'
        logging.info(info_msg)
    else:
        logging.error('Compressing logs failure')

    rm_logs_cmd = ("rm -rf " + logs_dir + "/" + logs_folder)
    logging.debug('rm_logs_cmd is: {}'.format(rm_logs_cmd))
    sshlib.execute(rm_logs_cmd, connection=conn)

    log_compress_file = logs_folder + '-' + logs_folder_postfix + ".tgz"
    return log_compress_file


def collect_startup_or_journal_log(cnf_type, namespace, log_type_input, conn=None):
    # Get current working directory
    stdout_info = sshlib.execute('pwd', connection=conn)
    working_directory = stdout_info.strip()
    logs_dir = working_directory

    # Make directory
    curr_time = time.strftime("%Y-%m-%d-%H%M", time.localtime())
    logs_folder = cnf_type + '-' + curr_time
    make_directory_cmd = ("mkdir " + logs_folder)
    sshlib.execute(make_directory_cmd, connection=conn)

    log_type_list = log_type_input.split(',')
    for log_type in log_type_list:
        if log_type == 'startup' or log_type == 'journal':
            collect_container_log(cnf_type, log_type, namespace, logs_dir, logs_folder, conn=conn)
        else:
            raise Exception("The input parameter of log_type is invalid")

    log_type_postfix = log_type_input.replace(',', '-')
    logging.info('log_type_postfix is: {}'.format(log_type_postfix))
    logs_folder_postfix = log_type_postfix
    log_compress_file = log_compress(logs_dir, logs_folder, logs_folder_postfix, conn=conn)

    return logs_dir, log_compress_file
