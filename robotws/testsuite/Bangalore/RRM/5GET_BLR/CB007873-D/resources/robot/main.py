import os
import re
import xml.etree.ElementTree as Et
import subprocess

from datetime import datetime

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.running.context import EXECUTION_CONTEXTS
from robot.utils import is_truthy

from utils.tadek import ta_tadek


ROBOT_LIBRARY_DOC_FORMAT = "reST"

_RE_INVALID_NAME = re.compile("[^-0-9A-Z_a-z]")
_RE_INVALID_PATH = re.compile("[^-0-9A-Z_a-z/]")

ResourceBuildKey = ['CPRI-Config/CPRI-RP1-RE_List/RE/identity/buildversion',
                    'CPRI-Config/CPRI-RP1-RE_List/RE/identity/bldVersion',
                    'CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/version']
SwFileKey_File = 'CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file'
GSCN = 'CPRI-Config/CPRI-RP1-RE_List/RE/hardware/vcellList/vcell/GSCN'
VlanDistName = 'MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1'
VlanAttribName = 'vlanId'


def _sanitize(value, sanitize_regexp):
    """Replaces troublesome characters with underscores and dashes"""
    sanitized_path = sanitize_regexp.sub("-", str(value).replace(" ", "_"))
    return sanitized_path


def resolve_logs_directory(subdir="", add_timestamp=True):
    """Returns path to store logs in, that depends on current execution context.

    An extra subdirectory can be added to the resulting path using ``subdir`` argument.
    Note that non alphanumeric characters will be replaced with dashes and underscores.

    By default, current timestamp is appended to the path (or used instead of ``subdir``
    if not provided). This can be changed by setting ``add_timestamp=False``.
    """
    testcase = EXECUTION_CONTEXTS.current.test
    teardown = EXECUTION_CONTEXTS.current.in_suite_teardown

    if not testcase:
        if teardown:
            dynamic_part = "Suite_logs/Teardown"
        else:
            dynamic_part = "Suite_logs/Setup"
    else:
        dynamic_part = "TC_" + _sanitize(testcase, _RE_INVALID_NAME)

    extra_part = os.path.normpath(str(subdir)).strip("/") if subdir else ""
    timestamp = datetime.strftime(datetime.now(), "%Y%m%d_%H%M%S")
    if is_truthy(add_timestamp):
        extra_part = "_".join([part for part in [extra_part, timestamp] if part])

    return os.path.join(
        BuiltIn().replace_variables("${OUTPUT_DIR}"),
        dynamic_part,
        _sanitize(extra_part, _RE_INVALID_PATH),
    )


def execute_command_in_console(console, command, **kwargs):
    return ta_tadek.execute_command_in_console(console, command, **kwargs)


def copy_file(source, destination, **kwargs):
    return ta_tadek.copy_file(source, destination, **kwargs)


def update_iphy_xml(radio_name, custom_iphy, gscn_value='1'):
    """
    Updates sw versions, and gscn value in IPHY xml to match target BD in order to avoid Incompatible SW alarm
    :param custom_iphy: path to custom iphy.xml
    :param gscn_value: gscn value which should be inserted to custom iphy.xml
    :param radio_name: name of simulated radio taken from TargetBD.xml file
    """
    targetbd = get_targetbd_file(custom_iphy)
    tree_targetbd = Et.parse(targetbd)
    root_targetbd = tree_targetbd.getroot()
    targetbd_values = get_values_from_targetbd(root_targetbd, radio_name)
    update_custom_iphy_by_target_bd_and_gscn_values(custom_iphy, targetbd_values, gscn_value)


def get_targetbd_file(iphy_path):
    """
    Copy TragetBD filre from gNB to custom iphy directory
    :param iphy_path: path to the custom iphy directory
    :return: path to the TargetBD
    """
    targetdb = get_targetbd_name()
    destination = os.path.dirname(iphy_path)
    sshpass_prefix = 'sshpass -p oZPS0POrRieRtu'
    scp_options = '-oStrictHostKeyChecking="no" -P 22 -oUserKnownHostsFile="/dev/null" -oLogLevel="QUIET"'
    source = 'toor4nsn@192.168.255.129:/rom/{}'.format(targetdb)

    execute_command_in_console('local', '{sshpass_prefix} scp {scp_options} {source} {destination}'.format(
        sshpass_prefix=sshpass_prefix,
        scp_options=scp_options,
        source=source,
        destination=destination))
    return os.path.join(os.path.dirname(iphy_path), targetdb)


def get_targetbd_name():
    """
    Gets TargetBD file name name
    :return:
    """
    host = '192.168.255.1'
    command = 'ls /rom/'
    r = re.compile("^TargetBD.*xml$")
    ssh = subprocess.Popen(['ssh', host, command],
                           shell=False,
                           stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
    result = ssh.stdout.readlines()
    if not result:
        raise Exception(ssh.stderr.readlines())
    return list(filter(r.match, result))[0].strip()


def get_values_from_targetbd(root, radio_name):
    """
    Returns dictionary with resourceSWVersion and swFileKey
    :param root: parsed TargetBD.xml file
    :param radio_name: name of simulated radio taken from TargetBD.xml file
    :return: ditionary
    """
    target_bd_values = {'resourceSWVersion': False, 'swFileKey': []}
    for child in root:
        try:
            if child.attrib['resourceBuildKey'] == radio_name and not target_bd_values['resourceSWVersion']:
                target_bd_values['resourceSWVersion'] = child.attrib['resourceSWVersion']
        except KeyError:
            pass
        try:
            if child.attrib['hwUnit'] == radio_name:
                target_bd_values['swFileKey'].append(child.attrib['swFileKeyName'])
        except KeyError:
            pass
    return target_bd_values


def update_custom_iphy_by_target_bd_and_gscn_values(custom_iphy, targetbd_values, gscn_value):
    """
    Overwrites custom iphy.xml with resourceSWVersion and swFileKey from TargetBD and new GSCN value
    :param custom_iphy: path to custom iphy.xml file
    :param targetbd_values: dictionary with resourceSWVersion and swFileKey
    :param gscn_value: gscn which should be inserted to iphy.xml
    """
    tree = Et.parse(custom_iphy)
    root = tree.getroot()
    for tag in ResourceBuildKey:
        build_version = root.find(tag)
        build_version.text = targetbd_values['resourceSWVersion']
    for i, value in enumerate(targetbd_values['swFileKey']):
        sw_file_key = SwFileKey_File + '[' + str(i+1) + ']' + '/name'
        usage_status = SwFileKey_File + '[' + str(i+1) + ']' + '/usageStatus'
        version = SwFileKey_File + '[' + str(i+1) + ']' + '/version'
        build_key = root.find(sw_file_key)
        build_key.text = value
        usage_status_key = root.find(usage_status)
        usage_status_key.text = 'active'
        value_key = root.find(version)
        value_key.text = targetbd_values['resourceSWVersion']
    gscn_tag = root.find(GSCN)
    gscn_tag.text = gscn_value

    tree.write(custom_iphy, encoding='utf-8', xml_declaration=True)


def send_custom_iphy_to_simulator(custom_iphy):
    """
    Sends custom iphy.xml to the IPHY module.
    :param custom_iphy: path to the custom iphy.xml
    """
    destination = 'toor4nsn@192.168.200.1:/ffs/run/simmode'
    sshpass_prefix = 'sshpass -p oZPS0POrRieRtu'
    scp_options = '-oStrictHostKeyChecking="no" -P 22 -oUserKnownHostsFile="/dev/null" -oLogLevel="QUIET"'
    source = custom_iphy

    execute_command_in_console('local', '{sshpass_prefix} scp {scp_options} {source} {destination}'.format(
        sshpass_prefix=sshpass_prefix,
        scp_options=scp_options,
        source=source,
        destination=destination))


def get_tl_name():
    """
    Returns testline name
    :return: testline name
    """
    tl_name = subprocess.check_output('hostname').replace("-", "_").strip()
    return tl_name


def update_vlan_value(full_scfc):
    """
    Updates parameter vlanId in custom full scfc
    :param full_scfc:  path to the custom full scfc
    """
    vlanid_value = get_vlan_value_from_init_file()
    update_vlan_value_in_full_scfc(full_scfc, vlanid_value)


def get_vlan_value_from_init_file():
    """
    Gets vlanId value from __init__.py file
    :return: vlanId value
    """
    path = os.path.join('/home/ute/testline_configuration/', get_tl_name(), '__init__.py')
    with open(path, 'r') as init_file:
        return re.search(r's1u.*vlan_id=(\d+)', init_file.read()).group(1)


def update_vlan_value_in_full_scfc(full_scfc_path, vlanid_value):
    """
    Updates custom full scfc with suitable vlanId value
    :param full_scfc_path: path to the custom full scfc
    :param vlanid_value: vlanId value which should be used full scfc
    """
    Et.register_namespace('', "raml21.xsd")
    tree = Et.parse(full_scfc_path)
    root = tree.getroot()
    for child in root[0]:
        try:
            if child.attrib['distName'] == VlanDistName and child[0].attrib['name'] == VlanAttribName:
                child[0].text = vlanid_value
        except KeyError:
            continue
    tree.write(full_scfc_path, encoding='utf-8', xml_declaration=True)


def get_tput_chunks(tput_value, chunk='140'):
    """ Return list of throughput chunks from which each chunk can be passed as `mbps` to trf_data_start Egate command.

    :param str tput_value: throughput value (mbps) to be divided into chunks
    :param str chunk: size of a single chunk
    :return: list of throughput chunks (int)
    :rtype list
    """
    tput_value, chunk = int(tput_value), int(chunk)
    tput_chunks = (tput_value // chunk) * [chunk]
    if tput_value % chunk != 0:
        tput_chunks.append(tput_value % chunk)
    return tput_chunks
