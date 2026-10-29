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


MODIFY_SCF_5GC002538toFalse = {'actPdschRmCsirsForTracking': 'false', 'actPdschAtSsbSlots': 'false'}
MODIFY_SCF_5GC002538toTrue = {'actPdschRmCsirsForTracking': 'true', 'actPdschAtSsbSlots': 'true',
                              'nrCellType': '4DL4UL', 'prachConfigurationIndex': '189'}

MODIFY_SCF_CU_50M = [
    dict(
        value='50MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
]

MODIFY_SCF_CU_100M = [
    dict(
        value='100MHz',
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw'),
]
