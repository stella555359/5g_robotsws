# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_GROUP = MR_NR_BTS_NAME + '/NRCELLGRP-0'


MODIFY_SCF_NA = []
MODIFY_SCF_case3 = [
    # 1208 frame structure
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actCustomBsr'),
    dict(
        value='beamSet_1',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet'),
    dict(
        value='8 beams',
        dist_name=MR_NR_CELL_GROUP,
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='test_1',
        dist_name=MR_NR_CELL_NAME,
        p_name='externalAntennaType'),
    dict(
        value='BSR_AZQG_8_H8_ALN45_ARP45_test_1_00111_00001',
        dist_name=MR_NR_CELL_NAME,
        p_name='customBeamSetName')
]
MODIFY_SCF_prepare = [
    dict(
        value='98',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='100MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
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
    dict(
        value='1/4',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio')
]

MODIFY_SCF_case5 = [
    # 1208 frame structure
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actCustomBsr'),
    dict(
        value='beamSet_1',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet'),
    dict(
        value='8 beams',
        dist_name=MR_NR_CELL_GROUP,
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='test_2',
        dist_name=MR_NR_CELL_NAME,
        p_name='externalAntennaType'),
    dict(
        value='BSR_AZQG_8_H8_ALN45_ARP45_test_2_00222_00001',
        dist_name=MR_NR_CELL_NAME,
        p_name='customBeamSetName')
]
