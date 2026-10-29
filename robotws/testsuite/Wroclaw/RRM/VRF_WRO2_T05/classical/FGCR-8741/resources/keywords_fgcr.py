import re
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from collections import Counter
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *

# VARIABLES FOR ONE UE
# 27-23
highest_mcs = ["0x1c\t0x0019\t0x0000", "0x18\t0x0019\t0x0000",
               "0x17\t0x0019\t0x0000"]
# 20-16
high_mcs = ["0x0f\t0x0019\t0x0000", "0x0e\t0x0019\t0x0000",
            "0x0d\t0x0019\t0x0000", "0x0c\t0x000d\t0x0000", "0x10\t0x0019\t0x0000"]
# 13-9
medium_mcs = ["0x0b\t0x000d\t0x0006", "0x0b\t0x0019\t0x0000", "0x09\t0x000d\t0x0006",
              "0x08\t0x000b\t0x0009"]
# 8-4
low_mcs = ["0x07\t0x000b\t0x0009", "0x06\t0x0019\t0x0000",
           "0x05\t0x0019\t0x0000", "0x04\t0x0010\t0x0009"]
# 3-0
lowest_mcs = ["0x03\t0x000d\t0x0006", "0x02\t0x000d\t0x0006",
              "0x01\t0x000d\t0x0006", "0x00\t0x000b\t0x0009",
              "0x00\t0x000d\t0x0006", "0x00\t0x0008\t0x0009"]

# prb_mcs = highest_mcs and high_mcs and medium_mcs and low_mcs and lowest_mcs

mcs = ["b'0x0000001c\\t0x0000004f'", "b'0x0000001b\\t0x0000004f'", "b'0x00000015\\t0x00000027'",
       "b'0x00000019\\t0x0000004f'", "b'0x0000001c\\t0x00000041'", "b'0x0000001c\\t0x00000017'",
       "0x1c\t0x0003", "0x1c\t0x0041", "0x1c\t0x0039", "0x1c\t0x0029"]
mcs0 = ["b'0x00000000\\t0x00000018'", "b'0x00000000\\t0x00000004'", "b'0x00000001\\t0x00000004'",
        "0x00\t0x0008", "0x00\t0x000e", "0x00\t0x0027", "0x00\t0x0004"]
mcs1 = ["b'0x00000001\\t0x0000000e'", "b'0x00000001\\t0x00000004'", "b'0x00000002\\t0x00000004'",
        "0x01\t0x0027", "0x01\t0x0008", "0x01\t0x0004"]
mcs2 = ["b'0x00000004\\t0x0000001a'", "b'0x00000002\\t0x0000000e'", "b'0x00000002\\t0x0000001b'",
        "0x02\t0x000e", "0x02\t0x0008"]

# mcs_prb = mcs0 or mcs1 or mcs4 or mcs
# MCshark:
highest_mcs_mc = ["28\t25\t0", "27\t25\t0", "26\t25\t0",
                  "25\t25\t0", "24\t25\t0", "23\t25\t0"]
# 20-14
high_mcs_mc = ["20\t25\t0", "19\t25\t0", "17\t25\t0", "16\t25\t0",
               "15\t25\t0", "14\t25\t0"]
# 13-9
medium_mcs_mc = ["13\t25\t0", "12\t13\t0", "11\t13\t6", "11\t25\t0",
                 "10\t25\t0", "9\t13\t6"]
# 8-4
low_mcs_mc = ["8\t25\t0", "8\t11\t9", "7\t11\t9", "7\t25\t0", "6\t25\t0",
              "6\t3\t0", "5\t25\t0", "5\t13\t6", "5\t3\t0", "4\t10\t9"]
# 3-0
lowest_mcs_mc = ["3\t13\t6", "3\t12\t6", "3\t11\t9", "2\t13\t6",
                 "2\t12\t6", "1\t8\t4", "1\t10\t9", "1\t13\t6", "0\t11\t9",
                 "0\t12\t6", "0\t4\t19", "0\t13\t6", "0\t8\t9"]

# prb_mcs = highest_mcs and high_mcs and medium_mcs and low_mcs and lowest_mcs

mcs_mc = ["b'28\\t79'", "b'27\\t79'", "b'21\\t39'",
          "b'25\\t79'", "b'28\\t65'", "b'28\\t23'",
          "28\t3", "28\t65", "28\t57", "28\t41"]
mcs0_mc = ["b'0\\t24'", "b'0\\t4'", "b'1\\t4'",
           "0\t8", "0\t14", "0\t39", "0\t4"]
mcs1_mc = ["b'1\\t14'", "b'1\\t4'", "b'2\\t4'",
           "0x01\t39", "1\t8", "1\t4"]
mcs2_mc = ["b'4\\t26'", "b'2\\t14'", "b'2\\t27'",
           "2\t14", "2\t8"]

# mcs_prb = mcs0 or mcs1 or mcs4 or mcs


def check_two_rnti(pcap_path):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output = tshark \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e 3gpp.rnti') \
            .build()
    else:
        grants_item = get_grant_item(pcap_path)
        output = tshark.with_attached_lua_scripts() \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PuschReceiveReq.' + grants_item + '.rnti') \
            .build()
        remove_luashark_loading_from_output(output=output)
    rnti = list(dict.fromkeys(output))
    print("OUTPUT: ", rnti)
    return True if len(rnti) >= 2 else False


def get_grant_item(pcap_path):
    tshark = TSharkCommandAssembler()
    grants_item = tshark.with_attached_lua_scripts() \
        .with_filter("dldata_pdschsendreq") \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters("-T pdml") \
        .inject_additional_parameters("-c 1000") \
        .build()
    remove_luashark_loading_from_output(grants_item)
    for item in grants_item:
        cds = (re.search(r"DlData_PdschSendReq.*mcs", item))
        if cds:
            return (re.search(r"grants_item_\d{1,5}", cds.group(0))).group(0)


def check_mcs_one_ue(pcap_path):
    result = False
    pcap_data = generated_pcap_data(pcap_path)
    if using_mcshark:
        if (
            (any(x in highest_mcs_mc for x in pcap_data)) and
            (any(x in high_mcs_mc for x in pcap_data)) and
            (any(x in medium_mcs_mc for x in pcap_data)) and
            (any(x in lowest_mcs_mc for x in pcap_data))
        ):
            result = True
    else:
        if (
            (any(x in highest_mcs for x in pcap_data)) and
            (any(x in high_mcs for x in pcap_data)) and
            (any(x in medium_mcs for x in pcap_data)) and
            (any(x in lowest_mcs for x in pcap_data))
        ):
            result = True
    print("type pcap_data: ", type(pcap_data[1]))
    print("pcap_data: ", pcap_data)
    return result


def check_mcs_two_ues(pcap_path):
    result = False
    pcap_data = generated_pcap_data_for_two_ues(pcap_path)
    if using_mcshark:
        if (
            (any(x in mcs_mc for x in pcap_data)) and
            (any(x in mcs0_mc for x in pcap_data)) and
            (any(x in mcs1_mc for x in pcap_data)) and
            (any(x in mcs2_mc for x in pcap_data))
        ):
            result = True
    else:
        if (
            (any(x in mcs for x in pcap_data)) and
            (any(x in mcs0 for x in pcap_data)) and
            (any(x in mcs1 for x in pcap_data)) and
            (any(x in mcs2 for x in pcap_data))
        ):
            result = True
    return result


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
        grants_item = get_grant_item(pcap_path)
        output = tshark.with_attached_lua_scripts() \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PuschReceiveReq.'+grants_item+'.mcs '
                                          '-e UlData_PuschReceiveReq.'+grants_item+'.numOfPrb '
                                          '-e UlData_PuschReceiveReq.'+grants_item+'.startPrb') \
            .build()
        remove_luashark_loading_from_output(output=output)
    print("OUTPUT: ", output)
    return output


def generated_pcap_data_for_two_ues(pcap_path):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output = tshark \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_puschReceiveReqGrant_t.mcs '
                                          '-e UlData_puschReceiveReqGrant_t.numOfPrb') \
            .build()
    else:
        grants_item = get_grant_item(pcap_path)
        output = tshark.with_attached_lua_scripts() \
            .with_filter("uldata_puschreceivereq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e UlData_PuschReceiveReq.'+grants_item+'.mcs '
                                          '-e UlData_PuschReceiveReq.'+grants_item+'.numOfPrb') \
            .build()
        remove_luashark_loading_from_output(output=output)
    print("OUTPUT: ", output)
    return output
