# -*- coding: utf-8 -*-
"""
Author: gcao
Contacts: ge.cao@nokia-sbell.com
Description: this script is used for aic bts common

"""
from robot.api import logger
import yaml
import csv
from taf.transport.ssh import ssh
ssh = ssh()


def get_sub_param_value_of_current_plan(para_dict, i):
    '''
    :param :
    {b'items': [{b'distname': b'MRBTS-247/NRBTS-1',
                 b'mo_uuid': b'fecb5dc8-e539-4645-84b0-3f51f3f35cd1',
                 b'nidd_id': b'199432',
                 b'parameter': {b'complex_parameter': {b'name': b'cipherPrefL',
                                                       b'state': 'unchanged',
                                                       b'value': [{'structure_parameters': [{'complex_parameter': None,
                                                                                'parameter_type': u'simple',
                                                                                'simple_list_parameter': None,
                                                                        'simple_parameter': {'name': 'nea0',
                                                                                            'state': u'unchanged',
                                                                                            'value': '0'}},
                                                                        {'complex_parameter': None,
                                                                         ...
                                                                        'simple_parameter': {'name': 'nea1_128',
                                                                                'state': u'unchanged',
                                                                                'value': '2'}},
                                                                        {'complex_parameter': None,
                                                                         ...
                                                                        'simple_parameter': {'name': 'nea2_128',
                                                                                            'state': u'unchanged',
                                                                                            'value': '4'}},
                                                                        {'complex_parameter': None,
                                                                         ...
                                                                        'simple_parameter': {'name': 'nea3_128',
                                                                                            'state': u'unchanged',
                                                                                            'value': '5'}}]}]},
                               b'parameter_type': 'complex',
                               b'simple_list_parameter': None,
                               b'simple_parameter': None},
                 b'parameter_name': b'cipherPrefL',
                 b'state': 'unchanged'}], b'total': 1}

    :return: ciphering dict
    note: structure_parameters type is
    <class 'taf.internal.gnb.oam.coam.cu.client.asm.v1.models.complex_param_children_structure.
    ComplexParamChildrenStructure'>
    '''
    ciphering_dict = {}
    structure_parameters = para_dict['items'][i]['parameter']['complex_parameter']['value'][0]
    logger.info("structure_parameters type is {}".format(type(structure_parameters)))
    for structure_para_value in structure_parameters.structure_parameters:
        ciphering_dict[structure_para_value.simple_parameter.name] = structure_para_value.simple_parameter.value
    return ciphering_dict


def check_param_value_whether_none(para_data):
    if para_data is None:
        return True


def yaml_file_to_dictionary(file_path):
    """change dictionary to yaml file.

    *AUTHOR* Liang.xiang@nokia-sbell.com

    | Input Parameters | Man. | Description |
    | file_path       | Yes  | file_path of yaml file |

    *RETURN VALUE*
    Dictionary of content

    Example
    | ${dictionary_content} | yaml_file_to_dictionary | /home/ute/a.yaml |
    """
    with open(file_path) as stream:
        NoDatesSafeLoader = yaml.SafeLoader
        NoDatesSafeLoader.yaml_implicit_resolvers = {
            k: [r for r in v if r[0] != 'tag:yaml.org,2002:timestamp']
            for k, v in NoDatesSafeLoader.yaml_implicit_resolvers.items()
        }
        data_loaded = yaml.load(stream, Loader=NoDatesSafeLoader)
    return data_loaded


def store_alarms_to_csvfile(alarm_data, file_name):
    """
    this function is used to store alarms to a csv file

    Parameters:
        alarm_data(dict): dict with keys: - alarms: the value is list with alarms
                                          - total: the value is total amount of alarms as int
        file_name(str): file path of csv file

    Returns:
        None
    """
    # use vdu active alarm header as alarm base header
    alarm_base_header = ['severity', 'appear_time', 'last_updated_time', 'alarm_id', 'alarm_name',
                         'fault_id', 'fault_name', 'alarming_object', 'event_type_name',
                         'probable_cause_name', 'additional_info', 'uuid']
    vdu_historical_alarm_header = alarm_base_header.copy()
    insert_index = vdu_historical_alarm_header.index('appear_time') + 1
    vdu_historical_alarm_header.insert(insert_index, 'cleared_time')

    vcu_active_alarm_header = alarm_base_header.copy()
    insert_index = vcu_active_alarm_header.index('alarming_object') + 1
    vcu_active_alarm_header.insert(insert_index, 'cell_name')

    vcu_historical_alarm_header = vdu_historical_alarm_header.copy()
    insert_index = vcu_historical_alarm_header.index('additional_info') + 1
    vcu_historical_alarm_header.insert(insert_index, 'affected_cells')

    with open(file_name, 'a', newline='', encoding='utf-8') as f:
        if 'vdu_active' in file_name:
            writer = csv.DictWriter(f, fieldnames=alarm_base_header)
        elif 'vdu_historical' in file_name:
            writer = csv.DictWriter(f, fieldnames=vdu_historical_alarm_header)
        elif 'vcu_active' in file_name:
            writer = csv.DictWriter(f, fieldnames=vcu_active_alarm_header)
        elif 'vcu_historical' in file_name:
            writer = csv.DictWriter(f, fieldnames=vcu_historical_alarm_header)

        writer.writeheader()

        if alarm_data['total'] == 0:
            print('No data')
            return
        else:
            writer.writerows(alarm_data['alarms'])


def compare_alarms(file_path1, file_path2):
    """
    this function is used to compare alarms from two given files and return add and delete alarms with dicts.

    Parameters:
        file_path1(str): origin alarm file path of csv file
        file_path2(str): target alarm file path of csv file

    Returns:
        dict with keys: - alarms: the value is list with alarms
                        - total: the value is total amount of alarms as int
    """
    file1_lines_len = len(open(file_path1).readlines())
    file2_lines_len = len(open(file_path2).readlines())

    add_alarm_list = []
    clear_alarm_list = []
    unchanged_alarm_list = []
    add_count = 0
    clear_count = 0
    unchanged_count = 0

    # case1: both files have no alarms
    if file1_lines_len == 1 and file2_lines_len == 1:
        pass
    # case2: file1 has no alarms, file2 has alarms
    elif file1_lines_len == 1 and file2_lines_len > 1:
        with open(file_path2, 'r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                add_alarm_list.append(row)
                add_count += 1
    # case3: file1 has alarms, file2 has no alarms
    elif file1_lines_len > 1 and file2_lines_len == 1:
        with open(file_path1, 'r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                clear_alarm_list.append(row)
                clear_count += 1
    # case4: both files have alarms
    else:
        with open(file_path1, 'r', encoding='utf-8') as f:
            total_alarms = csv.DictReader(f)
            for alarm in total_alarms:
                flag = 0
                with open(file_path2, 'r', encoding='utf-8') as n:
                    dat = csv.DictReader(n)
                    for d in dat:
                        if alarm == d:
                            flag = 1
                            unchanged_alarm_list.append(alarm)
                            unchanged_count += 1
                            break
                if flag != 1:
                    clear_alarm_list.append(alarm)
                    clear_count += 1
        # Get add alarms in file path2 compared with file path1
        with open(file_path2, 'r', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            if len(unchanged_alarm_list) == 0:
                for row in reader:
                    add_alarm_list.append(row)
                    add_count += 1
            else:
                for row in reader:
                    if row not in unchanged_alarm_list:
                        add_alarm_list.append(row)
                        add_count += 1

    add_alarms_info = {'alarms': add_alarm_list, 'total': add_count}
    clear_alarms_info = {'alarms': clear_alarm_list, 'total': clear_count}
    return add_alarms_info, clear_alarms_info


def helm_get_pod_for_vdu(master_ip, username, password, namespace, pod_name_filter="aic-vdu", timeout='10'):
    conn = ssh.connect_to(hostname=master_ip, username=username, password=password, port='22', alias="master",
                          timeout=timeout)
    cmd_base = "helm list -n {namespace} |grep {pod_name_filter} ".format(pod_name_filter=pod_name_filter,
                                                                          namespace=namespace)
    cmd_get_pod_name = cmd_base + "|awk '{print $1}'"
    cmd_get_chart = cmd_base + "|awk '{print $9}'"
    cmd_get_status = cmd_base + "|awk '{print $8}'"
    ssh.send_command(cmd_get_pod_name, connection=conn, timeout=timeout)
    result_stdout_pod_list = ssh.read_output(connection=conn)
    pod_list = result_stdout_pod_list.rstrip().split("\n")
    ssh.send_command(cmd_get_chart, connection=conn, timeout=timeout)
    result_stdout_chart_list = ssh.read_output(connection=conn)
    chart_list = result_stdout_chart_list.rstrip().split("\n")
    ssh.send_command(cmd_get_status, connection=conn, timeout=timeout)
    result_stdout_pod_status = ssh.read_output(connection=conn)
    pod_status = result_stdout_pod_status.rstrip().split("\n")
    dict_vdu_pod = {}
    for i in range(len(pod_list)):
        dict_vdu_pod[pod_list[i]] = [chart_list[i], pod_status[i]]
    ssh.disconnect(connection=conn)
    return dict_vdu_pod


def helm_get_pod_for_vcu(master_ip, username, password, namespace, pod_name_filter="aic-vcu", timeout='10'):
    conn = ssh.connect_to(hostname=master_ip, username=username, password=password, port='22', alias="master",
                          timeout=timeout)
    cmd_base = "helm list -n {namespace} |grep {pod_name_filter} ".format(pod_name_filter=pod_name_filter,
                                                                          namespace=namespace)
    cmd_get_pod_name = cmd_base + "|awk '{print $1}'"
    cmd_get_chart = cmd_base + "|awk '{print $9}'"
    cmd_get_status = cmd_base + "|awk '{print $8}'"
    ssh.send_command(cmd_get_pod_name, connection=conn, timeout=timeout)
    result_stdout_pod_list = ssh.read_output(connection=conn)
    pod_list = result_stdout_pod_list.rstrip().split("\n")
    ssh.send_command(cmd_get_chart, connection=conn, timeout=timeout)
    result_stdout_chart_list = ssh.read_output(connection=conn)
    chart_list = result_stdout_chart_list.rstrip().split("\n")
    ssh.send_command(cmd_get_status, connection=conn, timeout=timeout)
    result_stdout_pod_status = ssh.read_output(connection=conn)
    pod_status = result_stdout_pod_status.rstrip().split("\n")
    dict_vcu_pod = {}
    for i in range(len(pod_list)):
        dict_vcu_pod[pod_list[i]] = [chart_list[i], pod_status[i]]
    ssh.disconnect(connection=conn)
    return dict_vcu_pod
