import json
import os
import re

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

_builtin = BuiltIn()

HO_SUCCEEDED_MSG = r'.*?CellNeighbourStatusUpdateIndProcedure.cpp:\d+' \
                   r'.*?inter-gNb.*?' \
                   r'.*?hoSucceeded.*?'

GNB_CHANGE_RESULT_MSG = r'.*?SgNbChangeEventHandler.cpp:\d+' \
                        r'.*?PCMD - Change sgNbChangeResult' \
                        r'.*?setting from : SgNbChangeResult:success to : SgNbChangeResult:success'
GNB_CHANGE_CONFIRM_MSG = r'.*?MessageHandler.hpp:\d+ Received response of type messages::x2ap::SgNBChangeConfirm'

HO_NOT_ALLOWED_MSG_1 = r'.*?Activation flag for cell reserved for operator use per PLMN group is set to: true'

HO_NOT_ALLOWED_MSG_2 = r'.*?The specific PLMN is \'reserved\' on the neighbour cell and handover to this cell' \
                       r' is not allowed'

HO_NOT_ALLOWED_MSG_3 = r'.*?Plmn set is \'reserved\' on the target cell and handover to this cell is not allowed'

HO_NEUTRAL_PLMN_1 = r'.*Is NeutralPlmnEnabled : false, is UE SelectedPlmn equal to NeutralPlmn : true'

HO_NEUTRAL_PLMN_2 = r'.*Update for inter-GNB relation from source cell:832831489 to target cell:832815105 with ' \
                    r'PhyCellId:<LOG_SCRAM_11>50</LOG_SCRAM_11> with ssbFrequency: 176410 with new status: hoFailed'
HO_NEUTRAL_PLMN_3 = r'.*?Configuration flags: actRanSharing = true, actPlmnCellResForOpUseEnabled = true, ' \
                    r'neutralPlmnEnabled = false, cgiInfo = { \"CgiInfo\": { \"plmnIdentityList\": ' \
                    r'[ { \"PlmnIdentityInfo\": { \"plmnIdentities\": [{\"MCC\": \"540\", \"MNC\": \"01\"}]' \
                    r'.*?\"cellReservedForOperatorUse\": \"CellReservedForOperatorUse:reserved\"'

NEUTRAL_PLMN_ATTACH_FAIL_MSG_1 = r'.*?Cannot select PSCell,cause is: plmnCheckFailed'

NEUTRAL_PLMN_ATTACH_FAIL_MSG_2 = r'.*?PCMD Record for SgNbAdditionResultReason in SgNbAddition record : ' \
                               r'SgNbAdditionResult:cacFailure'

sib_validation_re = re.compile(r"nr-rrc\.plmn_IdentityList_tree.*?nr-rrc\.cellReservedForOperatorUse': '"
                               r"(?P<item0>\d)'}}.*?nr-rrc\.cellReservedForOperatorUse': '(?P<item1>\d)'}")

measrep_msg = re.compile(r"nr-rrc\.plmn_IdentityList_tree.*?{'Item 0': {'nr-rrc.MCC_MNC_Digit': '5'}, 'Item 1': "
                         r"{'nr-rrc.MCC_MNC_Digit': '4'}, 'Item 2': {'nr-rrc.MCC_MNC_Digit': '0'}}, "
                         r"'per.sequence_of_length': '2', 'nr-rrc.mnc': '2', 'nr-rrc.mnc_tree': {'Item 0': "
                         r"{'nr-rrc.MCC_MNC_Digit': '0'}, 'Item 1': {'nr-rrc.MCC_MNC_Digit': '1'"
                         r".*cellReservedForOperatorUse': '(?P<item0>\d)'.*?{'Item 0': {'nr-rrc.MCC_MNC_Digit': '0'}, "
                         r"'Item 1': {'nr-rrc.MCC_MNC_Digit': '0'}, 'Item 2': {'nr-rrc.MCC_MNC_Digit': '1'}}, "
                         r"'per.sequence_of_length': '2', 'nr-rrc.mnc': '2', 'nr-rrc.mnc_tree': {'Item 0': "
                         r"{'nr-rrc.MCC_MNC_Digit': '0'}, 'Item 1': {'nr-rrc.MCC_MNC_Digit': '1'}"
                         r".*cellReservedForOperatorUse': '(?P<item1>\d)'.*?{'Item 0': {'nr-rrc.MCC_MNC_Digit': '5'}, "
                         r"'Item 1': {'nr-rrc.MCC_MNC_Digit': '5'}, 'Item 2': {'nr-rrc.MCC_MNC_Digit': '5'}}, "
                         r"'per.sequence_of_length': '2', 'nr-rrc.mnc': '2', 'nr-rrc.mnc_tree': {'Item 0': "
                         r"{'nr-rrc.MCC_MNC_Digit': '1'}, 'Item 1': {'nr-rrc.MCC_MNC_Digit': '0'}"
                         r".*cellReservedForOperatorUse': '(?P<item2>\d)'.*?{'Item 0': {'nr-rrc.MCC_MNC_Digit': '3'}, "
                         r"'Item 1': {'nr-rrc.MCC_MNC_Digit': '1'}, 'Item 2': {'nr-rrc.MCC_MNC_Digit': '0'}}, "
                         r"'per.sequence_of_length': '3', 'nr-rrc.mnc': '3', 'nr-rrc.mnc_tree': {'Item 0': "
                         r"{'nr-rrc.MCC_MNC_Digit': '2'}, 'Item 1': {'nr-rrc.MCC_MNC_Digit': '6'}, 'Item 2': "
                         r"{'nr-rrc.MCC_MNC_Digit': '0'}"
                         r".*cellReservedForOperatorUse': '(?P<item3>\d)'}")


def validate_cell_reserved_for_operator(elt_log, first_value):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msgs = list(filter(lambda x: x['name'] == 'SystemInformationBlockType1' and 'nr-rrc' in x['data'], log))
    assert len(msgs) == 1, "Should have only one nr-rrc SystemInformationBlockType1 msg"
    matched_sib = re.search(sib_validation_re, str(msgs[0]))
    assert matched_sib, f"SIB has unrecognizable structure, found SIB: {msgs[0]}"
    assert matched_sib.groups() == (first_value, '1'), f"Expected cellReservedForOperatorUse values = " \
           f"{(first_value, '1')}, instead got: {matched_sib.groups()}"


def validate_cell_cgi_rslt(elt_log, first_value):
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msgs = list(filter(lambda x: x['name'] == 'MeasurementReport' and 'nr-rrc' in x['data']
                       and 'nr-rrc.UL_DCCH_Message_element' in x['data']['nr-rrc']
                       and 'nr-rrc.cgi_Info_element' in x['data']['nr-rrc']['nr-rrc.UL_DCCH_Message_element']
                       ['nr-rrc.message_tree']['nr-rrc.c1_tree']['nr-rrc.measurementReport_element']
                       ['nr-rrc.criticalExtensions_tree']['nr-rrc.measurementReport_element']
                       ['nr-rrc.measResults_element']['nr-rrc.measResultNeighCells_tree']
                       ['nr-rrc.measResultListNR_tree']['Item 0']['nr-rrc.MeasResultNR_element'], log))
    matched = re.search(measrep_msg, str(msgs[0]))
    assert matched, f"MeasurementReport has unrecognizable structure, found MeasurementReport: {msgs[0]}"
    assert matched.groups() == (first_value, '1', '1', '1'), f"Expected cellReservedForOperatorUse values = " \
           f"{(first_value, '1', '1', '1')}, instead got: {matched.groups()}"


def confirm_handover_succeeded(syslog_path):
    ho_pattern = re.compile(HO_SUCCEEDED_MSG, re.IGNORECASE)
    gnb_change_result_pattern = re.compile(GNB_CHANGE_RESULT_MSG, re.IGNORECASE)
    gnb_change_confirm_pattern = re.compile(GNB_CHANGE_CONFIRM_MSG, re.IGNORECASE)
    ho_ok, gnb_change_ok, gnb_confirm_ok = False, False, False
    for line in file_reader(syslog_path):
        if ho_pattern.match(line):
            ho_ok = True
        if gnb_change_result_pattern.match(line):
            gnb_change_ok = True
        if gnb_change_confirm_pattern.match(line):
            gnb_confirm_ok = True
        print([ho_ok, gnb_change_ok, gnb_confirm_ok])
        if all([ho_ok, gnb_change_ok, gnb_confirm_ok]):
            return True
    raise ValueError('Handover procedure failed')


def confirm_handover_not_allowed(syslog_path):
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if sw_release == 'SBTS24R3':
            ho_pattern_1 = re.compile(HO_NOT_ALLOWED_MSG_1, re.IGNORECASE)
            ho_pattern_2 = re.compile(HO_NOT_ALLOWED_MSG_2, re.IGNORECASE)
            ho_msg_1, ho_msg_2, = False, False
            for line in file_reader(syslog_path):
                if ho_pattern_1.match(line):
                    ho_msg_1 = True
                if ho_pattern_2.match(line):
                    ho_msg_2 = True
                print([ho_msg_1, ho_msg_2])
                if all([ho_msg_1, ho_msg_2]):
                    return True
        else:
            ho_pattern_1 = re.compile(HO_NOT_ALLOWED_MSG_3, re.IGNORECASE)
            ho_msg_1, = False,
            for line in file_reader(syslog_path):
                if ho_pattern_1.match(line):
                    ho_msg_1 = True
                print([ho_msg_1])
                if all([ho_msg_1]):
                    return True
        raise ValueError('Handover procedure failed')


def confirm_handover_not_allowed_to_neutral_plmn(syslog_path):
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if sw_release == 'SBTS24R3':
            ho_pattern_1 = re.compile(HO_NEUTRAL_PLMN_1, re.IGNORECASE)
            ho_pattern_2 = re.compile(HO_NEUTRAL_PLMN_2, re.IGNORECASE)
        else:
            ho_pattern_1 = re.compile(HO_NEUTRAL_PLMN_2, re.IGNORECASE)
            ho_pattern_2 = re.compile(HO_NEUTRAL_PLMN_3, re.IGNORECASE)
        ho_msg_1, ho_msg_2, = False, False
        for line in file_reader(syslog_path):
            if ho_pattern_1.match(line):
                ho_msg_1 = True
            if ho_pattern_2.match(line):
                ho_msg_2 = True
            if all([ho_msg_1, ho_msg_2]):
                return True
        raise ValueError('Handover messages not found: ho_msg_1={}, ho_msg_2={}'.format(ho_msg_1, ho_msg_2))


def confirm_attach_not_allowed(syslog_path):
    attach_pattern_1 = re.compile(NEUTRAL_PLMN_ATTACH_FAIL_MSG_1, re.IGNORECASE)
    attach_pattern_2 = re.compile(NEUTRAL_PLMN_ATTACH_FAIL_MSG_2, re.IGNORECASE)
    attach_msg_1, attach_msg_2, = False, False
    for line in file_reader(syslog_path):
        if attach_pattern_1.match(line):
            attach_msg_1 = True
        if attach_pattern_2.match(line):
            attach_msg_2 = True
        print([attach_msg_1, attach_msg_2])
        if all([attach_msg_1, attach_msg_2]):
            return True
    raise ValueError('Attach procedure failed')


def get_parameters_for_nrplmnset_sa():
    parameters = [
        {"parameterName": "cellReservedForOperatorUse", "value": "notReserved", "operation": "update"},
        {"parameterName": "cellReservedForOperatorUseUacAutoMax", "value": "notReserved", "operation": "update"},
        {"parameterName": "nrPlmnDNList", "value": ["MRBTS-50831/NRBTS-50831/NRPLMN-4"], "operation": "update"},
        {"parameterName": "trackingAreaDN", "value": "MRBTS-50831/NRBTS-50831/TRACKINGAREA-7154", "operation": "update"}
    ]
    return parameters


def perform_scf_commissioning(scf_type):
    with Admin5G() as admin_api:
        branch = admin_api.get_sw_release_name()[-4:]
        scf_5g_file = _find_scf_file(branch, scf_type)
        blog("Performing gnb commissioning with file {}...".format(scf_5g_file))
        admin_api.perform_commissioning(scf_file=scf_5g_file, timeout=300)


def _find_scf_file(branch, scf_type):
    path_to_custom_config = _builtin.get_variable_value("${TL_CONFIG}")
    path_to_scf = '{}/{}'.format(path_to_custom_config, branch)
    if scf_type.lower() == 'neutral':
        scf_5g = [filename for filename in os.listdir(path_to_scf) if "NEUTRAL" in filename]
    else:
        scf_5g = [filename for filename in os.listdir(path_to_scf) if "5g" in filename and "NEUTRAL"
                  not in filename and "50832" not in filename]
    assert len(scf_5g) == 1, 'Error, found more than one SCF file'
    return '{}/{}'.format(path_to_scf, scf_5g[0])
