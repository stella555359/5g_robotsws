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
MR_NR_BTS_NAME3 = 'MRBTS-' + str(tl.gnbs[0].slave[0].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
MR_NR_BTS_NAME2 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
MR_NR_BTS_NAME4 = MR_NR_BTS_CLOCK_NAME + '/GNSSE-1'
MR_NR_BTS_NAME5 = MR_NR_BTS_CLOCK_NAME + '/TOP-1'

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

GM_expect_list0 = [128, 6, '21', '00:B0:AE:FF:FE:05:26:0B']

GM_expect_list1 = [None, None, None, None]

step2_except_topp_list = [True, {'availability': 'Available', 'usability': 'Usable'}, 1]
step2_except_other_list = [False, {'availability': 'Available', 'usability': 'Usable'}, 2]

step3_except_topp_list = [False, {'availability': 'Unavailable', 'usability': 'Unusable'}, 1]
step3_except_other_list = [True, {'availability': 'Available', 'usability': 'Usable'}, 2]

step4_except_topp_list = [False, {'availability': 'Available', 'usability': 'Usable'}, 2]
step4_except_other_list = [True, {'availability': 'Available', 'usability': 'Usable'}, 1]

case319_modify_sync1 = [dict(dist_name=MR_NR_BTS_CLOCK_NAME, parameter='syncInputList',
                             value=[{'syncInputPrio': '2'}, {'syncInputPrio': '1'}])]

case319_modify_sync2 = [dict(dist_name=MR_NR_BTS_CLOCK_NAME, parameter='syncInputList',
                             value=[{'syncInputPrio': '1'}, {'syncInputPrio': '2'}])]

index_list = [0, 1]

modify_keywords_list1 = ['SYNC_A-1']

parameter0_315 = [dict(dist_name=MR_NR_BTS_CLOCK_NAME, parameter='outputConfiguration1Pps',
                       value='EnabledWithoutBtsInputReference'),
                  dict(dist_name=MR_NR_BTS_NAME4, parameter='actGnssOutputLnaPowerSupply', value='true')]

parameter5_315 = [dict(dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig',
                       value=[{'remoteSyslogServerIPaddress': '10.57.157.246', 'remoteSyslogServerPortNo': '51001'}])]

parameter3_315 = [dict(dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig',
                       value=[{'remoteSyslogServerIPaddress': '10.57.157.246', 'remoteSyslogServerPortNo': '51000'}])]


parameter4_315 = [dict(dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig',
                       value=[{'remoteSyslogServerIPaddress': '10.57.157.245', 'remoteSyslogServerPortNo': '51000'}])]

parameter_0 = [dict(dist_name=MR_NR_BTS_CLOCK_NAME, parameter='outputConfiguration1Pps',
                    value='EnabledWithBtsInputReference')]

parameter_6 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actGnssOutputLnaPowerSupply', value='false')]

parameter_7 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actGnssOutputLnaPowerSupply', value='true')]

parameter_8 = [dict(dist_name=MR_NR_BTS_NAME5, parameter='topDomainNumber', value='5')]

parameter_9 = [dict(dist_name=MR_NR_BTS_NAME5, parameter='topDomainNumber', value='0')]

keywords_list1 = ['TRBLCADM_A-1']

GPS_only1 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actBeidou', value='false'),
             dict(dist_name=MR_NR_BTS_NAME4, parameter='actGlonass', value='false'),
             dict(dist_name=MR_NR_BTS_NAME4, parameter='actGps', value='true')]

GLONASS_only1 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actBeidou', value='false'),
                 dict(dist_name=MR_NR_BTS_NAME4, parameter='actGlonass', value='true'),
                 dict(dist_name=MR_NR_BTS_NAME4, parameter='actGps', value='false')]

Beidou_only1 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actBeidou', value='true'),
                dict(dist_name=MR_NR_BTS_NAME4, parameter='actGlonass', value='false'),
                dict(dist_name=MR_NR_BTS_NAME4, parameter='actGps', value='false')]

GLONASS_Beidou1 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actBeidou', value='true'),
                   dict(dist_name=MR_NR_BTS_NAME4, parameter='actGlonass', value='true'),
                   dict(dist_name=MR_NR_BTS_NAME4, parameter='actGps', value='false')]

GPS_GLONASS1 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actBeidou', value='false'),
                dict(dist_name=MR_NR_BTS_NAME4, parameter='actGlonass', value='true'),
                dict(dist_name=MR_NR_BTS_NAME4, parameter='actGps', value='true')]

GPS_Beidou1 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actBeidou', value='true'),
               dict(dist_name=MR_NR_BTS_NAME4, parameter='actGlonass', value='false'),
               dict(dist_name=MR_NR_BTS_NAME4, parameter='actGps', value='true')]

gnss_mode_all = [GPS_GLONASS1, GPS_Beidou1, GPS_only1, GLONASS_only1, GLONASS_Beidou1, Beidou_only1]

gnss_mode_glonass = [GLONASS_only1]

CB005750_5G_EAAG_TC01 = [0]
