# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: 5G_SW_WRO
:contact: I_MBB_LTE_DEVWRO1_TEST_GMS <I_MBB_LTE_DEVWRO1_TEST@internal.nsn.com>
# """
import time
import paramiko
import zipfile
import logging
import os
import xml.etree.ElementTree as ET
from ta5g_admin_operations import ta_admin_interface
from ta5g_ue_mobility import ta5g_ue_mobility
from robot.errors import ExecutionFailed
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.admin import admin
from taf.transport.ssh import ssh


class GeneralException(Exception):
    pass


def intercell_handover_trigger_by_A3(ue_id=1, dst_cell=2, dst_phy_cell_id=51, meas_id=1):
    ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
    srsrp_part = 'srsrp_nr=11 srsrq_nr=11 ssinr_nr=11'
    nrsrp_part = 'nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30'
    logger.console("Performing intraENB handover to cell {} for UE {}".format(dst_cell, ue_id))
    ta5g_ue_wts.execute_egate_command(
        cmd='ue_measurement_send_nr id={} meas_id={} event=A3 {} phycell_id={} {}'.
        format(ue_id, meas_id, srsrp_part, dst_phy_cell_id, nrsrp_part),
        pass_regexp=r'UE{}: Intra-eNB handover from (EXT_)?ENB-.\.\d+ to (EXT_)?ENB-.\.{} performed'.format(
            ue_id, dst_cell), timeout=8)


def intercell_handover_loop(loop_num=16, delay=5):
    meas_id = 1
    for i in range(0, loop_num):
        intercell_handover_trigger_by_A3(dst_cell=2, dst_phy_cell_id=51, meas_id=meas_id)
        meas_id = meas_id + 2
        intercell_handover_trigger_by_A3(dst_cell=1, dst_phy_cell_id=50, meas_id=meas_id)
        meas_id = meas_id + 2
        time.sleep(delay)


def set_internal_traffic_type_to_multiple_ues(num_of_ues=6):
    for i in range(1, num_of_ues+1):
        ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
        pdu_id = (i - 1) % 15 + 1
        ta5g_ue_wts.execute_egate_command(
            cmd='set_pdu_param ue={} pdu={} trf_type=internal'.
            format(i, pdu_id))


def set_pdu_session_to_multiple_ues(num_of_ues=6):
    for i in range(1, num_of_ues+1):
        ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
        pdu_id = (i - 1) % 15 + 1
        ta5g_ue_wts.execute_egate_command(
            cmd='ue_pdu_session_setup ue={} pdu={} nwslice=1 gw={}'.
            format(i, pdu_id, i))


def start_data_traffic_to_multiple_ues(num_of_ues=6, tput=10, qfi=1):
    for i in range(1, num_of_ues+1):
        ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
        pdu_id = (i - 1) % 15 + 1
        ta5g_ue_wts.execute_egate_command(
            cmd='trf_data_start ue={} pdu={} qfi={} dir=dl mbps={}'.
            format(i, pdu_id, qfi, tput))
        ta5g_ue_wts.execute_egate_command(
            cmd='trf_data_start ue={} pdu={} qfi={} dir=ul mbps={}'.
            format(i, pdu_id, qfi, tput))


def change_rad_param_with_aashell(param, value):
    ssh = connect_ssh('192.168.255.129', 22, 'toor4nsn', 'oZPS0POrRieRtu')
    channel = ssh.invoke_shell()
    print(send_ssh_cmd('telnet 127.0.0.1 15007', channel))
    print(send_ssh_cmd('rad -mpw ' + param + ' ' + value, channel))
    ssh.close()


def check_that_l2hi_resources_are_not_used(used_cpnrt_resources):
    logger.console(used_cpnrt_resources)
    l2nrtpoollist_keys = ['allocatedNumOfPduSessions', 'allocatedNumOfBearers']
    if used_cpnrt_resources['activeUes'] != 0:
        raise GeneralException('Number of active ues is not 0, '
                               'actual value {}'.format(used_cpnrt_resources['activeUes']))
    for l2nrtpoollist in used_cpnrt_resources['l2NrtPoolList']:
        for key in l2nrtpoollist_keys:
            if l2nrtpoollist[key] != 0:
                raise GeneralException('{} is not 0, actual value {}'.format(key, l2nrtpoollist['key']))


def check_that_l2hi_resources_are_used(used_cpnrt_resources):
    logger.console(used_cpnrt_resources)
    l2nrtpoollist_keys = ['allocatedNumOfPduSessions', 'allocatedNumOfBearers']
    if used_cpnrt_resources['activeUes'] <= 0:
        raise GeneralException('Number of active ues is not greater than 0, '
                               'actual value {}'.format(used_cpnrt_resources['activeUes']))
    for key in l2nrtpoollist_keys:
        sum_of_values = 0
        for l2nrtpoollist in used_cpnrt_resources['l2NrtPoolList']:
            sum_of_values += l2nrtpoollist[key]
        if sum_of_values <= 0:
            raise GeneralException('{} is not greater than 0 , actual value {}'.format(key, sum_of_values))


def send_ssh_cmd(cmd, chann):
    chann.send(cmd + '\n')

    for _ in range(10):
        if chann.recv_ready():
            output = chann.recv(102400)
            return output
        else:
            time.sleep(2)
            # if not (chann.recv_ready()):
            #     break


def connect_ssh(ip, port, user, passw):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(ip, port, user, passw, allow_agent=False)
    return ssh


def trigger_radio_capability_and_check_reqexp():
    ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
    return ta5g_ue_wts.execute_egate_command(
        cmd='amf_ue_trigger_radio_capability_check id=1 ue=1 '
            'gnb=2 ue_radio_capability=none',
        pass_regexp='IMSVoiceSupportIndicator:SUPPORTED',
        fail_regexp='IMSVoiceSupportIndicator:NOT-SUPPORTED', timeout='20s')


def check_cell_is_in_given_procedural_status(cell_status, timeout='480'):
    time_step = 10
    timeout = int(timeout)
    time_start = time.time()
    while time.time() < time_start + timeout:
        with ta_admin_interface.admin_interface() as admin_client:
            for cell in admin_client.get_cells_info():
                logger.info('\nTime: {} ;Expected proceduralStatus cell status: {} ; '
                            'Current proceduralStatus cell status: {}'.
                            format(str(time.ctime(int(time.time()))), cell_status,
                                   cell['status']['proceduralStatus']), also_console=True)
                if cell_status in cell['status']['proceduralStatus']:
                    return True
            time.sleep(time_step)
    raise ExecutionFailed(message="Cell is not in expected status!")


def check_bts_is_in_given_state(bts_state, timeout='480'):
    time_step = 10
    timeout = int(timeout)
    time_start = time.time()
    while time.time() < time_start + timeout:
        with ta_admin_interface.admin_interface() as admin_client:
            bts_info = admin_client.get_mrbts_state()
            logger.info('\nTime: {} ; Expected BTS state: {} ; Current BTS state: {}'.
                        format(str(time.ctime(int(time.time()))), bts_state, bts_info), also_console=True)
            if bts_info in bts_state:
                return True
            time.sleep(time_step)
    raise ExecutionFailed(message="BTS is not in expected status!")


def deregister_multiple_ues(first_ue_id, last_ue_id):
    ta5g = BuiltIn().get_library_instance('ta5g_ue_mobility')
    for ue_id in range(int(first_ue_id), int(last_ue_id) + 1):
        ta5g.deregister_ue(ue_id)


def attach_nsa_ue_with_sgnb_addition(ue_id=11, bearer=2, cell_id=1, enb_id=2):
    ta5g_ue_mobility().attach_ue_to_enb(
        ue_id=ue_id,
        pass_regexp='UE{}: === UE IS ACTIVE'.format(ue_id)
    )
    ta5g_ue_mobility().start_gnb_addition_procedure(
        ue=ue_id,
        target_gnb=enb_id,
        target_cells=cell_id,
        bearer=bearer,
        dc_type='split_scg',
        pass_regexp=r'UE{}: Proxy [(]eNB \d+ cell \d+[)] reported successful RA'.format(ue_id)
    )


def attach_multiple_nsa_ues_with_sgnb_addition(first_ue_id=11, number_of_ues=3, bearer=2, cell_id=1, enb_id=2):
    """
    :param number_of_ues: (str, int)
    :param bearer: (int)
    :param enb_id: (int)
    """
    number_of_ues = int(number_of_ues)
    first_ue_id = int(first_ue_id)
    for ue_id in range(first_ue_id, first_ue_id + number_of_ues):
        attach_nsa_ue_with_sgnb_addition(ue_id=ue_id, bearer=bearer, cell_id=cell_id, enb_id=enb_id)


def start_data_traffic_to_multiple_nsa_ues(first_ue_id=11, last_ue_id=14, bearer_id=2, direction='dl', throughput=10):
    for i in range(int(first_ue_id), int(last_ue_id) + 1):
        ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
        ta5g_ue_wts.execute_egate_command(
            cmd='trf_data_start ue={} id={} dir={} mbps={}'.
            format(i, int(bearer_id), direction, int(throughput)))


def check_for_an_unexpected_alarm():
    failure_alarms_list = [7116, 4539, 6450, 4383]
    api = admin()
    connection = api.connect_to(bts_host='192.168.255.129')
    alarms = connection.get_historical_alarms()
    alarms_list = []
    for alarm in alarms:
        if alarm["severity"] == "Critical" or alarm["severity"] == "Major":
            logger.info(alarm)
            alarms_list.append(alarm['faultId'])
    if any(i in alarms_list for i in failure_alarms_list):
        raise ExecutionFailed(message="An unexpected fault occurred!")
    connection.teardown_admin()


def extract_snapshot(snapshot_dir):
    if not os.path.exists(snapshot_dir):
        raise FileNotFoundError("Directory '{}' does not exist.".format(snapshot_dir))

    zip_file = None
    for file in os.listdir(snapshot_dir):
        if file.endswith(".zip"):
            zip_file = os.path.join(snapshot_dir, file)
            break

    if zip_file is None:
        raise FileNotFoundError("No .zip file found in directory '{}'.".format(snapshot_dir))

    extraction_path = os.path.join(snapshot_dir, "snapshot")
    if not os.path.exists(extraction_path):
        os.makedirs(extraction_path)

    with zipfile.ZipFile(zip_file, 'r') as f:
        f.extractall(extraction_path)

    logging.info("Snapshot files extracted to path: {}".format(extraction_path))
    return extraction_path


def find_file_in_snapshot(snapshot_file_list_path, file_to_find):
    found = False
    file = open(snapshot_file_list_path, 'r')
    for line_number, line in enumerate(file, 1):
        if file_to_find in line:
            print(f"File found in '{snapshot_file_list_path}' at line {line_number}:")
            print(line.strip())
            found = True
    if not found:
        raise ExecutionFailed(message="File: {} not found in Snapshot".format(file_to_find))


def check_cell_list():
    ta5g_pm = BuiltIn().get_library_instance('ta5g_cell_operations')
    cell_list = ta5g_pm.get_list_of_all_cells_ids()
    return len(cell_list)


def replace_gscn(file_path, *gscn_values):
    tree = ET.parse(file_path)
    root = tree.getroot()

    gscn_elements = root.findall('.//GSCN')

    for index, gscn in enumerate(gscn_elements[:len(gscn_values)]):
        gscn.text = gscn_values[index]

    tree.write(file_path)


def get_addr_from_tl_init_file():
    tl = BuiltIn().get_variable_value('${tl}')
    addr_value = tl.test_pc.default_ssh_connection_details.addr
    return addr_value


def add_qos_to_ue(ue_id, qos_to_add):
    ta5g = BuiltIn().get_library_instance('ta5g_ue_mobility')
    qos_to_add_table = qos_to_add.split(", ")
    for qos in qos_to_add_table:
        ta5g.modify_pdu_session(ue_id=ue_id, qos_to_add=qos)
        time.sleep(2)
