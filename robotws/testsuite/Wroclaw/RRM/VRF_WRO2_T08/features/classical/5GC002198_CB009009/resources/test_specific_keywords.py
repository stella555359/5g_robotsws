import re
from datetime import datetime

from robot.libraries.BuiltIn import BuiltIn
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

current_lua = True
ute_tshark = ute_tshark()
builtin = BuiltIn()

HO_SUCCEEDED_MSG = r'.*?CellNeighbourStatusUpdateIndProcedure.cpp:\d+' \
                   r'.*?inter-gNb.*?' \
                   r'.*?hoSucceeded.*?'
GNB_CHANGE_RESULT_MSG = r'.*?SgNbChangeEventHandler.cpp:\d+' \
                        r'.*?PCMD - Change sgNbChangeResult' \
                        r'.*?setting from : SgNbChangeResult:success to : SgNbChangeResult:success'
GNB_CHANGE_CONFIRM_MSG = r'.*?MessageHandler.hpp:\d+ Received response of type messages::x2ap::SgNBChangeConfirm'

MSG_1 = r'.*?5GC002198 feature is active'
MSG_2 = r'.*?intraNrNsaInterFreq ANR profile for drxLongCycle: 13'
MSG_3 = r'.*?Intra DU Handover triggered from cellId:832815105 to cellId:832815107'
MSG_4 = r'.*?Handling InterFreqIntraGnb NrcgiReport for PCI: PhyCellId:<LOG_SCRAM_11>52</LOG_SCRAM_11>'
MSG_5 = r'.*?ActiveProcedure set to psCellChangeWithSrb3'


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


def get_params_for_two_drxProfileNrAnr(drxControl_1, drxControl_2, gnbId):
    parameter = [
        {"parameterName": "drxProfileNrAnr", "operation": "update", "value":
            [{"drxControl": "{}".format(drxControl_1),
              "nrDrxDN": "MRBTS-{0}/NRBTS-{0}/NRDRX-5".format(gnbId)},
             {"drxControl": "{}".format(drxControl_2),
              "nrDrxDN": "MRBTS-{0}/NRBTS-{0}/NRDRX-6".format(gnbId)},
             {"drxControl": "any",
              "nrDrxDN": "MRBTS-{0}/NRBTS-{0}/NRDRX-3".format(gnbId)}
             ]
         },
    ]
    return parameter


def get_params_for_drxProfileNrAnr_ab2(drxControl, gnbId, nrDrxDN=4):
    parameter = [
        {"parameterName": "drxProfileNrAnr", "operation": "update", "value":
            [{"drxControl": "{}".format(drxControl),
              "nrDrxDN": "MRBTS-{0}/NRBTS-{0}/NRDRX-{1}".format(gnbId, nrDrxDN)},
             {"drxControl": "any",
              "nrDrxDN": "MRBTS-{0}/NRBTS-{0}/NRDRX-{1}".format(gnbId, nrDrxDN)},
             ]
         },
    ]
    return parameter


def get_params_for_drxProfileNrAnr_default(drxControl, gnbId, nrDrxDN=4):
    parameter = [
        {"parameterName": "drxProfileNrAnr", "operation": "update", "value":
            [{"drxControl": "{}".format(drxControl),
              "nrDrxDN": "MRBTS-{0}/NRBTS-{0}/NRDRX-{1}".format(gnbId, nrDrxDN)},
             ]
         },
    ]
    return parameter


def get_params_for_drxProfileNrAnr_delete():
    parameter = [
        {"parameterName": "drxProfileNrAnr", "operation": "delete", "value":
            [{}]
         },
    ]
    return parameter


def get_params_for_nrrel_object(nrradjnrcell_id):
    parameter = [
        {"parameterName": "cellIndividualSsbRsrpOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "cellIndividualSsbRsrqOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "gNbId", "operation": "update", "value": "50832"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "22"},
        {"parameterName": "lcrId", "operation": "update", "value": "{}".format(nrradjnrcell_id[-1])},
        {"parameterName": "removeNotAllowed", "operation": "update", "value": "false"},
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


def get_params_for_nradjnrcell_object(nrradjnrcell_id):
    parameter = [
        {"parameterName": "gNbId", "operation": "update", "value": "50832"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "22"},
        {"parameterName": "lcrId", "operation": "update", "value": "{}".format(nrradjnrcell_id[-1])},
        {"parameterName": "nrarfcn", "operation": "update", "value": "176700"},
        {"parameterName": "physCellId", "operation": "update", "value": "6{}".format(nrradjnrcell_id[-1])},
        {"parameterName": "cellDepType", "operation": "update", "value": "NSA"},
        {"parameterName": "ssbFrequency", "operation": "update", "value": "176670"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]}
    ]
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if not sw_release == 'SBTS23R3':
            parameter.append({"parameterName": "cellReservedForOperatorUse",
                              "value": "notReserved", "operation": "update"})
    return parameter


def get_params_for_idleTimeForNrNbRemoval():
    parameter = [
        {"parameterName": "idleTimeForNrNbRemoval", "operation": "update", "value": "2"},
    ]
    return parameter


def confirm_dedicated_drx_ho(syslog_path):
    drx_pattern_1 = re.compile(MSG_1, re.IGNORECASE)
    drx_pattern_2 = re.compile(MSG_2, re.IGNORECASE)
    drx_pattern_3 = re.compile(MSG_3, re.IGNORECASE)
    drx_pattern_4 = re.compile(MSG_4, re.IGNORECASE)
    drx_pattern_5 = re.compile(MSG_5, re.IGNORECASE)
    msg1, msg2, msg3, msg4, msg5 = False, False, False, False, False,
    for line in file_reader(syslog_path):
        if drx_pattern_1.match(line):
            msg1 = True
            blog(drx_pattern_1.match(line).group(0))
        if drx_pattern_2.match(line):
            msg2 = True
            blog(drx_pattern_2.match(line).group(0))
        if drx_pattern_3.match(line):
            msg3 = True
            blog(drx_pattern_3.match(line).group(0))
        if drx_pattern_4.match(line):
            msg4 = True
            blog(drx_pattern_4.match(line).group(0))
        if drx_pattern_5.match(line):
            msg5 = True
            blog(drx_pattern_5.match(line).group(0))
        if all([msg1, msg2, msg3, msg4, msg5]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}, msg3={}, msg4={}, msg5={}'.format(
        msg1, msg2, msg3, msg4, msg5))


def check_dedicated_drx_ho_in_pcap(log_path, test_name, msg1, msg2, msg3):
    ute_tshark.setup_tshark(interface='any', alias='drx_pcap')
    value = ute_tshark.get_packets_count(packet_filter=msg1,
                                         pcap_file_path="{}/{}_SCTP.pcap".format(log_path, test_name),
                                         alias='drx_pcap')
    builtin.should_be_equal_as_integers(value, 1)
    value = ute_tshark.get_packets_count(packet_filter=msg2,
                                         pcap_file_path="{}/{}_SCTP.pcap".format(log_path, test_name),
                                         alias='drx_pcap')
    builtin.should_be_equal_as_integers(value, 3)
    value = ute_tshark.get_packets_count(packet_filter=msg3,
                                         pcap_file_path="{}/{}_SCTP.pcap".format(log_path, test_name),
                                         alias='drx_pcap')
    builtin.should_be_equal_as_integers(value, 1)
    ute_tshark.teardown_tshark(alias='drx_pcap')


def check_if_counters_increased(final_cts, cell_id, expected_value=1):
    """Method verifies that particular pm counters increased by 1 for the chosen cell"""
    if int(expected_value) == 0:
        for counter_id in final_cts:
            if counter_id not in final_cts:
                break
            assert counter_id not in final_cts or int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"
    else:
        for counter_id in final_cts:
            assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                counter_id + "counter did not increment by 1"
