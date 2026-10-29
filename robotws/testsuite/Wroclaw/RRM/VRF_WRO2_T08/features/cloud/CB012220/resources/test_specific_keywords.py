import os
import re
import time
import xml.etree.ElementTree as ET
from pathlib import Path

from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from taf.hw.rf_attenuator import rf_attenuator
from taf.internal.sbts.admin.exceptions import AdminApiException

from test_constants import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.cloud.admin import vcu_context
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager import DCAPManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.log_profile import LogProfile
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.throughput_curves.resources.elt_verification \
    import EltLogParser
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

_cu = cu()
_vdu = vdu()
_elt = EltLogCollector()
_elt_parser = EltLogParser()
_dm = DCAPManager()
_attenuator = rf_attenuator()
_tl = TestlineConfiguration()
_vcu_log_profile = LogProfile().with_vcu_snapshot().with_tracer_vcu().with_vcu_syslog()

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


def setup():
    initialize_attenuators()
    sw_verification()
    deattenuate_source_cell()
    if sw_version == "CU26R1_":
        admin = _vdu.connect_to(host='10.42.38.213',
                                port='443',
                                username='Nemuadmin',
                                password='Nokia@123',
                                secure=True)
        json = '/home/ute/Desktop/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T08/' \
               'features/cloud/CB012220/resources/test_setup_branch_delta.json'
    elif sw_version == "CU26R2_":
        admin = _vdu.connect_to(host='10.42.38.208',
                                port='443',
                                username='Nemuadmin',
                                password='Nokia@123',
                                secure=True)
        json = '/home/ute/Desktop/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T08/' \
               'features/cloud/CB012220/resources/test_setup_trunk_delta.json'
    else:
        raise NameError(f"No json prepared for encountered release ({sw_version})")
    try:
        _vdu.perform_delta_recommissioning(delta_file=json, vdu_connection=admin)
        wait_for_bts_on_air(connection=admin)
    finally:
        print('Disconnecting WebEM connection.')
        _vdu.disconnect()


def teardown():
    attenuate_source_cell()
    if sw_version == "CU26R1_":
        admin = _vdu.connect_to(host='10.42.38.213',
                                port='443',
                                username='Nemuadmin',
                                password='Nokia@123',
                                secure=True)
        json = '/home/ute/Desktop/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T08/' \
               'features/cloud/CB012220/resources/test_teardown_branch_delta.json'
    elif sw_version == "CU26R2_":
        admin = _vdu.connect_to(host='10.42.38.208',
                                port='443',
                                username='Nemuadmin',
                                password='Nokia@123',
                                secure=True)
        json = '/home/ute/Desktop/robotws/testsuite/Wroclaw/RRM/VRF_WRO2_T08/' \
               'features/cloud/CB012220/resources/test_teardown_trunk_delta.json'
    else:
        raise NameError(f"No json prepared for encountered release ({sw_version})")
    try:
        _vdu.perform_delta_recommissioning(delta_file=json, vdu_connection=admin)
        wait_for_bts_on_air(connection=admin)
    finally:
        print('Disconnecting WebEM connection.')
        _vdu.disconnect()


def wait_for_bts_on_air(connection):
    try:
        _wait_for_bts_on_air(connection=connection)
    finally:
        print("BTS didn't come on air after 20 20-sec checks")


def _wait_for_bts_on_air(connection):
    time.sleep(120)
    attempts = 0
    while attempts < 20:
        try:
            check_if_bts_on_air(connection=connection)
            break
        except (AssertionError, AdminApiException) as e:
            attempts += 1
            time.sleep(20)
            assert attempts < 20, f"BTS isn\'t on air. Last error: {e}"
            print(f"waiting for BTS to come on air... (attempts: {attempts})")


def check_if_bts_on_air(connection):
    for i in range(0, 5):
        cells = _vdu.get_vdu_cells_status(timeout=300, vdu_connection=connection)
        operational_states = []
        availability_statuses = []
        for cell in cells:
            operational_states.append(cell['operational_state'])
            availability_statuses.append(cell['availability_status'])
        assert set(operational_states) == {'enabled'}, \
            f'Cell operational states not as expected: {operational_states}'
        assert set(availability_statuses) == {'on line'}, \
            f'Cell availability statuses not as expected: {availability_statuses}'
        print("BTS is on air!")


def teardown_elt():
    _elt.shutdown()


def sw_verification():
    with vcu_context() as admin:
        file_path = Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml'
        admin.get_current_plan_file(file_path)
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
    else:
        raise NameError(f"No configuration prepared for encountered release ({sw_version})")


def attenuate_source_cell():
    if sw_version == "CU26R1_":
        logger.info(f"Deattenuating source cell (pci={BRANCH_SOURCE_CELL}) to {MAX_ATTENUATION}db",
                    also_to_console=True)
        _attenuate_cell(BRANCH_SOURCE_CELL, MAX_ATTENUATION)
    elif sw_version == "CU26R2_":
        logger.info(f"Deattenuating source cell (pci={TRUNK_SOURCE_CELL}) to {MAX_ATTENUATION}db",
                    also_to_console=True)
        _attenuate_cell(TRUNK_SOURCE_CELL, MAX_ATTENUATION)
    else:
        raise NameError(f"No configuration prepared for encountered release ({sw_version})")


def _attenuate_cell(cell_id, value):
    cell = CELL_PORTS[cell_id]
    _attenuator.set_ports_attenuation(cell['ports'], [value] * len(cell['ports']), confirm=True,
                                      attenuator_device=f"atten_{cell['attenuator_id']}")


def setup_elt():
    if sw_version == "CU26R1_":
        logger.info(f"Setup ELT: {ELT_CONFIG_BRANCH}", also_to_console=True)
        _elt.setup(with_upload=True, configuration=ELT_CONFIG_BRANCH)
    elif sw_version == "CU26R2_":
        logger.info(f"Setup ELT: {ELT_CONFIG_TRUNK}", also_to_console=True)
        _elt.setup(with_upload=True, configuration=ELT_CONFIG_TRUNK)
    else:
        raise NameError(f"No configuration prepared for encountered release ({sw_version})")
    _elt.set_logging_filter()


def start_elt_tracing():
    _elt.start_log_collecting()


def stop_elt_tracing(output_dir):
    output_dir = Path(output_dir)
    elt_path = str(output_dir / ELT_LOG_NAME)
    _elt.stop_log_collecting()
    _elt.download_log(elt_path)


def get_path():
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def gather_elt_logs():
    start_elt_tracing()
    time.sleep(5)
    stop_elt_tracing(get_robot_variable('OUTPUT_DIR'))


def analyze_elt_log(log_path):
    if sw_version == "CU26R1_":
        logs = _elt_parser.analyze_log(logfile=log_path)
        print('layers ul:', float(logs['ul_rank']))
        assert float(logs['ul_rank']) == 0.0, 'Number of UL layers not as expected'
        print('layers: dl', float(logs['dl_rank']))
        assert float(logs['dl_rank']) == 0.0, 'Number of DL layers not as expected'
        print('Average MCS ul:', float(logs['ul_mcs_all']))
        assert float(logs['ul_mcs_all']) > 26.5, 'Average UL MCS too low'
        print('Average MCS dl:', float(logs['dl_mcs_all']))
        assert float(logs['dl_mcs_all']) > 26.5, 'Average DL MCS too low'
        print('Average UL tput:', float(logs['ul_pdcp_tput']))
        assert 65.0 < float(logs['ul_pdcp_tput']) < 75.0, 'Average UL tput not as expected'
        print('Average DL tput:', float(logs['dl_pdcp_tput']))
        assert 50.0 < float(logs['dl_pdcp_tput']) < 65.0, 'Average DL tput not as expected'
    elif sw_version == "CU26R2_":
        logs = _elt_parser.analyze_log(logfile=log_path)
        print('layers ul:', float(logs['ul_rank']))
        assert float(logs['ul_rank']) == 0.0, 'Number of UL layers not as expected'
        print('layers: dl', float(logs['dl_rank']))
        assert float(logs['dl_rank']) == 0.0, 'Number of DL layers not as expected'
        print('Average MCS ul:', float(logs['ul_mcs_all']))
        assert float(logs['ul_mcs_all']) > 26.5, 'Average UL MCS too low'
        print('Average MCS dl:', float(logs['dl_mcs_all']))
        assert float(logs['dl_mcs_all']) > 26.5, 'Average UL MCS too low'
        print('Average UL tput:', float(logs['ul_pdcp_tput']))
        assert 95.0 < float(logs['ul_pdcp_tput']) < 105.0, 'Average UL tput not as expected'
        print('Average DL tput:', float(logs['dl_pdcp_tput']))
        assert 80.0 < float(logs['dl_pdcp_tput']) < 90.0, 'Average DL tput not as expected'
    else:
        raise NameError(f"No analysis implementation for encountered release ({sw_version}")
