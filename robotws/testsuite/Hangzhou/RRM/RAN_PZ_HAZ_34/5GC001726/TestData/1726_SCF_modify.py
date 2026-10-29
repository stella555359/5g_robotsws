import os
import Frequency_mapping as freq_map
from robot.libraries.BuiltIn import BuiltIn
import re

program = BuiltIn().get_variable_value('${PROGRAM}')
tl = BuiltIn().get_variable_value('${tl}')
TL_NUM = str(tl.gnbs[0].instance_id)
ru_type = tl.gnbs[0].du.rus[0].radio_type

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

if program == '21B':
    gscn_name = 'gscn'
else:
    gscn_name = 'gscnOrSsPbchArfcn'

FOR_8CC_DEFAULT_NR_CELL_TYPE = [
    '2DL2UL', '2DL2UL', '2DL0UL', '2DL0UL', '2DL0UL', '2DL0UL', '2DL0UL', '2DL0UL'
]
FOR_8CC_DEFAULT_CELLBARRED = [
    'notBarred', 'notBarred', 'barred', 'barred', 'barred', 'barred', 'barred', 'barred'
]

TL_PARAMS_TO_ADD_8CC_CA = [
    dict(value='7', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='1', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl')
]

TL_PARAMS_TO_MODIFY_8CC_CA = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='8CCDL_4CC UL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actTddPrePooling'),
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='nrCellType')
]


def get_scf_parameter_list_for_cells_update(cell_num=8,
                                            act_beam_forming_value='true',
                                            list_nr_cell_type=FOR_8CC_DEFAULT_NR_CELL_TYPE,
                                            list_cell_barred_status=FOR_8CC_DEFAULT_CELLBARRED,
                                            list_nrarfcn=freq_map.FREQ_CON_8CC_CC0_CC7['nrarfcn'],
                                            list_gscn=freq_map.FREQ_CON_8CC_CC0_CC7['gscn'],
                                            list_type0coreset=freq_map.FREQ_CON_8CC_CC0_CC7['type0coreset']
                                            ):
    """
    Author: Ding Binmei
    Description: It's used for get parameter lists for update SCF file based on cell level
    :param list_cell_barred_status:
    :param cell_num:
    :param act_beam_forming_value:
    :param list_nr_cell_type: nr_cell_type value for each
    :param list_cell_barred_status: cellBarred value for each cell, default is to use cell 1 and cell 2 for pcell
    :param list_nrarfcn: set nrarfcn for each cell, values should be from the Frequency_mapping.py
    :param list_gscn: set gscn for each cell, values should be from the Frequency_mapping.py
    :return:
    """
    list_parameters_for_cell_update = []
    ru_type = tl.gnbs[0].du.rus[0].radio_type
    if re.search(r'AE\w?B', ru_type):
        BASIC_BEAMSET = 'beamSetAbf_32A'
        LEFT_ANGLE = '60'
        RIGHT_ANGLE = '60'
        LOWER_ANGLE = '123'
        UPPER_ANGLE = '87'
        PMAX_LIST = {'1': dict(pMax=280, ssPbchBlockPower=-1), '2': dict(pMax=250, ssPbchBlockPower=-4),
                     '3': dict(pMax=233, ssPbchBlockPower=-6), '4': dict(pMax=220, ssPbchBlockPower=-7),
                     '5': dict(pMax=211, ssPbchBlockPower=-8), '6': dict(pMax=203, ssPbchBlockPower=-9),
                     '7': dict(pMax=196, ssPbchBlockPower=-9), '8': dict(pMax=190, ssPbchBlockPower=-10)}
    elif re.search(r'A\w?EUA', ru_type):
        BASIC_BEAMSET = 'beamSetFR2_8_8_8_8_1P'
        LEFT_ANGLE = '60'
        RIGHT_ANGLE = '60'
        LOWER_ANGLE = '114'
        UPPER_ANGLE = '87'
        PMAX_LIST = {'1': dict(pMax=280, ssPbchBlockPower=-1), '2': dict(pMax=250, ssPbchBlockPower=-4),
                     '3': dict(pMax=233, ssPbchBlockPower=-6), '4': dict(pMax=220, ssPbchBlockPower=-7),
                     '5': dict(pMax=211, ssPbchBlockPower=-8), '6': dict(pMax=203, ssPbchBlockPower=-9),
                     '7': dict(pMax=196, ssPbchBlockPower=-9), '8': dict(pMax=190, ssPbchBlockPower=-10)}
    elif re.search(r'AE\w?D', ru_type):
        BASIC_BEAMSET = 'beamSetFR2_6_6_4_2P'
        LEFT_ANGLE = '90'
        RIGHT_ANGLE = '90'
        LOWER_ANGLE = '127'
        UPPER_ANGLE = '87'
        PMAX_LIST = {'1': dict(pMax=250, ssPbchBlockPower=-4), '2': dict(pMax=220, ssPbchBlockPower=-7),
                     '3': dict(pMax=203, ssPbchBlockPower=-9), '4': dict(pMax=190, ssPbchBlockPower=-10),
                     '5': dict(pMax=181, ssPbchBlockPower=-11), '6': dict(pMax=173, ssPbchBlockPower=-12),
                     '7': dict(pMax=166, ssPbchBlockPower=-12), '8': dict(pMax=160, ssPbchBlockPower=-13)}
    else:
        BASIC_BEAMSET = 'beamSetAbf_32A'
        LEFT_ANGLE = '60'
        RIGHT_ANGLE = '60'
        LOWER_ANGLE = '123'
        UPPER_ANGLE = '87'
        PMAX_LIST = {'1': dict(pMax=280, ssPbchBlockPower=-1), '2': dict(pMax=250, ssPbchBlockPower=-4),
                     '3': dict(pMax=233, ssPbchBlockPower=-6), '4': dict(pMax=220, ssPbchBlockPower=-7),
                     '5': dict(pMax=211, ssPbchBlockPower=-8), '6': dict(pMax=203, ssPbchBlockPower=-9),
                     '7': dict(pMax=196, ssPbchBlockPower=-9), '8': dict(pMax=190, ssPbchBlockPower=-10)}

    if cell_num is None:
        raise Exception("You will have to set cell number first")
    else:
        for cell_index in range(1, cell_num+1):
            MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-' + str(cell_index)
            dict_act_bf = dict(value=str(act_beam_forming_value), dist_name=MR_NR_CELL_NAME, p_name='actBeamforming')
            dict_beamset = dict(value=str(BASIC_BEAMSET), dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet')
            dict_left_edge_angle = dict(value=str(LEFT_ANGLE), dist_name=MR_NR_CELL_NAME, p_name='leftEdgeAngle')
            dict_right_edge_angle = dict(value=str(RIGHT_ANGLE), dist_name=MR_NR_CELL_NAME, p_name='rightEdgeAngle')
            dict_lower_edge_angle = dict(value=str(LOWER_ANGLE), dist_name=MR_NR_CELL_NAME, p_name='lowerEdgeAngle')
            dict_upper_edge_angle = dict(value=str(UPPER_ANGLE), dist_name=MR_NR_CELL_NAME, p_name='upperEdgeAngle')
            dict_pmax = dict(value=PMAX_LIST[str(cell_num)]['pMax'], dist_name=MR_NR_CELL_NAME,
                             p_name='pMax')
            dict_sspbch = dict(value=PMAX_LIST[str(cell_num)]['ssPbchBlockPower'], dist_name=MR_NR_CELL_NAME,
                               p_name='ssPbchBlockPower')
            list_parameters_for_cell_update.append(dict_act_bf)
            list_parameters_for_cell_update.append(dict_left_edge_angle)
            list_parameters_for_cell_update.append(dict_right_edge_angle)
            list_parameters_for_cell_update.append(dict_beamset)
            list_parameters_for_cell_update.append(dict_lower_edge_angle)
            list_parameters_for_cell_update.append(dict_upper_edge_angle)
            list_parameters_for_cell_update.append(dict_pmax)
            list_parameters_for_cell_update.append(dict_sspbch)
            if list_nr_cell_type is not None:
                dict_nr_cell_type = dict(value=str(list_nr_cell_type[cell_index - 1]), dist_name=MR_NR_CELL_NAME,
                                         p_name='nrCellType')
                list_parameters_for_cell_update.append(dict_nr_cell_type)
            if list_cell_barred_status is not None:
                dict_cell_barred = dict(value=str(list_cell_barred_status[cell_index - 1]),
                                        dist_name=MR_NR_CELL_NAME,
                                        p_name='cellBarred')
                list_parameters_for_cell_update.append(dict_cell_barred)
            if list_nrarfcn is not None:
                dict_nrarfcn = dict(value=str(list_nrarfcn[cell_index-1]),
                                    dist_name=MR_NR_CELL_NAME, p_name='nrarfcn')
                list_parameters_for_cell_update.append(dict_nrarfcn)
            if list_gscn is not None:
                dict_gscn = dict(value=str(list_gscn[cell_index-1]), dist_name=MR_NR_CELL_NAME, p_name=gscn_name)
                list_parameters_for_cell_update.append(dict_gscn)
            if list_type0coreset is not None:
                dict_type0coreset = dict(value=str(list_type0coreset[cell_index - 1]), dist_name=MR_NR_CELL_NAME,
                                         p_name='type0CoresetConfigurationIndex')
                list_parameters_for_cell_update.append(dict_type0coreset)
    return list_parameters_for_cell_update


def get_scf_parameter_list_for_cells_update_for_pname_with_same_value(dict_pname_value, cell_num=8):
    """
    Author: Ding Binmei
    Description: Generation scf parameter list for cells with provided pname and value
    :param dict_pname_value: dict with format{pname1:value1, pname2:value2}
    :param cell_num:
    :return:
    """
    list_parameters_for_cell_update = []
    for cell_index in range(1, cell_num + 1):
        MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-' + str(cell_index)
        for pname in dict_pname_value.keys():
            parameter_for_update = dict(
                value=str(dict_pname_value[pname]), dist_name=MR_NR_CELL_NAME, p_name=str(pname))
            list_parameters_for_cell_update.append(parameter_for_update)
    return list_parameters_for_cell_update


MODIFY_SCF_FOR_8CC_CELL_PARAMETERS = get_scf_parameter_list_for_cells_update()

MODIFY_SCF_FOR_4CC_CELL_PARAMETERS = \
    get_scf_parameter_list_for_cells_update(cell_num=4,
                                            act_beam_forming_value='true',
                                            list_nr_cell_type=None,
                                            list_cell_barred_status=None,
                                            list_nrarfcn=None,
                                            list_gscn=None,
                                            list_type0coreset=None)

MODIFY_SCF_FOR_C2_FORMAT = [
    # 5GC001300: Frame structure enhancement: Preamble format C2 - 120 kHz
    dict(
        value='semiStatic', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='25Symbols', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='1/4', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='196', dist_name=MR_NR_BTS_NAME + '/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(
        value='semiStatic', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='25Symbols', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='1/4', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='196', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='prachConfigurationIndex'),
]
# For sub-feature GE IWK cases: 561, 562


# for 4c 4dl 2ul
FOR_4CC_4DL_2UL_DEFAULT_NR_CELL_TYPE = [
    '2DL2UL', '2DL2UL', '2DL0UL', '2DL0UL'
]

FOR_4CC_4DL_2UL_DEFAULT_CELLBARRED = [
    'notBarred', 'notBarred', 'barred', 'barred',
]

MODIFY_SCF_FOR_4CC_4DL_2UL_CELL_PARAMETERS = get_scf_parameter_list_for_cells_update(
    cell_num=4,
    act_beam_forming_value='true',
    list_nr_cell_type=FOR_4CC_4DL_2UL_DEFAULT_NR_CELL_TYPE,
    list_cell_barred_status=FOR_4CC_4DL_2UL_DEFAULT_CELLBARRED,
    list_nrarfcn=freq_map.FREQ_NON_CON_4CC_1_1_1_1['nrarfcn'],
    list_gscn=freq_map.FREQ_NON_CON_4CC_1_1_1_1['gscn'],
    list_type0coreset=freq_map.FREQ_NON_CON_4CC_1_1_1_1['type0coreset'])


MODIFY_SCF_FOR_4CC_4DL_2UL_BTS_PARAMETERS = [
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actCarrierAggregation'),
    dict(
        value='4CCDL_2CCUL',
        dist_name=MR_NR_BTS_NAME,
        p_name='caConfigurationSupport'),
    dict(
        value='blind',
        dist_name=MR_NR_BTS_NAME,
        p_name='sCellActivationMethod'),
    dict(
        value='3',
        dist_name=MR_NR_BTS_NAME,
        p_name='maxNumScellsDl'),
    dict(
        value='1',
        dist_name=MR_NR_BTS_NAME,
        p_name='maxNumScellsUl')
]


MODIFY_SCF_FOR_8CC_NON_CON_8CC_1_1_1_1_1_1_1_1 = get_scf_parameter_list_for_cells_update(
    cell_num=8,
    act_beam_forming_value='true',
    list_nr_cell_type=FOR_8CC_DEFAULT_NR_CELL_TYPE,
    list_cell_barred_status=FOR_8CC_DEFAULT_CELLBARRED,
    list_nrarfcn=freq_map.FREQ_NON_CON_8CC_1_1_1_1_1_1_1_1['nrarfcn'],
    list_gscn=freq_map.FREQ_NON_CON_8CC_1_1_1_1_1_1_1_1['gscn'],
    list_type0coreset=freq_map.FREQ_NON_CON_8CC_1_1_1_1_1_1_1_1['type0coreset']
)

MODIFY_SCF_FOR_4CC_4DL_2UL_COMMON_PARAMETERS = MODIFY_SCF_FOR_4CC_4DL_2UL_CELL_PARAMETERS + \
                                               MODIFY_SCF_FOR_4CC_4DL_2UL_BTS_PARAMETERS

if TL_NUM != '419':
    MODIFY_SCF_FOR_8CC_BTS_PARAMETERS = [
        dict(
            value='true',
            dist_name=MR_NR_BTS_NAME,
            p_name='actCarrierAggregation'),
        dict(
            value='8CCDL_4CC UL',
            dist_name=MR_NR_BTS_NAME,
            p_name='caConfigurationSupport'),
        dict(
            value='true',
            dist_name=MR_NR_BTS_NAME,
            p_name='actTddPrePooling'),
        dict(
            value='bufferBased',
            dist_name=MR_NR_BTS_NAME,
            p_name='sCellActivationMethod'),
        dict(
            value='7',
            dist_name=MR_NR_BTS_NAME,
            p_name='maxNumScellsDl'),
        dict(
            value='1',
            dist_name=MR_NR_BTS_NAME,
            p_name='maxNumScellsUl')
    ]
    MODIFY_SCF_FOR_8CC_CELL_PARAMETERS = get_scf_parameter_list_for_cells_update()
    MODIFY_SCF_COMMON = MODIFY_SCF_FOR_8CC_CELL_PARAMETERS + MODIFY_SCF_FOR_8CC_BTS_PARAMETERS
else:
    MODIFY_SCF_COMMON = [dict(
            value='7',
            dist_name=MR_NR_BTS_NAME,
            p_name='maxNumScellsDl'),
        dict(
            value='1',
            dist_name=MR_NR_BTS_NAME,
            p_name='maxNumScellsUl')]

MODIFY_SCF_8CC_IWK_1094 = MODIFY_SCF_COMMON + [
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actIntraFreqIntraGnbMobilityNSA')] + \
                          get_scf_parameter_list_for_cells_update_for_pname_with_same_value(
                              dict_pname_value=dict(a3MeasEnabled='rsrp', a5MeasEnabled='rsrp'), cell_num=8)
