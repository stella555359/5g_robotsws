import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_425_01 = [
    dict(value='300', dist_name=MR_NR_CELL_NAME, p_name='pMax')
]

PARAMS_425_02 = [
    dict(value='260', dist_name=MR_NR_CELL_NAME, p_name='pMax'),
    dict(value='-90', dist_name=MR_NR_CELL_NAME, p_name='p0NominalPucch'),
    dict(value='-86', dist_name=MR_NR_CELL_NAME, p_name='p0NominalPusch')
]

PARAMS_425_03 = [
    dict(value='230', dist_name=MR_NR_CELL_NAME, p_name='pMax'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]

PARAMS_425_04 = [
    dict(value='230', dist_name=MR_NR_CELL_NAME, p_name='pMax'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]

PARAMS_425_05 = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actUlOpenLoopPwrCtrl'),
    dict(value='-90', dist_name=MR_NR_CELL_NAME, p_name='p0NominalPucch'),
    dict(value='-90', dist_name=MR_NR_CELL_NAME, p_name='p0NominalPusch')
]
