import re
import os
import json
import xml.etree.ElementTree as ET
from moler.device import DeviceFactory
from moler.exceptions import CommandTimeout, CommandFailure
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.exceptions import AlarmIsNotActive
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue, DataNotAvailable
from taf.internal.managed.ssh.managed_ssh_connection import ManagedSshConnection
from taf.transport.ssh.exceptions import ConnectFailedError
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.test_config import get_repository_path
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.logger.custom_logger import log_warn_to_console
from robot.libraries.BuiltIn import BuiltIn


deltas_directory = 'testsuite/Krakow/OAM/regression/RAN_PZ_KRK5/CRT_4G_ASIR_LTE4500-K-R_LTE4694_CNI58604/deltas/'
hub_proxy = BuiltIn().get_variable_value('${tl.test_pcs[1].default_ssh_connection_details.addr}')
proxy_user = BuiltIn().get_variable_value('${tl.test_pcs[1].default_ssh_connection_details.username}')
proxy_password = BuiltIn().get_variable_value('${tl.test_pcs[1].default_ssh_connection_details.password}')
hub_lmp = '192.168.255.129'
hub_user = 'toor4nsn'
hub_password = 'oZPS0POrRieRtu'
nidd_pattern = r"managedObject.*\sversion=\"(.*)\""


def get_id_from_cell_name(cell):
    return cell[cell.index('-') + 1:]


def change_and_activate_asirhub_parameter(dn, name, value):
    gnb_asir_hub = GnbAsirHubOperations()
    delta = [{
        'distName': dn,
        'parameters': [{
            'operation': 'update',
            'parameterName': name,
            'value': value
        }]
    }]
    gnb_asir_hub.perform_asir_recommissioning(delta=delta)


def verify_asirhub_parameter(dist_name, parameter, expected_value):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml')
    asir_scf = ET.parse("/tmp/temp_asir_scf.xml")

    if asir_scf.find(".//*[@distName='{}']".format(dist_name)) is not None:
        obj = asir_scf.find(".//*[@distName='{}']".format(dist_name))
        param = obj.find(".//*[@name='{}']".format(parameter))

        if param is not None:
            value = param.text
            if value != expected_value:
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


@load_moler_configuration_from_tl()
def ssh_hub_via_lmp(user=hub_user, use_correct_password=True):
    lmp_password = hub_password if use_correct_password else "incorrect_password"
    pc_device = DeviceFactory.get_device(name='TEST_PC', initial_state="UNIX_REMOTE")
    ssh_cmd = pc_device.get_cmd(cmd_name="ssh", cmd_params={"login": proxy_user,
                                                            "host": hub_proxy,
                                                            "password": proxy_password,
                                                            "expected_prompt": r'{}@.*(\$|#|>)\s+'.format(proxy_user)})
    ssh_cmd()
    ssh_cmd = pc_device.get_cmd(cmd_name="ssh", cmd_params={"login": user,
                                                            "host": hub_lmp,
                                                            "password": lmp_password,
                                                            "expected_prompt": r'toor4nsn@.*(\$|#|>)\s+'})
    try:
        ssh_output = ssh_cmd()
        return ssh_output
    except (CommandTimeout, CommandFailure):
        return None


def is_hub_lmp_pingable():
    result = False
    pattern = r'^5 packets transmitted, (\d) received'
    lmp_proxy = ManagedSshConnection(
        host=hub_proxy,
        user=proxy_user,
        password=proxy_password)
    lmp_proxy.setup()
    ping_output = lmp_proxy.execute(command="ping {} -c 5 -q".format(hub_lmp))
    output = ping_output.split('\n')
    if re.match(pattern, output[3]):
        if int(re.match(pattern, output[3]).group(1)) > 0:
            result = True
    lmp_proxy.teardown()
    return result


def verify_is_hub_lmp_pingable():
    if not is_hub_lmp_pingable():
        raise Exception("Hub LMP port is not pingable.")


def verify_is_hub_lmp_not_pingable():
    if is_hub_lmp_pingable():
        raise Exception("Hub LMP port is pingable but it shouldn't.")


def ssh_hub_with_incorrect_password(user=hub_user, nr_of_tries=2):
    for _ in range(nr_of_tries):
        try:
            if ssh_hub_via_lmp(user=user, use_correct_password=False):
                raise Exception("User {} should not login with wrong password".format(user))
        except ConnectFailedError:
            pass


def update_gnb_param(dist_name, parameter, value):
    delta = [{
        'distName': str(dist_name),
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': str(parameter),
            'value': value}]}]
    gnb_comm = GnbCommissioning()
    gnb_comm.perform_bts_delta_commissioning(delta=delta)


def verify_info_banner(info_banner, case='successful', nr_of_fail_attempts=None):
    expected_info_banner = ['You are about to access a private system. This system is for the use of',
                            'authorized users only. All connections are logged to the extent and by means',
                            'acceptable by the local legislation. Any unauthorized access or access',
                            'attempts may be punished to the fullest extent possible under the applicable',
                            'local legislation.']
    warning = 'you are using default password, please change it as soon as possible'

    for banner_line in range(5):
        if info_banner["LINES"][banner_line] != expected_info_banner[banner_line]:
            raise Exception("SSH banner line '{}' is not as expected '{}'".format(
                info_banner["LINES"][banner_line], expected_info_banner[banner_line]))

    if case == 'successful':
        if not (warning in info_banner["LINES"][6]):
            raise Exception("Cannot get message about default password")
        else:
            if info_banner["FAILED_LOGIN_ATTEMPTS"]:
                raise Exception("Number of failed attempts should be None, but it is {}.".format(
                    info_banner["FAILED_LOGIN_ATTEMPTS"]))
    else:
        parsed_nr_of_fail_attempts = int(info_banner["FAILED_LOGIN_ATTEMPTS"])
        if nr_of_fail_attempts != parsed_nr_of_fail_attempts:
            raise Exception("Wrong number of failed attempts. Should be {}, but it is {}.".format(
                nr_of_fail_attempts, parsed_nr_of_fail_attempts))


def verify_ssh_info_banner_content():
    ssh_hub_via_lmp()
    ssh_hub_with_incorrect_password(user=hub_user, nr_of_tries=1)
    ssh_result = ssh_hub_via_lmp()
    verify_info_banner(info_banner=ssh_result, case='unsuccessful', nr_of_fail_attempts=3)
    ssh_result = ssh_hub_via_lmp()
    verify_info_banner(info_banner=ssh_result)


def load_gnb_delta_from_file(delta_json_file):
    delta_json_path = '{}{}{}'.format(get_repository_path(), deltas_directory, delta_json_file)
    delta_file = open(delta_json_path)
    delta = json.load(delta_file)
    load_gnb_delta(delta=delta)


def load_gnb_delta(delta):
    gnb_comm = GnbCommissioning()
    gnb_comm.perform_bts_delta_commissioning(delta=delta)


def load_asir_delta_from_file(delta_xml_file):
    delta_xml_path = '{}{}{}'.format(get_repository_path(), deltas_directory, delta_xml_file)
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.perform_asir_commissioning(scf_path=delta_xml_path)


def verify_dl_mimo(cell, mimo_value):
    mimo_regex = {
        'Closed Loop MIMO (4x4)': r'Closed Loop MIMO \(4x4\)',
        'Closed Loop MIMO (4x2)': r'Closed Loop MIMO \(4x2\)',
        'Dynamic Open Loop MIMO': r'Dynamic Open Loop MIMO'
    }
    cell_id = get_id_from_cell_name(cell=cell)
    dist_name = 'MRBTS-76079/LNBTS-76079/LNCEL-{}/LNCEL_TDD-0'.format(cell_id)
    mimo = {
        dist_name: {
            'dlMimoMode': mimo_regex[mimo_value]
        },
    }
    gnb_du = GnbDuOperations()
    gnb_du.verify_configuration_parameters_values(param_dict=mimo)


def get_allowed_alarms(custom_alarms=None):
    from common_variables import DEFAULT_ALARMS
    allowed_alarms = DEFAULT_ALARMS
    if custom_alarms and allowed_alarms:
        for custom_alarm in custom_alarms:
            if custom_alarm not in allowed_alarms:
                allowed_alarms.append(custom_alarm)
    return allowed_alarms


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


def verify_allowed_alarms_on_asir(alarm_list):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.verify_only_allowed_alarms_are_active(allowed_alarms=alarm_list)


def check_scout_scf_id_is_present():
    debug_file_path = os.path.join(get_builtin_value('OUTPUT_DIR'), "debug.log")
    scout_scf_id_pattern = r'\-\s+INFO\s+-\s+SCOUT_SCF_ID\:\s\d+'
    test_start_pattern = r'\-\s+INFO\s+-\s+\+\-\s+START\sTEST'
    with open(debug_file_path, 'r') as debug_file:
        file_content = debug_file.read()
        nr_of_tests = len(re.findall(test_start_pattern, file_content))
        scout_scf_ids = len(re.findall(scout_scf_id_pattern, file_content))
        if int(nr_of_tests) != int(scout_scf_ids):
            log_warn_to_console("Not all tests get SCOUT_SCF_ID, verify it in debug.log")
