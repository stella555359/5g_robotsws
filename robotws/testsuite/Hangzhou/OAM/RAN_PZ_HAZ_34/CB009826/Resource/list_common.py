#!/usr/bin/python
# -*- coding: UTF-8 -*-
"""
Author: Xinyu Zhang
Contacts: sherry.1.zhang@nokia-sbell.com
Description: some common keywords

"""
from __future__ import unicode_literals
import requests
import json
import re
import os
import shutil
import datetime
import time
import csv
import random
from requests.packages.urllib3.exceptions import InsecureRequestWarning, InsecurePlatformWarning
from robot.libraries.BuiltIn import BuiltIn
from taf.selenium.sbts import sbts
from taf.pdu import pdu
from taf.transport.ssh import ssh
from taf.collectors.pmcounters import pmcounters
from taf.analyzer.pmcounter import PMCounterLogReader
from taf.ul.oam_kpi_calculations import oam_kpi_calculations
from gnb_handler import login, logout, check_gnb_cell_status


def list_should_be_equal(compare_list1, compare_list2):
    """
    - Compare two list that should be equal
    """
    if len(compare_list1) != len(compare_list2):
        raise Exception('the length of the two list is not equal!')
    for index, item in enumerate(compare_list1):
        if isinstance(item, (int, str, dict)):
            if isinstance(item, type(compare_list2[index])):
                if item != compare_list2[index]:
                    raise Exception('the value of item is not equal!')
            else:
                raise Exception('the type of item is not equal!' % index)
        elif isinstance(item, list):
            if isinstance(item, type(compare_list2[index])):
                list_should_be_equal(item, compare_list2[index])
            else:
                raise Exception('the type of item is not equal!' % index)


def find_value_in_list(check_list, check_key, check_value_list):
    """
    - If any value in check_value_list exists in check_list, return True. Else return False

    Example:
    | Find Value In List | [{'a': 2, 'b': 2}, {'a': 1, 'b': 3}] | a | [2, 3] |
    result:True

    | Find Value In List | [{'a': 2, 'b': 2}, {'a': 1, 'b': 3}] | a | [4, 3] |
    result:False
    """
    if not isinstance(check_value_list, list):
        check_value_list = [check_value_list]
    check_value_list = [str(i) for i in check_value_list]
    for item in check_list:
        if check_key in item.keys():
            if str(item[check_key]) in check_value_list:
                return True
    return False


def list_contain_sub_dict_or_not(compare_list, compare_key, compare_value):
    """
    - The compare_list should be a list that contain many dicts.
    - Give back a result if those dicts contain compare_key:compare_value.
    - contain->True, not contain->False

    Example:
    | List Contain Sub Dict or Not | [{'a': 2, 'b': 2}, {'a': 1, 'b': 3}] | a | 2 |
    result:True
    """
    for item in compare_list:
        if compare_key in item.keys():
            if str(item[compare_key]) == str(compare_value):
                return True
    return False


def power_reset_via_facoam_or_hbte(host, port, model='HBTE'):
    ports = [port]
    ta_pdu = pdu()
    ta_pdu.setup_pdu(model=model, host=host)
    ta_pdu.reset_ports(ports, time_interval=10)


def get_parameter_from_webem(dist_name, filter_param, abbr, addr, username="Nemuadmin", password="nemuuser"):
    coam_handler = sbts()
    coam_handler.enable_virtual_display()
    try:
        coam_handler.login(url=addr, username=str(username), password=str(password))
        coam_handler.disable_message_box()
        coam_handler.disable_screen_lock()
        try:
            if coam_handler.start_up_view_window_exists():
                coam_handler.close_start_up_view_window()
        except Exception:
            print('No start up view')
        parameter_value = coam_handler.get_parameter_value(dist_name=dist_name, filter_param=filter_param, abbr=abbr)
    finally:
        coam_handler.logout()
    return parameter_value


def add_json_to_file(add_key, add_value, file_path, action):
    """
    - Open or create a file and put {add_key:add_value} to it.
    """
    try:
        with open(file_path, 'r') as f:
            file_content = f.read()
    except Exception as e:
        file_content = None
    if file_content:
        load_dict = json.loads(file_content.encode('utf-8'))
    else:
        load_dict = {}
    modify_dict = {str(add_key): add_value}
    if str(action).lower() == 'provision' or str(action).lower() == 'upgrade':
        upgrade_dict = load_dict.get('upgrade')
        if not upgrade_dict:
            upgrade_dict = {}
        upgrade_dict.update(modify_dict)
        load_dict['upgrade'] = upgrade_dict
    elif str(action).lower() == 'rollback':
        rollback_dict = load_dict.get('rollback')
        if not rollback_dict:
            rollback_dict = {}
        rollback_dict.update(modify_dict)
        load_dict['rollback'] = rollback_dict
    elif str(action) == 'ENB_reset':
        reset_dict = load_dict.get('ENB_reset')
        if not reset_dict:
            reset_dict = {}
        reset_dict.update(modify_dict)
        load_dict['ENB_reset'] = reset_dict
    elif str(action) == 'GNB_reset':
        reset_dict = load_dict.get('GNB_reset')
        if not reset_dict:
            reset_dict = {}
        reset_dict.update(modify_dict)
        load_dict['GNB_reset'] = reset_dict
    with open(file_path, 'w') as f:
        json.dump(load_dict, f)


def get_active_alarm_on_netact_backend(netactnode, username, password, dn, ignore_fault=""):
    alarm_severity = {"1": "Critical", "2": "Major", "3": "Minor"}
    command = "SELECT SUPPLEMENTARY_INFO, DN,UPDATE_TIMESTAMP,SEVERITY FROM FX_ALARM WHERE AGENT_ID='"
    command = command + dn + "' AND ALARM_STATUS='1';\n"
    active_alarm = connect_to_sql_from_netact_backend(netactnode=netactnode, username=username,
                                                      password=password, command=command)
    print(active_alarm)
    split_str = """SUPPLEMENTARY_INFO
--------------------------------------------------------------------------------
DN
--------------------------------------------------------------------------------
UPDATE_TIMESTAMP
---------------------------------------------------------------------------
  SEVERITY
----------"""
    alarms = active_alarm.split(split_str)
    alarm_list = []
    for alarm in alarms:
        alarm_dict = {}
        alarm_tmp = alarm.strip().rstrip("SQL>").rstrip("\n").rstrip("no rows selected")
        print(alarm_tmp)
        if alarm_tmp:
            alarm_item = alarm_tmp.split("\n")
            command = "SELECT DIAGNOSTIC_INFO FROM FX_ALARM WHERE ALARM_STATUS='1' AND SUPPLEMENTARY_INFO='"
            command = command + alarm_item[0].replace("&", "'||chr(38)||'") + "' AND DN='" + alarm_item[1]
            command = command + "' AND UPDATE_TIMESTAMP='" + alarm_item[2] + "' AND SEVERITY='"
            command = command + alarm_item[3].lstrip("\t").strip() + "';\n"
            fault_info = connect_to_sql_from_netact_backend(netactnode=netactnode, username=username,
                                                            password=password, command=command)
            fault_id = re.search(r"\d+", fault_info, flags=0)
            ignore_alarms = ignore_fault.split(',')
            if not str(fault_id.group()) in ignore_alarms:
                alarm_dict['FaultId'] = fault_id.group()
                alarm_dict['FaultName'] = alarm_item[0]
                alarm_dict['Object'] = alarm_item[1]
                alarm_dict['Time'] = alarm_item[2]
                alarm_dict['Severity'] = alarm_severity[alarm_item[3].lstrip("\t").strip()]
                alarm_list.append(alarm_dict)
    return alarm_list


def connect_to_sql_from_netact_backend(netactnode, username, password, command):
    netact_conn = None
    try:
        csn = ssh()
        netact_conn = csn.connect_to(hostname=netactnode, username=username, password=password, alias="netactnode")
        obj = netact_conn.send_command(command="sqlplus omc")
        obj.read_output_until(pattern="assword:", timeout=5)
        obj.write_input(data='omc\n')
        obj.read_output_until(pattern="SQL>", timeout=5)
        obj.write_input(data=command)
        output = obj.read_output_until(pattern='SQL>', timeout=5)
        return output
    finally:
        netact_conn.disconnect()


def get_pm_counter_from_gnb(cellid, pmcounter, host, user="Nemuadmin", password="nemuuser", port=443):
    target_dir = os.path.join(
        BuiltIn().get_variable_value("${OUTPUT DIR}"),
        BuiltIn().get_variable_value("${SUITE NAME}"),
        BuiltIn().get_variable_value("${TEST NAME}"))
    pm_counter_dir = target_dir + '/gnb_pm_counter/'
    try:
        webservice = {'host': host, 'user': user, 'password': password, 'port': port}
        pmcounter_handler = pmcounters()
        pmcounter_handler.create_pm_collector(name="gnb_pm_counter", webservice=webservice)
        pmcounter_handler.setup_collectors(names="gnb_pm_counter")
        pmcounter_handler.collect_collectors(names="gnb_pm_counter")
        pmcounter_handler.teardown_collectors(names="gnb_pm_counter")
        counter_path = "//NRCELL[@id='{cell_id}']//@" + pmcounter
        file_lists = os.listdir(pm_counter_dir)
        file_lists.sort(key=lambda file: os.path.getmtime(pm_counter_dir + file)
                        if not os.path.isdir(pm_counter_dir + file) else 0, reverse=True)
        pm_counter_value = []
        for file in file_lists:
            file_path = os.path.join(pm_counter_dir, file)
            with open(file_path, "rb") as file_obj:
                for log_entry in PMCounterLogReader(file_obj_iterator=[file_obj]):
                    # counter_path = "//NRCELL[@id='{cell_id}']//@" + pmcounter
                    counter_value = log_entry.pm_setup.xpath(counter_path.format(cell_id=int(cellid)))
                    print(counter_value)
                    if counter_value and int(counter_value[-1]) != 0:
                        pm_counter_value = pm_counter_value + counter_value
        return pm_counter_value
    finally:
        shutil.rmtree(pm_counter_dir)


def check_nms_status_from_webem(tls_status, addr, username="Nemuadmin", password="nemuuser"):
    coam_handler = sbts()
    coam_handler.enable_virtual_display()
    try:
        coam_handler.login(url=addr, username=username, password=password)
        coam_handler.disable_message_box()
        coam_handler.disable_screen_lock()
        try:
            if coam_handler.start_up_view_window_exists():
                coam_handler.close_start_up_view_window()
        except Exception:
            print('No start up view')
        tls_info = coam_handler.get_tls_info()
        mns_status = ([tls_info['TLS connection status']] if 'TLS connection status' in tls_info
                      else [tls_info['Downlink from NMS'], tls_info['Uplink to NMS']])
        if tls_status == 'forced':
            if not all(item == 'Secured' for item in mns_status):
                raise Exception('NMS status in BTS is:%s' % tls_info)
        elif tls_status == 'off':
            if not all(item == 'Not secured' for item in mns_status):
                raise Exception('NMS status in BTS is:%s' % tls_info)
        else:
            raise Exception('wrong tls configuration')
    finally:
        coam_handler.logout()


def check_amf_status_from_webem(addr, username="Nemuadmin", password="nemuuser"):
    coam_handler = sbts()
    coam_handler.enable_virtual_display()
    try:
        coam_handler.login(url=addr, username=username, password=password)
        coam_handler.disable_message_box()
        coam_handler.disable_screen_lock()
        try:
            if coam_handler.start_up_view_window_exists():
                coam_handler.close_start_up_view_window()
        except Exception:
            print('No start up view')
        amf_info = coam_handler.get_amf_info()
        if amf_info['NG link status'] != 'Active':
            raise Exception('AMF status is abnormal! NG link status: %s' % amf_info['NG link status'])
    finally:
        coam_handler.logout()


def check_if_package_exists(package_path):
    requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
    requests.packages.urllib3.disable_warnings(InsecurePlatformWarning)
    try:
        r = requests.get(package_path, verify=False)
    except Exception:
        return False
    package_path_list = package_path.split('/')
    if package_path_list[-1] == '':
        package = package_path_list[-2]
    else:
        package = package_path_list[-1]
    pattern_list = [r'.*%s.*downloadable_A54.zip.*</a>.*\s+(.*)\s+GB' % package,
                    r'.*%s.*downloadable_A54.zip.*</a>.*\s+(\d+)' % package,
                    r'AirScale-%s.zip.*</a>.*\s+(.*)\s+GB' % package]
    if r.status_code == 200:
        for pattern in pattern_list:
            size = re.search(pattern, r.text, flags=0)
            if not size:
                continue
            else:
                break
        else:
            return False
        size = size.group(1)
        print(size)
        if '.' in str(size):
            if float(size) > 1:
                return True
            else:
                return False
        else:
            if len(size) > 9:
                return True
            else:
                return False
    else:
        return False


def get_sw_process_duration_from_swdlreport(action, process, sw_process, file_path, ip,
                                            username='toor4nsn', password='oZPS0POrRieRtu'):
    time_list = []
    try:
        csn = ssh()
        gnb_conn = csn.connect_to(hostname=ip, username=username, password=password, alias="gnb")
        if process in sw_process.keys():
            for item in sw_process[process]:
                commad = "cat /ffs/run/config/SWDLreport.txt | grep '" + item + "'"
                all_start = gnb_conn.execute(command=commad, timeout=60)
                last_time = datetime.datetime.strptime(all_start.split('\r\n')[-2].split('Z')[0].replace('T', ' '),
                                                       '%Y-%m-%d %H:%M:%S')
                time_list.append(last_time)
        else:
            raise Exception('SW process %s not in %s' % (process, sw_process))
        duration = (time_list[1] - time_list[0]).seconds
        add_json_to_file(process, duration, file_path, action)
    finally:
        gnb_conn.disconnect()


def get_ru_username_password(ru_type, build_release, if_need_handle_dollar=True):
    user_passwd_list = []
    # resource_path = 'E:\\robotws\\testsuite\\Hangzhou\\OAM\\RAN_PZ_HAZ_34\\UUF\\Resource\\ru_username_password.csv'
    resource_path = '/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/ru_username_password.csv'
    with open(os.path.abspath('.') + resource_path, encoding='UTF-8') as f:
        f_csv = csv.reader(f)
        for index, row in enumerate(f_csv):
            if index == 0:
                release_index = row.index(str(build_release))
            if index != 0 and ru_type in row[0]:
                user_passwd_split = row[release_index].split(',')
                for item in user_passwd_split:
                    user_passwd = item.split('//')
                    if len(user_passwd) <= 1:
                        user_passwd = ["", ""]
                    if if_need_handle_dollar:
                        password = _handle_string_with_dollar(user_passwd[1])
                    else:
                        password = user_passwd[1]
                    if len(user_passwd) == 3:
                        if if_need_handle_dollar:
                            root_password = _handle_string_with_dollar(user_passwd[2])
                        else:
                            root_password = user_passwd[2]
                        user_passwd_list.append(
                            {'username': user_passwd[0], 'password': password, 'root_password': root_password})
                    elif len(user_passwd) == 2:
                        user_passwd_list.append({'username': user_passwd[0], 'password': password})
    return user_passwd_list


def _handle_string_with_dollar(my_str):
    if '$' in my_str:
        index = my_str.index('$')
        re_str = my_str[0:index] + '\\' + my_str[index::]
    else:
        re_str = my_str
    return re_str


def connet_to_ru(PC_ip, PC_user, PC_password, ru_ip, ru_type, build_release):
    csn = ssh()
    pc_conn = csn.connect_to(PC_ip, PC_user, PC_password, alias='taf_proxy')
    ru_info = get_ru_username_password(ru_type, build_release, if_need_handle_dollar=False)
    for item in ru_info:
        print(item)
        try:
            ru_conn = csn.connect_to(ru_ip, item['username'], item['password'], proxy='taf_proxy', alias='RU')
            print('*************************')
            print(ru_conn)
            if 'root_password' in item.keys():
                ru_shell = ru_conn.invoke_shell()
                ru_shell.send('su root\n')
                time.sleep(2)
                print(ru_shell.recv(65535))
                ru_shell.send(item['root_password'] + '\n')
                time.sleep(5)
                print(ru_shell.recv(65535))
                ru_shell.send('ls -lt\n')
                time.sleep(5)
                print(ru_shell.recv(65535))
            break
        except Exception:
            continue
    else:
        raise Exception('connet ru fail')
    return ru_conn, pc_conn


def disconnect_ru(PC_alias, ru_alias):
    ru_alias.disconnect()
    PC_alias.disconnect()


def reboot_ue_pc(pc_info):
    csn = ssh()
    for pc in pc_info:
        pc_conn = csn.connect_to(hostname=pc['addr'], username=pc['username'], password=pc['password'], alias="pc")
        pc_conn.execute(command='shutdown -r -t 0', timeout=60)
        time.sleep(1)
        pc_conn.disconnect()


def check_made_power(PC_ip, PC_user, PC_password, ru_ip, ru_type, build_release):
    ru_conn, pc_conn = connet_to_ru(PC_ip, PC_user, PC_password, ru_ip, ru_type, build_release)
    ru_info = get_ru_username_password(ru_type, build_release, if_need_handle_dollar=False)
    ru_shell = ru_conn.invoke_shell()
    ru_username = ru_info[0]['username']
    ru_passwd = ru_info[0]['password']
    login_made_command = 'ssh %s@192.168.102.2\n' % ru_username
    print(ru_shell.recv(65535))
    time.sleep(5)
    print('--------output3------------')
    ru_shell.send(login_made_command)
    time.sleep(5)
    output1 = ru_shell.recv(65535)
    print('--------output1------------')
    print(output1)
    output1 = output1.decode()
    if '(yes/no)' in output1:
        ru_shell.send('yes\n')
        output1 = ru_shell.recv(65535)
        print('--------output2------------')
        print(output1)
    time.sleep(5)
    if 'password:' in output1:
        ru_shell.send(ru_passwd + '\n')
        print(ru_shell.recv(65535))
    time.sleep(5)
    ru_shell.send('sudo dapd -sq\n')
    print(ru_shell.recv(65535))
    time.sleep(5)
    timeout = 100
    start_time = time.time()
    end_time = time.time()
    output = ''
    while end_time - start_time < timeout:
        ru_output = ru_shell.recv(65535)
        output = output + ru_output.decode()
        if '[%s@ct-made DFE1]' % ru_username in output:
            break
        time.sleep(5)
        end_time = time.time()
    print(output)
    if '-inf' in output:
        power_status = PC_ip + '_' + 'power abnormal'
        print(power_status)
    else:
        power_status = PC_ip + '_' + 'power normal'
        print(power_status)
    disconnect_ru(pc_conn, ru_conn)
    return power_status, output


def send_command_on_windows_pc(hostname, username, password, command):
    SSH = ssh()
    windows = SSH.connect_to(hostname=hostname, username=username, password=password, alias='windows_pc')
    try:
        command_return = windows.send_command(command)
        time.sleep(5)
        return command_return
    finally:
        windows.disconnect()


def start_ru_btslog_at_windows_pc(hostname, username, password):
    SSH = ssh()
    windows = SSH.connect_to(hostname=hostname, username=username, password=password, alias='windows_pc')
    SSH.send_command('c:/"Program Files (x86)"/BTSLog2/BTSlog2.exe -nogui \n', connection="windows_pc")
    time.sleep(5)
    print(SSH.read_output_until("BTSLog>", connection="windows_pc"))
    time.sleep(5)
    SSH.write_input("start_udplog\n", connection="windows_pc")
    time.sleep(5)
    print(SSH.read_output_until("BTSLog>", connection="windows_pc"))
    windows.disconnect()


def compare_versions(version_1, version_2):
    ver_1_items = version_1.split("_")
    ver_2_items = version_2.split("_")
    if len(ver_1_items) < len(ver_2_items):
        return False
    return (version_1 > version_2)


def get_downtime_from_ims2(path):
    oam_kpi = oam_kpi_calculations()
    results = oam_kpi.calculate_kpi2a(path)
    oam_kpi.clear_results()
    downtime = results['kpi2a'][0]['delta'].total_seconds()
    return downtime


def get_random_cell_id(ip, username="Nemuadmin", password="nemuuser", gnb_type='coam'):
    cell_id = []
    try:
        login(ip, username, password, gnb_type, 'cell_id')
        cell_status = check_gnb_cell_status('cell_id')
        for item in cell_status:
            cell_id.append(item['name'].split('-')[-1])
    finally:
        logout('cell_id')
    cell_chioce = random.choice(cell_id)
    return cell_chioce


def get_json_from_file(add_key, file_path, action):
    if str(action).lower() == 'provision' or str(action).lower() == 'upgrade':
        action = 'upgrade'
    elif str(action).lower() == 'rollback':
        action = 'rollback'
    value_dict = {}
    try:
        with open(file_path, 'r') as f:
            file_content = f.read()
    except Exception as e:
        file_content = {}
    if file_content:
        load_dict = json.loads(file_content.encode('utf-8'))
        action_dict = load_dict.get(action)
        try:
            value_dict = action_dict.get(add_key)
            if not value_dict:
                value_dict = {}
        except Exception as e:
            value_dict = {}
    return value_dict


def count_list_contain_sub_dict(compare_list, compare_key, compare_value):
    count_index = 0
    for item in compare_list:
        if compare_key in item.keys():
            if str(item[compare_key]) == str(compare_value):
                count_index = count_index + 1
    return count_index


if __name__ == '__main__':
    from taf.selenium.nms.nom import nom

    # ru_conn, pc_conn = connet_to_ru('10.68.86.173', 'ute', '3edc4rfv%TGB', '192.168.101.1', 'AEQK', 'SBTS21B')
    # disconnect_ru(pc_conn, ru_conn)
    # user_passwd_list = get_ru_username_password('AZQO', '5G21A')
    # print(user_passwd_list)
    # list1 = [{'a': 2, 'b': 2}, {'a': 1, 'b': 2}]
    # list2 = [1, {'a': 1, 'b': 2}, [1, {'a': 1, 'b': 2}]]
    # list_should_be_equal(list1, list2)
    # print list_contain_sub_dict_or_not(list1, 'a', 1)
    print(check_if_package_exists(
        'http://10.135.157.75:8081/artifactory/mn5gran_hzlog-local/SBTS21B_packages/SBTS21B_ENB_0000_001662_000000/'))
