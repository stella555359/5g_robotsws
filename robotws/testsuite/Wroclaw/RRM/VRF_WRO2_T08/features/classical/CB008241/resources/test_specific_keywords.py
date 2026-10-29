import re

from robot.libraries.BuiltIn import BuiltIn
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.cleaners import clear_admin_api_logs
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

ute_tshark = ute_tshark()
builtin = BuiltIn()

SYSLOG_B_B5_MSG_1 = r'.*SA NR ANR enabled: true'

NRREL_REMOVE_MSG_1 = r'.*?AutomaticNeighbourRelationRemovalProcedure: Decrementing idleTimeAllowed for NRREL ' \
                     r'NrCellId: 208273409 it\'s current value of idleTimeAllowed = 2'
NRREL_REMOVE_MSG_2 = r'.*?AutomaticNeighbourRelationRemovalProcedure: NrRel with NRCGI: 208273409' \
                     r' value of idleTimeAllowed is updated to new value = 1'
NRREL_REMOVE_MSG_3 = r'.*?AutomaticNeighbourRelationRemovalProcedure: NRREL with NrCellId: 208273409 has value of ' \
                     r'idleTimeAllowed = 1. NRREL will be removed'
NRREL_REMOVE_MSG_4 = r'.*?AutomaticNeighbourRelationRemovalProcedure: REMOVE NrRel with NRCGI: 208273409'
NRREL_REMOVE_MSG_5 = r'.*?AutomaticNeighbourRelationRemovalProcedure: Removing 1 NRRELs' \
                     r' and 0 NRADJNRCELLs'
NRREL_REMOVE_MSG_6 = r'.*?AutomaticNeighbourRelationRemovalProcedure: Decrementing idleTimeAllowed for NRREL ' \
                     r'NrCellId: 208273409 it\'s current value of idleTimeAllowed = 3'
NRREL_REMOVE_MSG_7 = r'.*?AutomaticNeighbourRelationRemovalProcedure: Decrementing idleTimeAllowed for NRREL ' \
                     r'NrCellId: 208273409 it\'s current value of idleTimeAllowed = 2'
NRREL_REMOVE_INTRAHO_1 = r'.*?AutomaticNeighbourRelationRemovalProcedure: Decrementing idleTimeAllowed for NRREL' \
                         r' NrCellId: 208216066 it\'s current value of idleTimeAllowed = 2'
NRREL_REMOVE_INTRAHO_2 = r'.*?AutomaticNeighbourRelationRemovalProcedure: NrRel with NRCGI:' \
                         r' 208216066 value of idleTimeAllowed is updated to new value = 1'
NRREL_REMOVE_INTRAHO_3 = r'.*?AutomaticNeighbourRelationRemovalProcedure: NRREL with NrCellId: 208216066 has value of' \
                         r' idleTimeAllowed = 1. NRREL will be removed'
NRREL_REMOVE_INTRAHO_4 = r'.*?AutomaticNeighbourRelationRemovalProcedure: REMOVE NrRel with NRCGI: 208216066'
NRREL_REMOVE_INTRAHO_5 = r'.*?AutomaticNeighbourRelationRemovalProcedure: Removing 2 NrRels and 0 NrAdjNrCells'
NRADJNRCELL_REMOVE_MSG = r'.*?AutomaticNeighbourRelationRemovalProcedure: Removing 0 NRRELs' \
                         r' and 1 NRADJNRCELLs'
NRADJGNB_REMOVE_MSG = r'.*?MO deleted with distName: MRBTS-50834/NRBTS-50834/NRADJGNB-1'
XNLINK_REMOVE_MSG = r'.*?XnLink object for .*10.44.224.106.*was destroyed'

source_InterGnbHO_messages_with_xnlink = [
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 0 and xnap.radioNetwork == 1",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 0",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 1",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 6",
]

source_InterGnbHO_messages_with_nglink = [
    "ip.src == 10.44.225.88 and ip.dst == 10.27.28.136 and ngap.procedureCode == 12 and ngap.radioNetwork == 16",
    "ip.src == 10.27.28.136 and ip.dst == 10.44.225.88 and ngap.procedureCode == 12",
    "ip.src == 10.44.225.88 and ip.dst == 10.27.28.136 and ngap.procedureCode == 49",
    "ip.src == 10.27.28.136 and ip.dst == 10.44.225.88 and ngap.procedureCode == 41 and ngap.radioNetwork == 2",
    "ip.src == 10.44.224.88 and ip.dst == 10.44.224.106 and xnap.procedureCode == 17 and xnap.XnAP_PDU == 0",
    "ip.src == 10.44.224.106 and ip.dst == 10.44.224.88 and xnap.procedureCode == 17 and xnap.XnAP_PDU == 1",
]

target_InterGnbHO_messages_with_nglink = [
    "ngap.procedureCode == 13 and ngap.radioNetwork == 16 and ip.src == 10.27.28.136 and ip.dst == 10.44.225.106",
    "ngap.procedureCode == 13 and ip.src == 10.44.225.106 and ip.dst == 10.27.28.136 and ngap.NGAP_PDU == 1",
    "ngap.procedureCode == 7 and ngap.NGAP_PDU == 0",
    "ngap.procedureCode == 11 and ip.src == 10.44.225.106 and ip.dst == 10.27.28.136 and ngap.NGAP_PDU == 0",
]

target_InterGnbHO_messages = [
    "ngap and ngap.procedureCode == 25 and ip.src == 10.44.225.106 and ip.dst == 10.27.28.136",
    "ngap and ngap.procedureCode == 25 and ip.src == 10.27.28.136 and ip.dst == 10.44.225.106 and ngap.NGAP_PDU == 1",
]

inter_gnb_ho_filters = {
    "source_with_xnlink": source_InterGnbHO_messages_with_xnlink,
    "source_with_nglink": source_InterGnbHO_messages_with_nglink,
    "target": target_InterGnbHO_messages,
    "target_with_nglink": target_InterGnbHO_messages_with_nglink
}

drx_setup_msg = [
    "f1ap and f1ap.procedureCode == 7 and f1ap.id == 38 and f1ap.longDRXCycleLength == 13 and nr-rrc.reportConfig == 0 "
    "and nr-rrc.reportType == 2 and nr-rrc.cellForWhichToReportCGI == 999",
    "f1ap and f1ap.procedureCode == 7 and nr-rrc.drx_Config == 1 and nr-rrc.milliSeconds == 7 and "
    "nr-rrc.drx_InactivityTimer == 14 and nr-rrc.drx_LongCycleStartOffset == 13"
]

CONFIGS = {
    "gNB50834": {
        "VM_IP": "10.44.178.80",
    },
    "gNB50848": {
        "VM_IP": "10.44.178.82",
    },
}


def clear_admin_logs():
    clear_admin_api_logs()


def verify_dedicated_drx_profile_setup_pcap():
    filter_list = drx_setup_msg
    source_filepath = "{}/{}/{}_SCTP.pcap".format(builtin.get_variable_value("${LOG_PATH}"),
                                                  builtin.get_variable_value("${TESTNAME}"),
                                                  builtin.get_variable_value("${TESTNAME}"))
    pcap_alias = "drx_pcap"
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[0],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 1, "{} packets for filter: {} in {}-should be 1".format(packets, filter_list[0], source_filepath)
    packets = ute_tshark.get_packets_count(packet_filter=filter_list[1],
                                           pcap_file_path=source_filepath,
                                           alias=pcap_alias)
    assert packets == 2, "{} packets for filter: {} in {}-should be 2".format(packets, filter_list[1], source_filepath)
    ute_tshark.teardown_tshark(alias=pcap_alias)


def check_if_counters_increased(final_cts, cell_id, cell_id_2, cell_id_3, expected_value=1):
    """Method verifies that particular pm counters increased by 1 for the chosen cell"""
    if int(expected_value) == 0:
        for counter_id in final_cts:
            blog(counter_id)
            blog(final_cts[counter_id])
            if counter_id not in final_cts:
                break
            for cell in final_cts[counter_id]:
                if str(cell) == str(1):
                    assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                        counter_id + "counter did not increment by 1"
                elif str(cell) == str(2):
                    assert int(final_cts[counter_id][str(cell_id_2)]) == int(0), \
                        counter_id + "counter did not increment by 1"
                else:
                    assert int(final_cts[counter_id][str(cell_id_3)]) == int(expected_value), \
                        counter_id + "counter did not increment by 1"
    else:
        for counter_id in final_cts:
            for cell in final_cts[counter_id]:
                if str(cell) == str(1):
                    assert int(final_cts[counter_id][str(cell_id)]) == int(expected_value), \
                        counter_id + "counter did not increment by 1"
                elif str(cell) == str(2):
                    assert int(final_cts[counter_id][str(cell_id_2)]) == int(0), \
                        counter_id + "counter did not increment by 1"
                else:
                    assert int(final_cts[counter_id][str(cell_id_3)]) == int(expected_value), \
                        counter_id + "counter did not increment by 1"


@logged_keyword
def verify_intergnb_ho_by_cgi_report_pcap(nglink):
    filter_dict = inter_gnb_ho_filters
    pcap_alias = "ho_pcap"
    source_filepath = "{}/{}/{}_SCTP.pcap".format(builtin.get_variable_value("${LOG_PATH}"),
                                                  builtin.get_variable_value("${TESTNAME}"),
                                                  builtin.get_variable_value("${TESTNAME}"))
    target_filepath = "{}/{}/{}_target_SCTP.pcap".format(builtin.get_variable_value("${LOG_PATH}"),
                                                         builtin.get_variable_value("${TESTNAME}"),
                                                         builtin.get_variable_value("${TESTNAME}"))
    ute_tshark.setup_tshark(interface="any", alias=pcap_alias)
    if nglink is None:
        for element in filter_dict["source_with_xnlink"]:
            packets = ute_tshark.get_packets_count(packet_filter=element,
                                                   pcap_file_path=source_filepath,
                                                   alias=pcap_alias)
            assert packets == 1, "{} packets for filter: {} in {} - should be 1".format(packets, element,
                                                                                        source_filepath)
        for element in filter_dict["target"]:
            packets = ute_tshark.get_packets_count(packet_filter=element,
                                                   pcap_file_path=target_filepath,
                                                   alias=pcap_alias)
            assert packets == 1, "{} packets for filter: {} in {} - should be 1".format(packets, element,
                                                                                        target_filepath)
    else:
        with Admin5G() as admin_api:
            sw_release = admin_api.get_sw_release_name()
            if sw_release not in ['SBTS24R3', 'SBTS24R2']:
                for element in filter_dict["source_with_nglink"]:
                    packets = ute_tshark.get_packets_count(packet_filter=element,
                                                           pcap_file_path=source_filepath,
                                                           alias=pcap_alias)
                    assert packets == 1, "{} packets for filter: {} in {} - should be 1".format(packets, element,
                                                                                                source_filepath)
                for element in filter_dict["target_with_nglink"]:
                    packets = ute_tshark.get_packets_count(packet_filter=element,
                                                           pcap_file_path=target_filepath,
                                                           alias=pcap_alias)
                    assert packets == 1, "{} packets for filter: {} in {} - should be 1".format(packets, element,
                                                                                                target_filepath)
            else:
                for element in filter_dict["source_with_xnlink"]:
                    packets = ute_tshark.get_packets_count(packet_filter=element,
                                                           pcap_file_path=source_filepath,
                                                           alias=pcap_alias)
                    assert packets == 1, "{} packets for filter: {} in {} - should be 1".format(packets, element,
                                                                                                source_filepath)
                for element in filter_dict["target"]:
                    packets = ute_tshark.get_packets_count(packet_filter=element,
                                                           pcap_file_path=target_filepath,
                                                           alias=pcap_alias)
                    assert packets == 1, "{} packets for filter: {} in {} - should be 1".format(packets, element,
                                                                                                target_filepath)
    ute_tshark.teardown_tshark(alias=pcap_alias)


def get_pci_fire_times(syslog_path):
    fires = []
    for line in file_reader(syslog_path):
        if "ANR not to be attempted, no actSaUeBasedInterFreqAnrNr" in line:
            fires.append(line.split(' ')[1].split('.')[0])
    return fires


def count_fires_for_pci_resolution(syslog_path):
    return len(get_pci_fire_times(syslog_path))


def confirm_ho_after_act_flag(syslog_path):
    syslog_b_b5_msg_1 = re.compile(SYSLOG_B_B5_MSG_1, re.IGNORECASE)
    for line in file_reader(syslog_path):
        if syslog_b_b5_msg_1.match(line):
            blog(syslog_b_b5_msg_1.match(line).group(0))
            return True
    raise ValueError('No msg found in syslog.')


def check_removal_syslog_messages(syslog_path):
    nrrel_remove_msg_1 = re.compile(NRREL_REMOVE_MSG_1, re.IGNORECASE)
    nrrel_remove_msg_2 = re.compile(NRREL_REMOVE_MSG_2, re.IGNORECASE)
    nrrel_remove_msg_3 = re.compile(NRREL_REMOVE_MSG_3, re.IGNORECASE)
    nrrel_remove_msg_4 = re.compile(NRREL_REMOVE_MSG_4, re.IGNORECASE)
    nrrel_remove_msg_5 = re.compile(NRREL_REMOVE_MSG_5, re.IGNORECASE)
    nradjnrcell_remove_msg = re.compile(NRADJNRCELL_REMOVE_MSG, re.IGNORECASE)
    nradjgnb_remove_msg = re.compile(NRADJGNB_REMOVE_MSG, re.IGNORECASE)
    xnlink_remove_msg = re.compile(XNLINK_REMOVE_MSG, re.IGNORECASE)
    msg1 = msg2 = msg3 = msg4 = msg5 = msg6 = msg7 = msg8 = False
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
        if nrrel_remove_msg_5.match(line):
            msg5 = True
            blog(nrrel_remove_msg_5.match(line).group(0))
        if nradjnrcell_remove_msg.match(line):
            msg6 = True
            blog(nradjnrcell_remove_msg.match(line).group(0))
        if nradjgnb_remove_msg.match(line):
            msg7 = True
            blog(nradjgnb_remove_msg.match(line).group(0))
        if xnlink_remove_msg.match(line):
            msg8 = True
            blog(xnlink_remove_msg.match(line).group(0))
        if all([msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}, msg3={}, msg4={}, msg5={}, '
                     'msg6={}, msg7={}, msg8={}'.format(msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8))


def check_removal_syslog_messages_for_intra_and_inter_ho(syslog_path):
    nrrel_remove_msg_1 = re.compile(NRREL_REMOVE_MSG_1, re.IGNORECASE)
    nrrel_remove_msg_2 = re.compile(NRREL_REMOVE_MSG_2, re.IGNORECASE)
    nrrel_remove_msg_3 = re.compile(NRREL_REMOVE_MSG_3, re.IGNORECASE)
    nrrel_remove_msg_4 = re.compile(NRREL_REMOVE_MSG_4, re.IGNORECASE)
    nrrel_remove_msg_5 = re.compile(NRREL_REMOVE_INTRAHO_1, re.IGNORECASE)
    nrrel_remove_msg_6 = re.compile(NRREL_REMOVE_INTRAHO_2, re.IGNORECASE)
    nrrel_remove_msg_7 = re.compile(NRREL_REMOVE_INTRAHO_3, re.IGNORECASE)
    nrrel_remove_msg_8 = re.compile(NRREL_REMOVE_INTRAHO_4, re.IGNORECASE)
    nrrel_remove_msg_9 = re.compile(NRREL_REMOVE_INTRAHO_5, re.IGNORECASE)
    nradjnrcell_remove_msg = re.compile(NRADJNRCELL_REMOVE_MSG, re.IGNORECASE)
    nradjgnb_remove_msg = re.compile(NRADJGNB_REMOVE_MSG, re.IGNORECASE)
    xnlink_remove_msg = re.compile(XNLINK_REMOVE_MSG, re.IGNORECASE)
    msg1 = msg2 = msg3 = msg4 = msg5 = msg6 = msg7 = msg8 = msg9 = msg10 = msg11 = msg12 = False
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
        if nrrel_remove_msg_5.match(line):
            msg5 = True
            blog(nrrel_remove_msg_5.match(line).group(0))
        if nrrel_remove_msg_6.match(line):
            msg6 = True
            blog(nrrel_remove_msg_6.match(line).group(0))
        if nrrel_remove_msg_7.match(line):
            msg7 = True
            blog(nrrel_remove_msg_7.match(line).group(0))
        if nrrel_remove_msg_8.match(line):
            msg8 = True
            blog(nrrel_remove_msg_8.match(line).group(0))
        if nrrel_remove_msg_9.match(line):
            msg9 = True
            blog(nrrel_remove_msg_9.match(line).group(0))
        if nradjnrcell_remove_msg.match(line):
            msg10 = True
            blog(nradjnrcell_remove_msg.match(line).group(0))
        if nradjgnb_remove_msg.match(line):
            msg11 = True
            blog(nradjgnb_remove_msg.match(line).group(0))
        if xnlink_remove_msg.match(line):
            msg12 = True
            blog(xnlink_remove_msg.match(line).group(0))
        if all([msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8, msg9, msg10, msg11, msg12]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}, msg3={}, msg4={}, msg5={}, '
                     'msg6={}, msg7={}, msg8={}, msg9={}, msg10={}, msg11={}, msg12={}'.format
                     (msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8, msg9, msg10, msg11, msg12))


def check_removal_syslog_messages_for_online_modification(syslog_path):
    nrrel_remove_msg_1 = re.compile(NRREL_REMOVE_MSG_1, re.IGNORECASE)
    nrrel_remove_msg_2 = re.compile(NRREL_REMOVE_MSG_2, re.IGNORECASE)
    nrrel_remove_msg_3 = re.compile(NRREL_REMOVE_MSG_3, re.IGNORECASE)
    nrrel_remove_msg_4 = re.compile(NRREL_REMOVE_MSG_4, re.IGNORECASE)
    nrrel_remove_msg_5 = re.compile(NRREL_REMOVE_MSG_5, re.IGNORECASE)
    nrrel_remove_msg_6 = re.compile(NRREL_REMOVE_MSG_6, re.IGNORECASE)
    nrrel_remove_msg_7 = re.compile(NRREL_REMOVE_MSG_7, re.IGNORECASE)
    nradjnrcell_remove_msg = re.compile(NRADJNRCELL_REMOVE_MSG, re.IGNORECASE)
    nradjgnb_remove_msg = re.compile(NRADJGNB_REMOVE_MSG, re.IGNORECASE)
    xnlink_remove_msg = re.compile(XNLINK_REMOVE_MSG, re.IGNORECASE)
    msg1 = msg2 = msg3 = msg4 = msg5 = msg6 = msg7 = msg8 = msg9 = msg10 = False
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
        if nrrel_remove_msg_5.match(line):
            msg5 = True
            blog(nrrel_remove_msg_5.match(line).group(0))
        if nrrel_remove_msg_6.match(line):
            msg6 = True
            blog(nrrel_remove_msg_6.match(line).group(0))
        if nrrel_remove_msg_7.match(line):
            msg7 = True
            blog(nrrel_remove_msg_7.match(line).group(0))
        if nradjnrcell_remove_msg.match(line):
            msg8 = True
            blog(nradjnrcell_remove_msg.match(line).group(0))
        if nradjgnb_remove_msg.match(line):
            msg9 = True
            blog(nradjgnb_remove_msg.match(line).group(0))
        if xnlink_remove_msg.match(line):
            msg10 = True
            blog(xnlink_remove_msg.match(line).group(0))
        if all([msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8, msg9, msg10]):
            return True
    raise ValueError('No msg found in syslog. Messages status: msg1={}, msg2={}, msg3={}, msg4={}, msg5={}, '
                     'msg6={}, msg7={}, msg8={}, msg9={}, msg10={}'.format(
                      msg1, msg2, msg3, msg4, msg5, msg6, msg7, msg8, msg9, msg10))


def get_params_for_nradjnrcell_object():
    parameter = [
        {"parameterName": "cellDepType", "operation": "update", "value": "SA+NSA"},
        {"parameterName": "fiveGsTac", "operation": "update", "value": "7152"},
        {"parameterName": "freqBandIndicatorNR", "operation": "update", "value": "66"},
        {"parameterName": "gNbId", "operation": "update", "value": "50848"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "24"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]},
        {"parameterName": "lcrId", "operation": "update", "value": "1"},
        {"parameterName": "nrarfcn", "operation": "update", "value": "434000"},
        {"parameterName": "physCellId", "operation": "update", "value": "999"},
        {"parameterName": "ssbFrequency", "operation": "update", "value": "433970"},
    ]
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if not sw_release == 'SBTS23R3':
            parameter.append({"parameterName": "cellReservedForOperatorUse",
                              "value": "notReserved", "operation": "update"})
    return parameter


def get_params_for_nrrel_object():
    parameter = [
        {"parameterName": "cellIndividualSsbRsrpOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "cellIndividualSsbRsrqOffset", "operation": "update", "value": "0dB"},
        {"parameterName": "gNbId", "operation": "update", "value": "50848"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "24"},
        {"parameterName": "lcrId", "operation": "update", "value": "1"},
        {"parameterName": "removeNotAllowed", "operation": "update", "value": "false"},
        {"parameterName": "handoverAllowedSA", "operation": "update", "value": "allowed"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]},
        {"parameterName": "nrDcAllowed", "operation": "update", "value": "false"}
    ]
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if sw_release == 'SBTS23R2':
            parameter.append({"parameterName": "handoverAllowedSARedCap", "operation": "update", "value": "forbidden"})
        else:
            parameter.append({"parameterName": "handoverAllowedSARedCap", "operation": "update", "value": "forbidden"})
            parameter.append({"parameterName": "isRplCellForPSCell", "operation": "update", "value": "false"})
    return parameter


def get_params_for_nradjgnb_object():
    parameter = [
        {"parameterName": "administrativeState", "operation": "update", "value": "Unlocked"},
        {"parameterName": "gNbIdLength", "operation": "update", "value": "24"},
        {"parameterName": "gnbPlmn", "operation": "update", "value": [{"mcc": 540, "mnc": 1, "mncLength": 2}]},
        {"parameterName": "gNodeBId", "operation": "update", "value": "50848"},
        {"parameterName": "gNodeBIdCtrl", "operation": "update", "value": "oamControlled"},
        {"parameterName": "xnLinkRef", "operation": "update", "value": "1"},
    ]
    return parameter


def get_params_for_xnlink_object():
    parameter = [
        {"parameterName": "cPlaneIpAddr", "operation": "update", "value": "10.44.224.106"},
        {"parameterName": "cPlaneIpAddrCtrl", "operation": "update", "value": "oamControlled"},
        {"parameterName": "xnLinkId", "operation": "update", "value": "1"},
    ]
    return parameter
