import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_TO_MODIFY_SCF_1347_A_001 = [
    dict(value='automatic', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_A_002 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_A_007 = [
    dict(value='automatic', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_A_009 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_A_010 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_A_011 = [
    dict(value='No additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_A_012 = [
    dict(value='automatic', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_B_001 = [
    dict(value='automatic', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
    dict(value='pos2', dist_name=MR_NR_CELL_NAME, p_name='dmrsTypeAPosition')
]

PARAMS_TO_MODIFY_SCF_1347_B_002 = [
    dict(value='automatic', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_B_006 = [
    dict(value='automatic', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition')
]

PARAMS_TO_MODIFY_SCF_1347_B_008 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]

PARAMS_TO_MODIFY_SCF_1347_B_010 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]

PARAMS_TO_MODIFY_SCF_1347_B_011 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
    dict(value='pos2', dist_name=MR_NR_CELL_NAME, p_name='dmrsTypeAPosition')
]

PARAMS_TO_MODIFY_SCF_1347_B_013 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]
