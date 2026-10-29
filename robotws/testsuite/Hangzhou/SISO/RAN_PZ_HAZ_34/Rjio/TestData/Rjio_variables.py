# !/usr/bin/python
# -*- coding: utf-8 -*-
from taf.transport.ssh import ssh
import time
import re
from datetime import datetime
import os
import shutil
import subprocess
# import win32api
# import win32con

csn = ssh()

matrixPA_out_ports = [1, 2, 3, 4]
matrixPA_out_ports_9_12 = [9, 10, 11, 12]
matrixPA_rows = 16
matrixPA_TDD908 = [1, 18, 35, 52]
matrixPA_moduleUE_B9A1_B10A2_B11A3_B12_A4 = [129, 146, 163, 180]
matrixPA_B9A9_B10A10 = [137, 154]
matrixPA_B9A7_B10A8 = [135, 152]
matrixPA_B9A13_B10A14 = [141, 158]

moduleUE_list_ue3 = [4]

dl_tp_list = ['200M']
ul_tp_list = ['10M']

apn_info = {'2': 'dxdata2', '3': 'dxdata1', '4': 'dxdata1'}

tput_define_moduleUE = {
    62: {
        'dl_exp': 100,
        'dl_tp': '200M',
        'ul_exp': 1,
        'ul_tp': '10M',
        'ue_index': 4
    },
}

tput_define_case71 = {
    62: {
        'dl_exp': 200,
        'dl_tp': '300M/sec',
        'ul_exp': 50,
        'ul_tp': '100K/sec',
        'ue_index': 4
    },
}

tput_define_case64 = {
    62: {
        'dl_exp': 5,
        'dl_tp': '5M/sec',
        'ul_exp': 0,
        'ul_tp': '5M/sec',
        'ue_index': 4
    },
}

tput_define_case63 = {
    61: {
        'dl_exp': 1,
        'dl_tp': '200K',
        'ul_exp': 0,
        'ul_tp': '1M',
        'ue_index': 2
    },
}

tput_define_case34 = {
    61: {
        'dl_exp': 10,
        'dl_tp': '10M',
        'ul_exp': 0,
        'ul_tp': '0M',
        'ue_index': 2
    },
}

tput_define_BWP = {
    62: {
        'dl_exp': 100,
        'dl_tp': '100M',
        'ul_exp': 1,
        'ul_tp': '10M',
        'ue_index': 0
    },
}

tput_define_S23 = {
    62: {
        'dl_exp': 1497,
        'dl_tp': '1000M',
        'ul_exp': 166.7,
        'ul_tp': '300M',
        'ue_index': 0,
        'ui_version': 'Mi12UI13.0.12'
    },
}

tput_define_2300_reduce = {
    62: {
        'dl_exp': 100,
        'dl_tp': '100M',
        'ul_exp': 166.7,
        'ul_tp': '300M',
        'ue_index': 0,
        'ui_version': 'Mi12UI13.0.12'
    },
}

tput_define = {
    61: {
        'dl_exp': 1487,
        'dl_tp': '1600M',
        'ul_exp': 200,
        'ul_tp': '240M',
        'ue_index': 2,
        'ui_version': 'default'
    },
    62: {
        'dl_exp': 900,
        'dl_tp': '1500M',
        'ul_exp': 224,
        'ul_tp': '250M',
        'ue_index': 0,
        'ui_version': 'M40PUI1.1'
    },
    63: {
        'dl_exp': 200,
        'dl_tp': '300M',
        'ul_exp': 100,
        'ul_tp': '200M',
        'ue_index': 0
    },
    72: {
        'dl_exp': 99,
        'dl_tp': '120M',
        'ul_exp': 44,
        'ul_tp': '100M',
        'ue_index': 0
    },
}

tput_define_reduce = {
    61: {
        'dl_exp': 100,
        'dl_tp': '100M',
        'ul_exp': 200,
        'ul_tp': '240M',
        'ue_index': 2,
        'ui_version': 'default'
    },
    62: {
        'dl_exp': 100,
        'dl_tp': '100M',
        'ul_exp': 224,
        'ul_tp': '250M',
        'ue_index': 0,
        'ui_version': 'M40PUI1.1'
    },
}

tput_define_single_cell = {
    63: {
        'dl_exp': 1400,
        'dl_tp': '1500M',
        'ul_exp': 200,
        'ul_tp': '300M',
        'ue_index': 0
    },
    72: {
        'dl_exp': 99,
        'dl_tp': '120M',
        'ul_exp': 44,
        'ul_tp': '100M',
        'ue_index': 0
    },
}

tput_define_HO = {
    61: {
        'dl_exp': 1487,
        'dl_tp': '1600M',
        'ul_exp': 233,
        'ul_tp': '400M',
        'ue_index': 2
    },
    62: {
        'dl_exp': 780,
        'dl_tp': '900M',
        'ul_exp': 165,
        'ul_tp': '200M',
        'ue_index': 0
    },
    63: {
        'dl_exp': 200,
        'dl_tp': '300M',
        'ul_exp': 50,
        'ul_tp': '100M',
        'ue_index': 0
    },
    72: {
        'dl_exp': 50,
        'dl_tp': '100M',
        'ul_exp': 20,
        'ul_tp': '100M',
        'ue_index': 0
    },
}

tput_define_NR_ANR = {
    62: {
        'dl_exp': 1,
        'dl_tp': '20M',
        'ul_exp': 1,
        'ul_tp': '20M',
        'ue_index': 0
    },
}

tput_define_NR_LTE_ANR = {
    62: {
        'dl_exp': 5,
        'dl_tp': '20M',
        'ul_exp': 1,
        'ul_tp': '20M',
        'ue_index': 0
    },
}

rate_for_stream = {
    'SBTS22R4': '0.9',
    'master': '0.8'
}

rate_for_stream_min = {
    'SBTS22R4': '0.8',
    'master': '0.8'
}


def replace_scf_file_to_current_bts(current_path_file, new_file):
    """
     replacing the scf under the current robotws/commissionings with the scf download from the current BTS
     :parameter  current_path_file: current scf under robotws/commissionings path
     :parameter  new_file: the scf download from current BTS
    """
    current_path = os.path.abspath(current_path_file)
    father_path = os.path.dirname(current_path)
    new_path_file = os.path.abspath(new_file)
    new_father_path = os.path.dirname(new_path_file)
    re = os.path.exists(path=current_path)
    print(re)
    print(current_path, father_path)
    print(new_path_file, new_father_path)
    if re:
        os.remove(path=current_path)
        shutil.copy(src=new_path_file, dst=father_path)
    else:
        shutil.copy(src=new_path_file, dst=father_path)


def get_item_in_list(item_list=[], item=''):
    """
    :type item: str
    :type item_list: list
    """
    counter = item_list.count(item)
    return counter


def get_activate_and_passive_sw(gnb_ip, username, password):
    """
    Get the active SW build and the passive SW build of gNB via ssh.
    :param gnb_ip: gNB IP address
    :param username: gNB ssh username
    :param password: gNB ssh password
    :rtype str
    """
    connection = csn.connect_to(hostname=gnb_ip, username=username, password=password)
    active_command = r"ls -al /ffs/run/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'"
    passive_command = r"ls -al /ffs/stb/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'"
    active_sw_output = csn.execute(command=active_command, connection=connection)
    passive_sw_output = csn.execute(command=passive_command, connection=connection)
    active_sw = active_sw_output.strip('\r\n').lstrip('TargetBD_').rstrip('.xml')
    passive_sw = passive_sw_output.strip('\r\n').lstrip('TargetBD_').rstrip('.xml')
    csn.disconnect(connection=connection)
    return active_sw, passive_sw


def get_current_time():
    """
    Get current time.
    """
    weekday = datetime.now().strftime("%a")
    hour = time.strftime('%H', time.localtime())
    minute = time.strftime('%M', time.localtime())
    return weekday, hour, minute


def get_ue_network_status(host, username, password, ue_sn, alias='cell_crtlPC'):
    """
    get ue current network status
    :param host: pc ip
    :param username: pc username
    :param password: pc password
    :param ue_sn: UE SN
    :rtype: int
    """
    try:
        csn.connect_to(hostname=host, username=username, password=password, alias=alias)
    except Exception as e:
        print("connection failed: {}".format(e))
    else:
        csn.send_command(command="adb -s {} shell dumpsys telephony.registry | grep mServiceState".format(ue_sn),
                         connection=alias)
        service_state = csn.read_output(connection=alias)
        pattern = r"NrBearerStatus=\d"
        print(service_state)
        match_result = re.findall(pattern=pattern, string=service_state)[0]
        print(match_result)
        lte_status = match_result.split('=')[1].strip()
        print(lte_status)
    finally:
        try:
            csn.disconnect(connection=alias)
        except UnboundLocalError:
            print("close connection failed!")
    return lte_status


def capture_logs(ute_hostname, ute_username, ute_password, gnb_ip, capture_time):
    i = 1
    connection = csn.connect_to(hostname=ute_hostname, username=ute_username, password=ute_password,
                                alias="ute_pc")
    while i:
        csn.send_command(command="cd /tmp/gnb_logs/&&././gnb_logs {} -c1 -t -b {}".format(gnb_ip, capture_time),
                         connection=connection)
        output = csn.read_output(connection=connection)
        print(output)
        time.sleep(30)
        pattern = r"finished"
        match = re.findall(pattern=pattern, string=output)
        while not match:
            match = re.findall(pattern=pattern, string=output)
        time.sleep(3)
        csn.send_command(command="cd /tmp/gnb_logs/&&ls -l | grep {} ".format(gnb_ip) + "|awk '{print $9}'\n",
                         connection=connection)
        # time.sleep(1)
        log = csn.read_output(connection=connection)
        print(log)
        logs_list = list(log.split('\n'))
        # logs = log.strip('\n')
        print(logs_list)
        length = len(logs_list)
        print(length)
        rm_list = logs_list[:length-6]
        print(rm_list)
        if length == 16:
            for i in rm_list:
                csn.send_command(command="cd /tmp/gnb_logs/&&rm -rf {}".format(i), connection=connection)
                length += 1
    csn.disconnect(connection=connection)


# def simulate_keyboard_operation(key_code):
#     """
#     :param key_code: python keyboard key code
#     """
#     win32api.keybd_event(key_code, 0, 0, 0)   # press key
#     win32api.keybd_event(key_code, 0, win32con.KEYEVENTF_KEYUP, 0)   # release key


def delete_newline_symbol(str):
    new_str = str.rstrip('\n')
    return new_str


def check_hanging_resources(host, username, password, file_path):
    """
    :param host: ute ip address
    :param username: ute username
    :param password: ute password
    :param file_path: hanging resoures script file path
    :rtype: list
    """
    connenction = csn.connect_to(hostname=host, username=username, password=password)
    print("python " + str(file_path))
    p = os.popen(cmd="python " + str(file_path))
    result = ((p.read()).rstrip('\n')).split('\n')
    print("----------------------------------------------------------------------")
    print(result)
    print("----------------------------------------------------------------------")
    csn.disconnect(connection=connenction)
    return result
