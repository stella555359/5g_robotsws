"""
Author: Ding Binmei
Description: NIDD modification parameters update list via API or webUI
"""

import os
import re
import Frequency_mapping as freq_map
from robot.libraries.BuiltIn import BuiltIn
import logging

program = BuiltIn().get_variable_value('${PROGRAM}')
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCEL-1'
TL_NUM = str(tl.gnbs[0].instance_id)

if program == '21B':
    gscn_name = 'gscn'
else:
    gscn_name = 'gscnOrSsPbchArfcn'


def get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(cell_num, list_nrarfcn, list_gscn, list_type0coreset):
    """
    Author: Ding Binmei
    Description: Provide common keyword for update nrarfcn and gscn for all cells
    :param cell_num: total cell num
    :param list_nrarfcn: should provide values for each cell
    :param list_gscn: shoule provide values for each cell
    :return: return a list of parameters with nrarfcn and gscn values for update. Format will be:
    [{'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'nrarfcn', 'value': '2232535'},
    {'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'gscn', 'value': '23006'}]
    """
    list_parameters_for_cell_update = []
    if len(list_nrarfcn) != cell_num or len(list_gscn) != cell_num:
        raise Exception("NRARFCN or GSCN is not set for each cell")
    else:
        for cell_index in range(1, cell_num+1):
            NR_CELL_NAME = NR_NAME + '/NRCELL-' + str(cell_index)
            dict_nrarfcn = dict(value=str(list_nrarfcn[cell_index-1]), dist_name=NR_CELL_NAME, parameter='nrarfcn')
            dict_gscn = dict(value=str(list_gscn[cell_index - 1]), dist_name=NR_CELL_NAME, parameter=gscn_name)
            dict_type0coreset = dict(value=str(list_type0coreset[cell_index - 1]), dist_name=NR_CELL_NAME,
                                     parameter='type0CoresetConfigurationIndex')
            list_parameters_for_cell_update.append(dict_nrarfcn)
            list_parameters_for_cell_update.append(dict_gscn)
            list_parameters_for_cell_update.append(dict_type0coreset)
    return list_parameters_for_cell_update


def get_parameter_list_for_ecpri_analog_beamforming_via_rest_api(cell_num):
    """
    Author: Wang Yixiang
    Description: Provide common keyword for IWK 5GC000918 ecpri analog beamforming
    :param cell_num:
    """
    list_parameters_for_cell_update = []
    ru_type = tl.gnbs[0].du.rus[0].radio_type
    if re.search(r'AE\w?D', ru_type):
        basicBeamSet = 'beamSetFR2_6_6_4_2P'
        leftEdgeAngle = '90'
        rightEdgeAngle = '90'
        lowerEdgeAngle = '127'
        upperEdgeAngle = '87'
    elif re.search(r'AE\w?B', ru_type):
        basicBeamSet = 'beamSetFR2_8_8_8_8_1P'
        leftEdgeAngle = '60'
        rightEdgeAngle = '60'
        lowerEdgeAngle = '114'
        upperEdgeAngle = '87'
    elif re.search(r'A\w?EUA', ru_type):
        basicBeamSet = 'beamSetFR2_16_8_8_1P'
        leftEdgeAngle = '45'
        rightEdgeAngle = '45'
        lowerEdgeAngle = '110'
        upperEdgeAngle = '90'
    else:
        raise Exception("Not expected RU type, should be AExD or AExB")

    for cell_index in range(1, cell_num+1):
        NR_CELL_NAME = NR_NAME + '/NRCELL-' + str(cell_index)
        NR_CELL_GROUP_NAME = NR_NAME + '/NRCELLGRP-0'
        dict_basicBeamSet = dict(value=basicBeamSet, dist_name=NR_CELL_NAME, parameter='basicBeamSet')
        dict_leftEdgeAngle = dict(value=leftEdgeAngle, dist_name=NR_CELL_NAME, parameter='leftEdgeAngle')
        dict_rightEdgeAngle = dict(value=rightEdgeAngle, dist_name=NR_CELL_NAME, parameter='rightEdgeAngle')
        dict_lowerEdgeAngle = dict(value=lowerEdgeAngle, dist_name=NR_CELL_NAME, parameter='lowerEdgeAngle')
        dict_upperEdgeAngle = dict(value=upperEdgeAngle, dist_name=NR_CELL_NAME, parameter='upperEdgeAngle')
        dict_numberOfTransmittedSsBlocks = dict(value='32 beams', dist_name=NR_CELL_GROUP_NAME,
                                                parameter='numberOfTransmittedSsBlocks')
        dict_ssBurstSetPeriod = dict(value='20ms', dist_name=NR_CELL_GROUP_NAME,
                                     parameter='ssBurstSetPeriod')
        list_parameters_for_cell_update.append(dict_basicBeamSet)
        list_parameters_for_cell_update.append(dict_leftEdgeAngle)
        list_parameters_for_cell_update.append(dict_rightEdgeAngle)
        list_parameters_for_cell_update.append(dict_lowerEdgeAngle)
        list_parameters_for_cell_update.append(dict_upperEdgeAngle)
        list_parameters_for_cell_update.append(dict_numberOfTransmittedSsBlocks)
        list_parameters_for_cell_update.append(dict_ssBurstSetPeriod)

    return list_parameters_for_cell_update


MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
    cell_num=8, list_nrarfcn=freq_map.FREQ_CON_8CC_CC0_CC7['nrarfcn'],
    list_gscn=freq_map.FREQ_CON_8CC_CC0_CC7['gscn'],
    list_type0coreset=freq_map.FREQ_CON_8CC_CC0_CC7['type0coreset'])

MODIFY_eCPRIAnalogBeamforming_VIA_API = get_parameter_list_for_ecpri_analog_beamforming_via_rest_api(
    cell_num=8)

MODIFY_maxNumScellsDL_4_VIA_API = [
    dict(value='4', dist_name=NR_NAME, parameter='maxNumScellsDl')
]
#
MODIFY_maxNumScellsDL_5_VIA_API = [
    dict(value='5', dist_name=NR_NAME, parameter='maxNumScellsDl')
]
#
MODIFY_maxNumScellsDL_6_VIA_API = [
    dict(value='6', dist_name=NR_NAME, parameter='maxNumScellsDl')
]

MODIFY_maxNumScellsDL_7_VIA_API = [
    dict(value='7', dist_name=NR_NAME, parameter='maxNumScellsDl')
]
#
MODIFY_maxNumScellsDL_1_VIA_API = [
    dict(value='1', dist_name=NR_NAME, parameter='maxNumScellsDl')
]

MODIFY_maxNumScellsUl_0_VIA_API = [
    dict(value='0', dist_name=NR_NAME, parameter='maxNumScellsUl')
]

MODIFY_maxNumScellsUl_1_VIA_API = [
    dict(value='1', dist_name=NR_NAME, parameter='maxNumScellsUl')
]

MODIFY_SCF_GNB_ENABLE_MUL_DRB = [
    dict(value='true', dist_name=NR_NAME, parameter='actMultiDrbNSA'),
    dict(value='true', dist_name=NR_NAME, list_name='qciTab9Nsa3x', parameter='nsa3xBearerAllowed')
]

MODIFY_ENB_VIA_API_ENABLE_MUL_DRB = [
    dict(value='true', dist_name=LTE_NAME, parameter='actMultBearers'),
    dict(value='true', dist_name=LTE_NAME, parameter='actMultiSCGSplit')
]

MODIFY_VIA_API_DISABLE_CA = [
    dict(value='false', dist_name=NR_NAME, parameter='actCarrierAggregation')
]

MODIFY_VIA_API_ENABLE_CA = [
    dict(value='true', dist_name=NR_NAME, parameter='actCarrierAggregation')
]

MODIFY_VIA_API_ENABLE_SRB3 = [
    dict(value='true', dist_name=NR_NAME, parameter='srb3SupportEnabled')
]

MODIFY_VIA_API_ENABLE_A2_MEAS = [
    dict(value='true', dist_name=NR_NAME, parameter='actA2SgnbRelease')
]

MODIFY_caConfigurationSupport_4DL2UL_VIA_API = [
    dict(value='4CCDL_2CCUL', dist_name=NR_NAME, parameter='caConfigurationSupport')
]

MODIFY_caConfigurationSupport_2DL2UL_VIA_API = [
    dict(value='2CCDL_2CCUL', dist_name=NR_NAME, parameter='caConfigurationSupport')
]

MODIFY_VIA_API_COUNTER = [
    dict(value='5min', dist_name=NR_NAME + '/NRPMRNL-1', parameter='miNrCaCu'),
    dict(value='5min', dist_name=NR_NAME + '/NRPMRNL-1', parameter='miNrCaDu'),
    dict(value='5min', dist_name='MNL-1/MNLENT-1/PMCADM-1', parameter='reportingIntervalPm')
]


def get_parameter_list_for_drx_config_via_rest_api(cell_num=8):
    """
    Author: Ren Biyao
    Description: this keyword is to modify the drx for each scell. eg, The return value will be like,

            [{b'dist_name': b'NRBTS-1/NRCELL-1', b'parameter': b'actCDrx', b'value': b'true'},
             {b'dist_name': b'NRBTS-1/NRCELL-1', b'parameter': b'drxProfile1', b'value': [{b'drxInactivityTimer':
             b'4ms', b'drxLongCycle': b'40ms', b'drxOnDurationTimer': b'10ms', b'drxRetransTimerDl': b'8slot',
             b'drxRetransTimerUl': b'8slot'}]},
             {b'dist_name': b'NRBTS-1/NRCELL-2', b'parameter': b'actCDrx', b'value': b'true'},
             {b'dist_name': b'NRBTS-1/NRCELL-2', b'parameter': b'drxProfile1', b'value': [{b'drxInactivityTimer':
             b'4ms', b'drxLongCycle': b'40ms', b'drxOnDurationTimer': b'10ms', b'drxRetransTimerDl': b'8slot',
             b'drxRetransTimerUl': b'8slot'}]}]
    :param cell_num: is total number of scells
    """
    list_parameters_for_cell_update = []
    for cell_index in range(1, cell_num+1):
        NR_CELL_NAME = NR_NAME + '/NRCELL-' + str(cell_index)
        dict_actCDrx = dict(value='true', dist_name=NR_CELL_NAME, parameter='actCDrx')
        dict_drxProfile1 = dict(value=[dict(drxInactivityTimer='8ms',
                                            drxOnDurationTimer='10ms',
                                            drxRetransTimerDl='24slot',
                                            drxRetransTimerUl='24slot',
                                            drxLongCycle='40ms')],
                                dist_name=NR_CELL_NAME, parameter='drxProfile1')
        list_parameters_for_cell_update.append(dict_actCDrx)
        list_parameters_for_cell_update.append(dict_drxProfile1)
    return list_parameters_for_cell_update


MODIFY_VIA_API_ENABLE_DRX = get_parameter_list_for_drx_config_via_rest_api()

# The drx configuration which is need to check in x2ap
DRX_CONFIG = list(dict(MODIFY_VIA_API_ENABLE_DRX[1])['value'])[0]


def get_parameter_list_for_disable_drx_config_via_rest_api(cell_num=8):
    """
        Author: Ren Biyao
        Description: this keyword is to disable drx for each cell.
        :param cell_num: is total number of scells
    """
    list_parameters_for_cell_update = []
    for cell_index in range(1, cell_num+1):
        NR_CELL_NAME = NR_NAME + '/NRCELL-' + str(cell_index)
        dict_actCDrx = dict(value='false', dist_name=NR_CELL_NAME, parameter='actCDrx')
        list_parameters_for_cell_update.append(dict_actCDrx)
    return list_parameters_for_cell_update


DISABLE_DRX = get_parameter_list_for_disable_drx_config_via_rest_api()

MODIFY_VIA_API_FOR_BLIND_METHOD_SCELL = [dict(value='blind', dist_name=NR_NAME, parameter='sCellActivationMethod')]

MODIFY_VIA_API_FOR_BUFFERBASED_METHOD_SCELL = \
    [dict(value='bufferBased', dist_name=NR_NAME, parameter='sCellActivationMethod')]

PARA_TO_MODIFY_VIA_API_GF_623 = \
    MODIFY_VIA_API_FOR_BLIND_METHOD_SCELL + MODIFY_maxNumScellsDL_5_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API

MODIFY_VIA_API_FOR_DEFAULT_8CC_BTS_PARAMETERS = [
    dict(value='true', dist_name=NR_NAME, parameter='actCarrierAggregation'),
    dict(value='8CCDL_4CC UL', dist_name=NR_NAME, parameter='caConfigurationSupport'),
    dict(value='true', dist_name=NR_NAME, parameter='actTddPrePooling'),
    dict(value='false', dist_name=NR_NAME, parameter='srb3SupportEnabled'),
    dict(value='false', dist_name=NR_NAME, parameter='actA2SgnbRelease'),
    dict(value='7', dist_name=NR_NAME, parameter='maxNumScellsDl'),
    dict(value='1', dist_name=NR_NAME, parameter='maxNumScellsUl')] + \
                                                DISABLE_DRX + MODIFY_VIA_API_FOR_BUFFERBASED_METHOD_SCELL

if TL_NUM != '419':
    # for tl419, the ue is ROW, only support the 2cc ul + 4cc dl and 2cc ul +
    # 8cc dl
    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_3_3 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=8, list_nrarfcn=freq_map.FREQ_NON_CON_8CC_1_1_3_3['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_8CC_1_1_3_3['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_8CC_1_1_3_3['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_1_1_2_2 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=8, list_nrarfcn=freq_map.FREQ_NON_CON_8CC_1_1_1_1_2_2['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_8CC_1_1_1_1_2_2['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_8CC_1_1_1_1_2_2['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_8CC_1_1_1_1_1_1_1_1 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=8, list_nrarfcn=freq_map.FREQ_NON_CON_8CC_1_1_1_1_1_1_1_1['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_8CC_1_1_1_1_1_1_1_1['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_8CC_1_1_1_1_1_1_1_1['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_2_2_2_2 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=8, list_nrarfcn=freq_map.FREQ_NON_CON_8CC_2_2_2_2['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_8CC_2_2_2_2['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_8CC_2_2_2_2['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_5CC_1_2_2 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=5, list_nrarfcn=freq_map.FREQ_NON_CON_5CC_1_2_2['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_5CC_1_2_2['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_5CC_1_2_2['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_6CC_3_3 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=6, list_nrarfcn=freq_map.FREQ_NON_CON_6CC_3_3['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_6CC_3_3['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_6CC_3_3['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_7CC_1_1_1_2_2 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=7, list_nrarfcn=freq_map.FREQ_NON_CON_7CC_1_1_1_2_2['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_7CC_1_1_1_2_2['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_7CC_1_1_1_2_2['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API_CON_5CC = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=5, list_nrarfcn=freq_map.FREQ_CON_5CC['nrarfcn'],
        list_gscn=freq_map.FREQ_CON_5CC['gscn'],
        list_type0coreset=freq_map.FREQ_CON_5CC['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API_CON_6CC = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=6, list_nrarfcn=freq_map.FREQ_CON_6CC['nrarfcn'],
        list_gscn=freq_map.FREQ_CON_6CC['gscn'],
        list_type0coreset=freq_map.FREQ_CON_6CC['type0coreset'])

    MODIFY_NRARFCN_GSCN_VIA_API_CON_7CC = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=7, list_nrarfcn=freq_map.FREQ_CON_7CC['nrarfcn'],
        list_gscn=freq_map.FREQ_CON_7CC['gscn'],
        list_type0coreset=freq_map.FREQ_CON_7CC['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC7_CC14 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=8, list_nrarfcn=freq_map.FREQ_CON_8CC_CC7_CC14['nrarfcn'],
        list_gscn=freq_map.FREQ_CON_8CC_CC7_CC14['gscn'],
        list_type0coreset=freq_map.FREQ_CON_8CC_CC7_CC14['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_5CC_1_1_3 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=5, list_nrarfcn=freq_map.FREQ_NON_CON_5CC_1_1_3['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_5CC_1_1_3['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_5CC_1_1_3['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_6CC_2_2_2 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=6, list_nrarfcn=freq_map.FREQ_NON_CON_6CC_2_2_2['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_6CC_2_2_2['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_6CC_2_2_2['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_7CC_1_3_3 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=7, list_nrarfcn=freq_map.FREQ_NON_CON_7CC_1_3_3['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_7CC_1_3_3['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_7CC_1_3_3['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC14_CC21 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=8, list_nrarfcn=freq_map.FREQ_CON_8CC_CC14_CC21['nrarfcn'],
        list_gscn=freq_map.FREQ_CON_8CC_CC14_CC21['gscn'],
        list_type0coreset=freq_map.FREQ_CON_8CC_CC14_CC21['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_5CC_1_1_1_1_1 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=5, list_nrarfcn=freq_map.FREQ_NON_CON_5CC_1_1_1_1_1['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_5CC_1_1_1_1_1['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_5CC_1_1_1_1_1['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_5CC_1_1_1_2 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=5, list_nrarfcn=freq_map.FREQ_NON_CON_5CC_1_1_1_2['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_5CC_1_1_1_2['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_5CC_1_1_1_2['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_2_2_2_2 = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=8, list_nrarfcn=freq_map.FREQ_NON_CON_8CC_2_2_2_2['nrarfcn'],
        list_gscn=freq_map.FREQ_NON_CON_8CC_2_2_2_2['gscn'],
        list_type0coreset=freq_map.FREQ_NON_CON_8CC_2_2_2_2['type0coreset'])
    #
    MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_5CC = get_parameter_list_for_update_nrarfcn_gscn_via_rest_api(
        cell_num=5, list_nrarfcn=freq_map.FREQ_CON_5CC['nrarfcn'],
        list_gscn=freq_map.FREQ_CON_5CC['gscn'],
        list_type0coreset=freq_map.FREQ_CON_5CC['type0coreset'])

    MODIFY_VIA_API_NON_CON_8CC_1_1_3_3_8DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_3_3 + \
        MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API

    MODIFY_VIA_API_NON_CON_8CC_1_1_3_3_8DL_1UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_3_3 + \
        MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API
    MODIFY_VIA_API_NON_CON_8CC_1_1_1_1_2_2_8DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_1_1_2_2 + \
        MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_NON_CON_8CC_1_1_1_1_1_1_1_1_6DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_8CC_1_1_1_1_1_1_1_1 + \
        MODIFY_maxNumScellsDL_5_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_CON_8CC_CC0_CC7_7DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7 + \
        MODIFY_maxNumScellsDL_6_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API__NON_CON_8CC_1_1_1_1_1_1_1_1_8DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_8CC_1_1_1_1_1_1_1_1 + \
        MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_CON_8CC_CC0_CC7_5DL_1UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7 + \
        MODIFY_maxNumScellsDL_4_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API
    MODIFY_VIA_API_CON_8CC_CC0_CC7_6DL_1UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7 + \
        MODIFY_maxNumScellsDL_5_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API
    MODIFY_VIA_API_CON_8CC_CC0_CC7_6DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7 + \
        MODIFY_maxNumScellsDL_5_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_NON_CON_1_1_3_5DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_5CC_1_1_3 + \
        MODIFY_maxNumScellsDL_4_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_NON_CON_2_2_2_6DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_6CC_2_2_2 + \
        MODIFY_maxNumScellsDL_5_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_CON_8CC_CC0_CC7_7DL_1UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7 + \
        MODIFY_maxNumScellsDL_6_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API
    MODIFY_VIA_API_NON_CON_1_3_3_7DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_7CC_1_3_3 + \
        MODIFY_maxNumScellsDL_6_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_CON_8CC_C14_CC21_8DL_1UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC14_CC21 + \
        MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API
    MODIFY_VIA_API_CON_8CC_CC0_CC7_8DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7 + \
        MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_CON_7CC_7DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_7CC + \
        MODIFY_maxNumScellsDL_6_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_NON_CON_8CC_2_2_2_2_8DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_2_2_2_2 + \
        MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_CON_5CC_5DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_CON_5CC + \
        MODIFY_maxNumScellsDL_4_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_NON_CON_5CC_1_1_1_2_5DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_5CC_1_1_1_2 + \
        MODIFY_maxNumScellsDL_4_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API
    MODIFY_VIA_API_NON_CON_5CC_1_1_1_1_1_5DL_1UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_5CC_1_1_1_1_1 + \
        MODIFY_maxNumScellsDL_4_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API
    MODIFY_VIA_API_NON_CON_1_1_1_1_1_5DL_2UL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_5CC_1_1_1_1_1 + \
        MODIFY_maxNumScellsDL_4_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API

    MODIFY_5CCDL_1CCUL_MUL_DRB_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_5CC_1_2_2 \
        + MODIFY_maxNumScellsDL_4_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB
    MODIFY_6CCDL_2CCUL_MUL_DRB_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API_CON_6CC \
        + MODIFY_maxNumScellsDL_5_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB
    MODIFY_7CCDL_1CCUL_MUL_DRB_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_7CC_1_1_1_2_2 \
        + MODIFY_maxNumScellsDL_6_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB
    MODIFY_7CCDL_2CCUL_MUL_DRB_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API_CON_7CC \
        + MODIFY_maxNumScellsDL_6_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB
    MODIFY_8CCDL_1CCUL_MUL_DRB_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_3_3 \
        + MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB
    MODIFY_8CCDL_2CCUL_NON_CON_MUL_DRB_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_3_3 \
        + MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB
    MODIFY_8CCDL_2CCUL_CON_MUL_DRB_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC7_CC14 \
        + MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB
    MODIFY_8CCDL_2CCUL_CON_MUL_DRB_IWK5GC000918_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7 \
        + MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB + MODIFY_eCPRIAnalogBeamforming_VIA_API
    MODIFY_8CCDL_2CCUL_NON_CON_MUL_DRB_IWK5GC000918_VIA_API_ALL = MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_3_3 \
        + MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_1_VIA_API \
        + MODIFY_SCF_GNB_ENABLE_MUL_DRB + MODIFY_eCPRIAnalogBeamforming_VIA_API
    MODIFY_VIA_API__NON_CON_8CC_1_1_1_2_2_ACTIVE_7 = MODIFY_maxNumScellsDL_7_VIA_API + \
        MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_7CC_1_1_1_2_2

    # para for cases
    PARA_TO_MODIFY_VIA_API_GA_142 = \
        MODIFY_VIA_API_ENABLE_DRX + MODIFY_VIA_API_ENABLE_SRB3 \
        + MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_8CC_1_1_1_1_1_1_1_1
    TC142_EXPECT_UL_SCELL_NUM = 0
    PARA_TO_MODIFY_VIA_API_GA_129 = \
        MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_1_1_2_2 \
        + MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API
    PARA_TO_MODIFY_VIA_API_GF_608 = MODIFY_VIA_API_CON_8CC_CC0_CC7_8DL_2UL

else:
    # para for cases
    PARA_TO_MODIFY_VIA_API_GA_142 = MODIFY_VIA_API_ENABLE_DRX + MODIFY_VIA_API_ENABLE_SRB3
    TC142_EXPECT_UL_SCELL_NUM = 1
    PARA_TO_MODIFY_VIA_API_GA_129 = \
        MODIFY_maxNumScellsDL_7_VIA_API + MODIFY_maxNumScellsUl_0_VIA_API
    PARA_TO_MODIFY_VIA_API_GF_608 = MODIFY_VIA_API_FOR_DEFAULT_8CC_BTS_PARAMETERS
