# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

import time
import os
import shlex
import taf.ul.parser.pcap.interface as pcap
import taf.analyzer.pdml.interface as pdmlanalyzer
import lxml.etree as ET
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.errors import ExecutionFailed
from datetime import datetime
from robot.api import logger
from subprocess import Popen
from subprocess import PIPE
from functools import wraps
from subprocess import call

from testsuite.Wroclaw.RRM.L2PS_WRO.resources.Python.file_management import (
    upload_files_to_gnb, copy_files_from_gnb, change_file_name, check_path_exists
)
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.background_script import BackgroundScript
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import run_on_gnb
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.utilities import logger_console
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.sw_config_modifier import SwConfigModifier


def logger_info(message):
    logger.info(msg=" **** {}".format(message), also_console=True)


class BipNotFound(Exception):
    pass


def _start_bip_script(script_name):
    rc, output = run_on_gnb(cmd='./{}'.format(script_name))
    if rc != 0:
        msg = "Unable to start script {} on gnb due to: \n{}".format(script_name, output)
        raise Exception(msg)


def _wait_for_bip_script_ready_state(times, msg):
    logger_info("{}".format(msg))
    time.sleep(times)


def _get_dedicated_bip_scripts(hw_type):
    if 'ASIB_ABIO' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIB_ABIO_SCRIPTS_LIST}")
    elif 'ASIK_ABIL' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIK_ABIL_SCRIPTS_LIST}")
    elif 'ASOE' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASOE_SCRIPTS_LIST}")
    raise RuntimeError("{} doesn't have a valid bip script path in variables!".format(hw_type))


def _delete_files_on_remote(files_to_remove):
    for file_to_remove in files_to_remove:
        run_on_gnb("rm -rf {}".format(file_to_remove))


def _get_bip_file_names_on_remote(bip_default):
    _, output = run_on_gnb("ls /tmp | grep {}".format(bip_default))
    if not (bip_default in output):
        raise BipNotFound("Could not find {} on /tmp at GNB!".format(bip_default))
    return output.split('\r\n')[:-1]


def _prepare_bip_output_path(pcap_output_path):
    logger.info("Preparing Bip Output Path: {}".format(pcap_output_path), also_console=True)
    if not check_path_exists(pcap_output_path):
        pcap_output_path = '{}/{}/'.format(BuiltIn().get_variable_value("${OUTPUT_DIR}"), pcap_output_path)
    OperatingSystem().create_directory(pcap_output_path)
    logger_info(pcap_output_path)
    return pcap_output_path


def _name_files_properly(terminate_name, output, pcap_local_path):
    current_date = datetime.now().strftime("%d%m%Y_%H%M%S")
    for bip_file in output:
        bip_id = bip_file[-1]
        bip_name = "{}_bip_{}_{}.pcap".format(bip_id, terminate_name.lower(), current_date)
        old_path = '{}/{}'.format(pcap_local_path, bip_file)
        new_path = '{}/{}'.format(pcap_local_path, bip_name)
        change_file_name(old_path, new_path)


def _copy_captured_bip_from_remote(terminate_name, bip_default, output_path):
    output = _get_bip_file_names_on_remote(bip_default)
    pcap_output_path = _prepare_bip_output_path(output_path)
    copy_files_from_gnb(files=['/tmp/{}'.format(item) for item in output], local_path=pcap_output_path)
    _name_files_properly(terminate_name, output, pcap_output_path)
    _delete_files_on_remote(['/tmp/{}'.format(item) for item in output])


def start_biplog_collection():
    """
    Run robot KW in dependence of unit_name (ASIK, ASIB or ASOE).
    Possible KWs to run: 'Start Biplog On ASIK', 'Start Biplog On ASIB', 'Start Biplog On ASOE'
    :return:
    """
    modifier = SwConfigModifier()
    unit_name = modifier.get_capability_unit_name()
    BuiltIn().import_resource(os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(os.path.realpath(__file__)))),
        'resources', 'Robot', 'bip_logs.robot'))
    BuiltIn().run_keyword('Setup Biplog On {}'.format(unit_name))
    BuiltIn().run_keyword('Start Biplog On {}'.format(unit_name))


def start_collecting_bip(hw_type):
    """
    It copies proper bip script (according to HW type: ASIB_ABIO or ASIK_ABIL) and then runs it on gNB.
    It calls a function that needs in variables file following items:
    BIP_[HW_TYPE]_SCRIPT_LIST
    For example:
    CURDIR = '{}'.format(os.path.dirname(os.path.realpath(__file__))

    BIP_ASIK_ABIL_SCRIPT = '{}/scripts/gnbMirroring.sh'.format(CURDIR)
    BIP_ASIK_ABIL_SCRIPTS_LIST = [BIP_ASIK_ABIL_SCRIPT, '{}/scripts/gnbMirroringConfig.sh'.format(CURDIR)]

    BIP_ASIB_ABIO_SCRIPT_LIST = ['{}/scripts/bip_script.sh'.format(CURDIR)]

    Usage example:
    bip.Start Collecting Bip                ${HW_TYPE_ASIK_ABIL}
    :author: Mateusz Rzeczyca
    :modified: 28.06.2021 by Adrianna Pienkowska
    :param hw_type: a dedicated HW type for the  bip script, e.g. ${BIP_ABIO_SCRIPT}, 'ASIK_ABIL'
    :returns: Nothing
    """
    bip_script_file_list = _get_dedicated_bip_scripts(hw_type)
    bip_script_name = os.path.basename(bip_script_file_list[0])
    bips_remote_path = '/user/toor4nsn/'

    upload_files_to_gnb(remote_path=bips_remote_path, files=bip_script_file_list)
    remote_bip_filename = os.path.join(bips_remote_path, bip_script_name)

    run_on_gnb('chmod {} {}'.format('+x', remote_bip_filename))
    BackgroundScript().start_background_script(_start_bip_script, (bip_script_name,))
    _wait_for_bip_script_ready_state(25, "Waiting for the BIPs logging script start...")


def stop_collecting_bip(hw_type, output_path="BIP"):
    """
    It stops the bip script on gNB, checks if any pcap files were created in /tmp and copies the found files
    to the folder OUTPUT_DIR+BIP (e.g /home/ute/logs/BIP) with name
    bip_file_number+'bip'+hw_type+timestamp (e.g 0_bip_asik_abil_12072021_141834.pcap).
    Requires in variable file following items:
    BIP_TERMINATE_[HW_TYPE]_NAME, e.g:
            BIP_TERMINATE_ASIK_ABIL_NAME = 'tcpdumpL2L1_filtering_off.pcap'
            BIP_TERMINATE_ASIB_ABIO_NAME = 'bip.pcap'

    OUTPUT_DIR is an automatic  robotframework variable, more here:
    https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#using-builtin-library

    It calls a function that needs in variable file following items:
    NOKIA_PASS e.g. NOKIA_PASS = 'oZPS0POrRieRtu'
    GNB_IP e.g GNB_IP = '192.168.255.129'
    NOKIA_USERNAME e.g NOKIA_USERNAME = 'toor4nsn'

    Example usage:
    bip.Stop Collecting Bip                 hw_type=${HW_TYPE_ASIK_ABIL}
    :author: Mateusz Rzeczyca
    :modified: 28.06.2021 by Adrianna Pienkowska
    :param hw_type: a dedicated HW type for the  bip script, e.g. ${HW_TYPE_ASIK_ABIL}, 'ASIK_ABIL'
    :returns: Nothing
    """
    terminate_name = "BIP_TERMINATE_{}_NAME".format(hw_type)
    bip_default = BuiltIn().get_variable_value("${}".format(terminate_name))

    _wait_for_bip_script_ready_state(5, "Stopping BIP capture...")
    BackgroundScript().terminate_background_script()
    _copy_captured_bip_from_remote(hw_type, bip_default, output_path)
    _wait_for_bip_script_ready_state(15, "Waiting for the BIPs logging finish state...")


def convert_pcap_to_pdml(pcap_file_path, pdml_file_path, messages=[]):
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 12.02.2021
    Modified Date: 02.04.2021

    Function used to convert pcap file to pdml file

    Args:
        pcap_file_path(str): Path to the pcap file
        pdml_file_path(str): Path to output pdml file
        messages(list): List of messages to filter in tshark

    Returns:
        None
    """
    messages_str = ' || '.join(messages)

    pcap_parser = pcap.pcap()
    pcap_parser.load_pcap_file(pcap_file=pcap_file_path,
                               command_template='/usr/bin/tshark -Y \
                               "%s" -r %s -X lua_script:/opt/luashark/generated_luashark/luashark.lua \
                               -T pdml > %s' % (messages_str, pcap_file_path, pdml_file_path))


def validate_bip(pdml_file_path, messages=[]):
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 12.02.2021
    Modified Date: 28.06.2021

    Function used to validate proper messages in BipLog

    Args:
        pdml_file_path(str): Path to pdml file
        messages(list): List of messages you want to validate

    Raises:
        ExecutionFailed: Missing required RACH messages

    Returns:
        None
    """
    messages_count = []

    for msg in messages:
        with open(pdml_file_path, "rb") as file_obj:
            entries = list(pdmlanalyzer.PdmlReader(file_obj=file_obj))
            for log_entry in entries:
                if msg in log_entry.packet:
                    messages_count.append(msg)
                    break
    if len(messages_count) != len(messages):
        raise ExecutionFailed(message="Missing required RACH messages")


def verify_pucch_f3_modulation(filepath, modulation="BPSK"):
    """
    Author: Szymon Lange
    Contact: szymon.lange@nokia.com
    Creation Date: 13.05.2021
    Modified Date: 07.10.2021

    Method for verifying PUCCH F3 modulation in BIP log converted to PDML
    07.10.2021: added support for multiplexed F1 and F3

    :param filepath:    Path to PDML file
    :param modulation:  str "BPSK" or "QPSK"
    :return:            True/False if all PUCCH F3 messages have correct or incorrect modulation
    """

    pucchf3_entries = pdmlanalyzer.pdml.get_pdml_entries(
        filepath,
        "UlData_PucchReceiveReq.pucchResources_item_0.pucchFormat",
        "value", "03")
    assert len(pucchf3_entries) > 0, "No packets detected!"
    packet_modulation = []
    for entry in pucchf3_entries:
        resources_len = int(entry.packet["UlData_PucchReceiveReq.pucchResources-Length"].show, 16)
        for x in range(resources_len):
            form = int(entry.packet["UlData_PucchReceiveReq.pucchResources_item_{}.pucchFormat".format(x)].show)
            if form == 3:
                f3_modulation = entry.packet. \
                    xpath(".//UlData_PucchReceiveReq.pucchResources_item_{}.modulationType".format(x))[0].showname
                packet_modulation.append(f3_modulation)

    logger.info("Detected {} PucchF3 messages".format(len(pucchf3_entries)), also_console=True)

    result = all((modulation in x) is True for x in packet_modulation)
    if result is False:
        logger.error("Found messages with incorrect modulation!")
    return result


def return_values_as_integers(func):
    """
    Author: Jacek Kozmic
    Contact: jacek.kozmic@nokia.com
    Creation Date: 15.05.2021
    Modified Date:

    A function, which converts string values extracted from PDML file to integers. Should be used as a decorator.

    :param func:    a function, which returns a structure (list/dict) with strings, which can be converted to int
    :return:        a structure with all decimal or hexadecimal strings converted to ints
    """

    def _convert_values_to_int(structure):
        if isinstance(structure, str):
            if structure[:2] == '0x':
                structure = int(structure, 16)
            elif structure.isdigit():
                structure = int(structure)
        if isinstance(structure, list):
            for index, item in enumerate(structure):
                structure[index] = _convert_values_to_int(item)
        if isinstance(structure, dict):
            for key, val in structure.items():
                structure[key] = _convert_values_to_int(val)
        return structure

    @wraps(func)
    def wrapper(*args, **kwargs):
        output = func(*args, **kwargs)
        output = _convert_values_to_int(output)
        return output

    return wrapper


@return_values_as_integers
def extract_structure_from_pdml(pdml_file, structure):
    """
    Author: Jacek Kozmic
    Contact: jacek.kozmic@nokia.com
    Creation Date: 15.05.2021
    Modified Date: 22.06.2021

    A main function for extracting more complex data structures from PDML files. It searches through PDML file to
    extract a given structure provided by tester. It can search for 1st element or all elements at a given level.
    The structure should consist of nested dicts and lists. Dict key is the 'name' of an element, dict value can be
    either a string, in which case it's the name of the field whose value will be extracted, or a list containing
    another dict.

    example 1:
    structure = {'beamsMuted': 'value'} will search for 1st occurance of a 'field', which 'name' ends with 'beamsMuted'
    and return its 'value' field content
    output: {'beamsMuted': 1}

    example 2:
    structure = {'PdschSendReq': [{'patternId_item_0': 'show'}]} will find all <proto> with 'showname' field containing
     PdschSendReq string and for each of them will search for <field>, whose 'name' ends with 'patternId_item_0'
     and return its 'show' field content
     output: {b'PdschSendReq': [{b'patternId_item_0': 206},
                                {b'patternId_item_0': 191},
                                {b'patternId_item_0': 186}]}

    :param pdml_file:    path to a PDML file
    :param structure:    dict with a structure to be extracted
    :return:        a structure with all decimal or hexadecimal strings converted to ints
    """
    root = ET.parse(pdml_file).getroot()
    structure = _extract_structure_from_etree_element(root, structure)
    return structure


def _search_deep_in_xml_for_message(root, message, attrib_name):
    if len(root) > 1:
        for element in root:
            found = _search_deep_in_xml_for_message(element, message, attrib_name)
            if found is not None:
                return found
    else:
        for item in root.iter():
            if str(item.attrib.get('name', '')).endswith(message):
                return item.attrib[attrib_name]


def _extract_structure_from_etree_element(etree_elem, structure):
    output_structure = {}
    for elem_name, value in structure.items():
        if isinstance(value, str):
            pdml_value = _search_deep_in_xml_for_message(etree_elem, elem_name, value)
        if isinstance(value, list):
            pdml_elements = _find_elements(etree_elem, elem_name)
            pdml_value = [_extract_structure_from_etree_element(element, value[0]) for element in pdml_elements]
        output_structure.update({elem_name: pdml_value})
    return output_structure


def _find_elements(root, element_name):
    find_expression = ".//proto[contains(@showname, '{}')]".format(element_name)
    return root.xpath(find_expression)


def create_pdml_with_tshark_messages(tshark_filter, input_file_path, output_file_path=None, use_luashark=True):
    """
    Author: Jacek Kozmic
    Contact: jacek.kozmic@nokia.com
    Creation Date: 17.05.2021
    Modified Date:

    A function to decode BIP logs using luashark, filter them out and save as a pdml file.

    :param tshark_filter:    a valid tshark filter
    :param input_file_path:    path to a pcap file
    :param output_file_path:    path to output pdml file
    :return:        path to output pdml file
    """
    output_file_path = output_file_path or _create_output_filepath(input_file_path, tshark_filter)
    command = _create_tshark_command(tshark_filter, input_file_path, output_file_path, use_luashark)
    call([command], shell=True)
    return output_file_path


def _create_tshark_command(tshark_filter, input_file_path, output_file_path, use_luashark=True):
    if use_luashark:
        luashark_path = BuiltIn().get_variable_value('${LUASHARK_PATH}',
                                                     default='/opt/luashark/generated_luashark/luashark.lua')
        tshark_temp = 'tshark -r "{input_file}" -V -q -X lua_script:{lua} -Y "{tshark_filter}" -T pdml > {output_file}'
        command = tshark_temp.format(input_file=input_file_path, lua=luashark_path,
                                     tshark_filter=tshark_filter, output_file=output_file_path)
    else:
        tshark_temp = 'tshark -r "{input_file}" -V -q -Y "{tshark_filter}" -T pdml > {output_file}'
        command = tshark_temp.format(input_file=input_file_path,
                                     tshark_filter=tshark_filter, output_file=output_file_path)
    return command


def _create_output_filepath(input_file_path, pcap_filter):
    no_ext_file_path = os.path.splitext(input_file_path)[0]
    return no_ext_file_path + pcap_filter + '.pdml'


def decode_bip_and_return_it(luashark_lua_path, bip_pcap_file, split_str, reading_mode='-V', filter_mode=""):
    """Decodes given bip_pcap_file using luashark_lua_path, then decoded bip is enumerated with split_str and returned.

    :param luashark_lua_path: path to luashark.lua file
    :param bip_pcap_file: path to bip.pcap file
    :param split_str: str used to split messages, Ex. '\nFrame', 'ICOM 5G Protocol'
    :param reading_mode: reading mode for tshark, defaults to -V
    :param filter_mode: filter used like in Wireshark GUI, use with '-Y "{}"' prefix, where {} is place
                        for Wireshark's filter.
                        Ex. '-Y "uldata_pucchreceiverespps||uldata_pucchreceivereq||dldata_csirssendreq"'
    :return: splitted and decoded bip ready to validate.
    """
    tshark_cmd = 'tshark -X lua_script:{} -r {} {} '.format(luashark_lua_path, bip_pcap_file, reading_mode)
    if filter_mode:
        tshark_cmd += filter_mode
    logger_console('tshark command {}'.format(tshark_cmd))
    tshark_splitted_cmd = shlex.split(tshark_cmd)
    output = Popen(tshark_splitted_cmd, stdout=PIPE)
    logger_console("Running {} ...".format(tshark_cmd))
    output_stream = output.stdout.read()
    decoded_stream = output_stream.decode("utf-8")
    decoded_bip_splitted_by_msg = enumerate(decoded_stream.split(split_str))
    return decoded_bip_splitted_by_msg
