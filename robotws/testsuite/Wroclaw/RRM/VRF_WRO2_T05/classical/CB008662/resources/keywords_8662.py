from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *
from taf.sbts.oam.coam.admin import AdminConnection

ca_subcells = {'1', '2'}


def get_sw_release():
    bts = AdminConnection()
    sw_release = bts.get_sw_release_name()
    return sw_release


filter_dl = '(DlData_PdschGrantL1sw.mcs > 27) or (DlData_PdschGrantLoner.mcs > 27)'
filter_ul = 'UlData_puschReceiveReqGrant_t.mcs>27'


def check_reserved_mcs_ul(pcap_path):
    result = False
    pcap_data = generated_pcap_data_ul(pcap_path)
    print("len: ", len(pcap_data))
    if len(pcap_data) > 1:
        result = True
    return result


def check_reserved_mcs_dl(pcap_path):
    result = False
    pcap_data = generated_pcap_data_dl(pcap_path)
    print("len: ", len(pcap_data))
    if len(pcap_data) > 1:
        result = True
    return result


def check_reserved_mcs_dl_ca(pcap_path):
    result = False
    pcap_data = generated_pcap_data_dl_ca(pcap_path)
    if (ca_subcells.issubset(pcap_data)) is True:
        print("len: ", len(pcap_data))
        if len(pcap_data) > 3:
            result = True
    return result


def generated_pcap_data_ul(pcap_path):
    sw = get_sw_release()
    if sw > 'SBTS25R1':
        filter_ul = 'UlData_puschReceiveReqGrant_t.mcs > 27'
    else:
        filter_ul = 'UlData_puschReceiveReqGrant_t.mcs > 27'
    tshark = TSharkCommandAssembler()
    output = tshark \
        .with_filter(filter_ul) \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters('-T fields -e UlData_puschReceiveReqGrant_t.mcs') \
        .build()
    print("OUTPUT: ", output)
    return output


def generated_pcap_data_dl(pcap_path):
    sw = get_sw_release()
    if sw > 'SBTS25R1':
        filter_dl = '(DlData_PdschGrantL1sw.mcs > 27) || (DlData_PdschGrantLoner.mcs > 27)'
    else:
        filter_dl = 'DlData_PdschGrant.mcs > 27'
    tshark = TSharkCommandAssembler()
    output = tshark \
        .with_filter(filter_dl) \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters('-T fields -e UlData_puschReceiveReqGrant_t.mcs') \
        .build()

    print("OUTPUT: ", output)
    return output


def generated_pcap_data_dl_ca(pcap_path):
    tshark = TSharkCommandAssembler()
    sw = get_sw_release()
    if sw > 'SBTS25R1':
        filter_dl = 'DlData_PdschGrantL1sw.mcs > 27'
    else:
        filter_dl = 'DlData_PdschGrant.mcs > 27'
    output = tshark \
        .with_filter(filter_dl) \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters('-T fields -e 3gpp.subcellid') \
        .build()
    print("OUTPUT: ", output)
    return output


def check_counters_8662_ca(counter_list):
    counter_group_pcell = []
    counter_group_scell = []
    temp = 0
    for counter in counter_list:
        for countervalue in counter.values():
            counter_group_pcell.append(countervalue.get('2'))
            counter_group_scell.append(countervalue.get('3'))
    for element in counter_group_pcell:
        if element == 0:
            temp += 1
            if temp == 4:
                return False
        else:
            temp = 0
    for element in counter_group_scell:
        if element == 0:
            temp += 1
            if temp == 4:
                return False
        else:
            temp = 0
    print(counter_group_pcell)
    print(counter_group_scell)
    return True


def check_counters_8662(counter_list):
    counter_group = []
    temp = 0
    for counter in counter_list:
        for countervalue in counter.values():
            counter_group.append(countervalue.get('2'))
    for element in counter_group:
        if element == 0:
            temp += 1
            if temp == 4:
                return False
        else:
            temp = 0
    print(counter_group)
    return True
