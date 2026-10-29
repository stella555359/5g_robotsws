from robot.api import logger

import xml.etree.ElementTree as Et
import subprocess

Vlan_distName = 'MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1'
Vlan_attrib_name = 'vlanId'


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


def update_vlan_value(full_scfc):
    """
    Updates parameter vlanId in custom full scfc
    :param full_scfc:  path to the custom full scfc
    :return:
    """
    vlanid_value = get_vlan_value_from_defaul_scfc()
    update_vlan_value_in_full_scfc(full_scfc, vlanid_value)


def get_vlan_value_from_defaul_scfc():
    """
    Gets vlanId value from default ute scfc
    :return: vlanId value
    """
    find_default_scfc_path = execute_command('find /home/ute/testline_init_results/ -type f -name scfc.xml').strip()
    default_scfc_path = find_default_scfc_path.split('\n')[0]
    tree = Et.parse(default_scfc_path)
    root = tree.getroot()
    for child in root[0]:
        try:
            if child.attrib['distName'] == Vlan_distName and child[0].attrib['name'] == Vlan_attrib_name:
                return child[0].text
        except KeyError:
            continue


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
            if child.attrib['distName'] == Vlan_distName and child[0].attrib['name'] == Vlan_attrib_name:
                child[0].text = vlanid_value
        except KeyError:
            continue
    tree.write(full_scfc_path, encoding='utf-8', xml_declaration=True)
