import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

PARAMS_TO_MODIFY_100MHz = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='277', dist_name=MR_NR_CELL_NAME, p_name='frequencyDensityThresNrb1'),
]

PARAMS_TO_MODIFY_80MHz = [
    dict(value='80MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
]

PARAMS_TO_MODIFY_100MHz_CC = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
]

PARAMS_TO_MODIFY_80MHz_CC = [
    dict(value='80MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
]

PARAMS_TO_MODIFY_100MHz_CA = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='277', dist_name=MR_NR_CELL_NAME, p_name='frequencyDensityThresNrb1'),
    dict(value='false', dist_name=MR_NR_NAME, p_name='actFdmScheduling'),
]
