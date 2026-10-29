# -*- coding: utf-8 -*-
"""
Author: Yang Mengli, Liu Renhui
Contacts: mengli.yang@nokia-sbell.com, renhui-david.liu@nokia-sbell.com
Description: this script is used for collect and analysis bip log
with check status of all pods

"""

import csv
import os.path

from taf.transport.ssh import ssh
from command_result import RunResult, ClusterConnectionFailure, TimeoutError
import logging
import datetime

sshlib = ssh()


def vdu_master_connect(hostname, username, password, port="22", timeout="10"):
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
    conn = sshlib.connect_to(hostname=hostname, username=username, password=password, port=port, timeout=timeout)
    return conn


def vdu_master_close(conn=None):
    """
    This keyword is used to close vdu master
    *Command:*  None
    *Returns:*
        - None
    *Example:*
    | vdu_master_close |  |
     """
    self.sshlib.disconnect(conn)


def start_collect_bip_log(pod_name, namespace, container_name, port_id, pod_prefix="po-cran1",
                          container_prefix="ctr-cran1", port_name="l1bipl1", conn=None, timeout="10"):
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
        | ${pod_name_list} | start_collect_bip_log | pod_name=${pod_name} | namespace=${ns} |
        | container_name=${container_name} | tmp_log_dir=/tmp/bip/ | pod_prefix=${pod_prefix} |
        | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
        """
    cmd_prefix = "kubectl exec -it " + pod_prefix + "-" + pod_name + "-0" + " -n " + namespace + " -c " + \
                 container_prefix + "-" + container_name + " -- bash" + " -c "
    start_cmd = cmd_prefix + "'dpdk-cli pdump port {} path /tmp/dpdkdump".format(port_id)
    start_cmd = start_cmd + " > /tmp/dpdkdump/start_bip.log 2>&1'"
    print(start_cmd)
    output = sshlib.send_command(start_cmd, connection=conn, timeout=timeout)
    print(output)


def stop_collect_bip_log(conn=None, timeout="30"):
    """
        *Args:*
            - conn: which vDU is connected
            - timeout: see `command timeout `

        *Command:* `` ps -ef|grep dpdk|grep -v grep|awk '{print $2}'``

        *Returns:*
            - output

        *Example:*
        | ${pod_name_list} | stop_collect_bip_log | conn=conn |
        """
    check_process_cmd = ("ps -ef|grep dpdk|grep -v grep|awk '{print $2}'")
    # cmd = "source /etc/profile && source ~/.bash_profile && " + check_process_cmd
    # print(cmd)
    # output = sshlib.send_command(cmd, connection=conn, timeout=timeout)
    output = execute_command(cmd=check_process_cmd, conn=conn, timeout=timeout)
    print(output)
    stop_cmd = ("sudo pkill -f dpdk")
    cmd = "source /etc/profile && source ~/.bash_profile && " + stop_cmd
    print(cmd)
    output = sshlib.send_command(cmd, connection=conn, timeout=timeout)
    print(output)


def download_bip_log_to_master(pod_name, namespace, container_name, tmp_log_dir, pod_prefix="po-cran1",
                               container_prefix="ctr-cran1", conn=None, timeout="100"):
    """
        *Args:*
            - namespace: the tenant namespace which pod created in
            - pod_name: see `collect log in which pod `
            - container_name: see `collect log in which container `

        *Command:* `` kubectl cp -n cran1 po-cran1-up-0:/tmp/l1bipl1.pcap /tmp/dpdk/l1bipl1.pcap -c ctr-cran1-l1hi``

        *Returns:*
            - output

        *Example:*
        | ${remote_log_dir} | download_bip_log_to_master | pod_name=${pod_name} | namespace=${ns} |
        | container_name=${container_name} | tmp_log_dir=/tmp/bip/ | pod_prefix=${pod_prefix} |
        | container_prefix=${container_prefix} | conn=${conn} | timeout=${timeout} |
        """
    cmd_exec = "kubectl exec -i " + pod_prefix + "-" + pod_name + "-0" + " -c " + \
               container_prefix + "-" + container_name + " -n " + namespace + " -- bash " + "-c "
    cmd_cp = "kubectl cp " + "-n " + namespace + " " + pod_prefix + "-" + pod_name + "-0"
    cmd_cp_postfix = " -c " + container_prefix + "-" + container_name
    remote_log_dir = tmp_log_dir.rstrip("/") + "/"
    clear_master_log = "rm -r " + remote_log_dir + "*"
    execute_command(cmd=clear_master_log, conn=conn, timeout=timeout)
    # list bip log
    list_bip_log = cmd_exec + "'ls -alh /tmp/dpdkdump'"
    execute_command(cmd=list_bip_log, conn=conn, timeout=timeout)
    # rename a bip log to a specific name
    tem_bip_log_name = "tmp-bip.pcap"
    log_dir_in_container = ":tmp/dpdkdump/"
    cmd_part_1 = log_dir_in_container + tem_bip_log_name
    bip_log_path = os.path.join(remote_log_dir, tem_bip_log_name)
    cmd_rename = "'mv /tmp/dpdkdump/*.pcap /tmp/dpdkdump/{}'".format(tem_bip_log_name)
    rename_bip_log = cmd_exec + cmd_rename
    execute_command(cmd=rename_bip_log, conn=conn, timeout=timeout)
    # copy start_bip log
    start_bip_log_name = "start_bip.log"
    start_bip_log_path = os.path.join(remote_log_dir, start_bip_log_name)
    cmd_part_2 = log_dir_in_container + start_bip_log_name
    copy_start_bip_log = cmd_cp + cmd_part_2 + " " + start_bip_log_path + cmd_cp_postfix
    execute_command(cmd=copy_start_bip_log, conn=conn, timeout=timeout)
    # copy the bip log
    copy_bip_log = cmd_cp + cmd_part_1 + " " + bip_log_path + cmd_cp_postfix
    execute_command(cmd=copy_bip_log, conn=conn, timeout=timeout)
    # clear bip log in the pod
    clear_pod_log = cmd_exec + "'rm -r /tmp/dpdkdump/*'"
    execute_command(cmd=clear_pod_log, conn=conn, timeout=timeout)
    return remote_log_dir


def read_csv_file_into_matrix(file_path, delimiter=","):
    """
       read csv log file , split value by ",", and store all value into the matrix

       :param file_path: String: csv log file path.
       :param delimiter: String: the spliter to split values into cells.
       :return: The value matrix

    """
    with open(file_path) as csvfile:
        reader = csv.reader(csvfile, delimiter=str(delimiter))
        matrix = []
        line_number = 0
        for line in reader:
            if line:
                line_number += 1
                line_data = [line_number, line]
                matrix.append(line_data)
        return matrix


def get_lines_with_multiple_column_filter(file_path, column_list, expected_list, delimiter=","):
    """
       get all lines that match all filter.

       :param file_path: String: csv log file path.
       :param column_list: List: a list content all target filters' column number.
                                 column number count start from 1.
       :param expected_list: List: a list content all filters, the sort should match with column_list
       :param delimiter: String: the spliter to split values into cells.
       :return: List: content all lines match the filter.
    """
    result = []
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    for line in matrix:
        if line[1]:
            for i in range(len(column_list)):
                try:
                    target = line[1][int(column_list[i]) - 1]
                    expected = expected_list[i]
                    if expected not in target:
                        break
                except IndexError:
                    continue
            else:
                result.append(line)
    if not result:
        raise LookupError("Can't found any line match all column expected.")
    return result


def get_value_with_multiple_column_filter(file_path, value_column_list, expected_list, delimiter=","):
    """
       get all lines that match all filter.

       :param file_path: String: csv log file path.
       :param column_list: List: a list content all target filters' column number.
                                 column number count start from 1.
       :param expected_list: List: a list content all filters, the sort should match with column_list
       :param delimiter: String: the spliter to split values into cells.
       :return: List: content all lines match the filter.
    """
    result_line = []
    result_value = []
    matrix = read_csv_file_into_matrix(file_path, delimiter)
    print(matrix)
    value_column = 0
    csv_title_list = matrix[0][1]
    print('csv_title_list: {}'.format(csv_title_list))
    for title in csv_title_list:
        if title == value_column_list[0]:
            value_column = csv_title_list.index(title)
            break
    print('value_column: {}'.format(value_column))

    for line in matrix:
        if line[1]:
            try:
                for expected in expected_list:
                    if expected in line[1]:
                        value_target = line[1][value_column]
                        result_line.append(line)
                        result_value.append(value_target)
                        break
            except IndexError:
                continue
    if not result_line:
        raise LookupError("Can't found any line match all column expected.")
    return result_line, result_value


def get_value_according_to_index(list, expect_index):
    list_value = []
    for index, value in enumerate(list):
        if index == expect_index:
            print(index, value)
            list_value.append(value)
            return list_value


def get_all_index_according_to_value(list, expect_value):
    list_index = [index for (index, value) in enumerate(list) if value == expect_value]
    logging.debug("list_index value: {}".format(list_index))
    return list_index


def get_expected_index(list):
    first_rnti_value = list[0]
    print(first_rnti_value)
    for index, value in enumerate(list):
        try:
            if value != first_rnti_value:
                index = index
                break
        except AttributeError:
            raise getindexfail('can not found expected index')
    return index


def get_value_according_to_index(list, expect_index):
    list_value = []
    for index, value in enumerate(list):
        if index == expect_index:
            print(index, value)
            list_value.append(value)
            return list_value


def get_value_by_multiple_column_filter(file_path, value_column_list1, value_column_list2, expected_list):
    """
       get all lines that match all filter.

       :param file_path: String: csv log file path.
       :param column_list: List: a list content all target filters' column number.
                                 column number count start from 1.
       :param expected_list: List: a list content all filters, the sort should match with column_list
       :param delimiter: String: the spliter to split values into cells.
       :return: List: content all lines match the filter.
    """
    result_list1 = get_value_with_multiple_column_filter(file_path, value_column_list1, expected_list)
    result_list2 = get_value_with_multiple_column_filter(file_path, value_column_list2, expected_list)
    time_value_list = result_list1[1]
    del (time_value_list[0])
    print(time_value_list)
    print(len(time_value_list))
    rnti_value_list = result_list2[1]
    del (rnti_value_list[0])
    print(rnti_value_list)
    print(len(rnti_value_list))
    index = get_expected_index(list=rnti_value_list)
    last_index = index - 1
    last_package_time = get_value_according_to_index(list=time_value_list, expect_index=last_index)
    first_package_time = get_value_according_to_index(list=time_value_list, expect_index=index)
    return last_package_time, first_package_time


def get_column_from_matrix(matrix, column_nubmer):
    """
        get target column from matrix

            :param matrix: List: the matrix
            :param column_nubmer: Int: the index of target column.
                                 column number count start from 1.
            :return: List: target column
            """
    column = int(column_nubmer) - 1
    column_list = []
    for row in matrix:
        column_list.append(row[1][column])
    return column_list


def get_unique_values_in_column(matrix, column_number):
    """
       check the column and return a list ,
       which content all values in the column (already removed duplicate data)

       :param matrix: List: matrix type of csv file content
       :param column_number: target column's number
       :return: List: all unique values in target column
    """
    column = self.get_column_from_matrix(matrix, column_number)
    result = list(set(column))
    return result


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
        result_stdout = cmd + ": " + sshlib.read_output(connection=conn)
        result_stderr = cmd + ": " + sshlib.read_error(connection=conn)
        result_status = sshlib.get_exit_status(connection=conn)
        res = RunResult(stdout=result_stdout, stderr=result_stderr, status=result_status)
        logging.info(str(res))
        _fail_keyword_on_error_if_needed(fail_on_error, res)
        return res
    except AttributeError:
        raise ClusterConnectionFailure('Ssh connection to cluster does not work.')


def _fail_keyword_on_error_if_needed(fail_on_error, result):
    if result.status != 0 and str(fail_on_error).lower() == "true":
        raise Exception('Command execution failed:' + str(result))
