"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

import xml.etree.ElementTree as Et
import os
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ta5g_interface_tools import ta5g_interface_tools
import testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.file_management as file_mgmt
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.utilities import logger_console
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.utilities import logger_console_info
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import (
    run_on_ap, reset_units_and_wait_for_radio_head_online
)
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import run_on_gnb


def modify_iphy_parameters(params_dict, logs_dir='/tmp', iphy_prefix='new'):
    """
    Modify parameters in iphy file and upload to AP.
    :param params_dict: Dictionary of parameters to modify {param_path: param_value, ...}
                        WARNING: swFileKey value should be provided as a list
                        e.g {'CPRI-Config/CPRI-RP1-RE_List/RE/ecpri': 'true',
                        'CPRI-Config/CPRI-RP1-RE_List/RE/identity/antennaPanelMap/antennaPanel/productCode': '474750A',
                        'CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/name': [..., ...]}

    :param logs_dir: Directory where files will be downloaded
    :param iphy_prefix: Prefix for iphy filename
    :return: None
    """
    file_mgmt.copy_files_from_ap(files=['/rom/simmode/iphy.xml'], local_path=logs_dir)
    local_iphy_filepath = os.path.join(logs_dir, '{}_iphy.xml'.format(iphy_prefix))
    file_mgmt.change_file_name(os.path.join(logs_dir, 'iphy.xml'), local_iphy_filepath)
    tree = Et.parse(local_iphy_filepath)
    root = tree.getroot()
    for param_path in params_dict.keys():
        if param_path == 'CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/name':
            sw_configs = root.findall('CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software')
            for sw_config in sw_configs:
                sw_config = _adjust_number_of_elements(sw_config, 2 * len(params_dict[param_path]))
                new_children_list = sw_config.findall('file')
                grouped_children_list = [new_children_list[n:n + 2] for n in range(0, len(new_children_list), 2)]
                for index in range(0, len(params_dict[param_path])):
                    _modify_file_element_values(grouped_children_list, index, params_dict, 'active')
                    _modify_file_element_values(grouped_children_list, index, params_dict, 'passive')
        else:
            iphy_params = root.findall(param_path)
            if not iphy_params:
                logger.warn("{} not found in IPHY file".format(param_path))
                continue
            for iphy_param in iphy_params:
                iphy_param.text = params_dict[param_path]
    tree.write(local_iphy_filepath)
    file_mgmt.upload_files_to_ap(files=[local_iphy_filepath], remote_path='/rom/simmode')
    run_on_ap('cd /rom/simmode; ln -fs {}_iphy.xml iphy.xml'.format(iphy_prefix))


def _adjust_number_of_elements(sw_config, target_num_of_elements):
    """
    Adjust number of elements in iphy.xml software configuration section.

    :param sw_config: Element from iphy.xml located at 'CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software'
    :param target_num_of_elements(int): Target number of 'file' elements in software configuration section
    :return: Updated sw_config variable
    """
    children_list = sw_config.findall('file')
    diff = len(children_list) - target_num_of_elements
    if diff < 0:
        for index in range(0, abs(diff)):
            new_element = _create_new_file_element()
            sw_config.append(new_element)
    elif diff > 0:
        for index in range(0, diff):
            sw_config.remove(children_list[index])
    return sw_config


def _modify_file_element_values(grouped_children_list, index, params_dict, usage_status):
    """
    Modify 'file' element in iphy.xml's software configuration section.

    :param grouped_children_list(list): Grouped list of 'file' elements
    :param index(int): Id matching proper object in params_dict variable with 'file' element
    :param params_dict(dict): Dictionary of parameters to modify
    :param usage_status(string): Usage status can be set to 'active' or 'passive'
    :return: None
    """
    item_id = 0 if usage_status == 'active' else 1
    for child in grouped_children_list[index][item_id]:
        if child.tag == 'name':
            child.text = params_dict['CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/name'][index]
        elif child.tag == 'usageStatus':
            child.text = usage_status
        elif child.tag == 'version':
            child.text = params_dict['CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/version'] \
                if not None else ''


def _create_new_file_element():
    """
    Create the 'file' element according to the iphy convention.
    :return : ElementTree.Element with content:
            <file>
                <name></name>
                <usageStatus></usageStatus>
                <version></version>
            </file>
    """
    new_element = Et.Element('file')
    new_element.text = '\n                            '
    new_element.tail = '\n                        '
    name = Et.SubElement(new_element, 'name')
    name.text = ''
    name.tail = '\n                            '
    status = Et.SubElement(new_element, 'usageStatus')
    status.text = ''
    status.tail = '\n                            '
    version = Et.SubElement(new_element, 'version')
    version.text = ''
    version.tail = '\n                            '
    return new_element


def get_sw_values_from_targetbd(ru_type, resource_build_key='', logs_dir='/tmp'):
    """

    :param ru_type: Type of Radio Unit e.g. 'AEQA'
    :param resource_build_key: Optional: Exact name of resource from TargetBD e.g. 'LTX_AEQA_N1'
    :param logs_dir: Directory where files will be downloaded
    :return: dictionary with SW values e.g. {'sw_file_key': ['LTX_AEQE_trm-rfsw-image-install_0x32E57948.tar'],
    'resource_sw_version': 'RF.TRM6.trunk.20210818.029', 'resource_build_key': 'LTX_AEQE'}
    """
    _, gnb_output = run_on_gnb(cmd="ls /rom/TargetBD* | head -n 1")
    targetbd_filepath = gnb_output.rstrip()
    file_mgmt.copy_files_from_gnb(files=[targetbd_filepath], local_path=logs_dir)
    target_bd_values = {}
    sw_file_key_list = []
    resource_build_key = resource_build_key if resource_build_key != '' else 'LTX_{}'.format(ru_type)
    target_bd_values.update({'resource_build_key': resource_build_key})
    tree = Et.parse(os.path.join(logs_dir, os.path.basename(targetbd_filepath)))
    root = tree.getroot()
    for child in root:
        if 'resourceBuildKey' in child.attrib and child.attrib['resourceBuildKey'] == resource_build_key:
            target_bd_values.update({'resource_sw_version': child.attrib['resourceSWVersion']})
            for grandchild in child:
                sw_file_key_list.append(grandchild.text)
            target_bd_values.update({'sw_file_key': sw_file_key_list})
    if len(target_bd_values) == 1:
        raise RuntimeError('Could not find data for {}. Try to check if provided resource build key exists '
                           'in TargetBD'.format(resource_build_key))
    return target_bd_values


def change_radio_unit_iphy(ru_type='AEQE', resource_build_key='', logs_dir='/tmp', site_reset=True):
    """
    Function to change RU type and update iphy file according to software version from TargetBD.

    :param ru_type: Type of Radio Unit e.g. 'AEQA'
    :param resource_build_key: Optional: Exact name of resource from TargetBD e.g. 'LTX_AEQA_N1'
                               Default value: RU type with prefix 'LTX_'
    :param logs_dir: Directory where files will be downloaded
    :param site_reset: (bool)
    """
    target_bd_values = get_sw_values_from_targetbd(
        ru_type=ru_type,
        resource_build_key=resource_build_key,
        logs_dir=logs_dir
    )
    parameters_to_modify = {
        'CPRI-Config/CPRI-RP1-RE_List/RE/identity/cardName': ru_type,
        'CPRI-Config/CPRI-RP1-RE_List/RE/identity/resourceBuildKey': target_bd_values['resource_build_key'],
        'CPRI-Config/CPRI-RP1-RE_List/RE/identity/bldVersion': target_bd_values['resource_sw_version'],
        'CPRI-Config/CPRI-RP1-RE_List/RE/identity/buildversion': target_bd_values['resource_sw_version'],
        'CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/name': target_bd_values['sw_file_key'],
        'CPRI-Config/CPRI-RP1-RE_List/RE/soap-config/software/file/version': target_bd_values['resource_sw_version']
    }
    modify_iphy_parameters(
        params_dict=parameters_to_modify,
        logs_dir=logs_dir,
        iphy_prefix=ru_type
    )
    if site_reset:
        reset_units_and_wait_for_radio_head_online()
    logger.info('IPHY file modified successfully', also_console=True)


def get_airphone_build():
    """Get AirPhone build version; function parses the file at AP ASIKs /rom/TargetDB*

    :return: AirPhone build in format like: 5G_GNB_0004_000000_016318
    """
    _, output_ap = run_on_ap(cmd="ls /rom/TargetBD* | head -n 1")
    return output_ap.split("BD_")[1][:-6]


def log_airphone_build():
    """Logs AirPhone version to the info logger and console.
    """
    build_ap = get_airphone_build()
    logger_console_info("Build AP:  {}".format(build_ap))


def collect_airphone_snapshot(prefix=None, output_filepath=None, all_nodes=True):
    if prefix is None:
        prefix = ta5g_interface_tools().get_robot_test_name()
    if output_filepath is None:
        output_dir = ta5g_interface_tools().get_robot_output_dir()
        output_filepath = os.path.join(output_dir, "snapshot_AP", "snapshot_{}.zip".format(prefix))
    logger_console("Collecting AirPhone snapshot to: {}".format(output_filepath))
    ta5g_iphy_instance = BuiltIn().get_library_instance('ta5g_iphy')
    ta5g_iphy_instance.get_iphy_snapshot(output_filepath=output_filepath, all_nodes=all_nodes)
