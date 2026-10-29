import json
import time
from pathlib import Path

from taf.hw.rf_attenuator import rf_attenuator

from test_constants_cloud import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.cloud.admin import vcu_context, vdu_context
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager import DCAPManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.log_profile import LogProfile
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.TafUe import TafUe
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

_taf_ue = TafUe(verbose=True)
_elt = EltLogCollector()
_dm = DCAPManager()
_tl = TestlineConfiguration()
_vcu_log_profile = LogProfile().with_vcu_snapshot().with_tracer_vcu()
_vdu_log_profile = LogProfile().with_vdu_snapshot().with_tracer_vdu().with_vdu_syslog()
_attenuator = rf_attenuator()


traces = {'vcu': {'log_profile': _vcu_log_profile,
                  'trace_id': '',
                  'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                  'stop_trace_name': 'dcap_vcu_stop_trace',
                  'download_log_name': 'dcap_collect_vcu_log',
                  'cells': ['4', '20']},
          'vdu_1': {'log_profile': _vdu_log_profile,
                    'trace_id': '',
                    'mplane': _tl.get_du_oam_connection_details(0, 0)['hostname'],
                    'stop_trace_name': 'dcap_vdu_1_stop_trace',
                    'download_log_name': 'dcap_collect_vdu_1_log',
                    'cells': ['20']},
          'vdu_2': {'log_profile': _vdu_log_profile,
                    'trace_id': '',
                    'mplane': _tl.get_du_oam_connection_details(0, 1)['hostname'],
                    'stop_trace_name': 'dcap_vdu_2_stop_trace',
                    'download_log_name': 'dcap_collect_vdu_2_log',
                    'cells': ['4']},
          }


def setup():
    initialize_attenuators()
    deattenuate_source_cell()
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
    logger.info(f"Deattenuating source cell (pci={SOURCE_CELL}) to {MIN_ATTENUATION}db", also_to_console=True)
    _attenuate_cell(SOURCE_CELL, MIN_ATTENUATION)


def _attenuate_cell(cell_id, value):
    cell = CELL_PORTS[cell_id]
    _attenuator.set_ports_attenuation(cell['ports'], [value] * len(cell['ports']), confirm=True,
                                      attenuator_device=f"atten_{cell['attenuator_id']}")


def start_tracing():
    start_elt_tracing()
    start_dcap_tracing()


def start_elt_tracing():
    _elt.setup(with_upload=True, configuration=ELT_CONFIG)
    _elt.set_logging_filter("OTA")
    _elt.set_logging_filter("SYS", codes="+CGPADDR:")
    _elt.start_log_collecting()


def start_dcap_tracing():
    _dm.connect_to(port='9443', user=None, passwd=None)
    global traces
    for trace, params in traces.items():
        params['trace_id'] = _dm.start_new_trace(mplane=params['mplane'], log_profile=params['log_profile'],
                                                 nr_cells=params['cells'])


def stop_tracing():
    output_dir = get_robot_variable('OUTPUT_DIR')
    stop_elt_tracing(output_dir)
    stop_dcap_tracing(output_dir)


def stop_elt_tracing(output_dir):
    output_dir = Path(output_dir)
    elt_path = str(output_dir / ELT_LOG_NAME)
    _elt.stop_log_collecting()
    _elt.download_log(elt_path)


def teardown_elt():
    _elt.shutdown()


def teardown_dcap():
    _dm.teardown()


def stop_dcap_tracing(output_dir):
    for trace, params in traces.items():
        _dm.stop_trace(params['trace_id'])
        _dm.download_logs(params['trace_id'], target_dir=output_dir)


def attach_redcap_ue():
    detach_redcap_ue()
    _elt.send_pcommand()
    for at_cmd in AT_COMMANDS:
        logger.info(at_cmd, also_to_console=True)
        _elt.send_at_command(at_cmd)
    ip = _elt.set_ip(serial_number=UE_SERIAL_NUMBER)
    logger.info(f"RedCap attached, ip = {ip}", also_to_console=True)


def trigger_cell_reselection():
    logger.info(f"Triggering cell reselection from cell {SOURCE_CELL} to cell {TARGET_CELL}", also_to_console=True)
    for value in range(MIN_ATTENUATION, MAX_ATTENUATION, ATTENUATION_STEP):
        _attenuate_cell(SOURCE_CELL, value)
        _attenuate_cell(TARGET_CELL, MAX_ATTENUATION + MIN_ATTENUATION - value)
        time.sleep(1)


def detach_redcap_ue():
    _elt.send_at_command('AT+EFUN=0')


def check_ue_log():
    output_dir = Path(get_robot_variable('OUTPUT_DIR'))
    elt_path = str(output_dir / ELT_LOG_NAME)
    with open(elt_path, 'r') as f:
        messages = (msg for msg in json.load(f))
    _find_rrc_release_with_suspend_config(messages)
    _find_rrc_resume_request_with_rna_update_resume_cause(messages)


def _find_rrc_release_with_suspend_config(messages):
    for msg in messages:
        if msg['name'] == 'RRCRelease':
            if 'suspendconfig_element' in str(msg['data']).lower():
                return
    raise AssertionError("No RRCRelease wih suspendConfig found in ue_log!")


def _find_rrc_resume_request_with_rna_update_resume_cause(messages):
    for msg in messages:
        if msg['name'] == 'RRCResumeRequest1':
            if msg['data']['nr-rrc']["nr-rrc.UL_CCCH1_Message_element"]["nr-rrc.message_tree"]["nr-rrc.c1_tree"][
                    "nr-rrc.rrcResumeRequest1_element"]["nr-rrc.rrcResumeRequest1_element"][
                    "nr-rrc.resumeCause"] == '8':
                return
    raise AssertionError("No RRCResumeRequest1 with resumeCause rna-update(8) found in ue_log!")
