import macro_utilities as utilities
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
import os

ru_type = "AEWD"
ru_units_beams_schemes = {
    "AEUB": {
        "1": 8,
        "2": 9,
        "3": 10,
        "4": 11,
        "5": 12,
        "6": 13,
        "7": 14,
        "8": 15,
        "9": 16,
        "10": 17,
        "11": 18,
        "12": 19,
        "13": 20,
        "14": 21,
        "15": 22,
        "16": 23,
        "17": 24,
        "18": 25,
        "19": 26,
        "20": 27,
        "21": 28,
        "22": 29,
        "23": 30,
        "24": 31,
        "25": 32,
        "26": 33,
        "27": 34,
        "28": 35,
        "29": 36,
        "30": 37,
        "31": 38,
        "32": 39},
    "AEUD": {
        "1": 12,
        "2": 13,
        "3": 14,
        "4": 15,
        "5": 16,
        "6": 17,
        "7": 30,
        "8": 31,
        "9": 32,
        "10": 33,
        "11": 34,
        "12": 35,
        "13": 46,
        "14": 47,
        "15": 48,
        "16": 49,
        "17": 268,
        "18": 269,
        "19": 270,
        "20": 271,
        "21": 272,
        "22": 273,
        "23": 286,
        "24": 287,
        "25": 288,
        "26": 289,
        "27": 290,
        "28": 291,
        "29": 302,
        "30": 303,
        "31": 304,
        "32": 305},
    "AEWD": {
        "1": 4,
        "2": 5,
        "3": 6,
        "4": 7,
        "5": 12,
        "6": 13,
        "7": 14,
        "8": 15,
        "9": 20,
        "10": 21,
        "11": 22,
        "12": 23,
        "13": 28,
        "14": 29,
        "15": 30,
        "16": 31,
        "17": 36,
        "18": 37,
        "19": 38,
        "20": 39,
        "21": 44,
        "22": 45,
        "23": 46,
        "24": 47,
        "25": 52,
        "26": 53,
        "27": 54,
        "28": 55,
        "29": 60,
        "30": 61,
        "31": 62,
        "32": 63}
}


def validate_dldata_pdschsendreq_muted_beams(muted_beams):
    tshark_device = DeviceFactory.get_cloned_device("GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "dldata_pdschsendreq" -T fields -e DlData_PdschSendReq.patternId.patternId_item_0  \
        -X lua_script:/opt/luashark/luashark.lua > result""".format(_get_bip_pcap_path())})
    tshark_cmd(timeout=300)
    _validate_muted_beams(muted_beams)
    _remove_data_file()


def validate_dldata_pdcchsendreq_muted_beams(muted_beams):
    tshark_device = DeviceFactory.get_cloned_device("GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "dldata_pdcchsendreq" -T fields -e DlData_PdcchSendReq.patternId.patternId_item_0  \
        -X lua_script:/opt/luashark/luashark.lua > result""".format(_get_bip_pcap_path())})
    tshark_cmd(timeout=300)
    _validate_muted_beams(muted_beams)
    _remove_data_file()


def validate_uldata_pucchreceivereq_muted_beams(muted_beams):
    tshark_device = DeviceFactory.get_cloned_device("GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "uldata_pucchreceivereq" -T fields -e UlData_PucchReceiveReq.patternId.patternId_item_0\
         -X lua_script:/opt/luashark/luashark.lua > result""".format(_get_bip_pcap_path())})
    tshark_cmd(timeout=300)
    _validate_muted_beams(muted_beams)
    _remove_data_file()


def validate_uldata_puschreceivereq_muted_beams(muted_beams):
    tshark_device = DeviceFactory.get_cloned_device("GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "uldata_puschreceivereq" -T fields -e UlData_PuschReceiveReq.patternId.patternId_item_0\
         -X lua_script:/opt/luashark/luashark.lua > result""".format(_get_bip_pcap_path())})
    tshark_cmd(timeout=300)
    _validate_muted_beams(muted_beams)
    _remove_data_file()


def validate_ssb_exclusion():
    tshark_device = DeviceFactory.get_cloned_device("GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "dldata_ssblocksendreq" -T fields -e DlData_SsBlockSendReq.SsBlockSendReq.slot\
         -e DlData_SsBlockSendReq.SsBlockSendReq.activeSsBlocks -e DlData_SsBlockSendReq.patternId.patternId_item_0 \
         -e DlData_SsBlockSendReq.patternId.patternId_item_1 -e DlData_SsBlockSendReq.patternId.patternId_item_2 \
         -e DlData_SsBlockSendReq.patternId.patternId_item_3 -X lua_script:/opt/luashark/luashark.lua > result"""
                                       .format(_get_bip_pcap_path(traffic=False))})
    tshark_cmd(timeout=300)
    _validate_ssb_blocks_and_pattern_ids()
    _remove_data_file()


def validate_ssb_blocks_and_pattern_ids():
    ru_type = "AEWD"
    MolerTest.info("RUTYPE", ru_type)

    def check_values(line, values):
        if line[1] != values["activeSsBlocks"] or line[2] != values["patternId_item_0"]:
            MolerTest.error('Beam was not muted\n{}'.format(line), raise_exception=True)
        else:
            MolerTest.info("slot", line[0])
            MolerTest.info("activeSsBlocks", line[1])

    with open('/home/ute/result') as result_file:
        result_f = result_file.readlines()
        if result_f:
            MolerTest.info("luashark result file OK")
        else:
            MolerTest.error("Result file is empty. Check if luashark is installed properly and check moler logs",
                            raise_exception=True)
        if ru_type == "AEUB":
            correct_values_beam1 = {
                "slot": "0x00000007",
                "activeSsBlocks": "0x00000010",
                "patternId_item_0": "0x00000000",
                "patternId_item_1": "0x00000000",
                "patternId_item_2": "0x00000000",
                "patternId_item_3": "0x00000017\n"
            }
            correct_values_beam2 = {
                "slot": "0x00000001",
                "activeSsBlocks": "0x00000080",
                "patternId_item_0": "0x00000008",
                "patternId_item_1": "0x00000000",
                "patternId_item_2": "0x00000000",
                "patternId_item_3": "0x00000000\n"
            }
        elif ru_type == "AEWD":
            correct_values_beam1 = {
                "slot": "1",
                "activeSsBlocks": "128",
                "patternId_item_0": "6,0,0,0\n"
            }
            correct_values_beam2 = {
                "slot": "7",
                "activeSsBlocks": "16",
                "patternId_item_0": "0,0,0,45\n"
            }
        else:
            MolerTest.error('Not supported ru type', raise_exception=True)

        for line in result_file:
            line = line.split("\t")
            if line[0] == correct_values_beam1["slot"] or line[0] == correct_values_beam2["slot"]:
                line_concern_muted_beam = True
            else:
                line_concern_muted_beam = False

            if not line_concern_muted_beam:
                if line[2] != '0,0,0,0\n':
                    MolerTest.info(line)
                    MolerTest.info(element)
                    MolerTest.error('Wrong beam was muted\n{}'.format(line), raise_exception=True)
            elif line[0] == correct_values_beam1["slot"]:
                check_values(line, correct_values_beam1)
            else:
                check_values(line, correct_values_beam2)


def validate_muted_beams(muted_beams):
    MolerTest.info("RUTYPE", ru_type)
    with open('/home/ute/result') as f:
        used_beams = f.readlines()
    if used_beams:
        packet_number = 1
        for beam in used_beams:
            if int(beam) in _get_forbidden_beams_list(muted_beams):
                MolerTest.error(
                    "Data transfer using beam {} which is muted in packet number {}".format(beam, packet_number),
                    raise_exception=True)
            packet_number = packet_number + 1
        MolerTest.info("All muted beams are NOT used in data transfer")
    else:
        MolerTest.error("Result file is empty. Check if luashark is installed properly and check moler logs",
                        raise_exception=True)


def _remove_data_file():
    tshark_device = DeviceFactory.get_cloned_device("GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    rm_cmd = tshark_device.get_cmd(cmd_name="rm", cmd_params={"file": "/home/ute/result"})
    rm_cmd()


def _get_decimal_values_from_list(beams_list):
    used_decimal_beams = []
    for beam in beams_list:
        used_decimal_beams.append(int(beam, 16))
    return used_decimal_beams


def _get_forbidden_beams_list(muted_beams):
    forbidden_beams = []
    beam_id = 31
    for char in "{:032b}".format(int(muted_beams)):
        if char == "1":
            forbidden_beams.append(beam_id)
        beam_id = beam_id - 1
    f = open("ktbgb.txt", "w")
    f.write(str(forbidden_beams))
    f.close()
    return forbidden_beams


def _get_bip_pcap_path(traffic=True):
    if traffic:
        log_path = utilities.set_test_case_log_path()
        return os.path.join(log_path, "data_transfer", "tcpdumpL2L1_filtering_off.pcap0")
    else:
        return os.path.join(utilities.get_builtin_value('OUTPUT_DIR'), "tcpdumpL2L1_filtering_off.pcap0")


def _get_csv_path(direction):
    log_path = utilities.set_test_case_log_path()
    return os.path.join(log_path,
                        "data_transfer", "tcpdumpL2L1_filtering_off_pcap0_{}_converted.csv".format(direction))


def _match_beams_id_for_internal_beams_id(beams_id_list):
    internal_beams_list = []
    for beam in beams_id_list:
        internal_beams_list.append(ru_units_beams_schemes[ru_type][str(beam)])
    return internal_beams_list
