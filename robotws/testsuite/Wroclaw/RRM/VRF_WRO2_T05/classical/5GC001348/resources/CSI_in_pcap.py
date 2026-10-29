import re
import time
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *


def get_prach_slot(pcap_path):
    subcell = get_subcellid_harqd(pcap_path)
    tshark = TSharkCommandAssembler()
    filter = 'UlData_PrachReceiveReq.subcells_item_0.subcellId == ' + str(subcell)
    filter_mc = 'uldata_prachreceivereq && 3gpp.subcellid == ' + str(subcell)
    if using_mcshark:
        builder = tshark \
            .with_filter(filter_mc) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e 3gpp.slot')
    else:
        builder = tshark.with_attached_lua_scripts() \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PrachReceiveReq.PrachReceiveReq.slot')
    output = builder.build()
    remove_luashark_loading_from_output(output=output)
    print("OUTPUT_get_prach: ", output)
    print("OUTPUT_get_prach[0]: ", output[0])
    if using_mcshark:
        print("OUTPUT_get_prach_int_val: ", int(output[0]))
        return int(output[0])
    return int(output[0][2:-1], 0)


def get_subcellid_harqd(pcap_path):
    tshark = TSharkCommandAssembler()
    filter = ' uldata_pucchreceiverespharqd'
    if using_mcshark:
        builder = tshark \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e 3gpp.subcellid')
    else:
        builder = tshark.with_attached_lua_scripts() \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PucchReceiveRespHarqD.subcells_item_0.subcellId')
    output = builder.build()
    print("OUTPUT_get_harqd: ", output)
    print("OUTPUT_get_harqd[0]: ", output[0])
    if using_mcshark:
        return int(output[0])
    return int(output[0][2:-1], 0)


def all_harqd_in_slot(pcap_path, slot):
    tshark = TSharkCommandAssembler()
    filter = 'UlData_PucchReceiveRespHarqD.PucchReceiveRespHarqD.slot == ' + str(slot)
    filter_mc = 'uldata_pucchreceiverespharqd && 3gpp.slot == ' + str(slot)
    if using_mcshark:
        builder = tshark \
            .with_filter(filter_mc) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e 3gpp.sfn')
    else:
        builder = tshark.with_attached_lua_scripts() \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PucchReceiveRespHarqD.PucchReceiveRespHarqD.sfn')
    output = builder.build()
    remove_luashark_loading_from_output(output=output)
    sfn_list = [int(x, 0) for x in output]
    sfn_list = [x for x in sfn_list if x % 2 == 1]

    return len(sfn_list)


def check_harqd_in_slot(pcap_path):
    slot = get_prach_slot(pcap_path)
    tshark = TSharkCommandAssembler()
    filter = 'UlData_PucchReceiveRespHarqD.PucchReceiveRespHarqD.slot == ' + str(slot) + " and \
     UlData_PucchReceiveRespHarqD.ackNack.ackNack_item_0 == 128 and \
     UlData_PucchReceiveRespHarqD.pucchResources_item_0.crc == 0 and \
      UlData_PucchReceiveRespHarqD.pucchResources_item_0.dtx == 0"
    filter_mc = 'uldata_pucchreceiverespharqd && 3gpp.slot == ' + str(slot) + " and \
     UlData_pucchReceiveRespHarqDPucchResource_t.crc ==0  and \
    UlData_pucchReceiveRespHarqDPucchResource_t.dtx == 0"
    if using_mcshark:
        builder = tshark \
            .with_filter(filter_mc) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e 3gpp.sfn')
    else:
        builder = tshark.with_attached_lua_scripts() \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PucchReceiveRespHarqD.PucchReceiveRespHarqD.sfn')
    output = builder.build()
    remove_luashark_loading_from_output(output=output)
    sfn_list = [int(x, 0) for x in output]
    sfn_list = [x for x in sfn_list if x % 2 == 1]
    all_sfn_list = all_harqd_in_slot(pcap_path, slot)

    if len(sfn_list) * 100 / all_sfn_list > 20:
        return True
    return False


def check_CSI_reports(pcap_path):
    result = False
    print("Len: ", len(generated_pcap_data(pcap_path)))
    if len(generated_pcap_data(pcap_path)) >= 5:
        # There will be more mesgs, but log collection may relapse to start and catch only some of required values
        result = True
    return result


def generated_pcap_data(pcap_path):
    tshark = TSharkCommandAssembler()
    print("generated_pcap_data")
    slot = get_prach_slot(pcap_path)
    filter = 'UlData_PucchReceiveRespPs.pucchResources_item_2.pucchFormat == 2 && ' \
             'UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot == ' + str(slot)
    filter_mc = 'UlData_pucchReceiveRespPsPucchResource_t.pucchFormat == 2 && ' \
                '3gpp.slot == ' + str(slot)
    if using_mcshark:
        builder = tshark \
            .with_filter(filter_mc) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e 3gpp.slot '
                                          '-e UlData_pucchReceiveRespPsPucchResource_t.pucchFormat')
    else:
        builder = tshark.with_attached_lua_scripts() \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot '
                                          '-e UlData_PucchReceiveRespPs.pucchResources_item_2.pucchFormat')
    # Watch out for pucchFormat, item_2 can be changed to item_175
    output = builder.build()
    print("OUTPUT: ", output)
    remove_luashark_loading_from_output(output=output)
    output_list = [x for x in output]
    print("output_list: ", output_list)
    return output
