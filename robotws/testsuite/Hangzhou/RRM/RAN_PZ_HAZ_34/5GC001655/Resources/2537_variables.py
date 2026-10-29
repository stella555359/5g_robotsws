import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-1024'

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-1024' + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

PARAMS_2537_A_01 = [
    dict(value='true', dist_name=MR_NR_NAME, p_name='actFdmScheduling'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='true', dist_name=MR_NR_NAME, p_name='actFdmEnhancedScheduling'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='beamSet_6', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet')
]

PARAMS_2537_A_02 = [
    dict(value='false', dist_name=MR_NR_NAME, p_name='actFdmScheduling'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='true', dist_name=MR_NR_NAME, p_name='actFdmEnhancedScheduling'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='beamSet_6', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet')
]

PARAMS_2537_A_03 = [
    dict(value='false', dist_name=MR_NR_NAME, p_name='actFdmScheduling'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='false', dist_name=MR_NR_NAME, p_name='actFdmEnhancedScheduling'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='beamSet_6', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet')
]

PARAMS_2537_A_04 = [
    dict(value='true', dist_name=MR_NR_NAME, p_name='actFdmScheduling'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='false', dist_name=MR_NR_NAME, p_name='actFdmEnhancedScheduling'),
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='beamSet_6', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet')
]
