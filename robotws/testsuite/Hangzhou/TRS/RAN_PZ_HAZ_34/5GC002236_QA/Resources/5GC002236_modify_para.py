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
NR_BTS_ID = str(tl.gnbs[0].global_bts_id)
MR_Cell_Name = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + NR_BTS_ID + '/NRCELL-1'

bfd_distname = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPAPP-1/BFD-1'
IPRT_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/IPNO-1/IPRT-1'
Trigger_distname_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TRIGGER-1'
Trigger_distname_1_1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/TNLSVC-1/TNL-1/TRIGGER-1/TRIGGER_R-1'


PARAMS_TO_MODIFY_TOPF_PhaseSync = [
    dict(value='0', dist_name=MR_NR_BTS_NAME, filter_param='Manual frame timing adjustment'),
    dict(value='TOPF', dist_name=MR_NR_BTS_CLOCK_NAME, filter_param='Sync input type'),
    dict(value='PhaseSync', dist_name=MR_NR_BTS_NAME, filter_param='BTS synchronization mode')
]

PARAMS_TO_MODIFY_TOPF_FreqSync = [
    dict(value='0', dist_name=MR_NR_BTS_NAME, filter_param='Manual frame timing adjustment'),
    dict(value='TOPF', dist_name=MR_NR_BTS_CLOCK_NAME, filter_param='Sync input type'),
    dict(value='FreqSync', dist_name=MR_NR_BTS_NAME, filter_param='BTS synchronization mode')
]

PARAMS_TO_MODIFY_TOPP_PhaseSync = [
    dict(value='0', dist_name=MR_NR_BTS_NAME, filter_param='Manual frame timing adjustment'),
    dict(value='TOPP', dist_name=MR_NR_BTS_CLOCK_NAME, filter_param='Sync input type'),
    dict(value='PhaseSync', dist_name=MR_NR_BTS_NAME, filter_param='BTS synchronization mode')
]

TOPF_PhaseSync = {'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1': [u'Whenever MNL-1 having MNL-1.productVariant'
                                                                        u'Planned (value: 5gDU) equal to 5gClassical'
                                                                        u'BTS or MNL-1.productVariantPlanned (value: '
                                                                        u'5gDU) equal to 5gDU, it is required that '
                                                                        u'embedded assertion valid (Namely: Whenever '
                                                                        u'SYNC-* having SYNC.profileType equal to RAU'
                                                                        u' and SYNC.btsSyncMode equal to PhaseSync, '
                                                                        u'for each CLOCK.syncInputList, it is required'
                                                                        u' that CLOCK.syncInputList.syncInputType is '
                                                                        u'within range 1pps/ToD from Sync Hub Master|'
                                                                        u'1pps/ToD from external GNSS receiver|TOPP|'
                                                                        u'1pps/ToD from backplane)'],
                  MR_NR_BTS_CLOCK_NAME: [u'Whenever CLOCK-1 having embedded assertion valid (Namely: It is required '
                                         u'that there exist MOs CLOCK.syncInputList, whenever for each '
                                         u'CLOCK.syncInputList, CLOCK.syncInputList.syncInputType equal to TOPF), '
                                         u'it is required that embedded assertion valid (Namely: It is required '
                                         u'that there exist MOs CLOCK/TOP/TOPF)']
                  }

TOPF_FreqSync = {MR_NR_BTS_NAME: [u'Whenever SYNC-1 having SYNC-1.btsSyncMode (value: FreqSync) not equal to PhaseSync'
                                  u', it is required that SYNC-1.actEcpriMasterClock (value: true) not equal to true',
                                  u'Whenever SYNC-1 having SYNC-1.profileType (value: RAU) not equal to RAU or SYNC-1.'
                                  u'btsSyncMode (value: FreqSync) not equal to PhaseSync, it is required that SYNC-1.'
                                  u'manualFrameTimingAdjustment (value: 0microseconds) is not configured'],
                 MR_Cell_Name: [u'Whenever NRCELL-1 having NRCELL-1.cell'
                                u'Technology (value: TDD) equal to TDD, '
                                u'it is required that embedded assertion'
                                u' valid (Namely: It is required that '
                                u'there exist MOs SYNC-* having '
                                u'SYNC.btsSyncMode equal to PhaseSync)'],
                 MR_NR_BTS_CLOCK_NAME: [u'Whenever CLOCK-1 having embedded assertion valid (Namely: It is required '
                                        u'that there exist MOs CLOCK.syncInputList, whenever for each '
                                        u'CLOCK.syncInputList, CLOCK.syncInputList.syncInputType equal to TOPF), '
                                        u'it is required that embedded assertion valid (Namely: It is required that '
                                        u'there exist MOs CLOCK/TOP/TOPF)']}

step2_except_topp_list = [True, {'availability': 'Available', 'usability': 'Usable'}, 1]
step2_except_other_list = [False, {'availability': 'Available', 'usability': 'Usable'}, 2]

step3_except_topp_list = [False, {'availability': 'Unavailable', 'usability': 'Unusable'}, 1]
step3_except_other_list = [True, {'availability': 'Available', 'usability': 'Usable'}, 2]

# PARAMS_TO_MODIFY_DomainNumber1 = [
#     dict(value='5', dist_name=MR_NR_BTS_TOP_NAME, filter_param='ToP domain number')
# ]
PARAMS_TO_MODIFY_DomainNumber1 = [dict(dist_name=MR_NR_BTS_TOP_NAME, parameter='topDomainNumber', value=5)]

# PARAMS_TO_MODIFY_DomainNumber2 = [
#     dict(value='0', dist_name=MR_NR_BTS_TOP_NAME, filter_param='ToP domain number')
# ]
PARAMS_TO_MODIFY_DomainNumber2 = [dict(dist_name=MR_NR_BTS_TOP_NAME, parameter='topDomainNumber', value=0)]

excpect_list = ['MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/MNL-1', MR_NR_BTS_CLOCK_NAME, MR_NR_BTS_NAME,
                'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + NR_BTS_ID + '/NRCELL-1']

except_topp_list1 = [True, {'availability': 'Available', 'usability': 'Usable'}, 1]

except_topp_list2 = [False, {'availability': 'Unavailable', 'usability': 'Unusable'}, 1]

# PARAMS_TO_MODIFY_MessageRate = [
#     dict(value='RATE_64', dist_name=MR_NR_BTS_TOPP_NAME, filter_param='Synchronization message rate')
# ]
PARAMS_TO_MODIFY_MessageRate = [dict(dist_name=MR_NR_BTS_TOPP_NAME, parameter='syncMessageRate', value='RATE_64')]

# PARAMS_TO_MODIFY_DSCPvalue = [
#     dict(value='63', dist_name=MR_NR_BTS_TOP_NAME, filter_param='Synchronization plane DSCP')
# ]
PARAMS_TO_MODIFY_DSCPvalue = [dict(dist_name=MR_NR_BTS_TOP_NAME, parameter='sPlaneDscp', value=63)]

PARAMS_TRIGGER = [
    dict(operation='update', parameterName='false2TrueDelay', value='1'),
    dict(operation='update', parameterName='itemList', value=[{"itemDN": bfd_distname}]),
    dict(operation='update', parameterName='logic', value='OR'),
    dict(operation='update', parameterName='triggerId', value='1')]

PARAMS_staticRoutes_3 = [
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '10.0.0.0',
     "gateway": '10.57.228.97'
     },
    {"destinationIpPrefixLength": '0',
     "destIpAddr": '0.0.0.0',
     "gateway": '10.57.243.129',
     "preSrcIpv4Addr": '0.0.0.0',
     "routeIpMtu": '1500',
     "triggerDN": Trigger_distname_1
     }
]

PARAMS_recover_staticRoutes_1 = [
    {"destinationIpPrefixLength": '0',
     "destIpAddr": '0.0.0.0',
     "gateway": '10.57.228.97'
     },
    {"destinationIpPrefixLength": '8',
     "destIpAddr": '20.0.0.0',
     "gateway": '10.57.243.129',
     "preSrcIpv4Addr": '0.0.0.0',
     "routeIpMtu": '1500'
     }
]
