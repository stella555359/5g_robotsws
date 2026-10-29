# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'


MODIFY_SCF_CB006064_CU_01 = [
    dict(
        value='100MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
]


MODIFY_SCF_CB006064_DU_01 = [
    # 1208 frame structure
    dict(
        value='100MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
    dict(
        value='longPucch',
        dist_name=MR_NR_CELL_NAME,
        p_name='pucchModeSelect'),
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actFdmScheduling'),
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
    dict(
        value='148',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actFdmEnhancedScheduling'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actPdschAtSsbSlots'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actPdschRmCsirsForTracking'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actUl256Qam'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam'),
]
