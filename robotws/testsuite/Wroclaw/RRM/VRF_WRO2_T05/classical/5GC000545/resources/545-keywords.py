# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Sebastian Mikos
:contact: sebastian.mikos@nokia.com
"""

from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from collections import Counter
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *

dci_for_tp_off = '0x00000028'
dci_for_tp_on = '0x00000026'
dci_for_tp_off_20 = '0x0000002B'
dci_for_tp_on_20 = '0x00000029'
# using_mcshark = False


class Filters:
    TP_ON_FILTER = 'UlData_PuschReceiveReq.grants_item_0.puschTransformPrecoderFlag == 1'
    TP_OFF_FILTER = 'UlData_PuschReceiveReq.grants_item_0.puschTransformPrecoderFlag == 0'
    DCI_FOR_TP_OFF = 'DlData_PdcchSendReq.dciInfo_item_0.dciSize == 0x00000028'
    DCI_FOR_TP_ON = 'DlData_PdcchSendReq.dciInfo_item_0.dciSize == 0x00000026'
    TP_FLAG = 'UlData_PuschReceiveReq.grants_item_0.puschTransformPrecoderFlag'
    DCI_FLAG = 'DlData_PdcchSendReq.dciInfo_item_0.dciSize'


class Filters_mcshark:
    TP_ON_FILTER = 'UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag == 1'
    TP_OFF_FILTER = 'UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag == 0'
    DCI_FOR_TP_OFF = 'DlData_DciInfo.dciSize == 40'
    DCI_FOR_TP_ON = 'DlData_DciInfo.dciSize == 38'
    DCI_FOR_TP_OFF_20 = 'DlData_DciInfo.dciSize == 43'
    DCI_FOR_TP_ON_20 = 'DlData_DciInfo.dciSize == 41'
    TP_FLAG = 'UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag'
    DCI_FLAG = ['DlData_DciInfo.dciSize', 'DlData_DciInfoL1sw.dciSize']


common_dci_on = 0
common_dci_off = 0


def create_tshark_command(msg_filter, pcap, parameters, using_mcshark=False):
    tshark = TSharkCommandAssembler()
    try:
        if using_mcshark:
            output = tshark \
                .with_filter(msg_filter) \
                .with_pcap_file(pcap_file=pcap) \
                .inject_additional_parameters('-T fields -e '+parameters)\
                .build()
        else:
            output = tshark.with_attached_lua_scripts() \
                .with_filter(msg_filter) \
                .with_pcap_file(pcap_file=pcap) \
                .inject_additional_parameters('-T fields -e '+parameters)\
                .build()
            remove_luashark_loading_from_output(output=output)
        return output
    except Exception:
        return []


if using_mcshark:
    print("MCShark detected")
    Filters = Filters_mcshark


def most_frequent(List):
    counter = 0
    try:
        num = List[0]
        for i in List:
            curr_frequency = List.count(i)
            if (curr_frequency > counter):
                counter = curr_frequency
                num = i
        return num
    except Exception:
        return 0


def check_transform_precoder_on(pcap_path):
    result = False
    pcap_data = create_tshark_command(Filters.TP_ON_FILTER, pcap_path, Filters.TP_FLAG, using_mcshark)
    if '1' in pcap_data:
        result = True
    return result


def check_transform_precoder_off(pcap_path):
    result = False
    pcap_data = create_tshark_command(Filters.TP_OFF_FILTER, pcap_path, Filters.TP_FLAG, using_mcshark)
    if '0' in pcap_data:
        result = True
    return result


def check_dci_for_tp_off(pcap_path1):
    global common_dci_off
    for index, filter in enumerate(Filters.DCI_FLAG):
        pcap_data1 = create_tshark_command(filter, pcap_path1, Filters.DCI_FLAG[index], using_mcshark)
        common_dci_off = most_frequent(pcap_data1)
        filter = filter + " == " + common_dci_off
        pcap_data1 = create_tshark_command(filter, pcap_path1, Filters.DCI_FLAG[index], using_mcshark)
        if 38 <= int(common_dci_off) <= 42:
            if int(common_dci_off, 16) in [int(x, 16) for x in pcap_data1 if "," not in x] or \
                    int(common_dci_off, 10) in [int(x, 10) for x in pcap_data1 if "," not in x]:
                return True


def check_dci_for_tp_on(pcap_path2):
    global common_dci_off
    for index, filter in enumerate(Filters.DCI_FLAG):
        print("filter: ", filter)
        common_dci_on = str(int(common_dci_off) - 2)
        filter = filter + ' == ' + str(common_dci_on)
        pcap_data2 = create_tshark_command(filter, pcap_path2, Filters.DCI_FLAG[index], using_mcshark)
        if int(common_dci_on, 16) in [int(x, 16) for x in pcap_data2 if "," not in x] or \
                int(common_dci_on, 10) in [int(x, 10) for x in pcap_data2 if "," not in x]:
            return True


def check_dci_for_tp_off_20MHz(pcap_path1):
    global common_dci_off
    for index, filter in enumerate(Filters.DCI_FLAG):
        pcap_data1 = create_tshark_command(filter, pcap_path1, Filters.DCI_FLAG[index], using_mcshark)
        common_dci_off = most_frequent(pcap_data1)
        filter = filter + " == " + str(common_dci_off)
        pcap_data1 = create_tshark_command(filter, pcap_path1, Filters.DCI_FLAG[index], using_mcshark)
        if 39 <= int(common_dci_off) <= 43:
            if int(common_dci_off, 16) in [int(x, 16) for x in pcap_data1 if "," not in x] or \
                    int(common_dci_off, 10) in [int(x, 10) for x in pcap_data1 if "," not in x]:
                return True


def check_dci_for_tp_on_20MHz(pcap_path2):
    global common_dci_off
    for index, filter in enumerate(Filters.DCI_FLAG):
        common_dci_on = str(int(common_dci_off) + 2)
        filter = filter + " == " + common_dci_on
        pcap_data2 = create_tshark_command(filter, pcap_path2, Filters.DCI_FLAG[index], using_mcshark)
        if int(common_dci_on, 16) in [int(x, 16) for x in pcap_data2 if "," not in x] or \
                int(common_dci_on, 10) in [int(x, 10) for x in pcap_data2 if "," not in x]:
            return True
