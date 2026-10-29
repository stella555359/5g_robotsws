# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/SYNC-1'
MR_NR_BTS_CLOCK_NAME = MR_NR_BTS_NAME + '/CLOCK-1'
MR_NR_BTS_TOP_NAME = MR_NR_BTS_CLOCK_NAME + '/TOP-1'
MR_NR_BTS_TOPP_NAME = MR_NR_BTS_TOP_NAME + '/TOPP-1'
MR_NR_BTS_PMMNL_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/PMMNL-1'

PARAMS_TO_MODIFY_MessageRate = [dict(dist_name=MR_NR_BTS_TOPP_NAME, parameter='syncMessageRate', value='RATE_64')]

PARAMS_TO_MODIFY_DomainNumber1 = [dict(dist_name=MR_NR_BTS_TOP_NAME, parameter='topDomainNumber', value=5)]

PARAMS_TO_MODIFY_DomainNumber2 = [dict(dist_name=MR_NR_BTS_TOP_NAME, parameter='topDomainNumber', value=0)]

PARAMS_TO_MODIFY_DSCPvalue = [dict(dist_name=MR_NR_BTS_TOP_NAME, parameter='sPlaneDscp', value=63)]


except_topp_list1 = [True, {'availability': 'Available', 'usability': 'Usable'}, 1]

except_topp_list2 = [False, {'availability': 'Unavailable', 'usability': 'Unusable'}, 1]

BTS_COUNTERS_list = ['M51362C0', 'M51362C1', 'M51362C2', 'M51362C3', 'M51362C4']

except_number_list0 = [115200, 500, 500, 500, 900]

except_number_list1 = [115200, 500, 500, 500, 1800]

PARAMS_TO_MODIFY_PMMNL = [dict(dist_name=MR_NR_BTS_PMMNL_NAME, parameter='topPhaseSyncStatisticsInterval',
                               value='30min'),
                          dict(dist_name=MR_NR_BTS_TOPP_NAME, parameter='syncMessageRate', value='RATE_64')]

GM_expect_list0 = [128, 6, '21', '00B0AEFFFE05260B']

GM_expect_list1 = [None, None, None, None]
