"""
:copyright: Nokia Networks
:author: Jakub Pisarczyk
:maintainer: Marcin Trebunia
:contact: marcin.trebunia@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import os

from robot.libraries.BuiltIn import BuiltIn

import testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management as file_mgmt
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import reset_units
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_airphone import \
    modify_iphy_parameters
from variables import *


def change_gscn_in_iphy(gscn_value={}, reset=False):
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
        if reset:
            reset_units()


def change_numberofsubcellsul_in_iphy(subcells_ul_value={}):
    for key, value in subcells_ul_value.items():
        parameters_to_modify = {
            f'CPRI-Config/CPRI-RP1-RE_List/RE[{key}]/hardware/vcellList/vcell/NumberOfSubCellsUL': value
        }
        modify_iphy_parameters(
            params_dict=parameters_to_modify,
            logs_dir='/tmp',
            iphy_prefix='new'
        )
    logger_console('Parameter NumberOfSubCellsUL in iphy.xml modified successfully')
