# testsuite/Wroclaw/OAM/VRF_WRO3_T04/features/5GC001518-A/resources/1518_utils.py

import netifaces as ni
import xml.etree.ElementTree as ET
import json
from robot.api import logger
from robot.errors import ExecutionFailed


def get_pdl_validation_result(output):
    output = output['validationResult']['pdlValidationResult']['logs']['relationErrors']
    return [feedback['feedback'] for feedback in output]


def analyze_change_cipher(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/'
                          'field[@name="tls.change_cipher_spec"]'):
        cert1.append(i.attrib)
    return cert1


def analyze_app_data(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/'
                          'field[@name="tls.app_data"]'):
        cert1.append(i.attrib)
    return cert1


def client_hello(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]/field[@name="tls.handshake"]'):
        cert1.append(i.attrib)
    return cert1


def protocol_finding(xml_path):
    cert1 = []
    tree = ET.parse(xml_path)
    root = tree.getroot()
    for i in root.findall('./packet/proto[@name="tls"]/field[@name="tls.record"]'):
        cert1.append(i.attrib)
    return cert1


class ValidationError(Exception):
    pass


def extract_selected_secprm_params_dict(secprm_object):
    """Note: 'param_is_deleted' is a special made up value and recognized only in keywords from this resource,
    it is not a valid param value for BTS."""
    if 'webEMSessionLogoutTimer' in secprm_object[0]['params'].keys():
        webEMSessionLogoutTimer = secprm_object[0]['params']['webEMSessionLogoutTimer']
    else:
        webEMSessionLogoutTimer = 'param_is_deleted'

    localPasswdExpiryPeriod = secprm_object[0]['params']['localPasswdExpiryPeriod']

    localPasswdWarningPeriod = secprm_object[0]['params']['localPasswdWarningPeriod']

    if 'emAccessPriorityLogoutTimer' in secprm_object[0]['params'].keys():
        emAccessPriorityLogoutTimer = secprm_object[0]['params']['emAccessPriorityLogoutTimer']
    else:
        emAccessPriorityLogoutTimer = 'param_is_deleted'

    return {'emAccessPriorityLogoutTimer': emAccessPriorityLogoutTimer,
            'localPasswdExpiryPeriod': localPasswdExpiryPeriod,
            'localPasswdWarningPeriod': localPasswdWarningPeriod,
            'webEMSessionLogoutTimer': webEMSessionLogoutTimer}


def compare_selected_secprm_params_dicts(actual_values, expected_values):
    return actual_values['emAccessPriorityLogoutTimer'] == expected_values['emAccessPriorityLogoutTimer'] and \
            actual_values['localPasswdExpiryPeriod'] == expected_values['localPasswdExpiryPeriod'] and \
            actual_values['localPasswdWarningPeriod'] == expected_values['localPasswdWarningPeriod'] and \
            actual_values['webEMSessionLogoutTimer'] == expected_values['webEMSessionLogoutTimer']


def validate_values_of_selected_secprm_params(actual_values, expected_values):
    if compare_selected_secprm_params_dicts(actual_values, expected_values):
        return
    else:
        raise ValidationError(
            'Selected SECPRM params values are not as expected. '
            'Actual: emAccessPriorityLogoutTimer: ', actual_values['emAccessPriorityLogoutTimer'],
            'localPasswdExpiryPeriod: ', actual_values['localPasswdExpiryPeriod'],
            'localPasswdWarningPeriod: ', actual_values['localPasswdWarningPeriod'],
            'webEMSessionLogoutTimer: ', actual_values['webEMSessionLogoutTimer'],
            '. Expected: emAccessPriorityLogoutTimer: ', expected_values['emAccessPriorityLogoutTimer'],
            'localPasswdExpiryPeriod: ', expected_values['localPasswdExpiryPeriod'],
            'localPasswdWarningPeriod.', expected_values['localPasswdWarningPeriod'],
            'webEMSessionLogoutTimer: ', expected_values['webEMSessionLogoutTimer']
        )


def prepare_delta_to_modify_secprm(new_values, actual_values):
    """Note: 'param_is_deleted' is a special made up value and recognized only in keywords from this resource,
    it is not a valid param value for BTS."""
    if new_values['emAccessPriorityLogoutTimer'] != 'param_is_deleted' \
            and actual_values['emAccessPriorityLogoutTimer'] == 'param_is_deleted':
        emAccessPriorityLogoutTimer_operation = 'create'
    elif new_values['emAccessPriorityLogoutTimer'] != 'param_is_deleted' \
            and actual_values['emAccessPriorityLogoutTimer'] != 'param_is_deleted':
        emAccessPriorityLogoutTimer_operation = 'update'
    elif new_values['emAccessPriorityLogoutTimer'] == 'param_is_deleted' \
            and actual_values['emAccessPriorityLogoutTimer'] != 'param_is_deleted':
        emAccessPriorityLogoutTimer_operation = 'delete'
    else:
        raise ValueError("Arguments: new_value and actual_value cannot both be 'param_is_deleted'")

    if new_values['webEMSessionLogoutTimer'] != 'param_is_deleted' \
            and actual_values['webEMSessionLogoutTimer'] == 'param_is_deleted':
        webEMSessionLogoutTimer_operation = 'create'
    elif new_values['webEMSessionLogoutTimer'] != 'param_is_deleted' \
            and actual_values['webEMSessionLogoutTimer'] != 'param_is_deleted':
        webEMSessionLogoutTimer_operation = 'update'
    elif new_values['webEMSessionLogoutTimer'] == 'param_is_deleted' \
            and actual_values['webEMSessionLogoutTimer'] != 'param_is_deleted':
        webEMSessionLogoutTimer_operation = 'delete'
    else:
        raise ValueError("Arguments: new_value and actual_value cannot both be 'param_is_deleted'")

    delta = [{
        'distName': f'ASI-1/SECPRM-1',
        'parameters': [{
            'operation': emAccessPriorityLogoutTimer_operation,
            'parameterName': "emAccessPriorityLogoutTimer",
            'value': new_values['emAccessPriorityLogoutTimer']},
            {
                'operation': "update",
                'parameterName': "localPasswdExpiryPeriod",
                'value': new_values['localPasswdExpiryPeriod']},
            {
                'operation': "update",
                'parameterName': "localPasswdWarningPeriod",
                'value': new_values['localPasswdWarningPeriod']},
            {
                'operation': webEMSessionLogoutTimer_operation,
                'parameterName': "webEMSessionLogoutTimer",
                'value': new_values['webEMSessionLogoutTimer']},
        ]}]

    if new_values['emAccessPriorityLogoutTimer'] == 'param_is_deleted':
        delta[0]['parameters'][0].pop('value')

    if new_values['webEMSessionLogoutTimer'] == 'param_is_deleted':
        delta[0]['parameters'][3].pop('value')

    return delta


def extract_webEMSessionLoginDelay(secprm_object):
    """Note: 'param_is_deleted' is a special made up value and recognized only in keywords from this resource,
    it is not a valid param value for BTS."""
    if 'webEMSessionLoginDelay' in secprm_object[0]['params'].keys():
        webEMSessionLoginDelay = secprm_object[0]['params']['webEMSessionLoginDelay']
    else:
        webEMSessionLoginDelay = 'param_is_deleted'

    return webEMSessionLoginDelay


def prepare_delta_to_modify_webEMSessionLoginDelay(new_value, actual_value):
    """Note: 'param_is_deleted' is a special made up value and recognized only in keywords from this resource,
    it is not a valid param value for BTS."""
    if new_value != 'param_is_deleted' and actual_value == 'param_is_deleted':
        operation = 'create'
    elif new_value != 'param_is_deleted' and actual_value != 'param_is_deleted':
        operation = 'update'
    elif new_value == 'param_is_deleted' and actual_value != 'param_is_deleted':
        operation = 'delete'
    else:
        raise ValueError("Arguments: new_value and actual_value cannot both be 'param_is_deleted'")

    delta = [{
        'distName': f'ASI-1/SECPRM-1',
        'parameters': [{
            'operation': operation,
            'parameterName': "webEMSessionLoginDelay",
            'value': new_value
        }]}]

    if new_value == 'param_is_deleted':
        delta[0]['parameters'][0].pop('value')

    return delta


def convert_sw_build_to_sbts00_format(sw_version):
    if sw_version.split("_", 3)[2] == "9999" or sw_version.split("_", 3)[2] == "9990":
        sw_version = "_".join(["SBTS00", sw_version.split("_", 1)[1]])
    return sw_version


def extract_sw_builds_names_and_convert_to_sbts00_format(software_info_dict):
    active_software = software_info_dict['Active SW version']
    passive_software = software_info_dict['Passive SW version'] if 'Passive SW version' in software_info_dict.keys() \
        else 'passive_sw_empty'
    active_software = convert_sw_build_to_sbts00_format(active_software)
    passive_software = convert_sw_build_to_sbts00_format(passive_software)
    return active_software, passive_software


def get_vm_ip():
    addresses = ni.ifaddresses('eth0')[ni.AF_INET]
    vm_ip = addresses[0]['addr']
    return vm_ip


def extract_release_from_bts_software_info(software_info_dict):
    sw_version = software_info_dict['Active SW version']
    if "SBTS" not in sw_version:
        raise ValueError("Provided BTS Active SW version doesn't contain 'SBTS' prefix")
    release = sw_version.split("_", 2)[0]
    return release


def prepare_delta_to_act_deact_btsapplication_and_btsread_users(mrbts_id, value):
    delta = [{
        'distName': f'MRBTS-{mrbts_id}/MNL-1/AMGR-1/LUAC-1',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'appAdmActivated',
                'value': f'{value}'},
            {
                'operation': 'update',
                'parameterName': 'readOnlyActivated',
                'value': f'{value}'},
        ]}]
    return json.dumps(delta)


def prepare_delta_to_act_deact_btssecurity_btsapplication_and_btsread_users(mrbts_id, value):
    delta = [{
        'distName': f'MRBTS-{mrbts_id}/MNL-1/AMGR-1/LUAC-1',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'secAdmActivated',
                'value': f'{value}'},
            {
                'operation': 'update',
                'parameterName': 'appAdmActivated',
                'value': f'{value}'},
            {
                'operation': 'update',
                'parameterName': 'readOnlyActivated',
                'value': f'{value}'},
        ]}]
    return json.dumps(delta)
