import re
import os
import json
import shutil
import xml.etree.ElementTree as ET
from typing import Iterator
from robot.libraries.BuiltIn import BuiltIn
from pathlib import Path
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from taf.hw.rf_attenuator import rf_attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.cloud.admin import vcu_context, vdu_context
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager import DCAPManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.log_profile import LogProfile
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.perf_cap.throughput_curves.resources.elt_verification \
     import EltLogParser
from test_constants import *
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.webemil_parser import decode_emil_and_save_as_json, \
    parse_msg_list_from_json_file
import time

_cu = cu()
_vdu = vdu()
_elt = EltLogCollector()
_elt_parser = EltLogParser()
_dm = DCAPManager()
_attenuator = rf_attenuator()
_tl = TestlineConfiguration()

_vcu_log_profile = LogProfile().with_vcu_snapshot().with_vcu_syslog()
_vdu_log_profile = LogProfile().with_vdu_snapshot().with_vdu_cplane().with_vdu_syslog()
traces_trunk = {'vcu': {'log_profile': _vcu_log_profile,
                        'trace_id': '',
                        'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                        'stop_trace_name': 'dcap_vcu_stop_trace',
                        'download_log_name': 'dcap_collect_vcu_log',
                        'cells': ['20']},
                'vdu_1': {'log_profile': _vdu_log_profile,
                          'trace_id': '',
                          'mplane': _tl.get_du_oam_connection_details(0, 0)['hostname'],
                          'stop_trace_name': 'dcap_vdu_1_stop_trace',
                          'download_log_name': 'dcap_collect_vdu_1_log',
                          'cells': ['20']},
                }
traces_branch = {'vcu': {'log_profile': _vcu_log_profile,
                         'trace_id': '',
                         'mplane': _tl.get_gnb_oam_connection_details(0)['hostname'],
                         'stop_trace_name': 'dcap_vcu_stop_trace',
                         'download_log_name': 'dcap_collect_vcu_log',
                         'cells': ['100']},
                 'vdu_1': {'log_profile': _vdu_log_profile,
                           'trace_id': '',
                           'mplane': _tl.get_du_oam_connection_details(0, 1)['hostname'],
                           'stop_trace_name': 'dcap_vdu_2_stop_trace',
                           'download_log_name': 'dcap_collect_vdu_2_log',
                           'cells': ['100']},
                 }

CB011041_EBC_1_MSG1 = r'.*?Conditions to use paging repetitions are met. Starting tRanPagingRepGuardTimer'

rrcreconfiguration_msg = re.compile(r"name': 'RRCReconfiguration.*?'nr-rrc\.ssbFrequency': '396510'.*?"
                                    r"'nr-rrc\.measIdToAddModList': '4'")

rrcreconfigurationcomplete_msg = re.compile(r"name': 'RRCReconfigurationComplete.*?"
                                            r"\{'nr-rrc.rrc_TransactionIdentifier': '0'")

rrcreconfiguration_msg_branch = re.compile(r"name': 'RRCReconfiguration.*?'nr-rrc\.ssbFrequency': '529970'.*?"
                                           r"'nr-rrc\.measIdToAddModList': '4'")

rrcreconfigurationcomplete_msg_branch = re.compile(r"name': 'RRCReconfigurationComplete.*?"
                                                   r"\{'nr-rrc.rrc_TransactionIdentifier': '1'")


def setup() -> None:
    """
    Set up the system by initializing attenuators, deattenuating the source cell,
    and setting up VCU parameters.

    :return: None
    """
    sw_verification()
    initialize_attenuators()
    deattenuate_source_cell()


def teardown() -> None:
    """
    Perform the teardown operations for the system.

    This function attenuates the source cell and sets VCU parameters to 'disabled' and 'none'.

    :return: None
    """
    attenuate_source_cell()


def sw_verification():
    """
    Perform software verification by analyzing an XML file for specific patterns.

    This function retrieves an XML file from the specified output directory, parses it,
    and searches for predefined patterns within the XML content. If any pattern is found,
    it logs the information. If no patterns are found, it logs a message indicating that
    the software version was not found.

    :raises FileNotFoundError: If the XML file does not exist in the specified directory.
    :raises ET.ParseError: If the XML file cannot be parsed.
    :return: None
    """
    with vcu_context() as admin:
        file_path = Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml'
        admin.get_current_plan_file(Path(get_robot_variable('OUTPUT_DIR')) / 'scf_vcu.xml')
        xml_tree = ET.parse(file_path)
        xml_root = xml_tree.getroot()
        patterns = [r"CU26R1_", r"CU26R2_"]
        for pattern in patterns:
            matched = re.findall(pattern, ET.tostring(xml_root, encoding='unicode'))
            if matched:
                logger.info(f"{pattern} was found!", also_to_console=True)
                global sw_version
                sw_version = pattern
        if sw_version:
            return True
        else:
            raise AssertionError("SW version not found!")


def setup_elt() -> None:
    """
    Setup ELT configuration and log the process.

    :return: None
    """
    if sw_version == "CU26R1_":
        logger.info(f"Setup ELT: {ELT_CONFIG_BRANCH}", also_to_console=True)
        _elt.setup(with_upload=True, configuration=ELT_CONFIG_BRANCH)
    elif sw_version == "CU26R2_":
        logger.info(f"Setup ELT: {ELT_CONFIG_TRUNK}", also_to_console=True)
        _elt.setup(with_upload=True, configuration=ELT_CONFIG_TRUNK)
    _elt.set_logging_filter()
    _elt.start_log_collecting()


def start_elt_tracing() -> None:
    """
    Start the ELT log collecting process.

    This function initiates the log collection for ELT (Event Log Tracing).
    It calls the `_elt.start_log_collecting()` method to begin the process.

    :return: None
    """
    _elt.start_log_collecting()


def stop_elt_tracing() -> None:
    """
    Stops the ELT log collecting and downloads the log to the specified output directory.

    :return: None
    """
    output_dir = Path(get_robot_variable('OUTPUT_DIR'))
    elt_path = str(output_dir / ELT_LOG_NAME)
    _elt.stop_log_collecting()
    _elt.download_log(elt_path)


def teardown_elt() -> None:
    """
    Shutdown the ELT system.

    This function is responsible for shutting down the ELT system safely.
    It ensures that all resources are properly released and the system is
    left in a stable state.

    :returns: None
    """
    _elt.shutdown()


def initialize_attenuators() -> None:
    """
    Initialize attenuators with specified attenuation values.

    This function iterates over the list of attenuators from the test line configuration
    and sets the attenuation for each port to 90.

    :rtype: None
    """
    for idx, atten in enumerate(TestlineConfiguration().tl_init.attenuators):
        logger.info(f"Initializing attenuator {atten.ip_addr}", also_to_console=True)
        _attenuator.setup_attenuator(atten, alias=f"atten_{idx}")
        _attenuator.set_ports_attenuation(atten.attenuation_port_numbers, [90] * len(atten.attenuation_port_numbers),
                                          confirm=True, attenuator_device=f"atten_{idx}")


def deattenuate_source_cell() -> None:
    """
    Deattenuate the source cell to the minimum attenuation level.

    :rtype: None
    """
    if sw_version == "CU26R1_":
        logger.info(f"Deattenuating source cell (pci={BRANCH_SOURCE_CELL}) to {MIN_ATTENUATION}db",
                    also_to_console=True)
        _attenuate_cell(BRANCH_SOURCE_CELL, MIN_ATTENUATION)
        _attenuate_cell(BRANCH_TARGET_CELL, TARGET_ATTENUATION)
    if sw_version == "CU26R2_":
        logger.info(f"Deattenuating source cell (pci={TRUNK_SOURCE_CELL}) to {MIN_ATTENUATION}db",
                    also_to_console=True)
        _attenuate_cell(TRUNK_SOURCE_CELL, MIN_ATTENUATION)
        _attenuate_cell(TRUNK_TARGET_CELL, TARGET_ATTENUATION)


def attenuate_source_cell() -> None:
    """
    Attenuate the source cell to the maximum attenuation level.

    :rtype: None
    """
    if sw_version == "CU26R1_":
        logger.info(f"Attenuating source cell (pci={BRANCH_SOURCE_CELL}) to {MAX_ATTENUATION}db",
                    also_to_console=True)
        _attenuate_cell(BRANCH_SOURCE_CELL, MAX_ATTENUATION)
        _attenuate_cell(BRANCH_TARGET_CELL, MAX_ATTENUATION)
    if sw_version == "CU26R2_":
        logger.info(f"Attenuating source cell (pci={BRANCH_SOURCE_CELL}) to {MAX_ATTENUATION}db",
                    also_to_console=True)
        _attenuate_cell(TRUNK_SOURCE_CELL, MAX_ATTENUATION)
        _attenuate_cell(TRUNK_TARGET_CELL, MAX_ATTENUATION)


def _attenuate_cell(cell_id: int, value: int) -> None:
    """
    Attenuate a specified cell by setting its port attenuation based on a multiplier.

    The function retrieves a cell from the global ``CELL_PORTS`` dictionary using the provided
    cell identifier. It then sets the attenuation on all ports of the cell by multiplying the given
    value with the number of ports. The attenuator identifier from the cell is used to generate a
    specific attenuator reference.

    :param cell_id: Identifier for the cell.
    :param value: Attenuation multiplier to be applied per port.
    :rtype: None
    """
    cell = CELL_PORTS[cell_id]
    _attenuator.set_ports_attenuation(cell['ports'], [value] * len(cell['ports']), confirm=True,
                                      attenuator_device=f"atten_{cell['attenuator_id']}")


def setup_vcu_parameters_on(state_1: str, state_2: str) -> None:
    """
    Setup VCU parameters on the specified states.

    :param state_1: The state value for the parameter `actHigherPrioFreqHo`.
    :param state_2: The state value for the parameter `actHigherPrioFreqHoForCA`.
    :return: None
    """
    _cu.connect_to(host='10.42.93.184', port='443', username='Nemuadmin', password='Nokia@123', secure=True)
    _cu.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505",
                                          parameter="actHigherPrioFreqHo",
                                          operation="update",
                                          value=state_1)
    _cu.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505",
                                          parameter="actHigherPrioFreqHoForCA",
                                          operation="update",
                                          value=state_2)
    time.sleep(10)
    _cu.disconnect(connection=None, timeout=10)


def setup_vcu_parameters_off(state_1: str, state_2: str) -> None:
    """
    Set up VCU parameters to turn off specific functionalities.

    :param state_1: The state value for the parameter `actHigherPrioFreqHoForCA`.
    :param state_2: The state value for the parameter `actHigherPrioFreqHo`.
    :return: None
    """

    _cu.connect_to(host='10.42.93.184', port='443', username='Nemuadmin', password='Nokia@123', secure=True)
    _cu.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505",
                                          parameter="actHigherPrioFreqHoForCA",
                                          operation="update",
                                          value=state_1)
    _cu.perform_parameter_recommissioning(dist_name="MRBTS-8505/NRBTS-8505",
                                          parameter="actHigherPrioFreqHo",
                                          operation="update",
                                          value=state_2)
    time.sleep(10)
    _cu.disconnect(connection=None, timeout=10)


def get_path() -> str:
    """
    Get the path by joining the output directory and test name.

    :return: The full path as a string.
    :rtype: str
    """
    return os.path.join(BuiltIn().get_variable_value("${OUTPUT_DIR}"), BuiltIn().get_variable_value("${TEST_NAME}"))


def start_utf_tracing() -> None:
    """
    Start UTF tracing for all configured traces.

    This function connects to the tracing manager and initiates new traces
    for each trace configuration present in the global `traces` dictionary.
    Each trace is started with specified parameters including mplane, log profile,
    and number of cells.

    :raises ConnectionError: If unable to connect to the tracing manager.
    :raises TraceStartError: If any trace fails to start.
    """
    _dm.connect_to(port='9443', user=None, passwd=None)
    if sw_version == "CU26R1_":
        global traces_branch
        for trace, params in traces_branch.items():
            params['trace_id'] = _dm.start_new_trace(mplane=params['mplane'], log_profile=params['log_profile'],
                                                     nr_cells=params['cells'])
    elif sw_version == "CU26R2_":
        global traces_trunk
        for trace, params in traces_trunk.items():
            params['trace_id'] = _dm.start_new_trace(mplane=params['mplane'], log_profile=params['log_profile'],
                                                     nr_cells=params['cells'])


def teardown_utf() -> None:
    """
    Teardown the UTF environment.

    This function disconnects and cleans up resources related to the UTF environment.
    """
    _dm.teardown()


def stop_utf_tracing() -> None:
    """
    Stop UTF tracing and download logs.

    This function iterates over the traces, stops each trace, and downloads the logs to the specified output directory.

    :return: None
    """
    output_dir = get_path()
    if sw_version == "CU26R1_":
        for trace, params in traces_branch.items():
            _dm.stop_trace(params['trace_id'])
            _dm.download_logs(params['trace_id'], target_dir=output_dir)
    elif sw_version == "CU26R2_":
        for trace, params in traces_trunk.items():
            _dm.stop_trace(params['trace_id'])
            _dm.download_logs(params['trace_id'], target_dir=output_dir)


def start_tracing() -> None:
    """
    Starts both UTF and ELT tracing.
    """
    start_utf_tracing()
    start_elt_tracing()


def stop_tracing() -> None:
    """
    Stops both UTF and ELT tracing.
    """
    stop_utf_tracing()
    stop_elt_tracing()


def teardown_tracing() -> None:
    """
    Tears down both UTF and ELT tracing.
    """
    teardown_utf()
    teardown_elt()


def _file_reader(filename: str) -> Iterator[str]:
    """
    Reads a file line by line and yields each line.

    :param filename: The name of the file to read.
    :type filename: str
    :return: An iterator over the lines of the file.
    :rtype: Iterator[str]
    """
    with open(filename, 'r') as f:
        for line in f:
            yield line


def find_syslog_files_from_utf() -> None:
    """
    Find and move syslog files from the UTF directory to a 'btslog' directory.

    The function searches for files containing 'syslog' in their names within the
    directory returned by `get_path()`. It moves these files to a subdirectory named
    'btslog', creating it if it does not exist.

    :raises OSError: If there is an issue creating the directory or moving files.
    """
    file_path = get_path()
    dest_dir = os.path.join(file_path, 'btslog')
    Path(dest_dir).mkdir(exist_ok=True)
    for dirpath, dirnames, filenames in os.walk(file_path):
        for filename in filenames:
            if 'syslog' in filename:
                file_path = os.path.join(dirpath, filename)
                shutil.move(file_path, os.path.join(dest_dir, filename))


def unzip_results() -> None:
    """
    Unzip all .zip files in the specified directory.

    This function retrieves the file path using `get_path()`, identifies all
    .zip files within that directory, and unpacks each archive into the same
    directory.

    :return: None
    """
    file_path = get_path()
    zip_files = [file for file in os.listdir(file_path) if file.endswith('.zip')]
    for zip_file in zip_files:
        shutil.unpack_archive(os.path.join(file_path, zip_file), file_path)


def merge_syslog() -> None:
    """
    Merge syslog files from the 'btslog' directory into a single file.

    The function searches for files with extensions '.LOG' or '.log' in the 'btslog' directory
    and merges their contents into a single file named 'btslog.LOG' within the 'btslogs_merged' directory.

    :raises ValueError: If no log files are found in the 'btslog' directory.
    """
    file_path = get_path()
    path = file_path + "/btslog/btslogs_merged"
    log_files = [f for f in os.listdir(file_path + "/btslog/") if f.endswith(('.LOG', '.log'))]
    log_files_iter = iter(log_files)
    if len(log_files) == 0:
        raise ValueError('Should be minimum one LOG file in the current directory.')
    if not os.path.exists(path):
        os.mkdir(path)
    with open(os.path.join(path, "btslog.LOG"), 'w') as f:
        while True:
            try:
                iterator = next(log_files_iter)
                for line in _file_reader(file_path + "/btslog/" + iterator):
                    f.write(line)
            except StopIteration:
                break


def validate_rrcreconfiguration_with_a4meas(elt_log: str) -> None:
    """
    Validate RRC Reconfiguration with A4 measurements from the given log file.

    :param elt_log: Path to the log file containing RRC messages.
    :type elt_log: str
    :raises AssertionError: If the MeasurementReport has an unrecognizable structure.
    """
    with open(elt_log, 'r') as elt:
        log = json.load(elt)
    msg1 = list(filter(lambda x: x['name'] == 'RRCReconfiguration' and 'nr-rrc' in x['data']
                       and 'nr-rrc.DL_DCCH_Message_element' in x['data']['nr-rrc']
                       and '0' in x['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']['nr-rrc.message_tree']
                       ['nr-rrc.c1_tree']['nr-rrc.rrcReconfiguration_element']['nr-rrc.rrc_TransactionIdentifier']
                       and '396510' in x['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']['nr-rrc.message_tree']
                       ['nr-rrc.c1_tree']['nr-rrc.rrcReconfiguration_element']['nr-rrc.criticalExtensions_tree']
                       ['nr-rrc.rrcReconfiguration_element']['nr-rrc.measConfig_element']
                       ['nr-rrc.measObjectToAddModList_tree']['Item 0']['nr-rrc.MeasObjectToAddMod_element']
                       ['nr-rrc.measObject_tree']['nr-rrc.measObjectNR_element']['nr-rrc.ssbFrequency']
                       and '4' in x['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']['nr-rrc.message_tree']
                       ['nr-rrc.c1_tree']['nr-rrc.rrcReconfiguration_element']['nr-rrc.criticalExtensions_tree']
                       ['nr-rrc.rrcReconfiguration_element']['nr-rrc.measConfig_element']
                       ['nr-rrc.reportConfigToAddModList']
                       and '1' in x['data']['nr-rrc']['nr-rrc.DL_DCCH_Message_element']['nr-rrc.message_tree']
                       ['nr-rrc.c1_tree']['nr-rrc.rrcReconfiguration_element']['nr-rrc.criticalExtensions_tree']
                       ['nr-rrc.rrcReconfiguration_element']['nr-rrc.measConfig_element']
                       ['nr-rrc.measGapConfig_element']['nr-rrc.gapFR1'], log))
    msg2 = list(filter(lambda x: x['name'] == 'RRCReconfigurationComplete' and 'nr-rrc' in x['data']
                       and '0' in x['data']['nr-rrc']['nr-rrc.UL_DCCH_Message_element']['nr-rrc.message_tree']
                       ['nr-rrc.c1_tree']['nr-rrc.rrcReconfigurationComplete_element']
                       ['nr-rrc.rrc_TransactionIdentifier'], log))
    log_info_to_console(msg1)
    log_info_to_console(msg2)
    matched_1 = re.search(rrcreconfiguration_msg, str(msg1[0]))
    matched_2 = re.search(rrcreconfigurationcomplete_msg, str(msg2[0]))
    assert matched_1, f"MeasurementReport has unrecognizable structure, found MeasurementReport: {msg1[0]}"
    assert matched_2, f"rrcReconfigurationComplete has unrecognizable structure, found MeasurementReport: {msg2[0]}"


def prepare_emil_logs() -> None:
    """
    Prepare EMIL logs by finding EMIL files in subfolders, decoding them, and logging information to the console.

    :return: None
    """
    file_path = get_path()
    find_emil_files_in_subfolders(file_path)
    decoded_emil_files = decode_emil_and_save_as_json(file_path, "10.42.194.122", "9443")
    log_info_to_console(decoded_emil_files)


def find_emil_files_in_subfolders(file_path: str) -> None:
    """
    Find EMIL files in subfolders and copy them to the specified file path with a new naming convention.

    :param file_path: The path where EMIL files are to be copied.
    :type file_path: str
    :return: None
    """
    count = 1
    for root, _, files in os.walk(file_path):
        for file in files:
            if file.endswith(".5gm"):
                emil_file_path = os.path.join(root, file)
                new_file_name = f"{file_path.rpartition('/')[2]}_{count}.5gm"
                shutil.copy(emil_file_path, os.path.join(file_path, new_file_name))
                count += 1
