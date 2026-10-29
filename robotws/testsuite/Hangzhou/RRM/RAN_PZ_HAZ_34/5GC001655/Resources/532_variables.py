import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

PARAMS_532_01 = [
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
]

PARAMS_532_02 = [
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
]

PARAMS_532_03 = [
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
]

PARAMS_532_04 = [
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
]

PARAMS_532_05 = [
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
]
