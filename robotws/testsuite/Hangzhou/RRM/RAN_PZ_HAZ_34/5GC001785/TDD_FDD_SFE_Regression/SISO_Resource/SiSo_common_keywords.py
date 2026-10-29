import re
import time

import yaml

from taf.transport.ssh import ssh


def get_info_from_file(file_path):
    with open(file_path, "r") as f:
        test_info = yaml.safe_load(f)
    return test_info


def get_required_distname_path(search_str, required_distname='LTEENB'):
    obj = re.compile(pattern=rf'{required_distname}" distName="(?P<distName_path>.*?)"', flags=re.S)
    distname_list = obj.finditer(string=search_str)
    distName_path_list = []
    for distname in distname_list:
        distName_path_list.append(distname.group('distName_path'))
    return distName_path_list


def check_fault_is_existed(
        detected_fault_id: list):
    _default_white_fault_id = [
        61652,
        4655,
        61524,
        4654,
        7313,
        61649,
        7300,
        7319,
        4459,
        4592,
        4334,
        49,
        4614,
        7107,
        62003,
        7523,
        6327,
        62001,
        7311,
        4291,
        6203,
        6278,
        8000
    ]
    is_unexpected_fault = False
    unexpected_fault_id = None
    for fault_id in detected_fault_id:
        if fault_id in _default_white_fault_id:
            continue
        else:
            is_unexpected_fault = True
            unexpected_fault_id = fault_id
            break
    return is_unexpected_fault, unexpected_fault_id


def convert_list_to_string(para_list):
    para_str = ','.join(para_list)
    return para_str


def collect_required_logs_on_ir_of_pr808181(bts_ip, bts_user, bts_password, connection='ssh_gnb'):
    sshconn = ssh()
    try:
        sshconn.connect_to(hostname=bts_ip, username=bts_user, password=bts_password, alias=connection)
        conn = sshconn.invoke_shell()
        conn.send("scp -r /ffs/run/config/toor4nsn/dump_oip_signals.sh toor4nsn@fsp1_b:/tmp\n")
        time.sleep(2)
        print(f"1: {conn.recv(65535).decode('utf-8')}")
        conn.send("ssh toor4nsn@fsp1_b\n")
        time.sleep(2)
        print(f"2: {conn.recv(65535).decode('utf-8')}")
        conn.send("cd /tmp;ls -l\n")
        time.sleep(2)
        print(conn.recv(65535).decode('utf-8'))
        conn.send("chmod +x dump_oip_signals.sh\n")
        time.sleep(2)
        conn.send("./dump_oip_signals.sh > dump.txt\n")
        time.sleep(5)
        conn.send("cat dump.txt\n")
        time.sleep(5)
        print(conn.recv(65535).decode('utf-8'))
    except Exception as e:
        print(f"Error: {e}")
    finally:
        sshconn.disconnect(connection=connection)


def restart_fpga_on_ir_of_pr808181(bts_ip, bts_user, bts_password, connection='ssh_gnb'):
    sshconn = ssh()
    try:
        sshconn.connect_to(hostname=bts_ip, username=bts_user, password=bts_password, alias=connection)
        conn = sshconn.invoke_shell()
        conn.send("ssh toor4nsn@fsp1_a\n")
        time.sleep(2)
        print(f"1: {conn.recv(65535).decode('utf-8')}")
        conn.send("fsm_fpga_upgrade -reconfig\n")
        time.sleep(10)
        print(f"2: {conn.recv(65535).decode('utf-8')}")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        sshconn.disconnect(connection=connection)


def get_attached_nr_cell_id_on_ue(host, username, password, sn, alias='cell_pc'):
    """
    get nr cell id via command with PC on ue
    :param host: : pc_ip
    :param username: pc_username
    :param password: pc_password
    :para sn: UEs SN
    """
    nr_cell_info_on_ue = None
    sshconn = ''
    try:
        sshconn = ssh()
        sshconn.connect_to(hostname=host, username=username, password=password, alias=alias)
    except Exception as e:
        print('connection failed: {}'.format(e))
    else:
        sshconn.send_command(
            command='adb -s {} shell dumpsys telephony.registry | grep mServiceState | grep mNci'.format(sn),
            connection=alias)
        service_state = sshconn.read_output(connection=alias)
        pattern = r'mNci = \d+'
        print(service_state)
        match_result = re.findall(pattern=pattern, string=service_state)[0]
        nr_cell_info_on_ue = match_result.split('=')[1].strip()
        print(nr_cell_info_on_ue)
    finally:
        try:
            sshconn.disconnect(connection=alias)
        except UnboundLocalError:
            print('close failed')
    return nr_cell_info_on_ue


def set_diff_tput_variable(dl_tput, ul_tput):
    schedulWeight = [20, 10, 5, 1]
    dl_diff_tput_1 = [int(dl_tput * 0.45 * i / 36) for i in schedulWeight]
    dl_diff_tput_2 = [int(dl_tput * 0.55 * i / 36) for i in schedulWeight]
    check_dl_diff_tput = dl_diff_tput_1 + dl_diff_tput_2
    real_check_dl_diff_tput = [i * 0.8 for i in check_dl_diff_tput]
    dl_diff_tput = [str(i) + 'M' for i in check_dl_diff_tput]
    print(check_dl_diff_tput)
    print(dl_diff_tput)
    ul_diff_tput_1 = [int(ul_tput * 0.45 * i / 36) for i in schedulWeight]
    ul_diff_tput_2 = [int(ul_tput * 0.55 * i / 36) for i in schedulWeight]
    check_ul_diff_tput = ul_diff_tput_1 + ul_diff_tput_2
    ul_diff_tput = [i * 1000 for i in check_ul_diff_tput]
    real_check_ul_diff_tput = [float(tput) * 0.85 for tput in check_ul_diff_tput]
    print(check_ul_diff_tput)
    print(ul_diff_tput)
    print(real_check_ul_diff_tput)
    return dl_diff_tput, real_check_dl_diff_tput, ul_diff_tput, real_check_ul_diff_tput
