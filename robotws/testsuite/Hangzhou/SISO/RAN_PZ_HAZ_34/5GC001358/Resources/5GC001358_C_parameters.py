# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'


MODIFY_SCF_NA = []
MODIFY_SCF_1208 = [
    # 1208 frame structure
    dict(
        value='semiStatic',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='2Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='1/4',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio')
]
MODIFY_SCF_1070 = [
    # 1070 frame structure
    dict(
        value='semiStatic',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='2Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='3/7',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio'),
]
