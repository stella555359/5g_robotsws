"""
Author: Wang Yixiang
Description: NIDD modification parameters update list via API or webUI
"""

import os
import re
from robot.libraries.BuiltIn import BuiltIn
import logging
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter import *

tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCEL-1'
TL_NUM = str(tl.gnbs[0].instance_id)


def get_parameter_list_for_update_nrarfcn_gscn(cell_num, list_nrarfcn, list_gscn, list_type0coreset):
    """
    Author: Wang Yixiang
    Description: Provide common keyword for update nrarfcn and gscn for all cells
    :param cell_num: total cell num
    :param list_nrarfcn: should provide values for each cell
    :param list_gscn: shoule provide values for each cell
    :return: return a list of parameters with nrarfcn and gscn values for update. Format will be:
    [{'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'nrarfcn', 'value': '2232535'},PW
    {'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'gscn', 'value': '23006'}]
    """
    list_parameters_for_cell_update = []
    if len(list_nrarfcn) != cell_num or len(list_gscn) != cell_num:
        raise Exception("NRARFCN or GSCN is not set for each cell")
    else:
        for cell_index in range(1, cell_num+1):
            NR_CELL_NAME = NR_NAME + '/NRCELL-' + str(cell_index)
            dict_nrarfcn = dict(value=str(list_nrarfcn[cell_index-1]), dist_name=NR_CELL_NAME, p_name='nrarfcn')
            dict_gscn = dict(value=str(list_gscn[cell_index - 1]), dist_name=NR_CELL_NAME,
                             p_name='gscnOrSsPbchArfcn')
            dict_type0coreset = dict(value=str(list_type0coreset[cell_index - 1]), dist_name=NR_CELL_NAME,
                                     p_name='type0CoresetConfigurationIndex')
            list_parameters_for_cell_update.append(dict_nrarfcn)
            list_parameters_for_cell_update.append(dict_gscn)
            list_parameters_for_cell_update.append(dict_type0coreset)
    return list_parameters_for_cell_update


MODIFY_4CC_VIA_API_NON_CONTINOUS = get_parameter_list_for_update_nrarfcn_gscn(
    cell_num=4,
    list_nrarfcn=['2264859', '2263195', '2261531', '2259631'],
    list_gscn=['23118', '23112', '23106', '23100'],
    list_type0coreset=['0', '0', '0', '0'])

MODIFY_8CC_VIA_API_NON_CONTINOUS = get_parameter_list_for_update_nrarfcn_gscn(
    cell_num=8,
    list_nrarfcn=['2249947', '2251675', '2253403', '2255131', '2256859', '2258587', '2260315', '2262043'],
    list_gscn=['23066', '23072', '23078', '23084', '23090', '23096', '23102', '23108'],
    list_type0coreset=['0', '0', '0', '0', '0', '0', '0', '0'])

ABIL_UL2CC_DL4CC_DEL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-8'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1/CHANNEL-2'),

    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4')
]

ABIL_UL2CC_DEL = [
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4')
]

ABIL_8CC_DEL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-8')]

ABIO_0CC_DEL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-11'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-12'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-13'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-14'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-12/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-13/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-14/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', index='-1')]

ABIL_0CC_DEL = [
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-3'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-4'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-8'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-3'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1/CHANNEL-4'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1/CHANNEL-1'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8/CHANNELGROUP-1/CHANNEL-2'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRDU-1', list_name='refNrCellGroup', index='0')]

ABIL_UL2CC_MODIFY = [
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME + '/NRCELL-3', p_name='nrCellType'),
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME + '/NRCELL-4', p_name='nrCellType')
]

ABIL_4CC_ABIO_0CC_DEL = ABIL_UL2CC_DL4CC_DEL + ABIO_0CC_DEL
ABIL_8CC_ABIO_0CC_DEL = ABIO_0CC_DEL + ABIL_UL2CC_DEL
ABIO_4CC_ABIL_0CC_DEL = ABIL_8CC_DEL + ABIL_0CC_DEL
ABIL_DL8CC_UL2CC_DEL = ABIL_UL2CC_DEL + ABIO_0CC_DEL
