import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_1347_A_06 = [
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_1347_A_01 = [
    dict(value='Automatic', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_1347_B_01 = [
    dict(value='Automatic', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition')
]

PARAMS_1347_A_02 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_1347_B_02 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition')
]

PARAMS_1347_A_07 = [
    dict(value='12', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_1347_B_07 = [
    dict(value='12', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition')
]

PARAMS_1347_B_08 = [
    dict(value='20', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition')
]
