import re
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *

# using_mcshark = False


def generate_dist():
    adminCoam = admin()
    connection = adminCoam.connect_to(name='cOAM')
    bts_info = connection.get_bts_info()
    bts_id = bts_info['mrbtsID']
    object_path = 'MRBTS-{}/NRBTS-{}/'.format(bts_id, bts_id)
    return object_path


def generate_cell_dist():
    adminHelp = AdminHelper()
    cell_dists = adminHelp.get_cells_distname_list()
    return cell_dists


def start_truput(dt_name, ue_alias, direction, duration, throughput, protocol):
    robotapi = robot.robot_api()
    robotapi.start_data_transfer(dt_name=dt_name, ue_alias=ue_alias, direction=direction,
                                 duration=duration, throughput=throughput, bearer_alias='UeAutomatic',
                                 protocol=protocol)
    robotapi.check_data_transfer_is_alive(dt_name=dt_name)
    robotapi.await_data_transfer_finish(dt_name=dt_name)


# def compare_truputs(tpt_1, tpt_2):
#     return int(tpt_1) > int(tpt_2)


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


def generated_pcap_data2(pcap_path):
    tshark = TSharkCommandAssembler()
    if using_mcshark:
        output = tshark \
            .with_filter("dldata_pdschsendreq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e DlData_PdschGrant.mcs '
                                          '-e DlData_PdschGrant.numOfDmrsCdmGroupWithoutData') \
            .build()
    else:
        grants_item = get_grant_item(pcap_path)
        output = tshark.with_attached_lua_scripts() \
            .with_filter("dldata_pdschsendreq") \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e DlData_PdschSendReq.'+grants_item+'.mcs '
                                          '-e DlData_PdschSendReq.'+grants_item+'.numOfDmrsCdmGroupWithoutData') \
            .build()
    remove_luashark_loading_from_output(output=output)
    print("OUTPUT: ", output)
    return output

# *** Documentation ***
# When feature is OFF, numOfDmrs value should be always 2
# when feature is ON and the radio conditions are making the MCS >=20 ==> dmrs value should be 1
# when feature is ON and the radio conditions are making the MCS <20 ==> dmrs value should be 2
# Threshold is respected:
# - above and equal to MCS20, we have multiplexed Data and DMRS
# - below MCS20, numOfDmrsCdmGroupWithoutData =2 means no DMRS and PDSCH multiplexed
# so we need to match this parameter dmrs with the MCS value


def is_correct_mcs(row):
    mcsTxt, dmrsTxt = row.strip().split("\t")
    try:
        mcs = int(mcsTxt, 16)
        dmrs = int(dmrsTxt, 16)
        return (mcs >= 20 and dmrs == 1) or (mcs < 20 and dmrs == 2)
    except ValueError:
        return False


def check_mcs_dmrs_value(pcap_path):
    pcap_data = generated_pcap_data2(pcap_path)
    return any((is_correct_mcs(row) for row in pcap_data))
