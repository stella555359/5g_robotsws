# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_GROUP_NAME = MR_NR_BTS_NAME + '/NRCELLGRP-0'
MR_NR_DRB = MR_NR_BTS_NAME + '/NRDRB-2'
MR_LCELNR = MR_BTS_NAME + '/MNL-1' + '/MNLENT-1' + '/CELLMAPPING-1' + '/LCELNR-1'


MODIFY_CB006062_07 = [
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actUl256Qam'),
    dict(
        value='201',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
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
        p_name='ulDlDataSlotRatio'),
]

MODIFY_CB006062_08 = [
    dict(
        value='198',
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='tdLte',
        dist_name=MR_NR_CELL_NAME,
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name=MR_NR_CELL_NAME,
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name=MR_NR_CELL_NAME,
        p_name='lteToNrFrameShift'),
    dict(
        value='1/4',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDlDataSlotRatio'),
]
