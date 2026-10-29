import os
import re
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCEL-1'


FREQ_CON_4CC_CC0_CC3 = dict(nrarfcn=[2232535, 2234199, 2235863, 2237527],
                            gscn=[23006, 23012, 23018, 23022],
                            type0coreset=[0, 1, 1, 0])


FOR_4CC_4DL_2UL_DEFAULT_NR_CELL_TYPE = [
    '2DL2UL', '2DL2UL', '2DL0UL', '2DL0UL'
]

FOR_4CC_4DL_2UL_DEFAULT_CELLBARRED = [
    'notBarred', 'barred', 'barred', 'barred',
]


def get_scf_parameter_list_for_cells_update(cell_num=4,
                                            act_beam_forming_value='true',
                                            list_nr_cell_type=FOR_4CC_4DL_2UL_DEFAULT_NR_CELL_TYPE,
                                            list_cell_barred_status=FOR_4CC_4DL_2UL_DEFAULT_CELLBARRED,
                                            list_nrarfcn=FREQ_CON_4CC_CC0_CC3['nrarfcn'],
                                            list_gscn=FREQ_CON_4CC_CC0_CC3['gscn'],
                                            list_type0coreset=FREQ_CON_4CC_CC0_CC3['type0coreset']
                                            ):
    """
    Author: Wang Yixiang
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
    if len(list_nr_cell_type) != cell_num:
        raise Exception("You will have to set config nrCellType for each cell")
    else:
        for cell_index in range(1, cell_num+1):
            MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-' + str(cell_index)
            dict_act_bf = dict(value=str(act_beam_forming_value), dist_name=MR_NR_CELL_NAME, p_name='actBeamforming')

            dict_nr_cell_type = dict(value=str(list_nr_cell_type[cell_index-1]), dist_name=MR_NR_CELL_NAME,
                                     p_name='nrCellType')
            dict_cell_barred = dict(value=str(list_cell_barred_status[cell_index-1]), dist_name=MR_NR_CELL_NAME,
                                    p_name='cellBarred')
            dict_nrarfcn = dict(value=str(list_nrarfcn[cell_index-1]), dist_name=MR_NR_CELL_NAME, p_name='nrarfcn')
            dict_gscn = dict(value=str(list_gscn[cell_index-1]), dist_name=MR_NR_CELL_NAME, p_name='gscn')
            dict_type0coreset = dict(value=str(list_type0coreset[cell_index-1]), dist_name=MR_NR_CELL_NAME,
                                     p_name='type0CoresetConfigurationIndex')
            list_parameters_for_cell_update.append(dict_act_bf)
            list_parameters_for_cell_update.append(dict_nr_cell_type)
            list_parameters_for_cell_update.append(dict_cell_barred)
            list_parameters_for_cell_update.append(dict_nrarfcn)
            list_parameters_for_cell_update.append(dict_gscn)
            list_parameters_for_cell_update.append(dict_type0coreset)
    return list_parameters_for_cell_update


SCF_4CC_DU_VAR1 = get_scf_parameter_list_for_cells_update()

SCF_4CC_DU_VAR2 = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='blind', dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actGeneralConnectivitySilver'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actGeneralConnectivityBronze'),
]

SCF_4CC_CU = [
    dict(value='4', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='0', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actCarrierAggregation'),
    dict(value='4CCDL_2CCUL', dist_name=MR_NR_BTS_NAME, p_name='caConfigurationSupport'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actGeneralConnectivitySilver'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actGeneralConnectivityBronze'),
]

MODIFY_SCF_4CC_CU = SCF_4CC_CU
MODIFY_SCF_4CC_DU = SCF_4CC_DU_VAR2
