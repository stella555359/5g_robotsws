from robot.api import logger
import os
import testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_1118.attenuator_keywords as att
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.preconditions_py import bts_prefix
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.webUI_operations import WebUIOperations, \
    get_parameter_value_from_webui
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.pcap_verification.tsharkWithLuaVerifier import \
    TSharkCommandAssembler, get_all_frames
from mcs.PuschFrame import PuschFrame
from mcs.mcs_parsing import mcs_filter, get_frames_for_rntis_mapping, get_mcs_table, get_mcs_average
import testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.rrm_fixture as fixture
import re
import json
from itertools import groupby
from taf.sbts.oam.coam.admin import admin

files = None
path = os.getcwd()
webui = admin()


def clear_attenuation_if_initialised():
    try:
        att.nullify_attenuation_on_all_ports()
    except att.AttenuatorNotConfigured:
        pass


def get_all_local_cells():
    cells = webui.get_cells_info()

    if not cells:
        logger.warn("Couldn't find any cells in WebUI configuration.")
    return cells


def set_ul_256qam_activation_state_for_all_cells(state):
    """
    It's faster than performing each parameter commissioning one by one.

    state should be "true" or "false"
    """

    state = state.lower()
    if state not in ['false', 'true']:
        logger.error("State should be a string 'true' or 'false'")

    delta_list = []
    for cell in get_all_local_cells():
        delta_list.append(create_delta(cell['id']['configuration'], 'actUl256Qam', state))
    delta = json.dumps(delta_list)
    webui.perform_delta_recommissioning(delta_file=delta)


def set_actUlDftSOfdm_activation_state_for_all_cells(state):
    state = state.lower()
    if state not in ['false', 'true']:
        logger.error("State should be a string 'true' or 'false'")

    delta_list = []
    for cell in get_all_local_cells():
        delta_list.append(create_delta(cell['id']['configuration'], 'actUlDftSOfdm', state))

    delta = json.dumps(delta_list)
    webui.perform_delta_recommissioning(delta_file=delta)


def set_trans_precode_for_all_cells(sinr_off=20, sinr_on=18):
    value = {
        "ulTransPrecodeOffSinrThresh": int(sinr_off) * 10,
        "ulTransPrecodeOnSinrThresh": int(sinr_on) * 10,
        "ulTransPrecodePi2Bpsk": "true",
        "ulTransPrePi2BpskPwrBoost": "false"
    }

    delta_list = []
    for cell in get_all_local_cells():
        delta_list.append(create_delta(cell['id']['configuration'], 'ulTransPrecodeCtl', [value]))

        delta = json.dumps(delta_list)
        webui.perform_delta_recommissioning(delta_file=delta)


def set_trans_precode_for_all_cells_23R2(sinr_off=20, sinr_on=18):
    value = {
        "ulTransPrecodeOffSinrThresh": int(sinr_off) * 10,
        "ulTransPrecodeOffSinrThrRedCap": int(sinr_off) * 10,
        "ulTransPrecodeOnSinrThresh": int(sinr_on) * 10,
        "ulTransPrecodeOnSinrThrRedCap": int(sinr_on) * 10,
        "ulTransPrecodePi2Bpsk": "true",
        "ulTransPrePi2BpskPwrBoost": "false"
    }

    delta_list = []
    for cell in get_all_local_cells():
        delta_list.append(create_delta(cell['id']['configuration'], 'ulTransPrecodeCtl', [value]))

        delta = json.dumps(delta_list)
        webui.perform_delta_recommissioning(delta_file=delta)


def create_delta(distname, parameter_name, parameter_value):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": parameter_value,
                "operation": "update"
            }
        ]
    }
    return parameter_delta


def load_logs_with_luashark(pcap_file_location, pcap_filter):
    tshark = TSharkCommandAssembler()
    output = tshark.with_attached_lua_scripts() \
        .with_filter(pcap_filter) \
        .with_pcap_file(pcap_file_location) \
        .build()
    return ''.join(output)


def load_logs_without_luashark(pcap_file_location, pcap_filter):
    tshark = TSharkCommandAssembler()
    output = tshark.with_filter(pcap_filter) \
        .with_pcap_file(pcap_file_location) \
        .build()
    return ''.join(output)


def verify_handover(pcap_file, src_pci, dst_pci):
    src_pci = int(src_pci)
    dst_pci = int(dst_pci)

    # output = load_logs_with_luashark(pcap_file, 'f1ap.procedureCode == 7 && nr-rrc.physCellId')
    # output = load_logs_with_luashark(pcap_file, 'f1ap.procedureCode == 11 && nr-rrc.physCellId')
    output = load_logs_without_luashark(pcap_file, 'f1ap.procedureCode == 11 && nr-rrc.physCellId')

    cell_ids_str = re.findall(r'nRCellIdentity.*?value\s+(\d+)', output, re.MULTILINE)
    # cell_ids_str = re.findall(r'spCellConfigCommon\s+physCellId: (\d+)', output, re.MULTILINE)
    cell_ids = [int(cell_id) for cell_id in cell_ids_str]

    assert dst_pci in cell_ids, 'Destination cell {} not found in PCAP logs'.format(dst_pci)
    # Check cell IDs in the RRC Reconfiguration message
    # serving_cell_res = re.findall(r'measResultServingCell\s+physCellId: (\d+)', output, re.MULTILINE)
    serving_cell_res = re.findall(r'physCellId: (\d+)', output, re.MULTILINE)
    serving_cell = int(serving_cell_res[0])
    assert src_pci == serving_cell, 'The measResultServingCell should be {}'.format(src_pci)

    # meas_result_cells = re.findall(r'MeasResultNR\s+physCellId: (\d+)', output, re.MULTILINE)
    # meas_result_cells = [int(cell) for cell in meas_result_cells]
    # assert dst_pci in meas_result_cells, 'The MeasResultNR should be {}'.format(dst_pci)


def get_frames_for_rntis_mapping_from_bips(pcap_file_ue_1, pcap_file_both_ues):
    frames_1 = get_all_frames(pcap_file=pcap_file_ue_1, lua_attached=False, ts_filter=mcs_filter)
    frames_2 = get_all_frames(pcap_file=pcap_file_both_ues, lua_attached=False, ts_filter=mcs_filter)
    frames = frames_1 + frames_2

    mcs_frames = [PuschFrame(frame) for frame in frames]
    frames_for_rnti = get_frames_for_rntis_mapping(mcs_frames)

    return frames_for_rnti


def verify_bip_logs_for_activation_test(pcap_file_ue_1, pcap_file_both_ues):
    frames_for_rnti = get_frames_for_rntis_mapping_from_bips(pcap_file_ue_1, pcap_file_both_ues)

    rntis_count = len(frames_for_rnti.keys())
    assert rntis_count == 2, 'Found {} RNTIs. Should have found 2.'.format(rntis_count)

    # We can do that since frames_for_rntis is an OrderedDict.
    # UE1 should appear first in PCAP, as its data transfer started first.
    ue_1_frames = list(frames_for_rnti.values())[0]
    ue_2_frames = list(frames_for_rnti.values())[1]

    assert get_mcs_table(ue_1_frames) == '64QAM', 'Modulation for first UE should be 64QAM'
    assert get_mcs_table(ue_2_frames) == '256QAM', 'Modulation for second UE should be 256QAM'

    v = fixture.get_robot_variable

    msg = 'Wrong MCS for %s'
    assert int(v('${64_mod_ord_6_mcs_min}')) <= get_mcs_average(ue_1_frames) <= int(v('${64_mcs_max}')), msg % 'UE 1'
    assert int(v('${256_mod_ord_8_mcs_min}')) <= get_mcs_average(ue_2_frames) <= int(v('${256_mcs_max}')), msg % 'UE 2'


def get_trans_precoder(frame):
    trans_precoder = re.findall(r"transformPrecoder: (enabled|disabled)", str(frame))[0]
    return trans_precoder


def verify_transform_precoder_activation(pcap):
    """
    Gradually attenuates all cells and checks for transformPrecodingEnabled.
    """
    # frames = get_all_frames(pcap_file=pcap, lua_attached=True, ts_filter='nr-rrc.transformPrecoder')
    frames = get_all_frames(pcap_file=pcap, lua_attached=False, ts_filter='nr-rrc.transformPrecoder')
    trans_precoders = [get_trans_precoder(frame) for frame in frames]
    precoders_grouped = [p for p, _ in groupby(trans_precoders)]

    assert precoders_grouped == ['disabled', 'enabled', 'disabled'], 'The transform precoders are incorrect.'


def set_servedamf_state(state):

    if state not in ['Locked', 'Unlocked']:
        logger.error("State should be a string 'locked' or 'unlocked'")

    delta_list = []
    delta_list.append(create_delta('{}/SERVEDAMF-1'.format(bts_prefix), 'administrativeState', state))
    delta = json.dumps(delta_list)
    webui.perform_delta_recommissioning(delta_file=delta)


def get_file_for_Load(package):
    release, names = package.split("_", 1)
    if package.find("_9999_") >= 0:
        files = get_file_for_SBTS22R1_Load(package)
    else:
        files = get_file_for_SBTS21B_Load(package)
    return files


def get_file_for_SBTS22R1_Load(package):
    os.chdir(path)
    release1, gnb, brand, packet, names = package.split("_", 4)
    release1 = release1.lstrip("SBTS")
    package = package.replace(release1, "00")
    release, num = package.split("_", 1)
    for i in range(0, 3):
        packet1 = packet.lstrip("0")
        packet = int(packet1) - i
        packet1 = "%06d" % packet
        packet = str(packet1)
        names = names.lstrip("0")
        for m in range(0, 15):
            if i == 0:
                name = int(names) - m
            else:
                name = 15 - m
            if name == 0:
                break
            name1 = "%06d" % name
            name1 = str(name1)
            files = (
                release
                + "_"
                + gnb
                + "_"
                + brand
                + "_"
                + packet
                + "_"
                + name1
                + "_luashark.zip"
            )
        os.system(
            "sudo wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/%s/%s"
            % (release, files)
        )
        file_path = os.path.join(path, files)
        if os.access(file_path, os.F_OK):
            return files
            break
    return "No Found"


def get_file_for_SBTS21B_Load(package):
    os.chdir(path)
    release1, gnb, brand, packet, names = package.split("_", 4)
    release, num = package.split("_", 1)
    for i in range(0, 50):
        packet1 = packet.lstrip("0")
        packet = int(packet1) - i
        packet1 = "%06d" % packet
        packet = str(packet1)
        files = (
            release1
            + "_"
            + gnb
            + "_"
            + brand
            + "_"
            + packet
            + "_"
            + names
            + "_luashark.zip"
        )
        os.system(
            "sudo wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/%s/%s"
            % (release, files)
        )
        file_path = os.path.join(path, files)
        if os.access(file_path, os.F_OK):
            return files
            break
    return "No Found"


def unzip_file(files):
    os.system("rm -rf /home/ute/luashark/*")
    os.chdir(path)
    os.system("mv %s /home/ute/luashark/" % files)
    os.chdir("/home/ute/luashark/")
    os.system("unzip *")
    os.chdir("/home/ute/")
    os.system("rm -rf %s" % files)
