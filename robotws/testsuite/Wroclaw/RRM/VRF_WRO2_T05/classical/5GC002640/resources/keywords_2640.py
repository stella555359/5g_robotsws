from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *
from taf.sbts.oam.coam.admin import AdminConnection
from itertools import groupby

subcells = 3
subcells_release = 2
subcells_8533_A = 5
unwanted_slots = [0, 5, 9]
# subcells = '0x00000000' and '0x00000001' and '0x00000002'
# subcells_8533_A = '0x00000000' and '0x00000001' and '0x00000002' and '0x00000003' and '0x00000004'
# unwanted_slots = '0x00000000' and '0x00000005' and '0x00000009'
# using_mcshark = False


class Filters:
    PUCCH_SUBCELL_FILTER_UL = 'UlData_pucchReceiveReqPucchResource_t.pucchFormat == 3 \
             && uldata_pucchreceiverespps && 3gpp.subcellid == 1'
    SLOT_ABSENCE_FILTER = 'dldata_pdschsendreq && 3gpp.subcellid==1'
    SUBCELL_FILTER_DL = 'dldata_pdschpayloadtbsendreq && 3gpp.subcellid'
    HARQ_FILTER = 'uldata_puschreceiverespharqu'
    CSI_FILTER = 'dldata_csirssendreq && 3gpp.subcellid'
    CSI_FLAG = '3gpp.subcellid'
    SUBCELL_FLAG_UL = '3gpp.subcellid'
    SUBCELL_FLAG_DL = '3gpp.subcellid'
    PUCCH_FLAG_UL = 'UlData_pucchReceiveReqPucchResource_t.pucchFormat'
    PDSCHSENDREQ = '3gpp.slot'
    PDCCHSENDREQ = '3gpp.slot'
    SSBLOCKSENDREQ = '3gpp.slot'
    CSIRSSENDREQ = '3gpp.slot'
    HARQ_FLAG = '3gpp.subcellid'


class Filters_mcshark:
    PUCCH_SUBCELL_FILTER_UL = 'UlData_pucchReceiveReqPucchResourceLoner_t.pucchFormat == 3 \
             && uldata_pucchreceiveresppsloner && 3gpp.subcellid == 1'
    SLOT_ABSENCE_FILTER = 'dldata_pdschsendreqloner && 3gpp.subcellid==1'
    SUBCELL_FILTER_DL = 'dldata_pdschpayloadtbsendreqloner && 3gpp.subcellid'
    HARQ_FILTER = 'uldata_puschreceiverespharquloner'
    CSI_FILTER = '(dldata_csirssendreqloner || dldata_csirssendreql1sw) && 3gpp.subcellid'
    CSI_FLAG = '3gpp.subcellid'
    SUBCELL_FLAG_UL = '3gpp.subcellid'
    SUBCELL_FLAG_DL = '3gpp.subcellid'
    PUCCH_FLAG_UL = 'UlData_pucchReceiveReqPucchResourceLoner_t.pucchFormat'
    PDSCHSENDREQ = '3gpp.slot'
    PDCCHSENDREQ = '3gpp.slot'
    SSBLOCKSENDREQ = '3gpp.slot'
    CSIRSSENDREQ = '3gpp.slot'
    HARQ_FLAG = '3gpp.subcellid'


if using_mcshark:
    print("MCShark detected")


def get_sw_release():
    bts = AdminConnection()
    return bts.get_sw_release_name()


def create_tshark_command(pcap, msg_filter, using_mcshark=False, *parameters):
    tshark = TSharkCommandAssembler()
    parameter_str = ''
    parameters_str = ''
    for parameter in parameters:
        parameter_str = ' -e '+parameter
        parameters_str += parameter_str
    if using_mcshark:
        output = tshark \
            .with_filter(msg_filter) \
            .with_pcap_file(pcap_file=pcap) \
            .inject_additional_parameters('-T fields' + parameters_str)\
            .build()
        output_list = [x for x in output]
        try:
            output = check_bytes(output_list)
        except Exception:
            output = output_list
    else:
        output = tshark.with_attached_lua_scripts() \
            .with_filter(msg_filter) \
            .with_pcap_file(pcap_file=pcap) \
            .inject_additional_parameters('-T fields' + parameters_str) \
            .build()
        remove_luashark_loading_from_output(output=output)
        output_list = [x for x in output]
        try:
            output = check_bytes(output_list)
        except Exception:
            output = output_list
    print("OUTPUT: ", output)
    return output


def check_CSI_RS(pcap_path, cells=subcells):
    global Filters
    Filters = Filters_mcshark
    if len(set(create_tshark_command
               (pcap_path, Filters.CSI_FILTER, using_mcshark, Filters.CSI_FLAG))) >= cells:
        result = True
    return result


def check_CQI(pcap_path):
    result = False
    global Filters
    if get_sw_release() > 'SBTS25R1':
        Filters = Filters_mcshark
    if len(create_tshark_command(pcap_path, Filters.PUCCH_SUBCELL_FILTER_UL, using_mcshark, Filters.PUCCH_FLAG_UL,
                                 Filters.SUBCELL_FLAG_UL)) >= 2:
        result = True
    return result


def check_DL_flow(pcap_path, cells=subcells):
    global Filters
    if get_sw_release() > 'SBTS25R1':
        Filters = Filters_mcshark
    return True if len(set(cells)) <= len(set(create_tshark_command(pcap_path,
                                                                    Filters.SUBCELL_FILTER_DL,
                                                                    using_mcshark,
                                                                    Filters.SUBCELL_FLAG_DL))) else False


def check_Pcell_slots(pcap_path):
    global Filters
    if get_sw_release() > 'SBTS25R1':
        Filters = Filters_mcshark
    result = True
    if any(item in unwanted_slots for item in create_tshark_command(pcap_path,
                                                                    Filters.SLOT_ABSENCE_FILTER,
                                                                    using_mcshark,
                                                                    Filters.PDSCHSENDREQ,
                                                                    Filters.PDCCHSENDREQ,
                                                                    Filters.SSBLOCKSENDREQ,
                                                                    Filters.CSIRSSENDREQ)):
        result = False
    return result


def check_UL_flow(pcap_path):
    global Filters
    if get_sw_release() > 'SBTS25R1':
        Filters = Filters_mcshark
    ul_msg_cell = []
    ul_mesgs_list = create_tshark_command(pcap_path,
                                          Filters.PUCCH_SUBCELL_FILTER_UL,
                                          using_mcshark,
                                          Filters.PUCCH_FLAG_UL,
                                          Filters.SUBCELL_FLAG_UL)
    for msg in ul_mesgs_list:
        ul_msg_cell.append(msg.split("\t")[1])
    ul_mesgs_list = groupby(ul_msg_cell)
    return next(ul_mesgs_list, True) and not next(ul_mesgs_list, False)


def check_HARQ(pcap_path):
    global Filters
    sw = get_sw_release()
    if sw > 'SBTS25R1':
        Filters = Filters_mcshark
    harq_mesgs_list = create_tshark_command(pcap_path, Filters.HARQ_FILTER, using_mcshark, Filters.HARQ_FLAG)
    print(harq_mesgs_list.count(harq_mesgs_list[1]))
    print(len(harq_mesgs_list))
    return True if harq_mesgs_list.count(harq_mesgs_list[1]) - (len(harq_mesgs_list)) < 5 else False


def short_pcap(mesgs):
    print("Used short pcap")
    for i in range(len(mesgs)):
        mesgs[i] = int(mesgs[i], 16)
    return mesgs


def long_pcap(mesgs):
    print("Used long pcap")
    for i in range(len(mesgs)):
        mesgs[i] = int(mesgs[i][2:-1], 16)
    return mesgs


def check_bytes(mesgs):
    bytemesgs = False
    for i in mesgs:
        if "b" in i:
            bytemesgs = True
    return long_pcap(mesgs) if bytemesgs is True else short_pcap(mesgs)
