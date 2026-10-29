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

MODIFY_SCF_5GC001200 = [
    # 1208 frame structure
    dict(
        value='ulOverLteNr_PrimaryPathOverNr',
        dist_name=MR_NR_DRB,
        p_name='ulDataPath'),
]
MODIFY_SCF_5GC001200_TEST = {'actDl256Qam': 'false', 'actUl256Qam': 'true'}
