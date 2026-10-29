import os
import sys
from py_script import *
from robot.libraries.BuiltIn import BuiltIn
sys.path.append('${}/../../5GC001655/Resources')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
scf_file = BuiltIn().get_variable_value('${_scf_file_path}')
ids = get_mrbtsid_from_scf(scf_file)
MR_NR_CELL_NAME = 'MRBTS-' + str(ids[0]) + '/NRBTS-' + str(ids[1]) + \
    '/NRCELL-' + str(ids[2])

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(ids[0]) + '/NRBTS-' + str(ids[1]) + \
    '/NRCELLGRP-0'


MODIFY_SCF_2538_BWP = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actPdschAtSsbSlots'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actPdschRmCsirsForTracking'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='2 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='40ms', dist_name=MR_NR_CELL_NAME, p_name='csirsTrackingPeriod'),
    dict(value='slots320', dist_name=MR_NR_CELL_NAME, p_name='csiReportPeriodicity'),
    dict(value='300', dist_name=MR_NR_CELL_NAME, p_name='pMax'),
    dict(value='12', dist_name=MR_NR_CELL_NAME, p_name='ssPbchBlockPower'),
    dict(value='BWP', dist_name=MR_NR_CELL_NAME, p_name='rbAllocation'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='startRB'),
    dict(value='longPucch', dist_name=MR_NR_CELL_NAME, p_name='pucchModeSelect'),
]

MODIFY_SCF_2538_52RB = [
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actPdschAtSsbSlots'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actPdschRmCsirsForTracking'),
    dict(value='beamSet_2', dist_name=MR_NR_CELL_NAME, p_name='basicBeamSet'),
    dict(value='2 beams', dist_name=MR_NR_CELLGRP_NAME, p_name='numberOfTransmittedSsBlocks'),
    dict(value='40ms', dist_name=MR_NR_CELL_NAME, p_name='csirsTrackingPeriod'),
    dict(value='slots320', dist_name=MR_NR_CELL_NAME, p_name='csiReportPeriodicity'),
    dict(value='300', dist_name=MR_NR_CELL_NAME, p_name='pMax'),
    dict(value='12', dist_name=MR_NR_CELL_NAME, p_name='ssPbchBlockPower'),
    dict(value='52RB', dist_name=MR_NR_CELL_NAME, p_name='rbAllocation'),
    dict(value='0', dist_name=MR_NR_CELL_NAME, p_name='startRB'),
    dict(value='longPucch', dist_name=MR_NR_CELL_NAME, p_name='pucchModeSelect'),
]
