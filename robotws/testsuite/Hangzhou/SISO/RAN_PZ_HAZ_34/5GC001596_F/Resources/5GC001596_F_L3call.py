from robot.libraries.BuiltIn import BuiltIn
import os
import re
from robot.libraries.BuiltIn import BuiltIn
import logging
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCELL-1'
DIST_RLRESUMEBACKOFFTMR = NR_CELL_NAME


def get_parameter_list_for_update_via_rest_api(cell_num, list_configuration, list_zczc, list_rangeEx):
    """
    Author: wang liya
    Description: Provide common keyword for update parameter for all cells
    """
    list_parameters_for_cell_update = []
    if len(list_configuration) != cell_num:
        raise Exception("check prach and zczc and rangeExtension value")
    else:
        for cell_index in range(1, cell_num + 1):
            NR_CELL_NAME = NR_NAME + '/NRCELL-' + str(cell_index)
            dict_configuration = dict(value=str(list_configuration[cell_index - 1]),
                                      dist_name=NR_CELL_NAME,
                                      parameter='prachConfigurationIndex')
            dict_zczc = dict(value=str(list_zczc[cell_index - 1]),
                             dist_name=NR_CELL_NAME,
                             parameter='zeroCorrelationZoneConfig')
            dict_rangeEx = dict(value=str(list_rangeEx[cell_index - 1]),
                                dist_name=NR_CELL_NAME,
                                parameter='rangeExtension')
            list_parameters_for_cell_update.append(dict_configuration)
            list_parameters_for_cell_update.append(dict_rangeEx)
            list_parameters_for_cell_update.append(dict_zczc)
    return list_parameters_for_cell_update


MODIFY_PARAMETER_8CC = \
    dict(
         rangeExtension=['0-2.3km', '0-2.3km', '0-2.3km', '0-2.3km', '0-2.3km', '0-2.3km', '0-2.3km', '0-2.3km'],
         prachConfigurationIndex=[182, 182, 182, 182, 182, 182, 182, 182],
         zeroCorrelationZoneConfig=[0, 0, 0, 0, 0, 0, 0, 0])


MODIFY_CB007462_CONFIGURATION = get_parameter_list_for_update_via_rest_api(
    cell_num=8, list_rangeEx=MODIFY_PARAMETER_8CC['rangeExtension'],
    list_configuration=MODIFY_PARAMETER_8CC['prachConfigurationIndex'],
    list_zczc=MODIFY_PARAMETER_8CC['zeroCorrelationZoneConfig'])
