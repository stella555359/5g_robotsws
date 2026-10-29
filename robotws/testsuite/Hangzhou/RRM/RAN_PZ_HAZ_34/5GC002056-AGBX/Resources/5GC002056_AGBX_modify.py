# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1'

Modify_011case_step5_1 = [dict(dist_name=MR_NR_BTS_NAME,
                               parameter='ulPowerControlCommon', value={'actUlOpenLoopPwrCtrl': 'true'})]

Modify_011case_step5_2 = [dict(dist_name=MR_NR_BTS_NAME,
                               parameter='ulPowerControlCommon', value={'actUlOpenLoopPwrCtrl': 'false'})]

Modify_011case_step5_3 = [dict(dist_name=MR_NR_BTS_NAME,
                               parameter='ulMimoMode', value='Closed loop Spatial Multiplexing (2x2)')]

Modify_011case_step5_4 = [dict(dist_name=MR_NR_BTS_NAME,
                               parameter='ulPowerControlCommon', value={'p0NominalSrs': '-80'})]

Modify_011case_step5_5 = [dict(dist_name=MR_NR_BTS_NAME,
                               parameter='ulPowerControlCommon', value={'p0NominalSrs': '-72'})]

keywords_list1 = ['NRCELL_A-1']
