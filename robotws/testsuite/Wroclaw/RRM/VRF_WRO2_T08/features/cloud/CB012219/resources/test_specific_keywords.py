import json
import os
import re
import shutil
import xml.etree.ElementTree as ET
from pathlib import Path

from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from taf.hw.rf_attenuator import rf_attenuator

from test_constants import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.cloud.admin import vcu_context, vdu_context
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager import DCAPManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.log_profile import LogProfile
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.TafUe import TafUe
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

_cu = cu()
_vdu = vdu()
_taf_ue = TafUe(verbose=True)
_elt = EltLogCollector()
_dm = DCAPManager()
_attenuator = rf_attenuator()
_tl = TestlineConfiguration()
_vcu_log_profile = LogProfile().with_vcu_snapshot().with_tracer_vcu().with_vcu_syslog()

sw_version = ""
traces_trunk = {'vcu': {'log_profile': _vcu_log_profile,
                        'trace_id': '',
                        'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                        'stop_trace_name': 'dcap_vcu_stop_trace',
                        'download_log_name': 'dcap_collect_vcu_log',
                        'cells': ['4', '5']}
                }
traces_branch = {'vcu': {'log_profile': _vcu_log_profile,
                         'trace_id': '',
                         'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                         'stop_trace_name': 'dcap_vcu_stop_trace',
                         'download_log_name': 'dcap_collect_vcu_log',
                         'cells': ['100']}
                 }


def setup():
    sw_verification()
    initialize_attenuators()
    deattenuate_source_cell()
    if sw_version == "CU26R1_":
        with vcu_context() as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml')
        with vdu_context(0) as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vdu1.xml')
    elif sw_version == "CU26R2_":
        with vcu_context() as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml')
        with vdu_context(0) as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vdu1.xml')
        with vdu_context(1) as admin:
            admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vdu2.xml')


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


def start_elt_tracing():
    if sw_version == "CU26R1_":
        logger.info(f"Setup ELT: {ELT_CONFIG_BRANCH}", also_to_console=True)
        _elt.setup(with_upload=True, configuration=ELT_CONFIG_BRANCH)
    elif sw_version == "CU26R2_":
        logger.info(f"Setup ELT: {ELT_CONFIG_TRUNK}", also_to_console=True)
        _elt.setup(with_upload=True, configuration=ELT_CONFIG_TRUNK)
    _elt.set_logging_filter()
    _elt.start_log_collecting()


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


def stop_tracing():
    stop_utf_tracing()


def stop_elt_tracing(output_dir):
    output_dir = Path(output_dir)
    elt_path = str(output_dir / ELT_LOG_NAME)
    _elt.stop_log_collecting()
    _elt.download_log(elt_path)


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


def run_ue_traffic():
    start_elt_tracing()
    _taf_ue.attach_ue('UE_1')
    output_dir = Path(get_robot_variable('OUTPUT_DIR'))
    stop_elt_tracing(output_dir)
    _taf_ue.start_tput_on_ue('UE_1', 'DL', 60, 'udp')
    _taf_ue.await_tput_end('UE_1')
    if sw_version == "CU26R1_":
        _taf_ue.verify_tput('UE_1', 'DL', '120Mbits/sec', omit=40)
    elif sw_version == "CU26R2_":
        _taf_ue.verify_tput('UE_1', 'DL', '180Mbits/sec', omit=40)


def detach():
    _taf_ue.detach_ue('UE_1', ignore_error=True)


def check_elt_log_for_integrity_protection_algorithm():
    elt_log_filepath = Path(get_robot_variable('OUTPUT_DIR')) / ELT_LOG_NAME
    with open(elt_log_filepath, 'r') as f:
        log = json.load(f)
        found_msg = False
        for msg in log:
            if msg['name'] == 'SecurityModeCommand':
                entry = msg['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']['nr-rrc.message_tree'][
                        'nr-rrc.c1_tree']['nr-rrc.securityModeCommand_element']['nr-rrc.criticalExtensions_tree'][
                        'nr-rrc.securityModeCommand_element']['nr-rrc.securityConfigSMC_element'][
                        'nr-rrc.securityAlgorithmConfig_element']
                assert entry['nr-rrc.cipheringAlgorithm'] == '2', \
                    f"cipheringAlgorithm == {entry['nr-rrc.cipheringAlgorithm']}, expected == 2"
                assert entry['nr-rrc.integrityProtAlgorithm'] == '2', \
                    f"integrityProtAlgorithm == {entry['nr-rrc.integrityProtAlgorithm']}, expected == 2"
                found_msg = True
        assert found_msg, "No 'SecurityModeCommand' msg found in ELT log!"
    logger.info("IntegrityProtection correctly enabled in ELT log!", also_to_console=True)


def teardown_elt():
    _elt.shutdown()


def teardown_dcap():
    _dm.teardown()


def unzip_results():
    file_path = get_path()
    zip_files = [file for file in os.listdir(file_path) if file.endswith('.zip')]
    for zip_file in zip_files:
        shutil.unpack_archive(os.path.join(file_path, zip_file), file_path)


def find_syslog_files_from_utf():
    file_path = get_path()
    dest_dir = os.path.join(file_path, 'btslog')
    Path(dest_dir).mkdir(exist_ok=True)
    for dirpath, dirnames, filenames in os.walk(file_path):
        for filename in filenames:
            if 'syslog' in filename:
                file_path = os.path.join(dirpath, filename)
                shutil.move(file_path, os.path.join(dest_dir, filename))


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


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def _file_reader(filename):
    with open(filename, 'r') as f:
        for line in f:
            yield line


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
