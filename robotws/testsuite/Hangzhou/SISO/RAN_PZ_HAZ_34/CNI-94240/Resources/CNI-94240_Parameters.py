# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_GROUP_NAME = MR_NR_BTS_NAME + '/NRCELLGRP-0'

MODIFY_SCF_A_1 = [
    # 1116 frame structure
    dict(
        value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='3ms',
        dist_name=MR_NR_CELL_NAME,
        p_name='lteToNrFrameShift'),
]


ultp_90MHz = 75
dltp_2DL_64QAM_90MHz = 455
dltp_2DL_256QAM_90MHz = 200
dltp_4DL_64QAM_90MHz = 200
dltp_4DL_256QAM_90MHz = 400
dldata_2DL_64QAM_90MHz = '500M'
dldata_2DL_256QAM_90MHz = '670'
dldata_4DL_64QAM_90MHz = '1100M'
dldata_4DL_256QAM_90MHz = '1400M'
uldata_90MHz = '80M'

ATTENUATION_VALUE_0 = {
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port4': 0,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127,
    'atten_value_of_port8': 127,
    'atten_value_of_port9': 127,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127,
    'atten_value_of_port12': 127
}
ATTENUATION_VALUE_1 = {
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 0,
    'atten_value_of_port6': 0,
    'atten_value_of_port7': 0,
    'atten_value_of_port8': 0,
    'atten_value_of_port9': 127,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127,
    'atten_value_of_port12': 127
}
ATTENUATION_VALUE_2 = {
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
    'atten_value_of_port4': 127,
    'atten_value_of_port5': 127,
    'atten_value_of_port6': 127,
    'atten_value_of_port7': 127,
    'atten_value_of_port8': 127,
    'atten_value_of_port9': 0,
    'atten_value_of_port10': 0,
    'atten_value_of_port11': 0,
    'atten_value_of_port12': 0
}
