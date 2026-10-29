import re
from datetime import datetime

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

NRREL_REMOVE_MSG_1 = r'.*?AutomaticNeighbourRelationRemovalProcedure: started'
NRREL_REMOVE_MSG_2 = r'.*?AutomaticNeighbourRelationRemovalProcedure: REMOVE NrRel with NRCGI: 832815106'
NRREL_REMOVE_MSG_3 = r'.*?AutomaticNeighbourRelationRemovalProcedure: Removing 1 NrRels and 0 NrAdjNrCells'
NRREL_REMOVE_MSG_4 = r'.*?AutomaticNeighbourRelationRemovalProcedure: finished'


def get_params_for_nrrel0():
    parameter = [
        {"parameterName": "cellIndividualSsbRsrpOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "cellIndividualSsbRsrqOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "gNbId", "operation": "update", "value": "50831"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "22"},
        {"parameterName": "lcrId", "operation": "update", "value": "2"},
        {"parameterName": "removeNotAllowed", "operation": "update", "value": "true"},
        {"parameterName": "handoverAllowedSA", "operation": "update", "value": "allowed"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]},
        {"parameterName": "nrDcAllowed", "operation": "update", "value": "false"},
    ]
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if sw_release == 'SBTS23R2':
            parameter.append({"parameterName": "handoverAllowedSARedCap", "operation": "update", "value": "forbidden"})
        else:
            parameter.append({"parameterName": "handoverAllowedSARedCap", "operation": "update", "value": "forbidden"})
            parameter.append({"parameterName": "isRplCellForPSCell", "operation": "update", "value": "false"})
    return parameter


def get_params_for_nrplmnset():
    parameter = [
        {"parameterName": "nrPlmnDNList", "value": ["MRBTS-50831/NRBTS-50831/NRPLMN-1"], "operation": "update"},
    ]
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if not sw_release == 'SBTS23R3':
            parameter.append({"parameterName": "cellReservedForOperatorUse",
                              "value": "notReserved", "operation": "update"})
    return parameter


def check_removal_entries_in_syslog(syslog_path):
    nrrel_remove_msg_1 = re.compile(NRREL_REMOVE_MSG_1, re.IGNORECASE)
    nrrel_remove_msg_2 = re.compile(NRREL_REMOVE_MSG_2, re.IGNORECASE)
    nrrel_remove_msg_3 = re.compile(NRREL_REMOVE_MSG_3, re.IGNORECASE)
    nrrel_remove_msg_4 = re.compile(NRREL_REMOVE_MSG_4, re.IGNORECASE)
    msg1, msg2, msg3, msg4 = False, False, False, False,
    for line in file_reader(syslog_path):
        if nrrel_remove_msg_1.match(line):
            msg1 = True
            blog(nrrel_remove_msg_1.match(line).group(0))
        if nrrel_remove_msg_2.match(line):
            msg2 = True
            blog(nrrel_remove_msg_2.match(line).group(0))
        if nrrel_remove_msg_3.match(line):
            msg3 = True
            blog(nrrel_remove_msg_3.match(line).group(0))
        if nrrel_remove_msg_4.match(line):
            msg4 = True
            blog(nrrel_remove_msg_4.match(line).group(0))
        if all([msg1, msg2, msg3, msg4]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}, msg3={}, msg4={}'
                     .format(msg1, msg2, msg3, msg4))


def confirm_ue_drop(syslog_path):
    ue_drop_pattern = re.compile(
        r'.*?MeasurementReport.*?.cpp:\d+'
        r'.*?No NrAnrProfile for SsbFrequency: \d+. '
        r".*?Pci resolution won't be triggered", re.IGNORECASE)
    for line in file_reader(syslog_path):
        if ue_drop_pattern.match(line):
            return True
    raise ValueError('No msg found in syslog')


def check_if_counters_increased(final_cts, cell_id, expected_value=1):
    """Method verifies that particular pm counters increased by 1 for the chosen cell"""
    if int(expected_value) == 0:
        for counter_id in final_cts:
            if counter_id not in final_cts:
                break
            assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter value is different than expected value:{}".format(expected_value)
    else:
        for counter_id in final_cts:
            assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"
