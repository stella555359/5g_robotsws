# -*- coding: UTF-8 -*-
"""
Authors:
michal.kusiak@nokia.com
marcin.sokolowski@nokia.com
przemyslaw.romanczyk@nokia.com
michal.popiel@nokia.com
krystian.gordziejewski@nokia.com
artur.lebek@nokia.com
"""

import re

import os
import paramiko
import xml.etree.ElementTree as et
import dateutil.parser as date_parser
import datetime
import logging
import json
import XML_replacer
import convert_delta
# from string import replace
import urllib3
from xml.etree import ElementTree as etree


def get_enb_alarm_ids(enb_alarms):

    enb_alarm_ids = []

    for alarm in enb_alarms:
        try:
            if int(alarm.faultId) != 61524 or int(alarm.faultId) != 61510 or int(alarm.faultId) != 61649 or\
                    int(alarm.faultId) != 4655 or int(alarm.faultId) != 4654:
                enb_alarm_ids.append(int(alarm.faultId))
        except Exception:
            if int(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID) != 61524 or\
                    int(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID) != 61510 \
                    or int(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID) != 61649 or\
                    int(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID) != 4655:
                enb_alarm_ids.append(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID)

    enb_alarm_ids.sort()
    return enb_alarm_ids


def get_netact_alarm_ids(netact_alarms):

    netact_alarms_ids = []
    prog = re.compile(r'(?<=additionalFaultI[dD][:=])\d*')

    if isinstance(netact_alarms, list):
        for item in netact_alarms:
            tmp = re.search(prog, str(item))
            if tmp:
                netact_alarms_ids.append(int(tmp.group()))
    else:
        for key, value in netact_alarms.items():
            for element in value:
                tmp = re.search(prog, str(element))
                if tmp:
                    netact_alarms_ids.append(int(tmp.group()))
    return netact_alarms_ids


# def get_netact_fault_ids(netact_alarms):
#
#     netact_alarms_ids = []
#     prog = re.compile(r'(?<=additionalText3.[:] u.)\d*')
#
#     if isinstance(netact_alarms, list):
#         for item in netact_alarms:
#             tmp = re.search(prog, str(item))
#             if tmp:
#                 netact_alarms_ids.append(int(tmp.group()))
#     else:
#         for key, value in netact_alarms.items():
#             for element in value:
#                 tmp = re.search(prog, str(element))
#                 if tmp:
#                     netact_alarms_ids.append(int(tmp.group()))
#     return netact_alarms_ids


def get_netact_fault_ids(netact_alarms):

    netact_alarms_ids = []
    prog = re.compile(r'(?<=additionalFaultI[dD][:=])\d*')

    if isinstance(netact_alarms, list):
        for alarm in netact_alarms:
            if alarm['additionalText3']:
                for item in alarm['additionalText3'].split(' '):
                    if 'additionalFaultID=' in item:
                        netact_alarms_ids.append(int(item.replace('additionalFaultID=', '')))

    else:
        for key, value in netact_alarms.items():
            for element in value:
                tmp = re.search(prog, str(element))
                if tmp:
                    netact_alarms_ids.append(int(tmp.group()))
    return netact_alarms_ids


def get_netact_number_alarms(netact_alarms):
    netact_alarms_ids = []
    prog = re.compile(r'(?<=specificProblem\'[:=]\s)\d*')

    if isinstance(netact_alarms, list):
        for item in netact_alarms:
            tmp = re.search(prog, str(item))
            if tmp:
                netact_alarms_ids.append(int(tmp.group()))
    else:
        for key in netact_alarms.keys():
            netact_alarms_ids.append(int(key))
    return netact_alarms_ids


def compare_alarms_from_enb_and_netact(enb_alarms, netact_alarms):
    """
    Return true if all eNB fault IDs are present on NetAct.
    Otherwise return False.
    modified by michal.popiel@nokia.com
    """
    enb_alarm_ids = get_enb_alarm_ids(enb_alarms)
    netact_alarms_ids = get_netact_fault_ids(netact_alarms)

    print('enb', enb_alarm_ids)
    print('netact', netact_alarms_ids)
    for alarm_id in enb_alarm_ids:
        if alarm_id not in netact_alarms_ids:
            logging.error(alarm_id, ' missing from NetAct faults!')
            return False, alarm_id
    return True, None


def unblock_enb_im_port(enb_ip, user, password):
    """Function unblocks IM port on selected eNB.
       Created by marcin.sokolowski@nokia.com
    Args:
        enb_ip: M-Plane of the selected eNB
        user: Username for eNB root user
        password: Password of root user
    Returns:
        The return value. True for success, False otherwise.

    """
    i = 0
    while i < 5:
        try:
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh.connect(enb_ip, username=user, password=password)
            print('Connection established.')
            stdin, stdout, stderr = ssh.exec_command(command='iptables -I INPUT -p tcp --dport 12345 -j ACCEPT;'
                                                             'iptables -I INPUT -p tcp --dport 21 -j ACCEPT;'
                                                             'iptables -I INPUT -p tcp --dport 20 -j ACCEPT;'
                                                             'iptables -I OUTPUT -p tcp --dport 21 -j ACCEPT;'
                                                             'iptables -I OUTPUT -p tcp --dport 20 -j ACCEPT')
            print('IM Port opened.')
            ssh.close()
            break
        except paramiko.SSHException as e:
            print('*WARN* SSH connection failure: {}!'.format(str(e)))
            pass
        finally:
            i += 1


def get_log_file(remote_path, local_path, oms_ip, oms_login, oms_password):
    """Function downloads pointed log file from selected ioms.
           Created by marcin.sokolowski@nokia.com
        Args:
            remote_path: path to log file on remote host. Path to log prepared by keyword lib_SFE.Prepare
            CMaussrv_trace file
            local_path: path to store log file locally
            oms_ip: ip address of iOMS
            oms_login: iOMS ssh username
            oms_password: iOMS ssh password
        Returns:
            None

    """
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(oms_ip, username=oms_login, password=oms_password)

    print('\nConnection established. Downloading log file...')
    ftp_conn = ssh.open_sftp()
    ftp_conn.get(remote_path, local_path)
    ftp_conn.close()
    print('\nFile downloaded successfully.')


def get_ccns_from_file(local_path, enb_id):
    """Function for parsing log file for CCNs for selected eNB
           Created by marcin.sokolowski@nokia.com
        Args:
            local_path: path to log file stored locally. Path of log file collected by 'get_log_file'
            enb_id: enb_id of eNB
        Returns:
            List. CCNs for selected eNB.

    """
    # variables
    in_xml = False
    previous_line = ''
    operation = ''
    ccns = []
    xml_ccn = ''

    # datetime from print helper function
    def get_datetime_from_print(pr):
        pattern = r'[A-Z][a-z]{2,3}.[A-Z][a-z]{2,3}.{1,2}\d{1,2}.\d{2}:\d{2}:\d{2}.\d{4}'
        p = re.compile(pattern)
        dt = re.match(p, pr).group(0)
        if not isinstance(dt, datetime.datetime):
            dt = date_parser.parse(dt)

        return dt

    trace = open(local_path, mode='r')

    for line in trace:
        if in_xml:
            xml_ccn += line

        if "<raml" in line and not in_xml:
            if 'MRBTS-' + enb_id in previous_line and 'OMS::TRACE INFO' in previous_line:
                in_xml = True
                xml_ccn = line
                dt = get_datetime_from_print(previous_line)
            if in_xml:
                if "AddEvent:" in previous_line:
                    operation = "AddEvent"
                elif "SendEvents:" in previous_line and in_xml:
                    operation = "SendEvents"
        elif "</raml>" in line and in_xml:
            in_xml = False
            ccns.append({'operation': operation, 'xml': xml_ccn, 'time': dt})

        previous_line = line

    return ccns


def get_lncel_from_ccn(ccns):
    """Function extract ccns only with lncel status change.
           Created by marcin.sokolowski@nokia.com
        Args:
            ccns: list of ccns. Value from function 'get_ccns_from_file'
        Returns:
            List of ccns with lncel status change

    """
    cells_info = []
    for item in ccns:
        if_cell = False
        if item['operation'] == 'AddEvent':
            root = et.fromstring(item['xml'])
            for cmData in root.findall("{raml21.xsd}cmData"):
                for managedObject in cmData.findall("{raml21.xsd}managedObject"):
                    if 'LNCEL' in managedObject.attrib['distName']:
                        operational_state = managedObject.find("./{raml21.xsd}p[@name='operationalState']")
                        if operational_state is not None:
                            cell = managedObject.attrib['distName'].split('-')[-1]
                            if_cell = True
                    if if_cell:
                        cells_info.append({'time': item['time'], 'operationalState': operational_state.text,
                                           'cell': cell})
    return cells_info


def check_cells_state(cells_info, cells_list, start_time):
    """Function extract cell state from ccns after given time.
           Created by marcin.sokolowski@nokia.com
        Args:
            cells_info: list of ccns with cell state changes. Value from function 'get_lncel_from_ccn'
            cells_list: list of cell_id on selected eNB. Value from keyword 'lib_SFE.Create List of Cells
            start_time: time of reset procedure start
        Returns:
            List of cells with every state change and its time.

    """
    if not isinstance(start_time, datetime.datetime):
        start_time = date_parser.parse(start_time)
    cells_states_times = []
    for cell in cells_list:
        time_last_disabled = None
        time_last_enabled = None
        for cell_info in cells_info:
            if cell_info['cell'] == cell and cell_info['time'] > start_time:
                if cell_info['operationalState'] == 'disabled':
                    if time_last_disabled is None or time_last_disabled < cell_info['time']:
                        time_last_disabled = cell_info['time']
                elif cell_info['operationalState'] == 'enabled':
                    if time_last_enabled is None or time_last_enabled < cell_info['time']:
                        time_last_enabled = cell_info['time']
        cells_states_times.append({'cell': cell, 'last_disabled': time_last_disabled,
                                   'last_enabled': time_last_enabled})
    return cells_states_times


def validate_cells_states(cells_states_times):
    """Function checks for every cell if there was state change to disabled and after that state change to enabled.
        State enabled should be the last one.
           Created by marcin.sokolowski@nokia.com
        Args:
            cells_states_times: list of cells with every state change and its time.
            Value from function 'check_cells_state'
        Returns:
            Dictionary. Contains Boolean 'result' and comment with validation result.

    """
    comment = ''
    result = True
    for cell in cells_states_times:
        disabled = cell['last_disabled']
        enabled = cell['last_enabled']
        stat_com = '||OK||'
        dis_comm = ''
        ena_comm = ''

        cell_comm = "Cell '" + str(cell['cell']) + ": "

        if disabled is not None:
            dis_comm = "disabled at: " + str(disabled)
        else:
            dis_comm = "CCN for disabled missing"

        if enabled is not None:
            ena_comm = "enabled at:" + str(enabled)
        else:
            ena_comm = "CCN for enabled missing"

        if disabled is None or enabled is None:
            stat_com = '!!WARNING!!'
            result = False
        elif disabled > enabled:
            stat_com = '!!WARNING!! Last state DISABLED!'
            result = False

        comment += re.sub(r'\s\s+', " ", stat_com + ' ' + cell_comm + ' ' + dis_comm + '; ' + ena_comm + '.') + '\n'
    return dict(result=result, comment=comment)


def get_lncel_ccns_from_ioms(remote_path, local_path, oms_ip, oms_login, oms_password, enb_id, cells_list, start_time):
    """ Function for complete CCN for LNCEL extractior. Output should be passed
        to function lib_SFE.py.validate_cells_states.
            Created by marcin.sokolowski@nokia.com
        Args:
            remote_path: path to log file on remote host. Path to log prepared by keyword
            lib_SFE.Prepare CMaussrv_trace file
            local_path: path to store log file locally
            oms_ip: ip address of iOMS
            oms_login: iOMS ssh username
            oms_password: iOMS ssh password
            enb_id: enb_id of eNB
            cells_list: list of cell_id on selected eNB. Value from keyword 'lib_SFE.Create List of Cells
            start_time: time of reset procedure start
        Returns:
            List of cells with every state change and its time.

        """
    get_log_file(remote_path, local_path, oms_ip, oms_login, oms_password)
    ccns = get_ccns_from_file(local_path, enb_id)
    cells_info = get_lncel_from_ccn(ccns)
    cells_states_times = check_cells_state(cells_info, cells_list, start_time)
    return cells_states_times


def get_software_release(mplane_ip, port=22, username='toor4nsn', password='oZPS0POrRieRtu'):
    software_version = get_software_version(mplane_ip, port=port, username=username, password=password)
    regex = r'[^_]+'
    if software_version[:11] == 'FL17A_ENB_1':
        software_release = 'FL17ASP1'
    else:
        tmp = re.search(re.compile(regex), software_version)
        if tmp:
            software_release = tmp.group().upper()
        else:
            logging.error('Cannot determine software release. Perhaps software format was changed')
    return software_release


def establish_ssh_connection(ip, port=22, username='toor4nsn', password='oZPS0POrRieRtu'):
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(hostname=ip, port=port, username=username, password=password)
        return ssh
    except Exception as e:
        logging.error('Connection can\'t be established: {}'.format(e))


def get_active_partition(mplane_ip, port=22, username='toor4nsn', password='oZPS0POrRieRtu'):
    ssh = establish_ssh_connection(mplane_ip, port=port, username=username, password=password)
    stdin, stdout, stderr = ssh.exec_command('uboot_env get active_partition')
    regex = r'\d'
    for line in stdout.readlines():
        tmp = re.search(re.compile(regex), line)
        if tmp:
            active_partition = tmp.group()
            ssh.close()
            return active_partition
    ssh.close()
    logging.error('Cannot determine active partition. Unknown problem')


def get_reset_counter_new(mplane_ip, port=22, username='toor4nsn', password='oZPS0POrRieRtu'):
    ssh = establish_ssh_connection(mplane_ip, port=port, username=username, password=password)
    stdin, stdout, stderr = ssh.exec_command('uboot_env get active_partition')
    regex = r'\d'
    for line in stdout.readlines():
        tmp = re.search(re.compile(regex), line)
        if tmp:
            active_partition = tmp.group()
            ssh.close()
            return active_partition
    ssh.close()
    logging.error('Cannot determine active partition. Unknown problem')


def get_software_version(mplane_ip, port=22, username='toor4nsn', password='oZPS0POrRieRtu'):
    ssh = establish_ssh_connection(mplane_ip, port=port, username=username, password=password)
    active_partition = get_active_partition(mplane_ip, port=port, username=username, password=password)
    stdin, stdout, stderr = ssh.exec_command('ls /ffs/fs{}/TargetBD*.xml'.format(active_partition))
    regex = r'(?<=TargetBD_)[^\.]+'
    for line in stdout.readlines():
        tmp = re.search(re.compile(regex), line)
        if tmp:
            software_version = tmp.group()
            ssh.close()
            return software_version
    ssh.close()
    logging.error('Cannot determine software version. Perhaps TargetBD*.xml file does not exist')


def query_builder(*args):
    tmp_query = ''
    for arg in args:
        tmp_query += '{}:'.format(arg)
    tmp_query = '{},'.format(tmp_query[:-1])
    return tmp_query


def construct_cli_query(scf, xml, class_name, values):
    object_nr = XML_replacer.get_object_nr_from_xml(class_name,
                                                    XML_replacer.get_xml_elements(xml,
                                                                                  './/*[@class[contains(., \'{}\')]]'
                                                                                  .format(class_name))[0]
                                                    .attrib['distName'])
    tmp_query = ''
    tmp_backup_query = ''
    for value in values:
        if value.tag[-1] == 'p':
            tmp_query += query_builder(class_name, object_nr, value.attrib['name'], value.text)
            tmp_backup_query += create_backup_parameters(scf, class_name, object_nr, value.attrib['name'])
        elif value.tag[-4:] == 'list':
            list_parameters = value.xpath('.//*[@name]')
            for parameter in list_parameters:
                tmp_query += query_builder(class_name, object_nr, value.attrib['name'], parameter.attrib['name'],
                                           parameter.text)
                tmp_backup_query += create_backup_parameters(scf, class_name, object_nr, parameter.attrib['name'],
                                                             value.attrib['name'])
    return tmp_query, tmp_backup_query


def create_backup_parameters(scf, class_name, object_nr, parameter_name, list_name=None):
    tmp_backup_query = ''
    if list_name is None:
        backup_value = XML_replacer.get_xml_elements(scf, './/*[@distName[contains(., \'{}-{}\')]]/*[@name=\'{}\']'
                                                     .format(class_name, object_nr, parameter_name))[0].text
        tmp_backup_query += query_builder(class_name, object_nr, parameter_name, backup_value)
    else:
        backup_value = XML_replacer\
            .get_xml_elements(scf, './/*[@distName[contains(., \'{}-{}\')]]/*[@name=\'{}\']/*[@name=\'{}\']'
                              .format(class_name, object_nr, list_name, parameter_name))
        tmp_backup_query += query_builder(class_name, object_nr, list_name, parameter_name, backup_value)

    return tmp_backup_query


def prepare_query_for_commissioning(scf_file_path, xml_plan_file_path):
    scf = XML_replacer.parse_scf_file(scf_file_path)
    xml = XML_replacer.parse_xml_file(xml_plan_file_path)
    classes = XML_replacer.get_class_from_xml(xml)
    query = ''
    backup_query = ''
    for class_name in classes:
        namespace = xml.get_xml_namespace()
        values = XML_replacer.get_xml_elements(xml, './/*[@class[contains(., \'{}\')]]/*[@name]'.format(class_name))
        queries = construct_cli_query(scf, xml, class_name, values)
        query += queries[0]
        backup_query += queries[1]
    return query, backup_query


def prepare_xml_plan(xml_object, scf_object, create_paths, validate=True, netact=True,  **kwargs):
    validate = bool(validate)
    used_paths = []
    xml_elements = XML_replacer.get_xml_elements(xml_object, xpath='.//*[@distName]')
    for class_name, element in zip(XML_replacer.get_class_from_xml(xml_object), xml_elements):
        path, as_used = XML_replacer.specify_path_to_replace(xml_object, scf_object, class_name, create_paths,
                                                             used_paths, validate, **kwargs)
        if netact is False:
            path.replace(path, 'PLMN-PLMN/', '')
        if element.attrib['class'] == class_name:
            element_to_set = XML_replacer.remove_element_from_xml(xml_object, class_name)
            set_element = XML_replacer.set_elements_attributes(xml_object, element_to_set, path, '', **kwargs)
            XML_replacer.add_element_to_xml(xml_object, set_element)
            used_paths.append(path)
    XML_replacer.save_xml_file(xml_object, os.getcwd(), 'xml_file')
    return create_paths


def create_backup_delta_json(scf, json_delta):
    json_delta = json.loads(json_delta)
    scf = json.loads(scf)
    backup_delta = []
    delta_del = {}
    for json_element in json_delta:
        if json_element['operation'] == 'create':
            delta_del['distName'] = json_element['distName']
            delta_del['operation'] = 'delete'
            delta_del['parameters'] = []
            backup_delta.append(delta_del)
        else:
            for scf_element in scf:
                if json_element['distName'] == scf_element['distName']:
                    for scf_element in scf:
                        if json_element['distName'] == scf_element['distName']:
                            delta = get_delta_backup(backup_delta, scf_element, json_element)
                            if len(delta) > 0:
                                backup_delta.append(delta)
                        elif json_element['operation'] == 'delete' and len(
                                XML_replacer.regex_searching(r'(?<={})/'.format(json_element['distName']),
                                                             scf_element['distName'])) > 0:
                            delta = get_delta_backup(backup_delta, scf_element, json_element)
                            if len(delta) > 0:
                                backup_delta.append(delta)

    return backup_delta


def get_delta_backup(backup_delta, scf_element, json_element):
    tmp_delta = {}
    operation = json_element['operation']
    parameter_list = []
    if operation == 'delete':
        backup_delta.append(scf_element)
    elif operation == 'create':
        tmp_delta['distName'] = scf_element['distName']
        tmp_delta['operation'] = 'delete'
    else:
        tmp_delta['distName'] = scf_element['distName']
        tmp_delta['operation'] = 'update'
        for parameter in json_element['parameters']:
            for scf_parameter in scf_element['parameters']:
                if parameter['parameterName'] == scf_parameter['parameterName']:
                    parameter_list.append(create_parameter_delta(scf_parameter, parameter))
        tmp_delta['parameters'] = parameter_list
    return tmp_delta


def create_parameter_delta(scf_element, delta_element):
    parameter_delta = {}

    list_value_dict = []
    operation = delta_element['operation']
    if operation == 'delete':
        parameter_delta = scf_element
    elif operation == 'create':
        parameter_delta['operation'] = 'delete'
        parameter_delta['parameterName'] = scf_element['parameterName']
    else:
        parameter_delta['operation'] = 'update'
        parameter_delta['parameterName'] = scf_element['parameterName']
        if isinstance(delta_element['value'], list):
            for element_d, element_s in zip(delta_element['value'], scf_element['value']):
                value_dict = {}
                for param in element_d.keys():
                    try:
                        value_dict[param] = element_s[param]
                    except KeyError:
                        pass
                list_value_dict.append(value_dict)
            parameter_delta['value'] = list_value_dict
        else:
            parameter_delta['value'] = scf_element['value']
    return parameter_delta


def jsonizator(scf_file, xml_file, output_json, create_paths, validate=True, **kwargs):
    scf = XML_replacer.parse_scf_file(scf_file)
    xml = XML_replacer.parse_xml_file(xml_file)
    create_paths = prepare_xml_plan(xml, scf, create_paths, validate, netact=False, **kwargs)
    json_delta = convert_delta.convert_delta_xml_to_json('xml_file.xml', output_json)
    scf_json = convert_delta.convert_delta_xml_to_json(scf_file)
    backup_delta = json.dumps(create_backup_delta_json(scf_json, json_delta),
                              sort_keys=True, indent=4, separators=(',', ': '))
    with open('{}.json'.format(output_json), 'w+') as f:
        f.write(json_delta)
    with open('{}_backup.json'.format(output_json), 'w+') as f_backup:
        f_backup.write(backup_delta)
    return create_paths


def check_branch(build):
    """Checks and returns branch name based on SW build name
    author: artur.lebek@nokia.com"""

    path = ('https://wft.int.net.nokia.com/ext/builds/'
            + '?custom_filter[baseline]=' + build)
    file = urllib3.urlopen(path)
    root = etree.parse(file).getroot()
    for child in root:
        if child.find('baseline').text == build:
            branch = child.find('branch').text
    return branch
