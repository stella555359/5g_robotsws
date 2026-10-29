# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTS_ID = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NRBTS_ID = MRBTS_ID + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRCELL_1 = NRBTS_ID + '/NRCELL-1'


case1_common = [dict(dist_name=NRCELL_1, parameter='actUlClosedLoopPwrCtrl', value='puschSrs')]

case2_common = [dict(dist_name=NRCELL_1, parameter='actUlClosedLoopPwrCtrl', value='pucchPuschSrs')]

case4_common = [dict(dist_name=NRCELL_1, parameter='actUlClosedLoopPwrCtrl', value='pucchPuschSrs')]

case5_common = [dict(dist_name=NRCELL_1, parameter='actUlClosedLoopPwrCtrl', value='pucch')]
