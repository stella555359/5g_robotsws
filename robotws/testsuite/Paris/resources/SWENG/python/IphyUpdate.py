from robot.api import logger

import xml.etree.ElementTree as Et
import subprocess
import re
import os
import sys

ResourceBuildKey = ['CPRI-Config/CPRI-RP1-RE_List/RE/identity/buildversion',
                    'CPRI-Config/CPRI-RP1-RE_List/RE/identity/bldVersion',
                    'CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/version']
SwFileKey = ['CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/name']
GSCN = 'CPRI-Config/CPRI-RP1-RE_List/RE/hardware/vcellList/vcell/GSCN'


# Richard - Fix for issue : TypeError: cannot serialize 6480 (type int)
# def update_iphy_xml(custom_iphy, gscn_value=6480, radio_name='LTX_AAHF_C1'):
def update_iphy_xml(custom_iphy, gscn_value='6480', radio_name='LTX_AAHF_C1'):
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


def execute_command(command):
    """ Executes given command in local console
    :param str command: command that will be executed
    :return: output of command
    :rtype: str
    """
    pipes = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, stderr = pipes.communicate()
    if pipes.returncode != 0:
        exception = subprocess.CalledProcessError(pipes.returncode, command, output=output)
        error_msg = 'ERROR occurred\nstderr: {}:\nRC: {}'.format(stderr.strip(), pipes.returncode)
        logger.error(error_msg)
        raise exception
    return output.decode('utf-8')


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
    execute_command('{} scp {} {} {}'.format(sshpass_prefix, scp_options, source, destination))
    return os.path.join(os.path.dirname(iphy_path), targetdb)


def get_targetbd_name():
    """
    Gets TargetBD file name name
    :return:
    """
    host = '192.168.255.129'
    command = "ls -l /rom/ | grep -i TargetBD | grep -v .p7 | awk '{print $9}'"
    r = re.compile("^TargetBD.*xml$")
    ssh = subprocess.Popen(['ssh', host, command],
                           shell=False,
                           stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
    with ssh.stdout:
        result = ssh.stdout.readlines()
    if not result:
        raise Exception(ssh.stderr.readlines())
    if sys.version_info[0] == 2:
        return filter(r.match, result)[0].strip()
    else:
        return result[0].decode('utf-8').replace('\n', '')


def get_values_from_targetbd(root, radio_name):
    """
    Returns dictionary with resourceSWVersion and swFileKey
    :param root: parsed TargetBD.xml file
    :param radio_name: name of simulated radio taken from TargetBD.xml file
    :return: ditionary
    """
    target_bd_values = {}
    for child in root:
        if child.attrib['resourceBuildKey'] == radio_name:
            target_bd_values['resourceSWVersion'] = child.attrib['resourceSWVersion']
            for grandchild in child:
                if grandchild.tag == 'swFileKey':
                    target_bd_values['swFileKey'] = grandchild.text
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
    for tag in SwFileKey:
        build_key = root.find(tag)
        build_key.text = targetbd_values['swFileKey']
    gscn_tag = root.find(GSCN)
    gscn_tag.text = gscn_value

    tree.write(custom_iphy)


def send_custom_iphy_to_simulator(custom_iphy):
    """
    Sends custom iphy.xml to the IPHY module.
    :param custom_iphy: path to the custom iphy.xml
    """
    destination = 'toor4nsn@192.168.200.1:/ffs/run/simmode'
    sshpass_prefix = 'sshpass -p oZPS0POrRieRtu'
    scp_options = '-oStrictHostKeyChecking="no" -P 22 -oUserKnownHostsFile="/dev/null" -oLogLevel="QUIET"'
    source = custom_iphy

    execute_command('{} scp {} {} {}'.format(sshpass_prefix, scp_options, source, destination))
