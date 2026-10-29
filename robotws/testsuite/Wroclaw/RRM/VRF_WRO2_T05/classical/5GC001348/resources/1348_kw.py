import re
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *

dtx = '0'


def kill_server(UEs):
    if "ffline" in UEs:
        return False
    else:
        return True


def ip_giver(tl_host):
    tl_host = tl_host.replace("-", "_")
    init = open("/home/ute/testline_configuration/"+str(tl_host)+"/__init__.py")
    for i in init:
        if i[:10] == "_ue_pc_ssh":
            ip = re.findall('(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})', i)
            return ip[0]
        else:
            continue


def generated_pcap_data(pcap_path):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output = tshark \
            .with_filter('UlData_UePuschReceiveRespPs_t.dtx == 0') \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_UePuschReceiveRespPs_t.dtx')\
            .build()
    else:
        output = tshark.with_attached_lua_scripts() \
            .with_filter('UlData_PuschReceiveRespPs.grants_item_0.dtx == 0') \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PuschReceiveRespPs.grants_item_0.dtx')\
            .build()
    remove_luashark_loading_from_output(output=output)
    print("OUTPUT: ", output)
    # for line in output:
    #     line = line.split("\t")
    #     message = SubCell(line[0], line[1], line[2], line[3])
    #     pcap_data.append(message)
    return output


def check_dtx(pcap_path):
    # print('OK')
    pcap_data = generated_pcap_data(pcap_path)
    if len(pcap_data) > 0:
        return True
    return False


def generated_pcap_data1(pcap_path1, add_param):
    tshark = TSharkCommandAssembler()
    sfn_val = []
    filter = 'uldata_prachreceivereq || uldata_puschreceiverespps || uldata_puschreceiveresploloner'
    if using_mcshark:
        builder = tshark \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path1) \
            .inject_additional_parameters(add_param)
    else:
        builder = tshark.with_attached_lua_scripts() \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path1) \
            .inject_additional_parameters(add_param)
    output = builder.build()
    remove_luashark_loading_from_output(output=output)
    for line in output:
        if line:
            sfn_val.append(line)
    print("OUTPUT: ", sfn_val)
    return sfn_val


def check_sfn(pcap_path1):
    # print('OK')
    if using_mcshark:
        sfn_data_prachreceivereq = \
            generated_pcap_data1(pcap_path1, '-T fields -e 3gpp.sfn')
        sfn_data_puschreceiverespps = \
            generated_pcap_data1(pcap_path1, '-T fields -e 3gpp.sfn')
        sfn_data_puschreceiveresplo = \
            generated_pcap_data1(pcap_path1, '-T fields -e 3gpp.sfn')
    else:
        sfn_data_prachreceivereq = \
            generated_pcap_data1(pcap_path1, '-T fields -e UlData_PrachReceiveReq.PrachReceiveReq.sfn')
        sfn_data_puschreceiverespps = \
            generated_pcap_data1(pcap_path1, '-T fields -e UlData_PuschReceiveRespPs.PuschReceiveRespPs.sfn')
        sfn_data_puschreceiveresplo = generated_pcap_data1(
            pcap_path1,
            '-T fields -e UlData_PuschReceiveRespLoLoner.UlData_PuschReceiveRespLoLoner.sfn')
    for sfn in sfn_data_prachreceivereq:
        if sfn in sfn_data_puschreceiverespps and sfn_data_puschreceiveresplo:
            return True
        else:
            return False
