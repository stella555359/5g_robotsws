import csv
import sys
import re
import os
import ast
import time
import json
from taf.transport.ssh import ssh


def NestedDictValues(d):
    for v in d.values():
        if isinstance(v, dict):
            yield from NestedDictValues(v)
        else:
            yield v


def GetPMCountersValues(counters):
    return list(NestedDictValues(counters))


def _handle_string_with_dollar(my_str):
    if '$' in my_str:
        index = my_str.index('$')
        re_str = my_str[0:index] + '\\' + my_str[index::]
    else:
        re_str = my_str
    return re_str


def get_ru_username_password(ru_type, build_release, if_need_handle_dollar=True):
    user_passwd_list = []
    # resource_path = 'C:\\robotws\\testsuite\\Hangzhou\\OAM\\RAN_PZ_HAZ_34\\UUF_NEW\\Config\\ru_username_password.csv'
    # with open(resource_path, encoding='UTF-8') as f:
    # resource_path = os.path.abspath('.') + '/Config/ru_username_password.csv'
    resource_path = os.path.dirname(os.path.realpath(
        __file__)) + "/../Config/ru_username_password.csv"
    with open(resource_path, encoding='UTF-8') as f:
        f_csv = csv.reader(f)
        for index, row in enumerate(f_csv):
            if index == 0:
                if build_release not in row:
                    print(
                        'build release not in csv file, set default release to SBTS00')
                    build_release = "SBTS00"
                print('-----build_release---------')
                print(build_release)
                release_index = row.index(str(build_release))
                print('----release_index---------')
                print(release_index)
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
                            root_password = _handle_string_with_dollar(
                                user_passwd[2])
                        else:
                            root_password = user_passwd[2]
                        user_passwd_list.append(
                            {'username': user_passwd[0], 'password': password, 'root_password': root_password})
                    elif len(user_passwd) == 2:
                        user_passwd_list.append(
                            {'username': user_passwd[0], 'password': password})
    return user_passwd_list


def enable_ssh_to_ru(pc_ip, pc_username, pc_password, ru_ip, ru_info):
    command = "ping " + ru_ip + " -c 3\n"
    print(command)
    enable = "3 packets transmitted, 3 received"
    print(ru_info)

    try:
        csn = ssh()
        pc_conn = csn.connect_to(
            hostname=pc_ip, username=pc_username, password=pc_password, alias='LMIPC_%s' % pc_ip)
        pc_shell = pc_conn.invoke_shell()
        pc_shell.send('sudo -i\n')
        time.sleep(2)
        print(pc_shell.recv(65535))
        pc_shell.send(command)
        time.sleep(10)
        # print(pc_shell.recv(65535))
        output = pc_shell.recv(65535)
        output = output.decode()
        print(output)
        if enable not in output:
            for item in ru_info:
                if not isinstance(item, dict):
                    item_dict = ast.literal_eval(item)
                else:
                    item_dict = item
                command1 = 'echo "' + \
                    item_dict['username'] + '" > /dev/ttyUSB0\n'
                command2 = 'echo "' + \
                    item_dict['password'] + '" > /dev/ttyUSB0\n'
                pc_shell.send("stty -F /dev/ttyUSB0 115200 parodd\n")
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command1)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                print('*********sudo lmi-eth on***************')
                pc_shell.send('echo "sudo lmi-eth on" > /dev/ttyUSB0\n')
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command)
                time.sleep(10)
                output = pc_shell.recv(65535)
                output = output.decode()
                print(output)
                if enable in output:
                    break
    except Exception:
        print('enable ssh to ru from PC fail')
    finally:
        csn.disconnect(connection='LMIPC_%s' % pc_ip)


def connet_to_ru_via_lmi(PC_ip, PC_user, PC_password, ru_ip, ru_type, build_release):
    csn = ssh()
    pc_conn = csn.connect_to(PC_ip, PC_user, PC_password, alias='pc_proxy')
    # home_dir = csn.execute(command="eval echo ~$USER", connection="pc_proxy")
    # clear_last_ssh = "ssh-keygen -f \"" + home_dir + "/.ssh/known_hosts\" -R " + PC_ip
    # home_dir = csn.execute(command=clear_last_ssh, connection="pc_proxy")

    ru_info = get_ru_username_password(
        ru_type, build_release, if_need_handle_dollar=False)
    for ru in ru_info:
        print(ru)
        try:
            ru_conn = csn.connect_to(
                ru_ip, ru['username'], ru['password'], proxy='pc_proxy', alias='RU')
            print('*************************')
            print(ru_conn)
            if 'root_password' in ru.keys():
                ru_shell = ru_conn.invoke_shell()
                ru_shell.send('su root\n')
                time.sleep(2)
                print(ru_shell.recv(65535))
                ru_shell.send(ru['root_password'] + '\n')
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


# def get_active_alarm_on_netact_backend(netactnode, username, password, dn, ignore_fault=""):
#     alarm_severity = {"1": "Critical", "2": "Major", "3": "Minor"}
#     command = "SELECT SUPPLEMENTARY_INFO, DN,UPDATE_TIMESTAMP,SEVERITY FROM FX_ALARM WHERE AGENT_ID='"
#     command = command + dn + "' AND ALARM_STATUS='1';\n"
#     active_alarm = connect_to_sql_from_netact_backend(netactnode=netactnode, username=username,
#                                                       password=password, command=command)
#     print(active_alarm)
#     split_str = """SUPPLEMENTARY_INFO
# --------------------------------------------------------------------------------
# DN
# --------------------------------------------------------------------------------
# UPDATE_TIMESTAMP
# ---------------------------------------------------------------------------
#   SEVERITY
# ----------"""
#     alarms = active_alarm.split(split_str)
#     alarm_detail_list = []
#     alarm_id_list = []
#     for alarm in alarms:
#         alarm_dict = {}
#         alarm_tmp = alarm.strip().rstrip("SQL>").rstrip("\n").rstrip("no rows selected")
#         print(alarm_tmp)
#         if alarm_tmp:
#             alarm_item = alarm_tmp.split("\n")
#             command = "SELECT DIAGNOSTIC_INFO FROM FX_ALARM WHERE ALARM_STATUS='1' AND SUPPLEMENTARY_INFO='"
#             command = command + \
#                 alarm_item[0].replace("&", "'||chr(38)||'") + \
#                 "' AND DN='" + alarm_item[1]
#             command = command + "' AND UPDATE_TIMESTAMP='" + \
#                 alarm_item[2] + "' AND SEVERITY='"
#             command = command + alarm_item[3].lstrip("\t").strip() + "';\n"
#             fault_info = connect_to_sql_from_netact_backend(netactnode=netactnode, username=username,
#                                                             password=password, command=command)
#             fault_id = re.search(r"\d+", fault_info, flags=0)
#             ignore_alarms = ignore_fault.split(',')
#             if not fault_id:
#                 continue
#             if not str(fault_id.group()) in ignore_alarms:
#                 alarm_dict['FaultId'] = fault_id.group()
#                 alarm_dict['FaultName'] = alarm_item[0]
#                 alarm_dict['Object'] = alarm_item[1]
#                 alarm_dict['Time'] = alarm_item[2]
#                 alarm_dict['Severity'] = alarm_severity[alarm_item[3].lstrip(
#                     "\t").strip()]
#                 alarm_detail_list.append(alarm_dict)
#                 alarm_id_list.append(fault_id.group())
#     return alarm_detail_list, alarm_id_list


def get_active_alarm_on_netact_backend(netactnode, username, password, dn, ignore_fault=""):
    command = "SELECT DIAGNOSTIC_INFO FROM FX_ALARM WHERE AGENT_ID='" + \
        dn + "' AND ALARM_STATUS='1';\n"
    active_alarm = connect_to_sql_from_netact_backend(netactnode=netactnode, username=username,
                                                      password=password, command=command)
    print(active_alarm)
    alarm_id_list = [r.group(1) for r in re.finditer(
        r"additionalFaultID=(\d+)", active_alarm, re.S)]
    print(alarm_id_list)
    return alarm_id_list, alarm_id_list


def connect_to_sql_from_netact_backend(netactnode, username, password, command):
    netact_conn = None
    try:
        csn = ssh()
        netact_conn = csn.connect_to(
            hostname=netactnode, username=username, password=password, alias="netactnode")
        obj = netact_conn.send_command(command="sqlplus omc")
        obj.read_output_until(pattern="assword:", timeout=5)
        obj.write_input(data='omc\n')
        obj.read_output_until(pattern="SQL>", timeout=5)
        obj.write_input(data=command)
        output = obj.read_output_until(pattern='SQL>', timeout=5)
        return output
    finally:
        netact_conn.disconnect()


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
    elif str(action) == 'reset':
        reset_dict = load_dict.get('reset')
        if not reset_dict:
            reset_dict = {}
        reset_dict.update(modify_dict)
        load_dict['reset'] = reset_dict
    with open(file_path, 'w') as f:
        json.dump(load_dict, f)


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


def catch_snapshot_via_vm(vm_ip, vm_username, vm_password, ssh_ip, ssh_username, ssh_passwd):
    try:
        csn = ssh()
        vm_conn = csn.connect_to(
            hostname=vm_ip, username=vm_username, password=vm_password, alias='vm_proxy')
        smod_conn = csn.connect_to(hostname=ssh_ip, username=ssh_username, password=ssh_passwd,
                                   proxy='vm_proxy', alias='smod')
        result = smod_conn.execute(
            command='rm -rf /tmp/snapshot.zip', timeout=60)
        print(result)
        smod_shell = smod_conn.invoke_shell()
        smod_shell.send('cd /tmp/\n')
        time.sleep(1)
        smod_shell.send('telnet 0 15007\n')
        time.sleep(2)
        print(smod_shell.recv(65535))
        print('\n' + '-----------collect-------------------')
        smod_shell.send('log -a -z snapshot.zip\n')
        wait_until_expect_result(smod_shell, 'AaShell>', 180)
        print('--------collect finish----------------')
        smod_shell.send('quit\n')
        # print('scp snapshot to vm')
        # command = 'sshpass -p %s scp %s@%s:/tmp/snapshot.zip %s/%s' % (ssh_passwd, ssh_username, ssh_ip,
        #                                                                   log_location, log_name)
        # result = vm_conn.execute(command=command, timeout=60)
        # print(result)
    finally:
        smod_conn.disconnect()
        vm_conn.disconnect()


def wait_until_expect_result(shell, expect_result, timeout):
    time_start = time.time()
    time_end = time.time()
    output = ''
    while time_end - time_start < timeout:
        time.sleep(5)
        output = output + shell.recv(65535).decode()
        print(output)
        if expect_result in output:
            break


if __name__ == '__main__':
    # user_passwd_list = get_ru_username_password('AQQK', 'SBTS23R1')
    # print(user_passwd_list)
    # enable_ssh_to_ru('10.71.217.114', 'ute', '3edc4rfv%TGB', '192.168.101.1', user_passwd_list)
    netactnode = "10.68.84.15"
    username = "omc"
    password = "Nokia123!"
    dn = "PLMN-PLMN/MRBTS-11553"
    alarm_detail_list, alarm_id_list = get_active_alarm_on_netact_backend(
        netactnode, username, password, dn)
    print(alarm_detail_list)
    print(alarm_id_list)
    # add_key = "active_alarm"
    # add_value = [{
    #     "alarmId": 7111,
    #     "alarmName": "BASE STATION SOFTWARE MANAGEMENT PROBLEM",
    #     "faultId": 23,
    #     "faultName": "Incompatible SW version detected",
    #     "severity": "Critical",
    #     "alarmObject": "MRBTS-98/EQM-1/APEQM-1/RMOD-2",
    #     "clearedTime": "2023-06-19 13:07:14",
    #     "time": "2023-06-19 12:43:05"
    # }]
    # file_path = "execution_results.json"
    # action = "upgrade"
    # value_dict = get_json_from_file(add_key, file_path, action)
    # add_json_to_file(add_key, add_value + value_dict, file_path, action)
