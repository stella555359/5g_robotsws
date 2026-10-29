import os
import re
import shutil
import time
from pathlib import Path

from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from taf.hw.rf_attenuator import rf_attenuator
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.sw.dcap.rd.interface import rd
from taf.transport.ssh import ssh
from taf.ue import ue

from test_variables_cloud import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager import DCAPManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.log_profile import LogProfile
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.webemil_parser import decode_emil_and_save_as_json, \
    parse_msg_list_from_json_file
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.pcap_reader import load_pcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.TafUe import TafUe
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

_taf_ue = TafUe(verbose=True)
_elt = EltLogCollector()
_builtin = BuiltIn()
_rd = rd()
cu_object = cu()
_dm = DCAPManager()
_ute_ue = ue()
du_object = vdu()
vdu_object = vdu()
_ssh = ssh()
_tl = TestlineConfiguration()
_attenuator = rf_attenuator()
dcap_gnb_cell_data = {'10.42.38.209': [504],
                      '10.42.38.208': [604]}
ELT_LOG_NAME = 'elt_log.json'
sib_validation_re = re.compile(r"nr-rrc\.plmn_IdentityList_tree.*?nr-rrc\.cellReservedForOperatorUse': '"
                               r"(?P<item0>\d)'}}.*?nr-rrc\.cellReservedForOperatorUse': '(?P<item1>\d)'}")
dcap_alias = 'test_logs_dcap'

_vcu_log_profile = LogProfile().with_vcu_snapshot().with_vcu_syslog()
_vdu_log_profile = LogProfile().with_vdu_snapshot().with_vdu_cplane().with_vdu_syslog()
traces = {'vcu': {'log_profile': _vcu_log_profile,
                  'trace_id': '',
                  'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                  'stop_trace_name': 'dcap_vcu_stop_trace',
                  'download_log_name': 'dcap_collect_vcu_log',
                  'cells': ['4', '40']},
          'vdu_1': {'log_profile': _vdu_log_profile,
                    'trace_id': '',
                    'mplane': _tl.get_du_oam_connection_details(0, 0)['hostname'],
                    'stop_trace_name': 'dcap_vdu_1_stop_trace',
                    'download_log_name': 'dcap_collect_vdu_1_log',
                    'cells': ['40']},
          'vdu_2': {'log_profile': _vdu_log_profile,
                    'trace_id': '',
                    'mplane': _tl.get_du_oam_connection_details(0, 1)['hostname'],
                    'stop_trace_name': 'dcap_vdu_2_stop_trace',
                    'download_log_name': 'dcap_collect_vdu_2_log',
                    'cells': ['4']},
          }
trace2 = {'vcu': {'log_profile': _vcu_log_profile,
                  'trace_id': '',
                  'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                  'stop_trace_name': 'dcap_vcu_stop_trace',
                  'download_log_name': 'dcap_collect_vcu_log',
                  'cells': ['6']},
          'vdu_2': {'log_profile': _vdu_log_profile,
                    'trace_id': '',
                    'mplane': _tl.get_du_oam_connection_details(0, 1)['hostname'],
                    'stop_trace_name': 'dcap_vdu_2_stop_trace',
                    'download_log_name': 'dcap_collect_vdu_2_log',
                    'cells': ['6']},
          }


def prepare_emil_logs():
    file_path = get_path()
    find_emil_files_in_subfolders(file_path)
    decoded_emil_files = decode_emil_and_save_as_json(file_path, "10.42.194.122", "9443")
    log_info_to_console(decoded_emil_files)


def analyze_emil_log(pattern):
    folder_path = get_path()
    emil_files = [file for file in os.listdir(folder_path) if file.endswith('.json') and 'session' in file]
    found_messages = []
    for file in emil_files:
        json_data = parse_msg_list_from_json_file(f"{folder_path}/{file}")
        msg_found_in_file = _find_messages_in_json(json_data, pattern, file)
        if msg_found_in_file:
            found_messages.append(msg_found_in_file)
    if not found_messages:
        raise Exception(pattern, "Not Found!")
    else:
        log_info_to_console(found_messages)


def _find_messages_in_json(json_data, pattern, file):
    for msg in json_data:
        if msg['Message_name'] == 'SctpMessage':
            msg = str(msg)
            found = re.search(pattern, msg)
            if found:
                return f"{pattern} was found in {file}"


def setup_vdu_parameters(feature_state):
    if feature_state == "ENABLED":
        du_object.connect_to(host="10.42.38.209", port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        du_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-40",
                                                    parameter="actCsiImRandomizationFddNonDss",
                                                    operation="update",
                                                    value="true")
        du_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-40",
                                                    parameter="timeRestrictionForIntfMeas",
                                                    operation="update",
                                                    value="configured")
        du_object.connect_to(host="10.42.38.208", port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        du_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-4",
                                                    parameter="actCsiImRandomizationFddNonDss",
                                                    operation="update",
                                                    value="true")
        du_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-4",
                                                    parameter="timeRestrictionForIntfMeas",
                                                    operation="update",
                                                    value="configured")
    else:
        du_object.connect_to(host="10.42.38.209", port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        du_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-40",
                                                    parameter="timeRestrictionForIntfMeas",
                                                    operation="update",
                                                    value="notConfigured")
        du_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-40",
                                                    parameter="actCsiImRandomizationFddNonDss",
                                                    operation="update",
                                                    value="false")
        du_object.connect_to(host="10.42.38.208", port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        du_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-4",
                                                    parameter="timeRestrictionForIntfMeas",
                                                    operation="update",
                                                    value="notConfigured")
        du_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505/NRCELL-4",
                                                    parameter="actCsiImRandomizationFddNonDss",
                                                    operation="update",
                                                    value="false")
    du_object.disconnect(timeout=10)
    time.sleep(20)


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def setup_attenuator():
    yaml_file = _builtin.get_variable_value("${ABSTRACT_LIB_CONFIG}")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells('90dB')


def collect_snapshot_for_cloud_tl():
    for tl_ip in snapshot_vCU_vDU1_vDU_2:
        cu_object.connect_to(host=tl_ip, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        cu_object.get_plan_info()
        output_dir = get_robot_variable('OUTPUT_DIR')
        cu_object.get_local_snapshot(output_dir, request_timeout=None, operation_timeout=600.0, connection=None)
        cu_object.disconnect(connection=None, timeout=10)


def verify_uplink_and_downlink_throughput(tput, feature_state, log_path, ue1, ue2):
    time.sleep(5)
    _ute_ue.start_data_transfer(dt_name="UL1", ue_alias=ue1, direction='ul',
                                duration='20s', throughput=tput, packet_size='1400')
    _ute_ue.start_data_transfer(dt_name="DL1", ue_alias=ue1, direction='dl',
                                duration='20s', throughput=tput, packet_size='1400')
    _ute_ue.start_data_transfer(dt_name="UL2", ue_alias=ue2, direction='ul',
                                duration='20s', throughput=tput, packet_size='1400')
    _ute_ue.start_data_transfer(dt_name="DL2", ue_alias=ue2, direction='dl',
                                duration='20s', throughput=tput, packet_size='1400')

    _ssh.connect_to(hostname=CONFIGS[list(CONFIGS)[0]]['VM_IP'], username='core', password='system123')
    _ssh.send_command(L1L2_SERVER, get_pty=True)
    time.sleep(5)
    _ssh.send_command(L1L2_CLIENT, get_pty=True)
    time.sleep(5)
    _ssh.send_command(L1L2_TERMINATE, get_pty=True)

    _ute_ue.await_data_transfer_finish(dt_name="UL1")
    _ute_ue.await_data_transfer_finish(dt_name="DL1")
    _ute_ue.await_data_transfer_finish(dt_name="UL2")
    _ute_ue.await_data_transfer_finish(dt_name="DL2")

    _ute_ue.stop_data_transfer(dt_name="UL1")
    _ute_ue.stop_data_transfer(dt_name="DL1")
    _ute_ue.stop_data_transfer(dt_name="UL2")
    _ute_ue.stop_data_transfer(dt_name="DL2")

    _ssh.send_command(f"sshpass -p 'ute' scp '/var/home/core/l2rt-l1upbiprt-l2biprt.pcap'"
                      f" ute@10.42.194.122:{log_path}/{feature_state}")
    time.sleep(50)
    _ssh.send_command("sudo rm l2rt-l1upbiprt-l2biprt.pcap")
    _ssh.send_command(L1L2_SERVER, get_pty=True)


def trigger_retransmissions(tput, ue):
    logger.info(f"Triggering retransmissions {SOURCE_CELL}", also_to_console=True)
    _ute_ue.start_data_transfer(dt_name="UL1", ue_alias=ue, direction='ul',
                                duration='60s', throughput=tput, packet_size='1400')
    _ute_ue.start_data_transfer(dt_name="DL1", ue_alias=ue, direction='dl',
                                duration='60s', throughput=tput, packet_size='1400')
    try:
        for value in range(MIN_ATTENUATION, MAX_ATTENUATION + 1, ATTENUATION_STEP):
            attenuate_cell(SOURCE_CELL, value)
            time.sleep(2)
    finally:
        _ute_ue.stop_data_transfer(dt_name="UL1")
        _ute_ue.stop_data_transfer(dt_name="DL1")
        attenuate_cell(SOURCE_CELL, 30)


def merge_syslog():
    file_path = get_path()
    path = file_path + "/btslog/btslogs_merged"
    log_files = [f for f in os.listdir(file_path + "/btslog/") if f.endswith(('.LOG', '.log'))]
    log_files_iter = iter(log_files)
    if len(log_files) == 0:
        raise ValueError('Should be minimum one LOG file in the current directory.')
    if not os.path.exists(path):
        os.mkdir(path)
    with open(os.path.join(path, "btslog.LOG"), 'w') as f:
        while True:
            try:
                iterator = next(log_files_iter)
                for line in _file_reader(file_path + "/btslog/" + iterator):
                    f.write(line)
            except StopIteration:
                break


def verify_syslog(parameters):
    file_path = get_path()
    for key, value in parameters.items():
        matches = False
        for line in _file_reader("{}{}".format(file_path, "/btslog/btslogs_merged/btslog.LOG")):
            if re.search(value, line):
                matches = True
        if matches is False:
            raise Exception(f'{key} not found in Syslog')


def initialize_attenuators():
    for idx, atten in enumerate(TestlineConfiguration().tl_init.attenuators):
        logger.info(f"Initializing attenuator {atten.ip_addr}", also_to_console=True)
        _attenuator.setup_attenuator(atten, alias=f"atten_{idx}")
        _attenuator.set_ports_attenuation(atten.attenuation_port_numbers, [90] * len(atten.attenuation_port_numbers),
                                          confirm=True, attenuator_device=f"atten_{idx}")


def attenuate_cell(cell_id, value):
    cell = CELL_PORTS[cell_id]
    _attenuator.set_ports_attenuation(cell['ports'], [value] * len(cell['ports']), confirm=True,
                                      attenuator_device=f"atten_{cell['attenuator_id']}")


def find_syslog_files_from_utf():
    file_path = get_path()
    dest_dir = os.path.join(file_path, 'btslog')
    Path(dest_dir).mkdir(exist_ok=True)
    for dirpath, dirnames, filenames in os.walk(file_path):
        for filename in filenames:
            if 'syslog' in filename:
                file_path = os.path.join(dirpath, filename)
                shutil.move(file_path, os.path.join(dest_dir, filename))


def convert_to_json_and_verify_num_of_prbs(pcap_path, output_json_path, target_num_prb, target_num_mcs, prb_p, mcs_p):
    tshark_filter = ('UlData_puschReceiveReqGrant_t.numOfPrb', 'UlData_puschReceiveReqGrant_t.mcs')
    log_info_to_console(f"Converting pcap to json")
    json_file = load_pcap(pcap_path, tshark_fields=tshark_filter, output_json_file=output_json_path)
    numofprb_list = []
    numofmcs_list = []
    for msg in json_file:
        if msg['_source']['layers']:
            mcs = int(msg['_source']['layers']['UlData_puschReceiveReqGrant_t.mcs'][0])
            numofprb = int(msg['_source']['layers']['UlData_puschReceiveReqGrant_t.numOfPrb'][0])
            numofprb_list.append(numofprb)
            numofmcs_list.append(mcs)
    num_prb_percent = int((numofprb_list.count(int(target_num_prb)) / len(numofprb_list)) * 100)
    log_info_to_console(f"Percentage of {target_num_prb} in numOfPrb:{num_prb_percent}%")
    assert num_prb_percent >= prb_p, f"90% of numOfPrb should be equal to {target_num_prb}. Result = {num_prb_percent}%"
    num_mcs_percent = int((numofprb_list.count(int(target_num_prb)) / len(numofprb_list)) * 100)
    log_info_to_console(f"Percentage of {target_num_mcs} in numOfMcs:{num_mcs_percent}%")
    assert num_mcs_percent >= mcs_p, f"90% of numOfMcs should be equal to {target_num_mcs}. Result = {num_mcs_percent}%"


def verify_syslog(parameters):
    file_path = get_path()
    for key, value in parameters.items():
        matches = False
        for line in _file_reader("{}{}".format(file_path, "/btslog/btslogs_merged/btslog.LOG")):
            if re.search(value, line):
                matches = True
        if matches is False:
            raise Exception(f'{key} not found in Syslog')


def _file_reader(filename):
    with open(filename, 'r') as f:
        for line in f:
            yield line


def start_utf_tracing():
    _dm.connect_to(port='9443', user=None, passwd=None)
    global traces
    for trace, params in traces.items():
        params['trace_id'] = _dm.start_new_trace(mplane=params['mplane'], log_profile=params['log_profile'],
                                                 nr_cells=params['cells'])


def teardown_utf():
    _dm.teardown()


def stop_utf_tracing():
    output_dir = get_path()
    for trace, params in traces.items():
        _dm.stop_trace(params['trace_id'])
        _dm.download_logs(params['trace_id'], target_dir=output_dir)


def unzip_results():
    file_path = get_path()
    zip_files = [file for file in os.listdir(file_path) if file.endswith('.zip')]
    for zip_file in zip_files:
        shutil.unpack_archive(os.path.join(file_path, zip_file), file_path)


def find_emil_files_in_subfolders(file_path):
    count = 1
    for root, _, files in os.walk(file_path):
        for file in files:
            if file.endswith(".5gm"):
                emil_file_path = os.path.join(root, file)
                new_file_name = f"{file_path.rpartition('/')[2]}_{count}.5gm"
                shutil.copy(emil_file_path, os.path.join(file_path, new_file_name))
                count += 1
