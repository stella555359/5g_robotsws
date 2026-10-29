from robot.libraries.BuiltIn import BuiltIn
import os
import re
import GP_ExtendRange_mapping as gp_map
from robot.libraries.BuiltIn import BuiltIn
import logging
tl = BuiltIn().get_variable_value('${tl}')
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME_11 = NR_NAME + '/NRCELL-'
NR_CELL_NAME = NR_NAME + '/NRCELL-11'
NR_CELL_NAME2 = NR_NAME + '/NRCELL-12'
NR_CELL_NAME3 = NR_NAME + '/NRCELL-13'
NR_CELL_NAME4 = NR_NAME + '/NRCELL-14'
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCELL-1'
DIST_RLRESUMEBACKOFFTMR = NR_CELL_NAME


def get_parameter_list_for_update_via_rest_api(cell_num, list_configuration, list_zczc, list_rangeEx, list_RAPreamble,
                                               list_gp, list_root, list_CBPreamble):
    """
    Author: wang liya
    Description: Provide common keyword for update parameter for all cells
    """
    list_parameters_for_cell_update = []
    if len(list_configuration) != cell_num:
        raise Exception("GP length or B4 configuration or ZCZC or range extend  is not set for each cell")
    else:
        for cell_index in range(11, cell_num + 1):
            NR_CELL_NAME = NR_NAME + '/NRCELL-' + str(cell_index)
            dict_gp = dict(value=str(list_gp[cell_index - 1]), dist_name=NR_CELL_NAME, parameter='guardPeriodLength')
            dict_configuration = dict(value=str(list_configuration[cell_index - 1]),
                                      dist_name=NR_CELL_NAME,
                                      parameter='prachConfigurationIndex')
            dict_zczc = dict(value=str(list_zczc[cell_index - 1]),
                             dist_name=NR_CELL_NAME,
                             parameter='zeroCorrelationZoneConfig')
            dict_rangeEx = dict(value=str(list_rangeEx[cell_index - 1]),
                                dist_name=NR_CELL_NAME,
                                parameter='rangeExtension')
            dict_RAPreamble = dict(value=str(list_RAPreamble[cell_index - 1]),
                                   dist_name=NR_CELL_NAME,
                                   parameter='totalNumberOfRAPreambles')
            dict_root = dict(value=str(list_root[cell_index - 1]),
                             dict_name=NR_CELL_NAME,
                             parameter='prachRootSequenceIndex')
            dict_CBPreamble = dict(value=str(list_CBPreamble[cell_index - 1]),
                                   dict_name=NR_CELL_NAME,
                                   parameter='cbraPreamblesPerSsb')
            list_parameters_for_cell_update.append(dict_gp)
            list_parameters_for_cell_update.append(dict_configuration)
            list_parameters_for_cell_update.append(dict_rangeEx)
            list_parameters_for_cell_update.append(dict_RAPreamble)
            list_parameters_for_cell_update.append(dict_zczc)
            list_parameters_for_cell_update.append(dict_root)
            list_parameters_for_cell_update.append(dict_CBPreamble)
    return list_parameters_for_cell_update


MODIFY_B4PRACH_CONFIGURATION = get_parameter_list_for_update_via_rest_api(
    cell_num=4, list_gp=gp_map.B4PRACH_CONFIGURATION_4CC['guardPeriodLength'],
    list_configuration=gp_map.B4PRACH_CONFIGURATION_4CC['prachConfigurationIndex'],
    list_zczc=gp_map.B4PRACH_CONFIGURATION_4CC['zeroCorrelationZoneConfig'],
    list_rangeEx=gp_map.B4PRACH_CONFIGURATION_4CC['rangeExtension'],
    list_root=gp_map.B4PRACH_CONFIGURATION_4CC['prachRootSequenceIndex'],
    list_RAPreamble=gp_map.B4PRACH_CONFIGURATION_4CC['totalNumberOfRAPreambles'],
    list_CBPreamble=gp_map.B4PRACH_CONFIGURATION_4CC['cbraPreamblesPerSsb'])
