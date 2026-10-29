import os
import GP_ExtendRange_mapping as gp_map
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
TL_NUM = str(tl.gnbs[0].instance_id)
ru_type = tl.gnbs[0].du.rus[0].radio_type

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

FOR_4CC_DEFAULT_NR_CELL_TYPE = [
    '2DL2UL', '2DL2UL', '2DL0UL', '2DL0UL'
]
FOR_4CC_DEFAULT_CELLBARRED = [
    'notBarred', 'notBarred', 'barred', 'barred'
]


def get_scf_parameter_list_for_cells_update(
        cell_num=4,
        list_nr_cell_type=FOR_4CC_DEFAULT_NR_CELL_TYPE,
        list_cell_barred_status=FOR_4CC_DEFAULT_CELLBARRED,
        list_gp=gp_map.B4PRACH_CONFIGURATION_4CC['guardPeriodLength'],
        list_prach=gp_map.B4PRACH_CONFIGURATION_4CC['prachConfigurationIndex'],
        list_zczc=gp_map.B4PRACH_CONFIGURATION_4CC['zeroCorrelationZoneConfig'],
        list_rangeEx=gp_map.B4PRACH_CONFIGURATION_4CC['rangeExtension'],
        list_RAPreamble=gp_map.B4PRACH_CONFIGURATION_4CC['totalNumberOfRAPreambles'],
        list_CBPreamble=gp_map.B4PRACH_CONFIGURATION_4CC['cbraPreamblesPerSsb'],
        list_root=gp_map.B4PRACH_CONFIGURATION_4CC['prachRootSequenceIndex']):
    """
    Author: wangliya
    Description: It's used for get parameter lists for update SCF file based on cell level
    :return:
    """
    list_parameters_for_cell_update = []
    if cell_num is None:
        raise Exception("You will have to set cell number first")
    else:
        for cell_index in range(11, cell_num + 1):
            MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-' + str(cell_index)
            if list_nr_cell_type is not None:
                dict_gp = dict(value=str(list_gp[cell_index - 1]),
                               dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength')
                list_parameters_for_cell_update.append(dict_gp)
            if list_nr_cell_type is not None:
                dict_nr_cell_type = dict(value=str(list_nr_cell_type[cell_index - 1]), dist_name=MR_NR_CELL_NAME,
                                         p_name='nrCellType')
                list_parameters_for_cell_update.append(dict_nr_cell_type)
            if list_cell_barred_status is not None:
                dict_cell_barred = dict(value=str(list_cell_barred_status[cell_index - 1]),
                                        dist_name=MR_NR_CELL_NAME,
                                        p_name='cellBarred')
                list_parameters_for_cell_update.append(dict_cell_barred)
            if list_prach is not None:
                dict_prach = dict(value=str(list_prach[cell_index - 1]),
                                  dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex')
                list_parameters_for_cell_update.append(dict_prach)
            if list_zczc is not None:
                dict_zczc = dict(value=str(list_zczc[cell_index - 1]),
                                 dist_name=MR_NR_CELL_NAME, p_name='zeroCorrelationZoneConfig')
                list_parameters_for_cell_update.append(dict_zczc)
            if list_rangeEx is not None:
                dict_rangeEx = dict(value=str(list_rangeEx[cell_index - 1]),
                                    dist_name=MR_NR_CELL_NAME, p_name='rangeExtension')
                list_parameters_for_cell_update.append(dict_rangeEx)
            if list_RAPreamble is not None:
                dict_RAPreamble = dict(value=str(list_RAPreamble[cell_index - 1]),
                                       dist_name=MR_NR_CELL_NAME, p_name='totalNumberOfRAPreambles')
                list_parameters_for_cell_update.append(dict_RAPreamble)
            if list_root is not None:
                dict_root = dict(value=str(list_root[cell_index - 1]),
                                 dist_name=MR_NR_CELL_NAME, p_name='prachRootSequenceIndex')
                list_parameters_for_cell_update.append(dict_root)
            if list_CBPreamble is not None:
                dict_CBPreamble = dict(value=str(list_CBPreamble[cell_index - 1]),
                                       dist_name=MR_NR_CELL_NAME, p_name='cbraPreamblesPerSsb')
                list_parameters_for_cell_update.append(dict_CBPreamble)
    return list_parameters_for_cell_update


MODIFY_SCF_FOR_4CC_BTS_PARAMETERS = [
        dict(
            value='true',
            dist_name=MR_NR_BTS_NAME,
            p_name='actCarrierAggregation'),
        dict(
            value='4CCDL_2CCUL',
            dist_name=MR_NR_BTS_NAME,
            p_name='caConfigurationSupport'),
        dict(
            value='bufferBased',
            dist_name=MR_NR_BTS_NAME,
            p_name='sCellActivationMethod'),
        dict(
            value='3',
            dist_name=MR_NR_BTS_NAME,
            p_name='maxNumScellsDl'),
        dict(
            value='1',
            dist_name=MR_NR_BTS_NAME,
            p_name='maxNumScellsUl')]

MODIFY_NIDD_VIA_API_4CC_CA = [
       dict(
           value='false',
           dist_name=MR_NR_BTS_NAME,
           parameter='actCarrierAggregation'),
       dict(
           value='none',
           dist_name=MR_NR_BTS_NAME,
           parameter='caConfigurationSupport')]

MODIFY_SCF_FOR_4CC_CELL_PARAMETERS = get_scf_parameter_list_for_cells_update()
MODIFY_DEFAULT_SCF = get_scf_parameter_list_for_cells_update() + MODIFY_SCF_FOR_4CC_BTS_PARAMETERS
