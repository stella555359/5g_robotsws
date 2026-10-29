import re
import os
import json
import time
import xml.etree.ElementTree as ET
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue, DataNotAvailable
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.exceptions import AlarmIsNotActive, AlarmIsActive, InvalidStatuses
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.utilities.test_config import get_repository_path
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.logger.custom_logger import log_warn_to_console
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state


deltas_directory = 'testsuite/Krakow/OAM/regression/RAN_PZ_KRK5/CRT_4G_ASIR_LTE4861_LTE5244_LTE4500-F_CR31552/deltas/'
hub_proxy = '10.84.174.160'
proxy_user = 'ute'
proxy_password = 'ute'
hub_lmp = '192.168.255.129'
hub_user = 'toor4nsn'
hub_password = 'oZPS0POrRieRtu'
nidd_pattern = r"managedObject.*\sversion=\"(.*)\""


def get_asir_scf():
    gnb_asir_hub = GnbAsirHubOperations()
    return gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml')


def get_number_of_rfc():
    scf_file = get_asir_scf()
    asir_scf = ET.parse(scf_file)
    nr_of_rfc = len(asir_scf.findall(".//*[@class='com.nokia.asi:RFC_R']"))
    return str(nr_of_rfc)


def verify_asirhub_parameter(dist_name, parameter, expected_value, asir_scf_file=None):
    if not asir_scf_file:
        gnb_asir_hub = GnbAsirHubOperations()
        asir_scf_file = gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml')
    asir_scf_xml = ET.parse(asir_scf_file)

    if asir_scf_xml.find(".//*[@distName='{}']".format(dist_name)) is not None:
        obj = asir_scf_xml.find(".//*[@distName='{}']".format(dist_name))
        param = obj.find(".//*[@name='{}']".format(parameter))

        if param is not None:
            value = param.text
            if value != str(expected_value):
                raise IncorrectParameterValue("Parameter '{}' should be '{}' but is '{}'".format(parameter,
                                                                                                 expected_value,
                                                                                                 value))
        else:
            raise DataNotAvailable(
                "Parameter '{}' doesn't exist in ASiR configuration, check if parameter name is correct".format(
                    parameter))
    else:
        raise DataNotAvailable(
            "DistName '{}' doesn't exist in ASiR configuration, check if distName name is correct".format(dist_name))


def verify_the_state_of_all_rfccell_channels(expected_state):
    asir_scf_file = get_asir_scf()
    asir_scf_xml = ET.parse(asir_scf_file)
    rfc_channels = asir_scf_xml.findall(".//*[@class='com.nokia.asi:RFCCHANNEL_R']")
    for channel in rfc_channels:
        actual_state = channel.find(".//*[@name='operationalState']")
        if actual_state.text != expected_state:
            raise IncorrectParameterValue("RFCCHANNEL state should be '{}' but is '{}'".format(expected_state,
                                                                                               actual_state.text))


def verify_the_state_of_antresource_under_rfcchannel(expected_state, ant_id=None):
    gnb_asir_hub = GnbAsirHubOperations()
    asir_scf_file = get_asir_scf()
    asir_scf_xml = ET.parse(asir_scf_file)
    rfc_channels = asir_scf_xml.findall(".//*[@class='com.nokia.asi:RFCCHANNEL_R']")
    for channel in rfc_channels:
        antantlrnds = channel.findall(".//*[@name='antAntlRDN']")
        for antantlrnd in antantlrnds:
            pattern = re.compile(r'ANTMOD_R-(\d+)')
            antmod_id = re.search(pattern, antantlrnd.text).group(1)
            if ant_id and (int(ant_id) != int(antmod_id)):
                continue
            gnb_asir_hub.verify_antmod_status(ant_ids=[int(antmod_id)],
                                              expected_statuses={'operationalState': expected_state})


def wait_for_rfc_cpri_link_establishment(timeout=300):
    start_time = time.time()
    gnb_asir_hub = GnbAsirHubOperations()
    cpri_alarm_id = 4483
    alarm_is_active = False
    while time.time() - start_time < int(timeout):
        for alarm in gnb_asir_hub.get_active_asir_webem_alarms():
            if alarm['fault_id'] == cpri_alarm_id:
                alarm_is_active = True
                break
        if alarm_is_active:
            alarm_is_active = False
            time.sleep(5)
        else:
            break

    else:
        raise AlarmIsActive("Timeout {}s passed. CPRI link down alarm is still active.".format(timeout))


def verify_rfc_cells_state(expected_state='operational'):
    gnb_asir_hub = GnbAsirHubOperations()
    asir_elements = gnb_asir_hub.get_site_logical_info()
    for element in asir_elements:
        if element['description'] and 'RFC-' in element['description']['label'] \
                and 'RFCCELL-' in element['description']['text'][0]:
            if element['status']['state'] != str(expected_state):
                raise InvalidStatuses("Unexpected '{}' rfccell state, should be '{}'".format(element['status']['state'],
                                                                                             expected_state))


def verify_ant_led_status(ant_ids=[1]):
    gnb_asir_hub = GnbAsirHubOperations()
    expected_statuses = {'fronthaulStatusLedColor': 'Green', 'rfStatusLedColor': 'Green', 'unitStatusLedColor': 'Green'}
    gnb_asir_hub.verify_antmod_status(ant_ids=ant_ids, expected_statuses=expected_statuses)


def verify_ant_status(ant_ids=[1]):
    gnb_asir_hub = GnbAsirHubOperations()
    expected_statuses = {'operationalstate': 'enabled', 'localstate': 'unblocked'}
    gnb_asir_hub.verify_antmod_status(ant_ids=ant_ids, expected_statuses=expected_statuses)


def verify_hub_led_status(ant_ids=[1]):
    gnb_asir_hub = GnbAsirHubOperations()
    expected_statuses = {'activeStatusLedColor': 'Green', 'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'}
    gnb_asir_hub.verify_hubmod_status(expected_statuses=expected_statuses)


def load_asir_delta_from_file(delta_xml_file):
    delta_xml_path = '{}{}{}'.format(get_repository_path(), deltas_directory, delta_xml_file)
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.perform_asir_commissioning(scf_path=delta_xml_path)


def verify_rfc_parameters(parameters):
    scf_file = get_asir_scf()
    for param_name in parameters['params']:
        verify_asirhub_parameter(dist_name=parameters['distName'], parameter=param_name,
                                 expected_value=parameters['params'][param_name], asir_scf_file=scf_file)


def get_list_of_ids_of_asir_objects(object_type):
    gnb_asir_hub = GnbAsirHubOperations()
    return gnb_asir_hub.get_all_antenna_ids()


def reset_asiant(ant_id):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.reset_antenna(ant_id=ant_id)


def reset_hub():
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.reset_hub()


def verify_alarm_is_active_on_asir(fault_id, fault_name=None):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.verify_alarm_is_active(fault_id=int(fault_id))
    if fault_name:
        alarm_is_active = False
        for alarm in gnb_asir_hub.get_active_asir_webem_alarms():
            if fault_name in alarm['fault_name'] and alarm['fault_id'] == int(fault_id):
                alarm_is_active = True
        if not alarm_is_active:
            raise AlarmIsNotActive("Alarm with id {} and name {} is not active, it should be active".format(fault_id,
                                                                                                            fault_name))


def verify_alarm_is_not_active_on_asir(fault_id):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.verify_alarm_is_not_active(fault_id=int(fault_id))


def verify_asiant_alarm(ant_id):
    gnb_asir_hub = GnbAsirHubOperations()
    last_cleared_alarm = gnb_asir_hub.get_historical_asir_webem_alarms()[-1]
    if not (last_cleared_alarm['fault_id'] == 4480
            and last_cleared_alarm['source_object'] == 'ASI-914/ASI_R-1/ANTMOD_R-{}'.format(ant_id)):
        raise Exception('Last cleared fault id alarm is not 4480')


def verify_hub_alarm():
    gnb_asir_hub = GnbAsirHubOperations()
    last_cleared_alarm = gnb_asir_hub.get_historical_asir_webem_alarms()[-1]
    if not (last_cleared_alarm['fault_id'] == 10
            and last_cleared_alarm['source_object'] == 'ASI-914/ASI_R-1/HUBMOD_R-1'):
        raise Exception('Last cleared fault id alarm is not 10')


def get_allowed_alarms(custom_alarms=None):
    from common_variables import DEFAULT_ALARMS
    allowed_alarms = DEFAULT_ALARMS
    if custom_alarms and allowed_alarms:
        for custom_alarm in custom_alarms:
            if custom_alarm not in allowed_alarms:
                allowed_alarms.append(custom_alarm)
    return allowed_alarms


def compare_power_consumption(command_output, ant_id):
    ant_powers = command_output.strip().split()
    ant_powers = ant_powers[:len(ant_powers) - 1]
    ant_id = int(ant_id) - 1
    threshold = 270
    for num_of_antenna, ant_val in enumerate(ant_powers):
        if str(num_of_antenna) == str(ant_id):
            if int(ant_val) < threshold:
                raise Exception('Wrong value of ant power. Is {}, but should more than {}'.format(ant_val, threshold))
            break


def verify_hub_processes(command_output, rfsw_processes):
    processes_not_found = []
    for process in rfsw_processes:
        process_flag = False
        pattern = re.compile(r'([\s+|\/]{}[:|\s+])'.format(process))
        for line in command_output.splitlines():
            if re.search(pattern, line):
                process_flag = True
                break
        if not process_flag:
            processes_not_found.append(process)
    if processes_not_found:
        raise Exception('Following process(es) is/are not running on HUB: {}.'.format(processes_not_found))


def verify_hub_systemctl_status(command_output):
    pattern = re.compile(r'State:\s+(.*)\s+')
    state = re.search(pattern, command_output).group(1)
    if state.lower() == 'running':
        raise Exception("Systemctl status is {} - it's not proper state.".format(
            re.search(pattern, command_output).group(1)))


def verify_if_ip_assigned_to_sw0_if_on_hub(command_output):
    pattern = re.compile(r'ether\s+(([0-9a-f]{2}[:-]){5}([0-9a-f]{2}))')
    if not re.search(pattern, command_output.lower()):
        raise Exception("Address for SW0 interface is not assigned.")


def verify_number_of_antennas(ant_ids, nr_of_antennas):
    if not len(ant_ids) == int(nr_of_antennas):
        raise Exception('Number of ANTMODs is {}, but should be {}.'.format(len(ant_ids), nr_of_antennas))


def verify_number_of_rfc_cells(expected_nr_of_cells):
    nr_of_cells = 0
    gnb_asir_hub = GnbAsirHubOperations()
    asir_elements = gnb_asir_hub.get_site_logical_info()
    for element in asir_elements:
        if element['description'] and 'RFC-' in element['description']['label'] \
                and 'RFCCELL-' in element['description']['text'][0]:
            nr_of_cells += 1
    if nr_of_cells != int(expected_nr_of_cells):
        raise Exception('Number of RFC cells is {}, but should be {}.'.format(nr_of_cells, expected_nr_of_cells))


def load_gnb_delta(delta):
    gnb_comm = GnbCommissioning()
    gnb_comm.perform_bts_delta_commissioning(delta=delta, timeout=600)


def load_gnb_delta_from_file(delta_json_file):
    delta_json_path = '{}{}{}'.format(get_repository_path(), deltas_directory, delta_json_file)
    delta_file = open(delta_json_path)
    delta = json.load(delta_file)
    load_gnb_delta(delta=delta)


def perform_action_according_to_matrix(cell, action='block'):
    from common_variables import CALL_CELL_MATRIX
    gnb_cell = GnbCellOperations()
    for bts_id in CALL_CELL_MATRIX[cell]:
        for cell_id in CALL_CELL_MATRIX[cell][bts_id]:
            if action == 'block':
                gnb_cell.block_cell(bts_id=bts_id, cell_id=cell_id)
            else:
                gnb_cell.unblock_cell(bts_id=bts_id, cell_id=cell_id)


def verify_no_alarm_on_asir():
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.connect()
    alarms = gnb_asir_hub.asir.get_active_alarms()
    gnb_asir_hub.disconnect()
    if alarms:
        raise Exception("There are active alarms on ASIR, verify them: {}".format(alarms))


def check_scout_scf_id_is_present():
    debug_file_path = os.path.join(get_builtin_value('OUTPUT_DIR'), "debug.log")
    scout_scf_id_pattern = r'\-\s+INFO\s+-\s+SCOUT_SCF_ID\:\s\d+'
    test_start_pattern = r'\-\s+INFO\s+-\s+\+\-\s+START\sTEST'
    with open(debug_file_path, 'r') as debug_file:
        file_content = debug_file.read()
        nr_of_tests = len(re.findall(test_start_pattern, file_content))
        scout_scf_ids = len(re.findall(scout_scf_id_pattern, file_content))
        if nr_of_tests != scout_scf_ids:
            log_warn_to_console("Not all tests get SCOUT_SCF_ID, verify it in debug.log")


def get_nidd_version(xml_file):
    with open(xml_file, 'r') as scf:
        line = scf.readline()
        while line:
            line = scf.readline()
            if re.search(nidd_pattern, line):
                nidd_version = re.search(nidd_pattern, line).group(1)
                return nidd_version
    raise Exception("Cannot find nidd version in ASIR scf.")


def replace_nidd_version(xml_file):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml')
    new_nidd_version = get_nidd_version(xml_file='/tmp/temp_asir_scf.xml')
    xml_path = '{}{}{}'.format(get_repository_path(), deltas_directory, xml_file)
    old_nidd_version = get_nidd_version(xml_file=xml_path)
    with open(xml_path, 'r+') as scf:
        file_content = scf.read()
        file_content = re.sub(old_nidd_version, new_nidd_version, file_content)
        scf.seek(0)
        scf.truncate()
        scf.write(file_content)


def verify_power_consumption():
    gnb_asir_hub = GnbAsirHubOperations()
    scf_file = get_asir_scf()
    gnb_asir_hub.verify_power_consumption_of_all_antennas(scf_file_path=scf_file)


def perform_setup_reconfiguration(prefix_tag=None):
    perform_commissioning_on_gnb_to_onair_state(prefix_tag=prefix_tag, asir_hub=False)
