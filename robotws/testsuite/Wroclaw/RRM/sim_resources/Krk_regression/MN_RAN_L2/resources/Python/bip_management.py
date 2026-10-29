# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Mateusz Adamek, Damian Zak, Jacek Kozmic, Mateusz Pajor
:contact: mateusz.adamek@nokia.com, damian.zak@nokia.com, jacek.kozmic@nokia.com, mateusz.pajor@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from taf.transport.ssh.exceptions import FileProtocolClientError
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from datetime import datetime
from robot.api import logger
from subprocess import Popen
from subprocess import PIPE
from functools import wraps
from subprocess import call
from glob import glob
import taf.analyzer.pdml.interface as pdmlanalyzer
import taf.ul.parser.pcap.interface as pcap
import taf.collectors.l1l2bip.interface as l1l2bip
import lxml.etree as ET
import shlex
import time
import os
from taf.transport.ssh import ssh

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    upload_files_to_gnb, copy_files_from_gnb, change_file_name, check_path_exists
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.background_script import \
    BackgroundScript
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import run_on_gnb
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_console, logger_console_info, logger_warning
)


class BipNotFound(Exception):
    pass


class CannotDecodeBipLogException(Exception):
    pass


def _start_bip_script(script_name):
    rc, output = run_on_gnb(cmd='./{}'.format(script_name))
    if rc != 0:
        msg = "Unable to start script {} on gnb due to: \n{}".format(script_name, output)
        raise Exception(msg)


def _wait_for_bip_script_ready_state(times, msg):
    logger_console("{}".format(msg))
    time.sleep(times)


def _get_dedicated_bip_scripts(hw_type):
    if 'ASIB_ABIO' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIB_ABIO_SCRIPTS_LIST}")
    elif 'ASIK_ABIL' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIK_ABIL_SCRIPTS_LIST}")
    elif 'ASIB_ABIL' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIB_ABIL_SCRIPTS_LIST}")
    elif 'ASIL_ABIO' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIL_ABIO_SCRIPTS_LIST}")
    elif 'ASIM_ABIO' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIM_ABIO_SCRIPTS_LIST}")
    elif 'ASOE' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASOE_SCRIPTS_LIST}")
    elif 'ASIL' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIL_ABIO_SCRIPTS_LIST}")
    elif 'ASIB_ABIL' in hw_type:
        return BuiltIn().get_variable_value("${BIP_ASIB_ABIL_SCRIPTS_LIST}")
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
    logger_console("Preparing Bip Output Path: {}".format(pcap_output_path))
    if not check_path_exists(pcap_output_path):
        pcap_output_path = '{}/{}/'.format(BuiltIn().get_variable_value("${OUTPUT_DIR}"), pcap_output_path)
    OperatingSystem().create_directory(pcap_output_path)
    logger_console("Prepared output path for bips: {}".format(pcap_output_path))
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


def get_test_name_directory():
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    suite_name = BuiltIn().get_variable_value("${SUITE_NAME}")
    test_name = BuiltIn().get_variable_value("${TEST_NAME}")
    test_name_directory = f'{output_dir}/{suite_name}/{test_name}'
    return test_name_directory


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


def stop_collecting_bip(hw_type, output_path="BIP", bip_log_nr=1):
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
    BackgroundScript().terminate_background_script(bip_log_nr)
    _copy_captured_bip_from_remote(hw_type, bip_default, output_path)
    _wait_for_bip_script_ready_state(15, "Waiting for the BIPs logging finish state...")


def convert_pcap_to_pdml(pcap_file_path, pdml_file_path, luashark_path="/opt/luashark/generated_luashark/luashark.lua",
                         use_luashark=False, messages=[]):
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 12.02.2021
    Modified Date: 21.04.2022

    Function used to convert pcap file to pdml file

    Args:
        pcap_file_path(str): Path to the pcap file
        pdml_file_path(str): Path to output pdml file
        luashark_path(str): Path to luashark script
        use_luashark(bool): Value that determines usage of luashark script to decode biplogs
        messages(list): List of messages to filter in tshark
    """

    messages_str = " || ".join(messages)
    luashark_parameter = "-X lua_script:{0}".format(luashark_path) if use_luashark else ""
    pcap_parser = pcap.pcap()
    try:
        pcap_parser.load_pcap_file(pcap_file=pcap_file_path,
                                   command_template="/usr/bin/tshark -Y '{0}' -r {1} {2} -T pdml > {3}"
                                   .format(messages_str, pcap_file_path, luashark_parameter, pdml_file_path))
    except Exception as e:
        if "appears to have been cut short in the middle of a packet" or "bigger than maximum" in str(e):
            pass
        else:
            raise e


def validate_bip(pdml_file_path, messages=[]):
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 12.02.2021
    Modified Date: 27.10.2022

    Function used to validate proper messages in BipLog

    Args:
        pdml_file_path(str): Path to pdml file
        messages(list): List of messages you want to validate

    Raises:
        ExecutionFailed: Missing required BIP messages

    Returns:
        None
    """
    messages_count = []
    with open(pdml_file_path, "rb") as file_obj:
        for msg in messages:
            entries = pdmlanalyzer.PdmlReader(file_obj=file_obj)
            for log_entry in entries:
                if msg in str(log_entry.packet):
                    messages_count.append(msg)
                    break
    if len(messages_count) != len(messages):
        raise ExecutionFailed(message="Missing required BIP messages")
    else:
        logger_console("BIP validated successfully")


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


def create_pdml_with_tshark_messages(tshark_filter, input_file_path, output_file_path=None, use_luashark=False,
                                     split_filter=False):
    """
    Author: Jacek Kozmic
    Contact: jacek.kozmic@nokia.com
    Creation Date: 17.05.2021
    Modified Date: 30.08.2023 Marcin Trebunia

    A function to decode BIP logs using (optional use of luashark), filter them out and save as a pdml file.

    :param tshark_filter:    a valid tshark filter
    :param input_file_path:    path to a pcap file
    :param output_file_path:    path to output pdml file
    :param use_luashark:       use luashark for decoding
    :param split_filter:       use only first part of pcap filter in file name
    :return:        path to output pdml file
    """
    output_file_path = output_file_path or _create_output_filepath(input_file_path, tshark_filter, split_filter)
    command = _create_tshark_command(tshark_filter, input_file_path, output_file_path, use_luashark)
    call([command], shell=True)
    return output_file_path


def _create_tshark_command(tshark_filter, input_file_path, output_file_path, use_luashark=False, add_sudo=False):
    if use_luashark:
        luashark_path = BuiltIn().get_variable_value('${LUASHARK_PATH}',
                                                     default='/opt/luashark/generated_luashark/luashark.lua')
        tshark_temp = 'tshark -r "{input_file}" -V -q -X lua_script:{lua} -Y "{tshark_filter}" -T pdml ' \
                      '-o syscom.tcp_port_enable:FALSE > {output_file}'
        command = tshark_temp.format(input_file=input_file_path, lua=luashark_path,
                                     tshark_filter=tshark_filter, output_file=output_file_path)
    else:
        tshark_temp = 'tshark -r "{input_file}" -V -q -Y "{tshark_filter}" -T pdml ' \
                      '-o syscom.tcp_port_enable:FALSE > {output_file}'
        command = tshark_temp.format(input_file=input_file_path,
                                     tshark_filter=tshark_filter, output_file=output_file_path)
    if add_sudo:
        command = "sudo " + command
    return command


def _create_output_filepath(input_file_path, pcap_filter, split_filter=False):
    no_ext_file_path = os.path.splitext(input_file_path)[0]
    if split_filter:
        pcap_filter = pcap_filter.split()[0]
    return no_ext_file_path + pcap_filter + '.pdml'


def _create_output_filepath_for_errors(output_path):
    """
    Returns path to file with errors.
    E.g.: output_path = 'home/ute/results.txt'
    returns 'home/ute/results_errors.txt'
    """

    path_split = os.path.splitext(output_path)
    errors_filename = path_split[0] + '_errors' + path_split[1]
    return errors_filename


def create_tshark_command(bip_pcap_file, luashark_path, using_mcshark, filter_mode, reading_mode='-V',
                          output_path=None, syscom_tcp_port=False, add_sudo=False):
    tshark_cmd = ''
    if luashark_path:
        tshark_cmd = 'tshark -X lua_script:{} -r {} {} '.format(luashark_path, bip_pcap_file, reading_mode)
    elif using_mcshark:
        tshark_cmd = 'tshark -r {} {} '.format(bip_pcap_file, reading_mode)
    else:
        raise CannotDecodeBipLogException("No luashark path given and not using mcshark. Bip log cannot be decoded!")
    if add_sudo:
        tshark_cmd = "sudo " + tshark_cmd
    if filter_mode:
        tshark_cmd += filter_mode
    if syscom_tcp_port:
        tshark_cmd += ' -o syscom.tcp_port_enable:FALSE'
    if output_path:
        tshark_cmd += " > {} 2> {}".format(output_path, _create_output_filepath_for_errors(output_path))
    logger_console('Created tshark command:\n{}'.format(tshark_cmd))
    return tshark_cmd


def decode_bip_and_return_it(bip_pcap_file, split_str, luashark_lua_path=None, reading_mode='-V', filter_mode="",
                             using_mcshark=False):
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
    tshark_cmd = create_tshark_command(bip_pcap_file=bip_pcap_file, luashark_path=luashark_lua_path,
                                       using_mcshark=using_mcshark, reading_mode=reading_mode,
                                       filter_mode=filter_mode)
    tshark_splitted_cmd = shlex.split(tshark_cmd)
    output = Popen(tshark_splitted_cmd, stdout=PIPE)
    logger_console("Running {} ...".format(tshark_cmd))
    output_stream = output.stdout.read()
    decoded_stream = output_stream.decode("utf-8")
    decoded_bip_splitted_by_msg = enumerate(decoded_stream.split(split_str))
    return decoded_bip_splitted_by_msg


def start_bip_sniffing(host_ip='192.168.255.129', interface='eths3', pcap_file_name="bip.pcap"):
    """
    Author: Marcin Trebunia
    Contact: marcin.trebunia@nokia.com
    Creation Date: 30.01.2023
    Modified Date:

    Function for sniffing bips if mirroring is already enabled

    :param host_ip: str             gNB IP Address
    :param interface: str           Interface to sniff on
    :param pcap_file_name: str      The name of the output file to save packets to
    """

    logger_console_info(f'\nStart sniffing biplogs on {interface}')
    ssh_instance = ssh()

    try:
        ssh_instance.connect_to(hostname=host_ip, username='toor4nsn', password='oZPS0POrRieRtu')
        ssh_instance.send_command(command=f'nohup tcpdump -i {interface} -w /ffs/run/logs/{pcap_file_name} '
                                          f'>/dev/null 2>&1 &')
        time.sleep(2)  # wait for process list to update
        tcpdump_output_files = ssh_instance.execute(command=f'ps -fC "tcpdump -i {interface} '
                                                            f'-w /ffs/run/logs/{pcap_file_name}"| awk "{{print $NF}}"')
        if f'/ffs/run/logs/{pcap_file_name}' not in tcpdump_output_files:
            logger_warning(f'{pcap_file_name} not found in tcpdump output files, sniffing start failed')
            raise ExecutionFailed(message='Enabling mirroring failed')
        logger_console_info('Sniffing started successfully')
    finally:
        ssh_instance.disconnect()


def stop_bip_sniffing(output_pcap_path=None, host_ip='192.168.255.129', interface='eths3',
                      pcap_file_name='bip.pcap'):
    """
    Author: Marcin Trebunia
    Contact: marcin.trebunia@nokia.com
    Creation Date: 30.01.2023
    Modified Date:

    Function for stopping sniffing logs without disabling mirroring

    :param host_ip: str             gNB IP Address
    :param output_pcap_path: str    The path of the output file to which the logs will be copied
    :param interface: str           Interface on which sniffing was started
    :param pcap_file_name: str      The name of the pcap file (both source and target)
    """

    run_on_gnb(
        cmd=f'pkill -f "tcpdump -i {interface} -w /ffs/run/logs/{pcap_file_name}"',
        hostname=host_ip
    )

    if not output_pcap_path:
        output_pcap_path = f'{get_test_name_directory()}/l1l2bip'
        if not os.path.exists(output_pcap_path):
            os.makedirs(output_pcap_path)

    try:
        copy_files_from_gnb(
            files=f'/ffs/run/logs/{pcap_file_name}',
            local_path=f'{output_pcap_path}/{pcap_file_name}')
        logger_console_info('Sniffing biplogs stopped and file copied')
    except FileProtocolClientError:
        logger_warning(f'{pcap_file_name} not found on gNB, sniffed BIPs will not be available')
    finally:
        run_on_gnb(f'rm /ffs/run/logs/{pcap_file_name}')


def add_preferences_to_wireshark(preferences=[], wireshark_preferences_path='~/.config/wireshark/preferences'):
    """
    Author: Damian Zak
    Contact: damian.zak@nokia.com
    Creation Date: 12.04.2022
    Modified Date:

    Function for adding preferences to Wireshark. If preferences file exists, function checks if
    preferences you are trying to add already exists or if you are trying to change only the value of preference.
    If preferences file doesn't exist, function will create it with all given preferences.

    :param preferences: list                    List containing all preferences to add/update
    :param wireshark_preferences_path: str      Wireshark preferences file path
    """
    preferences_after_check = []
    operating_system = OperatingSystem()
    logger_console('Checking if preferences file exists...')
    if os.path.exists(os.path.expanduser(wireshark_preferences_path)):
        logger_console('Preferences file exists, checking if preferences to add already exists...')
        for preference in preferences:
            preference_split = preference.split(':')
            preference_name_grep_status = operating_system.grep_file(path=wireshark_preferences_path,
                                                                     pattern=preference_split[0])
            if preference_name_grep_status.split(':')[0] == preference_split[0]:
                preference_value_grep_status = operating_system.grep_file(path=wireshark_preferences_path,
                                                                          pattern=preference)
                if preference_value_grep_status == "" or \
                        preference_value_grep_status.split(':')[1] != preference_split[1]:
                    operating_system.run_and_return_rc_and_output("sed -i 's/{0}/{1}/' {2}".format(
                        preference_name_grep_status, preference, wireshark_preferences_path))
                    logger_console('Preference {0} updated.'.format(preference_split[0]))
            else:
                preferences_after_check.append(preference)
    else:
        logger_console('Preferences file doesn\'t exists. Adding given preferences...')
        preferences_after_check = list(preferences)

    preferences_join = '\n' + '\n'.join(preferences_after_check)
    operating_system.append_to_file(path='~/.config/wireshark/preferences', content=preferences_join)
    logger_console('{0} new preferences added: {1}.'.format(len(preferences_after_check), preferences_after_check))


def get_bip_scripts_from_gnb_to_dir(hw_type, target_dir, remote_dir='/ffs/run/config/scripts'):
    file_list = _get_dedicated_bip_scripts(hw_type).copy()
    for id in range(len(file_list)):
        the_file = file_list[id].split('/')[-1]
        file_list[id] = os.path.join(remote_dir, the_file)
    try:
        copy_files_from_gnb(file_list, target_dir)
    except FileProtocolClientError:
        logger_console('No files has been found on gNB, trying to run bip with files on repo')


def start_syscom_collection(syscom_file_name='xp_syscom_gnb1_source.pcap'):
    """
       Author: Beata Kapusta
       Contact: beata.kapusta@nokia.com
       Creation Date: 16.09.2022
       Modified Date:

       Function for starting collection of syscom on gNB

       :param syscom_file_name (str)    filename
       """
    try:
        ssh_instance = ssh()
        ssh_instance.connect_to(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
        ssh_instance.send_command(command="nohup syscomdump -w /tmp/{} >/dev/null 2>&1 &".format(syscom_file_name))
        logger_console_info('Syscom collection started successfully')
    finally:
        ssh_instance.disconnect()


def stop_syscom_collection(output_path, syscom_file_name='xp_syscom_gnb1_source.pcap'):
    """
       Author: Beata Kapusta
       Contact: beata.kapusta@nokia.com
       Creation Date: 16.09.2022
       Modified Date:

       Function for stoping collection of syscom and copying it from gNB

       :param output_path (str)     Path where file will be saved
       :param syscom_file_name (str)         Filename
       """
    run_on_gnb(cmd="pkill -f 'syscomdump -w /tmp/{}'".format(syscom_file_name))
    copy_files_from_gnb(
        files='/tmp/{}'.format(syscom_file_name),
        local_path='{}/{}'.format(output_path, syscom_file_name))
    logger_console_info('Syscom collection ended successfully')


def start_biplog_collection_from_webem(host_ip='192.168.255.129', names='l1l2bip', interface='L1-L2', timeout=180):
    """
        Author: Marcin Trebunia
        Contact: marcin.trebunia@nokia.com
        Creation Date: 08.03.2023
        Modified Date:

        Function for setup and collecting BipLogs using ADMIN API request "interface monitoring" through taf library

        :param host_ip (str)     IP address of the gNB
        :param names (str)       Name of the collector for identification
        :param interface (str)   Either 'L1-L2' or 'L2Hi-L2Lo'
        :param timeout (str)     Time in seconds to wait for positive procedure result of downloading BIPs
    """
    webservice = {
        'host': host_ip,
        'user': 'Nemuadmin',
        'password': 'nemuuser',
        'port': 443
    }
    bip_collector = l1l2bip.l1l2bip()
    bip_collector.create_interface_mirroring_l1l2bip_collector(name=names, webservice=webservice, interface=interface,
                                                               timeout=timeout)
    bip_collector.setup_collectors(names=names)
    bip_collector.start_collectors(names=names)
    logger.console('BIP collection started')
    bip_collector.set_suite_alias(names)


def stop_and_download_biplog_from_webem(names='l1l2bip', output_pcap_path=None, pcap_file_name=None):
    """
       Author: Marcin Trebunia
       Contact: marcin.trebunia@nokia.com
       Creation Date: 08.03.2023
       Modified Date:

       Function for stopping and downloading BipLogs using ADMIN API request "interface monitoring" through taf library

       :param names (str)               Name of the collector for identification
       :param output_pcap_path (str)    The path of to which the BIPs will be copied
       :param pcap_file_name (str)      Name of the target BIP pcap file
    """
    if not output_pcap_path:
        output_pcap_path = get_test_name_directory()
    if not pcap_file_name:
        pcap_file_name = 'bip.pcap'
    bip_collector = l1l2bip.l1l2bip()
    bip_collector.stop_collectors(names=names)
    bip_collector.collect_collectors(names=names, target_dir=output_pcap_path)
    logger.console('BIPs stopped and downloaded')
    bip_collector.teardown_collectors(names=names)
    pcap_wildcard_name = glob(os.path.join(f'{output_pcap_path}/{names}', "BTS*.pcap"))[0]
    os.rename(pcap_wildcard_name, f'{output_pcap_path}/{names}/{pcap_file_name}')
