import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

PARAMS_TO_MODIFY_Korea_conf_B = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='2 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
]

PARAMS_TO_MODIFY_Korea_conf_A = [
    dict(value='60MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
]

PARAMS_TO_MODIFY_1116_100MHz = [
    dict(value='100MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='97', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='tdLte', dist_name=MR_NR_CELL_NAME, p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=MR_NR_CELL_NAME, p_name='guardPeriodLength'),
    dict(value='0ms', dist_name=MR_NR_CELL_NAME, p_name='lteToNrFrameShift'),
    dict(value='tdLteConfig2', dist_name=MR_NR_CELL_NAME, p_name='tdLteUlDlConfig'),
    dict(value='2/8', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
]

PARAMS_TO_MODIFY_1070_60MHz = [
    dict(value='60MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='98', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
    dict(value='config2', dist_name=MR_NR_NAME, p_name='pdschRat0RbgConfig'),
]

PARAMS_TO_MODIFY_1070_20MHz = [
    dict(value='20MHz', dist_name=MR_NR_CELL_NAME, p_name='chBw'),
    dict(value='98', dist_name=MR_NR_CELL_NAME, p_name='prachConfigurationIndex'),
    dict(value='3/7', dist_name=MR_NR_CELL_NAME, p_name='ulDlDataSlotRatio'),
]


def Remove_repetition_list(list1):
    list1 = set(list1)
    return list1
