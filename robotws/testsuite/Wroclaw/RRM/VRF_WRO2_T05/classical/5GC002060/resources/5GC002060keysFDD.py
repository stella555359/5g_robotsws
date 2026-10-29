from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *

# using_mcshark = False


def generated_pcap_data(pcap_path):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output = tshark \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_puschReceiveReqGrant_t.mcs '
                                          '-e UlData_puschReceiveReqGrant_t.numOfPrb '
                                          '-e UlData_puschReceiveReqGrant_t.startPrb') \
            .build()
    else:
        output = tshark.with_attached_lua_scripts() \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PuschReceiveReq.grants_item_15.mcs '
                                          '-e UlData_PuschReceiveReq.grants_item_15.numOfPrb '
                                          '-e UlData_PuschReceiveReq.grants_item_15.startPrb') \
            .build()
        remove_luashark_loading_from_output(output=output)
    print("OUTPUT: ", output)
    # for line in output:
    #     line = line.split("\t")
    #     message = SubCell(line[0], line[1], line[2], line[3])
    #     pcap_data.append(message)
    return output


def check_ue_ip_address(pcap_path):

    result = False
    pcap_data = generated_pcap_data(pcap_path)
    if prb_mcs in pcap_data:
        result = True
    return result
