import os
import re
import shutil
import time
import xml.etree.ElementTree as ET
from pathlib import Path

from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from taf.hw.rf_attenuator import rf_attenuator
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.sw.dcap.rd.interface import rd
from taf.transport.ssh import ssh

from test_constants import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.cloud.admin import vcu_context, vdu_context
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager import DCAPManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.log_profile import LogProfile
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.webemil_parser import decode_emil_and_save_as_json, \
    parse_msg_list_from_json_file
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.TafUe import TafUe
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

_rd = rd()
_ssh = ssh()
sw_version = ""
cu_object = cu()
du_object = vdu()
vdu_object = vdu()
_dm = DCAPManager()
_builtin = BuiltIn()
_elt = EltLogCollector()
_attenuator = rf_attenuator()
_tl = TestlineConfiguration()
_taf_ue = TafUe(verbose=True)
ELT_LOG_NAME = 'elt_log.json'
dcap_alias = 'test_logs_dcap'
_vcu_log_profile = LogProfile().with_vcu_snapshot().with_vcu_syslog()
_vdu_log_profile = LogProfile().with_vdu_snapshot().with_vdu_cplane().with_vdu_syslog()
traces_trunk = {'vcu': {'log_profile': _vcu_log_profile,
                        'trace_id': '',
                        'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                        'stop_trace_name': 'dcap_vcu_stop_trace',
                        'download_log_name': 'dcap_collect_vcu_log',
                        'cells': ['4']},
                'vdu_2': {'log_profile': _vdu_log_profile,
                          'trace_id': '',
                          'mplane': _tl.get_du_oam_connection_details(0, 1)['hostname'],
                          'stop_trace_name': 'dcap_vdu_2_stop_trace',
                          'download_log_name': 'dcap_collect_vdu_2_log',
                          'cells': ['4']},
                }
traces_branch = {'vcu': {'log_profile': _vcu_log_profile,
                         'trace_id': '',
                         'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                         'stop_trace_name': 'dcap_vcu_stop_trace',
                         'download_log_name': 'dcap_collect_vcu_log',
                         'cells': ['100']},
                 'vdu_1': {'log_profile': _vdu_log_profile,
                           'trace_id': '',
                           'mplane': _tl.get_du_oam_connection_details(0, 1)['hostname'],
                           'stop_trace_name': 'dcap_vdu_2_stop_trace',
                           'download_log_name': 'dcap_collect_vdu_2_log',
                           'cells': ['100']},
                 }


def setup_vdu_parameters(mo_info_list, host):
    log_info_to_console(mo_info_list)
    du_object.connect_to(host=host, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
    du_object.provision_vdu_delta_plan(mo_info_list=mo_info_list)
    du_object.disconnect(timeout=10)
    time.sleep(20)


def setup_vcu_parameters(mo_info_list, host):
    cu_object.connect_to(host=host, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
    cu_object.provision_vcu_delta_plan(mo_info_list=mo_info_list)
    time.sleep(10)
    cu_object.disconnect(connection=None, timeout=10)


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def collect_snapshot_for_cloud_tl():
    for tl_ip in snapshot_vCU_vDU1_vDU_2:
        cu_object.connect_to(host=tl_ip, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        cu_object.get_plan_info()
        output_dir = get_robot_variable('OUTPUT_DIR')
        cu_object.get_local_snapshot(output_dir, request_timeout=None, operation_timeout=600.0, connection=None)
        cu_object.disconnect(connection=None, timeout=10)


def _file_reader(filename):
    with open(filename, 'r') as f:
        for line in f:
            yield line


def teardown_utf():
    _dm.teardown()


def stop_utf_tracing():
    output_dir = get_path()
    if sw_version == "CU26R1_":
        for trace, params in traces_branch.items():
            _dm.stop_trace(params['trace_id'])
            _dm.download_logs(params['trace_id'], target_dir=output_dir)
    elif sw_version == "CU26R2_":
        for trace, params in traces_trunk.items():
            _dm.stop_trace(params['trace_id'])
            _dm.download_logs(params['trace_id'], target_dir=output_dir)


def unzip_results():
    file_path = get_path()
    zip_files = [file for file in os.listdir(file_path) if file.endswith('.zip')]
    for zip_file in zip_files:
        shutil.unpack_archive(os.path.join(file_path, zip_file), file_path)


def list_to_dict(lst):
    it = iter(lst)
    return dict(zip(it, it))


def collect_and_verify_vdu_pm_counters(counters):
    if sw_version == "CU26R1_":
        du_object.connect_to(host='10.42.38.213', port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        for counter_id in counters:
            if counter_id == "M55331C00004":
                pm_data = du_object.get_counter_values(counter_id=counter_id,
                                                       dimension_dn='MRBTS-8674/NRBTS-8674/NRCELL-100')
            else:
                pm_data = du_object.get_counter_values(counter_id=counter_id,
                                                       dimension_dn='MRBTS-8674/NRBTS-8674/NRDU-1')
            counters[counter_id] = pm_data
            log_info_to_console(pm_data)
            check_value_difference(pm_data)
    elif sw_version == "CU26R2_":
        du_object.connect_to(host='10.42.38.208', port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        for counter_id in counters:
            if counter_id == "M55331C00004":
                pm_data = du_object.get_counter_values(counter_id=counter_id,
                                                       dimension_dn='MRBTS-8505/NRBTS-8505/NRCELL-2')
            else:
                pm_data = du_object.get_counter_values(counter_id=counter_id,
                                                       dimension_dn='MRBTS-8505/NRBTS-8505/NRDU-1')
            counters[counter_id] = pm_data
            log_info_to_console(pm_data)
            check_value_difference(pm_data)
    du_object.disconnect(timeout=10)


def collect_and_verify_vcu_pm_counters(counters):
    if sw_version == "CU26R1_":
        cu_object.connect_to(host='10.42.93.161', port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        for counter_id in counters:
            pm_data = cu_object.get_counter(measurement_id=None, counter_id=counter_id,
                                            dimension_dist_name='MRBTS-8674/NRBTS-8674/NRCELL-100')
            counters[counter_id] = pm_data
            log_info_to_console(pm_data)
            check_value_difference(pm_data['values'])
    elif sw_version == "CU26R2_":
        cu_object.connect_to(host='10.42.93.184', port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        for counter_id in counters:
            pm_data = cu_object.get_counter(measurement_id=None, counter_id=counter_id,
                                            dimension_dist_name='MRBTS-8505/NRBTS-8505/NRCELL-2')
            counters[counter_id] = pm_data
            log_info_to_console(pm_data)
            check_value_difference(pm_data['values'])
    cu_object.disconnect(timeout=10)


def check_value_difference(data):
    has_different_value = False

    for value_entry in data:
        if value_entry['value'] != '0':
            has_different_value = True
            log_info_to_console(f"Difference found: {value_entry}")
    if has_different_value:
        log_info_to_console("PASS: Found a value different than '0'.")
    else:
        log_info_to_console("FAIL: All values are '0'.")
        raise Exception(f'All values are 0, please check WebEM')


def setup():
    sw_verification()
    initialize_attenuators()
    deattenuate_source_cell()
    if sw_version == "CU26R1_":
        with vcu_context() as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml')
        with vdu_context(1) as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vdu.xml')
    elif sw_version == "CU26R2_":
        with vcu_context() as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml')
        with vdu_context(1) as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vdu2.xml')
        with vdu_context(0) as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vdu1.xml')


def sw_verification():
    with vcu_context() as admin:
        file_path = Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml'
        admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml')
        xml_tree = ET.parse(file_path)
        xml_root = xml_tree.getroot()
        patterns = [r"CU26R1_", r"CU26R2_"]
        for pattern in patterns:
            matched = re.findall(pattern, ET.tostring(xml_root, encoding='unicode'))
            if matched:
                logger.info(f"{pattern} was found!", also_to_console=True)
                global sw_version
                sw_version = pattern
        if sw_version:
            return True
        else:
            raise AssertionError("SW version not found!")


def initialize_attenuators():
    for idx, atten in enumerate(TestlineConfiguration().tl_init.attenuators):
        logger.info(f"Initializing attenuator {atten.ip_addr}", also_to_console=True)
        _attenuator.setup_attenuator(atten, alias=f"atten_{idx}")
        _attenuator.set_ports_attenuation(atten.attenuation_port_numbers, [90] * len(atten.attenuation_port_numbers),
                                          confirm=True, attenuator_device=f"atten_{idx}")


def deattenuate_source_cell():
    if sw_version == "CU26R1_":
        logger.info(f"Deattenuating source cell (pci={BRANCH_SOURCE_CELL}) to {MIN_ATTENUATION}db",
                    also_to_console=True)
        _attenuate_cell(BRANCH_SOURCE_CELL, MIN_ATTENUATION)
    elif sw_version == "CU26R2_":
        logger.info(f"Deattenuating source cell (pci={TRUNK_SOURCE_CELL}) to {MIN_ATTENUATION}db",
                    also_to_console=True)
        _attenuate_cell(TRUNK_SOURCE_CELL, MIN_ATTENUATION)


def _attenuate_cell(cell_id, value):
    cell = CELL_PORTS[cell_id]
    _attenuator.set_ports_attenuation(cell['ports'], [value] * len(cell['ports']), confirm=True,
                                      attenuator_device=f"atten_{cell['attenuator_id']}")


def start_tracing():
    start_utf_tracing()


def trigger_attach():
    _taf_ue.attach_ue('UE_1')


def trigger_detach():
    _taf_ue.detach_ue('UE_1')


def stop_tracing():
    stop_utf_tracing()


def stop_elt_tracing(output_dir):
    output_dir = Path(output_dir)
    elt_path = str(output_dir / ELT_LOG_NAME)
    _elt.stop_log_collecting()
    _elt.download_log(elt_path)


def find_syslog_files_from_utf():
    file_path = get_path()
    dest_dir = os.path.join(file_path, 'btslog')
    Path(dest_dir).mkdir(exist_ok=True)
    for dirpath, dirnames, filenames in os.walk(file_path):
        for filename in filenames:
            if 'syslog' in filename:
                file_path = os.path.join(dirpath, filename)
                shutil.move(file_path, os.path.join(dest_dir, filename))
                log_info_to_console(f'Moved {file_path} to {dest_dir}')


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


def detach():
    _taf_ue.detach_ue('UE_1', ignore_error=True)


def teardown_elt():
    _elt.shutdown()


def start_utf_tracing():
    _dm.connect_to(port='9443', user=None, passwd=None)
    if sw_version == "CU26R1_":
        global traces_branch
        for trace, params in traces_branch.items():
            params['trace_id'] = _dm.start_new_trace(mplane=params['mplane'], log_profile=params['log_profile'],
                                                     nr_cells=params['cells'])
    elif sw_version == "CU26R2_":
        global traces_trunk
        for trace, params in traces_trunk.items():
            params['trace_id'] = _dm.start_new_trace(mplane=params['mplane'], log_profile=params['log_profile'],
                                                     nr_cells=params['cells'])


def prepare_emil_logs():
    file_path = get_path()
    find_emil_files_in_subfolders(file_path)
    decoded_emil_files = decode_emil_and_save_as_json(file_path, "10.42.194.122", "9443")
    log_info_to_console(decoded_emil_files)


def find_emil_files_in_subfolders(file_path):
    count = 1
    for root, _, files in os.walk(file_path):
        for file in files:
            if file.endswith(".5gm"):
                emil_file_path = os.path.join(root, file)
                new_file_name = f"{file_path.rpartition('/')[2]}_{count}.5gm"
                shutil.copy(emil_file_path, os.path.join(file_path, new_file_name))
                count += 1


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


def analyze_emil_logs():
    prepare_emil_logs()
    analyze_emil_log(qos1)
    analyze_emil_log(qos1_1)
    analyze_emil_log(qos2)
    analyze_emil_log(qos2_1)
    analyze_emil_log(f1)
    analyze_emil_log(rrc)


def analyze_syslog():
    find_syslog_files_from_utf()
    merge_syslog()
    verify_syslog(RAN_PAG)
