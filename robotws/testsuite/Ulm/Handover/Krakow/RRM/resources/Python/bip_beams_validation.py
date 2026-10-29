from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.test_config import set_test_case_log_path
from taf.rfrl.utilities.robot.general import get_builtin_value
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
import os
import re

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
    "AWEUA": {
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "10": 10,
        "11": 11,
        "12": 12,
        "13": 13,
        "14": 14,
        "15": 15,
        "16": 16,
        "17": 17,
        "18": 18,
        "19": 19,
        "20": 20,
        "21": 21,
        "22": 22,
        "23": 23,
        "24": 24,
        "25": 25,
        "26": 26,
        "27": 27,
        "28": 28,
        "29": 29,
        "30": 30,
        "31": 31,
        "32": 32},
    "AWEUB": {
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "10": 10,
        "11": 11,
        "12": 12,
        "13": 13,
        "14": 14,
        "15": 15,
        "16": 16,
        "17": 17,
        "18": 18,
        "19": 19,
        "20": 20,
        "21": 21,
        "22": 22,
        "23": 23,
        "24": 24,
        "25": 25,
        "26": 26,
        "27": 27,
        "28": 28,
        "29": 29,
        "30": 30,
        "31": 31,
        "32": 32}
}

tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
ru_type = tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0].radio_type


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def validate_dldata_pdschsendreq_muted_beams(muted_beams):
    """
    Check if 'dldata_pdschsendreq' packets does NOT contain pattern IDs matched with muted beams.

    :param muted_beams: scf value of 'beamsMuted' parameter
    :return: None
    """
    tshark_device = DeviceFactory.get_cloned_device(
        "GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "dldata_pdschsendreq" -T fields -e DlData_PdschGrant.patternId_item  \
        > result""".format(_get_bip_pcap_path())})
    tshark_cmd(timeout=300)
    _validate_muted_beams(muted_beams)
    _remove_data_file()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def validate_dldata_pdcchsendreq_muted_beams(muted_beams):
    """
    Check if 'dldata_pdcchsendreq' packets does NOT contain pattern IDs matched with muted beams.

    :param muted_beams: scf value of 'beamsMuted' parameter
    :return: None
    """
    tshark_device = DeviceFactory.get_cloned_device(
        "GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "dldata_pdcchsendreq" -T fields -e  DlData_DciInfo.patternId_item \
        > result""".format(_get_bip_pcap_path())})
    tshark_cmd(timeout=300)
    _validate_muted_beams(muted_beams)
    _remove_data_file()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def validate_uldata_pucchreceivereq_muted_beams(muted_beams):
    """
    Check if 'uldata_pucchreceivereq' packets does NOT contain pattern IDs matched with muted beams.

    :param muted_beams: scf value of 'beamsMuted' parameter
    :return: None
    """
    tshark_device = DeviceFactory.get_cloned_device(
        "GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "uldata_pucchreceivereq" -T fields \
        -e UlData_pucchReceiveReqPucchResource_t.patternId_item > result""".format(_get_bip_pcap_path())})
    tshark_cmd(timeout=300)
    _validate_muted_beams(muted_beams)
    _remove_data_file()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def validate_uldata_puschreceivereq_muted_beams(muted_beams):
    """
    Check if 'uldata_puschreceivereq' packets does NOT contain pattern IDs matched with muted beams.

    :param muted_beams: scf value of 'beamsMuted' parameter
    :return: None
    """
    tshark_device = DeviceFactory.get_cloned_device(
        "GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "uldata_puschreceivereq" -T fields -e UlData_eCpriConfigStruct_t.patternId_item\
         > result""".format(_get_bip_pcap_path())})
    tshark_cmd(timeout=300)
    _validate_muted_beams(muted_beams)
    _remove_data_file()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def validate_ssb_exclusion():
    tshark_device = DeviceFactory.get_cloned_device(
        "GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    tshark_cmd = tshark_device.get_cmd(cmd_name="tshark", cmd_params={
        "options": """-r {} -Y "dldata_ssblocksendreq" -T fields -e 3gpp.slot\
         -e DlData_SsBlockSendReq_t.activeSsBlocks -e DlData_SsBlockSendReq_t.patternId_item > result"""
                                       .format(_get_bip_pcap_path(traffic=False))})
    tshark_cmd(timeout=300)
    _validate_ssb_blocks_and_pattern_ids()
    _remove_data_file()


def get_beam_data():
    active_beam_1, active_beam_2 = None, None
    supported_ru = [ru for ru in ru_units_beams_schemes.keys()]
    if ru_type not in supported_ru:
        MolerTest.error('Not supported ru type detected: "{}". Supported RUs: "{}"'.format(ru_type, supported_ru),
                        raise_exception=True)
    else:
        MolerTest.info("Detected RU type: '{}'".format(ru_type))
        if ru_type == "AEUB":
            active_beam_1 = {
                "slot": "7",
                "activeSsBlocks": "16",
                "patternId_item_0": "0",
                "patternId_item_1": "0",
                "patternId_item_2": "0",
                "patternId_item_3": "16\n"
            }
            active_beam_2 = {
                "slot": "1",
                "activeSsBlocks": "128",
                "patternId_item_0": "1",
                "patternId_item_1": "0",
                "patternId_item_2": "0",
                "patternId_item_3": "0\n"
            }
        elif ru_type == "AEUD":
            active_beam_1 = {
                "slot": "3",
                "activeSsBlocks": "20",
                "patternId_item_0": "0",
                "patternId_item_1": "0",
                "patternId_item_2": "1e",
                "patternId_item_3": "0\n"
            }
            active_beam_2 = {
                "slot": "0x0000000f",
                "activeSsBlocks": "20",
                "patternId_item_0": "0",
                "patternId_item_1": "0",
                "patternId_item_2": "122",
                "patternId_item_3": "0\n"
            }
        elif ru_type == "AWEUA":
            active_beam_1 = {
                "slot": "1",
                "activeSsBlocks": "80",
                "patternId_item_0": "1",
                "patternId_item_1": "0",
                "patternId_item_2": "0",
                "patternId_item_3": "0\n"
            }
            active_beam_2 = {
                "slot": "7",
                "activeSsBlocks": "10",
                "patternId_item_0": "0",
                "patternId_item_1": "0",
                "patternId_item_2": "0",
                "patternId_item_3": "10\n"
            }
        elif ru_type == "AWEUB":
            active_beam_1 = {
                "slot": "1",
                "activeSsBlocks": "128",
                "patternId_item_0": "1",
                "patternId_item_1": "0",
                "patternId_item_2": "0",
                "patternId_item_3": "0\n"
            }
            active_beam_2 = {
                "slot": "7",
                "activeSsBlocks": "16",
                "patternId_item_0": "0",
                "patternId_item_1": "0",
                "patternId_item_2": "0",
                "patternId_item_3": "16\n"
            }
        return active_beam_1, active_beam_2


def _validate_active_beam_data(observed_beam_data, required_values):
    for observed_value, required_value in zip(observed_beam_data, required_values.items()):
        if observed_value != required_value[1]:
            MolerTest.error('Active beam validation error. Improper "{}" value: "{}" found in line "{}", '
                            'should be "{}"'.format(required_value[0], observed_value, observed_beam_data,
                                                    required_value[1]), raise_exception=True)
        else:
            MolerTest.info('Active beam validation log. "{}" required value: "{}"; '
                           'observed value: "{}"'.format(required_value[0], required_value[1], observed_value))


def _validate_muted_beam_data(observed_beam_data, item_names):
    for observed_value, item_name in zip(observed_beam_data, item_names):
        if observed_value not in ['0', '0\n']:
            MolerTest.error('Muted beam validation error. Improper "{}" value "{}" found in line "{}". '
                            'Expected value: 0'.format(
                                item_name, observed_value, observed_beam_data),
                            raise_exception=True)
        else:
            MolerTest.info('Muted beam validation log. "{}" required value: 0; '
                           'observed value: "{}"'.format(item_name, observed_value))


def _validate_ssb_blocks_and_pattern_ids():
    with open('/home/ute/result') as f:
        observed_beams = f.readlines()
        if not observed_beams:
            MolerTest.error("Result file is empty. Check if tshark/mcshark is installed properly and check moler logs",
                            raise_exception=True)
        else:
            MolerTest.info("tshark result file OK")
            active_beam_data = get_beam_data()
            active_beam_1, active_beam_2 = active_beam_data[0], active_beam_data[1]
            active_beam_slots = [active_beam_1["slot"], active_beam_2["slot"]]
            validation_items = [item for item in active_beam_1.keys()]
            for beam in observed_beams:
                beam = re.split('[,\t]', beam)
                slot = beam[0]
                if slot in active_beam_slots:
                    _validate_active_beam_data(
                        beam, active_beam_1 if slot == active_beam_1["slot"] else active_beam_2)
                else:
                    MolerTest.info("Muted beam slot: {}".format(slot))
                    _validate_muted_beam_data(beam[1:], validation_items[1:])


def _validate_muted_beams(muted_beams):
    with open('/home/ute/result') as f:
        used_beams = f.readlines()
    if used_beams:
        packet_number = 1
        for frame_beams in used_beams:
            for beam in frame_beams.split(","):
                if int(beam, 16) in _get_forbidden_beams_list(muted_beams):
                    MolerTest.error(
                        "Data transfer using beam {} which is muted in packet number {}".format(
                            beam, packet_number),
                        raise_exception=True)
                packet_number = packet_number + 1
        MolerTest.info("All muted beams are NOT used in data transfer")
    else:
        MolerTest.error("Result file is empty. Check if luashark is installed properly and check moler logs",
                        raise_exception=True)


def _remove_data_file():
    tshark_device = DeviceFactory.get_cloned_device(
        "GNB0", "GNB0_tshark", initial_state="PROXY_PC")
    rm_cmd = tshark_device.get_cmd(cmd_name="rm", cmd_params={
                                   "file": "/home/ute/result"})
    rm_cmd()


def _get_decimal_values_from_list(beams_list):
    used_decimal_beams = []
    for beam in beams_list:
        used_decimal_beams.append(int(beam, 16))

    return used_decimal_beams


def _get_forbidden_beams_list(muted_beams):
    forbidden_beams = []
    beam_id = 32
    for char in "{:032b}".format(int(muted_beams)):
        if char == "1":
            forbidden_beams.append(beam_id)
        beam_id = beam_id - 1

    return _match_beams_id_for_internal_beams_id(forbidden_beams)


def _get_bip_pcap_path(traffic=True):
    valid_file_path = None
    pcap_names = ["tcpdump_L2L1_bip_filtering_1:0.pcap0",
                  "tcpdump_L2L1_bip_filtering_off.pcap0",
                  "tcpdump_L2L1_bip_filtering_off.pcap",
                  "tcpdump_L2L1_bip_filtering_1:0.pcap"]
    if traffic:
        log_path = os.path.join(
            set_test_case_log_path(), "data_transfer")
    else:
        log_path = get_builtin_value('OUTPUT_DIR')

    for name in pcap_names:
        file_path = os.path.join(log_path, name)
        if os.path.isfile(file_path):
            valid_file_path = file_path
            break
    if valid_file_path is None:
        MolerTest.error('BIP log path not found.'
                        'Verify if in directory {}'
                        'exist any log file from following set: {}'.format(log_path, [name for name in pcap_names]))
    else:
        MolerTest.info('\nBIP log path:\n{}'.format(valid_file_path))
        return valid_file_path


def _get_csv_path(direction):
    log_path = set_test_case_log_path()
    return os.path.join(log_path,
                        "data_transfer", "tcpdump_L2L1_bip_filtering_off.pcap0_{}_converted.csv".format(direction))


def _match_beams_id_for_internal_beams_id(beams_id_list):
    internal_beams_list = []
    for beam in beams_id_list:
        internal_beams_list.append(ru_units_beams_schemes[ru_type][str(beam)])

    return internal_beams_list
