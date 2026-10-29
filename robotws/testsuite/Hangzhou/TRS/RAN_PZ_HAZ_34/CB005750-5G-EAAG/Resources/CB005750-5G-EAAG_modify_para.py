# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1'

MR_NR_BTS_NAME2 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'

MR_NR_BTS_NAME3 = 'MRBTS-' + str(tl.gnbs[0].slave[0].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'

MR_NR_BTS_NAME4 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1'

parameter0 = [dict(
    dist_name=MR_NR_BTS_NAME1, parameter='outputConfiguration1Pps', value='EnabledWithoutBtsInputReference')]

parameter1 = [dict(
    dist_name=MR_NR_BTS_NAME4, parameter='actGnssOutputLnaPowerSupply', value='true')]

parameter2 = [dict(
    dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': '10.57.157.245'})]

parameter3 = [dict(
    dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': '10.57.157.246'})]

parameter4 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': '10.57.157.245'})]

parameter5 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': '10.57.157.246'})]

parameter10 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerPortNo': '51001'})]

parameter11 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerPortNo': '51000'})]

keywords_list1 = ['TRBLCADM_A-1']
