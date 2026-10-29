"""
:copyright: Nokia Networks
:author: Damian Piasecki, Damian Żak
:maintainer: Damian Piasecki, Damian Żak
:contact: damian.piasecki@nokia.com, damian.zak@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import os
import xml.etree.ElementTree as Et
from robot.libraries.BuiltIn import BuiltIn

import testsuite.Paris.RRM.ET.resources_KRK.python.file_management as file_mgmt
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import run_on_ap
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console
from testsuite.Paris.RRM.ET.resources_KRK.python.common_airphone import modify_iphy_parameters
from variables import *


def _move_second_cell(root):
    ru_list = root.findall('CPRI-Config/CPRI-RP1-RE_List/RE')
    second_cell = ru_list[1].find('hardware/vcellList/vcell')
    first_cell_list = ru_list[0].find('hardware/vcellList')
    first_cell_list.insert(1, second_cell)


def _remove_second_ru(root):
    cpri_list = root.findall('CPRI-Config/CPRI-RP1-RE_List')[0]
    ru = cpri_list.findall('RE')
    cpri_list.remove(ru[1])


def modify_iphy_to_single_ru_configuration(logs_dir='/tmp', iphy_prefix='new'):
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if '_B_' in test_name:
        file_mgmt.copy_files_from_ap(files=['/rom/simmode/iphy.xml'], local_path=logs_dir)
        new_iphy_filepath = os.path.join(logs_dir, f'{iphy_prefix}_iphy.xml')
        file_mgmt.change_file_name(os.path.join(logs_dir, 'iphy.xml'), new_iphy_filepath)
        tree = Et.parse(new_iphy_filepath)
        root = tree.getroot()
        _move_second_cell(root)
        _remove_second_ru(root)
        tree.write(new_iphy_filepath)
        file_mgmt.upload_files_to_ap(files=[new_iphy_filepath], remote_path='/rom/simmode')
        run_on_ap('cd /rom/simmode; ln -fs {}_iphy.xml iphy.xml'.format(iphy_prefix))


def upload_default_iphy_file():
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if '_B_' in test_name or '_C_' in test_name:
        file_mgmt.upload_files_to_ap(files=[f'{OUTPUT_DIR}/{SUITE_NAME}/{test_name}/default_iphy.xml'],
                                     remote_path='/rom/simmode')
        run_on_ap('cd /rom/simmode; ln -fs default_iphy.xml iphy.xml')


def change_gscn_in_iphy(gscn_value={3: 1559, 4: 1595}):
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    logs_dir = f'{OUTPUT_DIR}/{SUITE_NAME}/{test_name}'
    if gscn_value:
        file_mgmt.copy_files_from_ap(files=['/rom/simmode/iphy.xml'],
                                     local_path=logs_dir)
        file_mgmt.change_file_name(os.path.join(logs_dir, 'iphy.xml'), os.path.join(logs_dir, 'default_iphy.xml'))
        for key, value in gscn_value.items():
            parameters_to_modify = {
                f'CPRI-Config/CPRI-RP1-RE_List/RE[{key}]/hardware/vcellList/vcell/GSCN': value
            }
            modify_iphy_parameters(
                params_dict=parameters_to_modify,
                logs_dir='/tmp',
                iphy_prefix='new'
            )
        logger_console('IPHY file modified successfully')
