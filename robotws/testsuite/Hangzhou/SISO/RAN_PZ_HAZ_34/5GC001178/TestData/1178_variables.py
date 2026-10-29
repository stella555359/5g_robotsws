import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# SCF parameters to modify
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELLGRP_NAME = MR_NR_BTS_NAME + '/NRCELLGRP-0'

MODIFY_PARA_SSPBCH = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='ssPbchBlockPower',
        value='0')
]
