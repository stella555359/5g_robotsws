# author: Michal Pekala
# contact: michal.pekala.ext@nokia.com

from taf.sbts.oam.coam.admin import admin
from AdminHelper import AdminHelper
import ute_ue.robot_api as robot
import re
import os
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
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

# moved to WRO_7/resources/common.py
# def generate_param_list(param_list):


def get_cells_availability():
    adminCoam = admin()
    cell_dists = generate_cell_dist()
    connection = adminCoam.connect_to(name='cOAM')
    cells_info = connection.get_cells_info(cell_type='nr')
    for cell in range(len(cell_dists)):
        status = cells_info[cell]['status']
        if status['availabilityStatus'] != 'Online':
            return 'Offline'
    return 'Online'


def start_truput(dt_name, ue_alias, direction, duration, throughput, protocol):
    robotapi = robot.robot_api()
    robotapi.start_data_transfer(dt_name=dt_name, ue_alias=ue_alias, direction=direction,
                                 duration=duration, throughput=throughput, bearer_alias='UeAutomatic',
                                 protocol=protocol)
    robotapi.check_data_transfer_is_alive(dt_name=dt_name)
    robotapi.await_data_transfer_finish(dt_name=dt_name)


# def get_counter_value_from_single_cell(counters_list, cell_id, counter_id):
#     for counter in counters_list:
#         if counter_id in counter.keys():
#             temp = counter.get(counter_id)
#             value = temp.get(cell_id)
#             print(value)
#     return value

# now in WRO_7/resources/common.py
# def configure_gnbmirroring_script(file_path, time, size):


def check_if_pdsch_is_on(list):
    is_true = 0
    for value in range(len(list)):
        if list[value] == '0x00000009':
            if list[value + 1] == '0x00000000':
                is_true += 1
            else:
                is_true = 0
        if is_true == 3:
            return True
    return False


# def get_cell_id_from_list(list):
#     cell_id = int(list[0], 16)
#     id_ret = cell_id + 1
#     return str(id_ret)


def check_x2_link_in_gui(status, state):
    with fixture.webUI.WebUIOperations() as coam:
        x2_list_status = coam.get_managed_objects(class_name='LTEENB_R', timeout=30)
        assert x2_list_status[0]['parameters']['x2LinkStatus'] == status, "x2 link is not in status: {}".format(status)
        x2_list_state = coam.get_managed_objects(class_name='LTEENB_A', timeout=30)
        assert x2_list_state[0]['parameters']['x2LinkLock'] == state, "x2 link is not in state: {}".format(state)


def generated_pcap_data_for_subcellid(pcap_path):
    tshark = TSharkCommandAssembler()
    filter = 'dldata_pdschpayloadtbsendreq && !(DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti == 0xffff)'
    filter_mc = 'dldata_pdschpayloadtbsendreq && !(3gpp.rnti == 0xffff)'
    if using_mcshark:
        builder = tshark \
            .with_filter(filter_mc) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e 3gpp.subcellid')
    else:
        builder = tshark.with_attached_lua_scripts() \
            .with_filter(filter) \
            .with_pcap_file(pcap_file=pcap_path) \
            .inject_additional_parameters('-T fields -e DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId')
    output = builder.build()
    remove_luashark_loading_from_output(output=output)
    print("OUTPUT: ", output)
    return output[-1] if output is True else []


# def generated_pcap_data_for_subcellid(pcap_path):
#     tshark = TSharkCommandAssembler()
#     filter = 'dldata_pdschpayloadtbsendreq && !(DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.rnti == 0xffff)'
#     builder = tshark.with_attached_lua_scripts() \
#         .with_filter(filter) \
#         .with_pcap_file(pcap_file=pcap_path) \
#         .inject_additional_parameters('-T fields -e DlData_PdschPayloadTbSendReq.PdschPayloadTbSendReq.subcellId')
#     output = builder.build()
#     remove_luashark_loading_from_output(output=output)
#     output = output[:-1]
#     return output
