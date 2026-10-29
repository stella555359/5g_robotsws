import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_531_01 = [
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
]

PARAMS_531_02 = [
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
]

PARAMS_531_03 = [
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
]

PARAMS_531_04 = [
    dict(value='2x2 Open Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
]

PARAMS_531_05 = [
    dict(value='2x2 Open Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
]

PARAMS_531_06 = [
    dict(value='2x2 Open Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
]
