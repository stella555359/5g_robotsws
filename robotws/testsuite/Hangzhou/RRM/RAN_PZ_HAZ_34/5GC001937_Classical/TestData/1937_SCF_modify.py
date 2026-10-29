from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.lib.NIDD_modify_merge_scf import *
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

PARAMS_TO_DELETE_1937_4CCDL_1CCUL = [
    dict(
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2'
         ),
    dict(
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4',
         ),
]

PARAMS_TO_MODIFY_1937_4CCDL_1CCUL = [
    dict(value='2DL0UL', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='nrCellType'),
    dict(value='barred', dist_name=MR_NR_BTS_NAME + '/NRCELL-2', p_name='cellBarred'),
]

TL_PARAMS_TO_DELETE_1Cell = [
    # NRCELL
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-8'),
    # cellmapping
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8'),
    # nrcell group
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1')
]

TL_PARAMS_TO_DELETE_2Cell = TL_PARAMS_TO_DELETE_1Cell + [
    # NRCELL
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-7'),
    # cellmapping
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7'),
    # nrcell group
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1')
]

TL_PARAMS_TO_DELETE_3Cell = TL_PARAMS_TO_DELETE_2Cell + [
    # NRCELL
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-6'),
    # cellmapping
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6'),
    # nrcell group
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1')
]

TL_PARAMS_TO_DELETE_4Cell = TL_PARAMS_TO_DELETE_3Cell + [
    # NRCELL
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-5'),
    # cellmapping
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5'),
    # nrcell group
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1')
]
