# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/SYNC-1'
MR_NR_BTS_CLOCK_NAME = MR_NR_BTS_NAME + '/CLOCK-1'
MR_NR_BTS_TOP_NAME = MR_NR_BTS_CLOCK_NAME + '/TOP-1'
MR_NR_BTS_TOPP_NAME = MR_NR_BTS_TOP_NAME + '/TOPP-1'
MR_NR_BTS_PMMNL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/PMMNL-1'

PARAMS_TO_MODIFY_MessageRate = [
    dict(value='RATE_64', dist_name=MR_NR_BTS_TOPP_NAME, filter_param='Synchronization message rate')
]

PARAMS_TO_MODIFY_DomainNumber1 = [
    dict(value='5', dist_name=MR_NR_BTS_TOP_NAME, filter_param='ToP domain number')
]

PARAMS_TO_MODIFY_DomainNumber2 = [
    dict(value='0', dist_name=MR_NR_BTS_TOP_NAME, filter_param='ToP domain number')
]

PARAMS_TO_MODIFY_DSCPvalue = [
    dict(value='63', dist_name=MR_NR_BTS_TOP_NAME, filter_param='Synchronization plane DSCP')
]

except_topp_list1 = [True, {'availability': 'Available', 'usability': 'Usable'}, 1]

except_topp_list2 = [False, {'availability': 'Unavailable', 'usability': 'Unusable'}, 1]

BTS_COUNTERS_list = ['M51362C0', 'M51362C1', 'M51362C2', 'M51362C3', 'M51362C4']

except_number_list0 = [115200, 500, 500, 500, 900]

except_number_list1 = [115200, 500, 500, 500, 1800]

PARAMS_TO_MODIFY_PMMNL = [
    dict(value='30min', dist_name=MR_NR_BTS_PMMNL_NAME,
         filter_param='ToP phase synchronization statistics measurement interval'),
    dict(value='RATE_64', dist_name=MR_NR_BTS_TOPP_NAME, filter_param='Synchronization message rate')
]

GM_expect_list0 = {
    'Grandmaster clock ID': '00:B0:AE:FF:FE:05:26:0B',
    'Grandmaster clock accuracy': '21',
    'Grandmaster offset scaled log variance': '6400',
    'Grandmaster priority 1': '128',
    'Grandmaster priority 2': '128',
    'Steps removed': '1',
    'Two step flag': 'None',
    'Master clock ID': '00:B0:AE:FF:FE:05:26:0B',
    'Master port number': '1',
    'Slave port number': '1',
    'Time traceable flag': 'True',
    'Frequency traceable flag': 'True',
    'PTP time scale': 'True',
    'UTC offset validity flag': 'True',
    'Negative leap second flag': 'False',
    'Positive leap second flag': 'False'
}

GM_expect_list1 = {
    'Grandmaster clock ID': 'None',
    'Grandmaster clock accuracy': 'None',
    'Grandmaster offset scaled log variance': 'None',
    'Grandmaster priority 1': 'None',
    'Grandmaster priority 2': 'None',
    'Steps removed': 'None',
    'Two step flag': 'None',
    'Master clock ID': 'None',
    'Master port number': 'None',
    'Slave port number': 'None',
    'Time traceable flag': 'None',
    'Frequency traceable flag': 'None',
    'PTP time scale': 'None',
    'UTC offset validity flag': 'None',
    'Negative leap second flag': 'None',
    'Positive leap second flag': 'None'
}

GM_expect_list2 = {
    'Grandmaster clock ID': '00:00:00:00:00:00:00:00',
    'Grandmaster clock accuracy': 'ff',
    'Grandmaster offset scaled log variance': 'ffff',
    'Grandmaster priority 1': '255',
    'Grandmaster priority 2': '255',
    'Steps removed': '255',
    'Two step flag': 'None',
    'Master clock ID': '00:00:00:00:00:00:00:00',
    'Master port number': '0',
    'Slave port number': 'False',
    'Time traceable flag': 'False',
    'Frequency traceable flag': '1',
    'PTP time scale': 'False',
    'UTC offset validity flag': 'False',
    'Negative leap second flag': 'False',
    'Positive leap second flag': 'False'
}

Add_To_Scf_File = [
    dict(value='false', dist_name='MRBTS-718/MNL-1/MNLENT-1/PMMNL-1', p_name='actLoadCsiPeriodicity')
]
