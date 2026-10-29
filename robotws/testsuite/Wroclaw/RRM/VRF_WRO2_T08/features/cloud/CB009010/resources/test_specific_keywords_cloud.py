import json
import re
import time
import xml.etree.ElementTree as ET
from pathlib import Path

from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from taf.hw.rf_attenuator import rf_attenuator

from test_variables_cloud import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.cloud.admin import vcu_context
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.TafUe import TafUe
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

_taf_ue = TafUe(verbose=True)
_elt = EltLogCollector()
cu_object = cu()
vdu_object = vdu()
_tl = TestlineConfiguration()
_attenuator = rf_attenuator()
ELT_LOG_NAME = 'elt_log.json'
sib_validation_re = re.compile(r"nr-rrc\.plmn_IdentityList_tree.*?nr-rrc\.cellReservedForOperatorUse': '"
                               r"(?P<item0>\d)'}}.*?nr-rrc\.cellReservedForOperatorUse': '(?P<item1>\d)'}")


def setup_vcu_parameters(state):
    cu_object.connect_to(host='10.42.93.184', port='443', username='Nemuadmin', password='Nokia@123', secure=True)
    json_on = 'testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/' \
              'CB009010/resources/delta/delta_actPlmnCellResForOpUse_on.json'
    json_off = 'testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/cloud/' \
               'CB009010/resources/delta/delta_actPlmnCellResForOpUse_off.json'
    if state == "ENABLED":
        cu_object.perform_delta_recommissioning(delta_file=json_on)
        time.sleep(10)
    else:
        cu_object.perform_delta_recommissioning(delta_file=json_off)
        time.sleep(10)
    cu_object.disconnect(connection=None, timeout=10)


def trigger_ho():
    initialize_attenuators()
    _attenuate_cell(SOURCE_CELL, 10)
    _taf_ue.attach_ue('UE_1')
    _attenuate_cell(TARGET_CELL, 0)
    _attenuate_cell(SOURCE_CELL, 15)
    time.sleep(30)
    _taf_ue.detach_ue('UE_1')


def detach():
    _taf_ue.detach_ue('UE_1')


def _attenuate_cell(cell_id, value):
    cell = CELL_PORTS[cell_id]
    _attenuator.set_ports_attenuation(cell['ports'], [value] * len(cell['ports']), confirm=True,
                                      attenuator_device=f"atten_{cell['attenuator_id']}")


def initialize_attenuators():
    for idx, atten in enumerate(TestlineConfiguration().tl_init.attenuators):
        logger.info(f"Initializing attenuator {atten.ip_addr}", also_to_console=True)
        _attenuator.setup_attenuator(atten, alias=f"atten_{idx}")
        _attenuator.set_ports_attenuation(atten.attenuation_port_numbers, [90] * len(atten.attenuation_port_numbers),
                                          confirm=True, attenuator_device=f"atten_{idx}")


def setup_vdu_parameters(state):
    for vdu_ip in vdu_ips:
        vdu_object.connect_to(host=vdu_ip, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        vdu_object.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505",
                                                     parameter="actPlmnCellResForOpUse",
                                                     operation="update",
                                                     value=state)
        time.sleep(10)
        vdu_object.disconnect(vdu_connection=None, timeout=10)


def validate_cell_reserved_for_operator(elt_log, first_value):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msgs = [x for x in log if x['name'] == 'SystemInformationBlockType1' and 'nr-rrc' in x['data']]
    assert len(msgs) >= 1, "Should have two nr-rrc SystemInformationBlockType1 msg, for primary cell and target cell"
    matched_sib = re.search(sib_validation_re, str(msgs[0]))
    assert matched_sib, f"SIB has unrecognizable structure, found SIB: {msgs[0]}"
    assert matched_sib.groups() == (first_value, '1'), f"Expected cellReservedForOperatorUse values = " \
                                                       f"{(first_value, '1')}, instead got: {matched_sib.groups()}"


def check_ho_ue_log(elt_log):
    with open(elt_log, 'r') as f:
        messages = [msg for msg in json.load(f)]
    _find_measurement_report_for_target_cell(messages)
    _find_reconfiguration_complete_for_ho(messages)


def _find_reconfiguration_for_ho(messages):
    for msg in messages:
        if msg['name'] == 'RRCReconfiguration':
            if (msg['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']
                    ['nr-rrc.message_tree']['nr-rrc.c1_tree']
                    ['nr-rrc.rrcReconfiguration_element']
                    ['nr-rrc.criticalExtensions_tree']
                    ['nr-rrc.rrcReconfiguration_element']
                    ['nr-rrc.measConfig_element']
                    ['nr-rrc.measObjectToAddModList_tree']['Item 0']
                    ['nr-rrc.MeasObjectToAddMod_element']['nr-rrc.measObject_tree']
                    ['nr-rrc.measObjectNR_element']['nr-rrc.ssbFrequency'] == '126250'):
                return
    raise AssertionError("RRCReconfiguration for ssbFrequency not found")


def validate_cell_cgi_rslt(elt_log):
    with open(elt_log, 'r') as f:
        messages = (msg for msg in json.load(f))
    found = False
    for msg in messages:
        try:
            if msg['name'] == 'MeasurementReport':
                if (msg['data']['nr-rrc']['nr-rrc.UL_DCCH_Message_element']
                        ['nr-rrc.message_tree']['nr-rrc.c1_tree']
                        ['nr-rrc.measurementReport_element']
                        ['nr-rrc.criticalExtensions_tree']
                        ['nr-rrc.measurementReport_element']
                        ['nr-rrc.measResults_element']
                        ['nr-rrc.measResultNeighCells_tree']
                        ['nr-rrc.measResultListNR_tree']['Item 0']
                        ['nr-rrc.MeasResultNR_element']
                        ['nr-rrc.cgi_Info_element']
                        ['nr-rrc.plmn_IdentityInfoList_tree']
                        ['Item 1']['nr-rrc.PLMN_IdentityInfo_element']
                        ['nr-rrc.cellReservedForOperatorUse'] == '1'):
                    found = True
                    break
        except KeyError:
            continue
    if not found:
        raise AssertionError("Item 1 with PLMN set and cellReservedForOperatorUse = 1 not found !")


def _find_reconfiguration_complete_for_ho(messages):
    for msg in messages:
        if msg['name'] == 'RRCReconfigurationComplete':
            return
    raise AssertionError("RRCReconfigurationComplete not found")


def _find_measurement_report_for_target_cell(messages):
    for msg in messages:
        if msg['name'] == 'MeasurementReport':
            if (msg['data']['nr-rrc']['nr-rrc.UL_DCCH_Message_element']
                    ['nr-rrc.message_tree']['nr-rrc.c1_tree']
                    ['nr-rrc.measurementReport_element']
                    ['nr-rrc.criticalExtensions_tree']
                    ['nr-rrc.measurementReport_element']
                    ['nr-rrc.measResults_element']
                    ['nr-rrc.measResultNeighCells_tree']
                    ['nr-rrc.measResultListNR_tree']['Item 0']
                    ['nr-rrc.MeasResultNR_element']['nr-rrc.physCellId'] == '602'):
                return
    raise AssertionError("MeasurementReport for 602 not found!")


def collect_snapshot_for_cloud_tl():
    for tl_ip in snapshot_vCU_vDU1_vDU_2:
        cu_object.connect_to(host=tl_ip, port='443', username='Nemuadmin', password='Nokia@123', secure=True)
        cu_object.get_plan_info()
        output_dir = get_robot_variable('OUTPUT_DIR')
        cu_object.get_local_snapshot(output_dir, request_timeout=None, operation_timeout=600.0, connection=None)
        cu_object.disconnect(connection=None, timeout=10)


def verify_anr_relation():
    with vcu_context() as admin:
        file_path = Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml'
        admin.get_current_plan_file(file_path)
        xml_tree = ET.parse(file_path)
        xml_root = xml_tree.getroot()
        pattern = r"MRBTS-8505/NRBTS-8505/NRCELL-20/NRREL-256"
        matched = re.findall(pattern, ET.tostring(xml_root, encoding='unicode'))
        if matched:
            logger.info(f"ANR NRREL {matched} are created!", also_to_console=True)
        else:
            raise AssertionError("ANR relation not created")
