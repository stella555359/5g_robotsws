import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_522_01 = [
    dict(value='4x4 or 4x2 Open Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
    dict(value='15', dist_name=MR_NR_CELL_NAME, p_name='dlQam256PowerBackoffSub6'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='2 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actBeamforming'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDlMuMimo'),
    dict(value='4DL2UL', dist_name=MR_NR_CELL_NAME, p_name='nrCellType')
]

PARAMS_522_01_MCS = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='28', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
]

PARAMS_522_02 = [
    dict(value='2x2 Open Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
    dict(value='15', dist_name=MR_NR_CELL_NAME, p_name='dlQam256PowerBackoffSub6'),
    dict(value='beamSet_1', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='1 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDlMuMimo'),
    dict(value='2DL2UL', dist_name=MR_NR_CELL_NAME, p_name='nrCellType')
]

PARAMS_522_02_MCS = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='28', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
]

PARAMS_522_03 = [
    dict(value='2x2 Closed Loop Spatial Multiplexing', dist_name=MR_NR_CELL_NAME, p_name='dlMimoMode'),
    dict(value='Closed loop Spatial Multiplexing (2x2)', dist_name=MR_NR_CELL_NAME, p_name='ulMimoMode'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam'),
    dict(value='15', dist_name=MR_NR_CELL_NAME, p_name='dlQam256PowerBackoffSub6'),
    dict(value='beamSet_1', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='1 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDlMuMimo'),
    dict(value='2DL2UL', dist_name=MR_NR_CELL_NAME, p_name='nrCellType')
]

PARAMS_522_03_MCS = [
    dict(value='27', dist_name=MR_NR_CELL_NAME, p_name='dllaIniMcs'),
    dict(value='28', dist_name=MR_NR_CELL_NAME, p_name='ullaIniMcs'),
]
