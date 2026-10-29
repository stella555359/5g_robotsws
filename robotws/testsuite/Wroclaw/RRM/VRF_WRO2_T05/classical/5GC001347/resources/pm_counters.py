from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *

pdschsendreq_params = ['1\t13\t15\t1', '1\t13\t16\t1']
puschreceivereq_params = ['1\t1\t27\t3\t13', '1\t1\t27\t3\t12']
# pdschsendreq_params = '0x00000001\t13\t0x0000000f\t1' or '0x00000001\t12\t0x0000000a\t1'
# puschreceivereq_params = '0x00000001\t1\t0x0000001b\t0x00000003\t13' or '0x00000001\t1\t0x0000001b\t0x00000003\t12'
# using_mcshark = False


def check_dmrs_parameters(pcap_path):
    result = False
    pcap_data = generated_pcap_data(pcap_path)
    pcap_data2 = generated_pcap_data2(pcap_path)
    if any(x in pdschsendreq_params for x in pcap_data):
        if any(x in puschreceivereq_params for x in pcap_data2):
            result = True
    return result


def generated_pcap_data(pcap_path):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output = tshark \
            .with_filter("dldata_pdschsendreq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e DlData_PdschGrant.dlDmrsAddPos '
                                          '-e DlData_PdschGrant.numOfPdschSymbols '
                                          '-e DlData_PdschGrant.mcs '
                                          '-e DlData_PdschGrant.mcsTable') \
            .build()
    else:
        output = tshark.with_attached_lua_scripts() \
            .with_filter("dldata_pdschsendreq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e DlData_PdschSendReq.grants_item_0.dlDmrsAddPos '
                                          '-e DlData_PdschSendReq.grants_item_0.numOfPdschSymbols '
                                          '-e DlData_PdschSendReq.grants_item_0.mcs '
                                          '-e DlData_PdschSendReq.grants_item_0.mcsTable') \
            .build()
        remove_luashark_loading_from_output(output=output)
    print("OUTPUT: ", output)
    return output


def generated_pcap_data2(pcap_path):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output2 = tshark \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_puschReceiveReqGrant_t.ulDmrsAddPos '
                                          '-e UlData_puschReceiveReqGrant_t.ulDmrsConfigType '
                                          '-e UlData_puschReceiveReqGrant_t.mcs '
                                          '-e UlData_puschReceiveReqGrant_t.ulDmrsTypeAPos '
                                          '-e UlData_puschReceiveReqGrant_t.numOfPuschSymbols') \
            .build()
    else:
        output2 = tshark.with_attached_lua_scripts() \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PuschReceiveReq.grants_item_0.ulDmrsAddPos '
                                          '-e UlData_PuschReceiveReq.grants_item_0.ulDmrsConfigType '
                                          '-e UlData_PuschReceiveReq.grants_item_0.mcs '
                                          '-e UlData_PuschReceiveReq.grants_item_0.ulDmrsTypeAPos '
                                          '-e UlData_PuschReceiveReq.grants_item_0.numOfPuschSymbols') \
            .build()
        remove_luashark_loading_from_output(output=output2)
    print("OUTPUT2: ", output2)
    return output2
