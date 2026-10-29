# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1' \
                 + '/MNLENT-1' + '/SYNC-1'
MR_NR_BTS_CLOCK_NAME = MR_NR_BTS_NAME + '/CLOCK-1'
MR_NR_BTS_TOP_NAME = MR_NR_BTS_CLOCK_NAME + '/TOP-1'
MR_NR_BTS_TOPP_NAME = MR_NR_BTS_TOP_NAME + '/TOPP-1'
NR_BTS_ID = str(tl.gnbs[0].global_bts_id)
MR_Cell_Name = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-1'

PARAMS_TO_MODIFY_TOPP_PhaseSync = [
    dict(value='0', dist_name=MR_NR_BTS_NAME, filter_param='Manual frame timing adjustment'),
    dict(value='TOPP', dist_name=MR_NR_BTS_CLOCK_NAME, filter_param='Sync input type'),
    dict(value='PhaseSync', dist_name=MR_NR_BTS_NAME, filter_param='BTS synchronization mode')
]

TOPF_PhaseSync = {'MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1': [u'Whenever MNL-1 having MNL-1.productVariant'
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
                  MR_NR_BTS_CLOCK_NAME: [u'Whenever CLOCK-1 having embedded assertion valid (Namely: Whenever for each'
                                         u' CLOCK.syncInputList, CLOCK.syncInputList.syncInputType equal to TOPF, it '
                                         u'is required that there exist MOs CLOCK.syncInputList), it is required that'
                                         u' embedded assertion valid (Namely: It is required that there exist MOs '
                                         u'CLOCK/TOP/TOPF)']}


step2_expect_topp_list = [True, {'availability': 'Available', 'usability': 'Usable'}, 1]
step2_expect_other_list = [False, {'availability': 'Available', 'usability': 'Usable'}, 2]

step3_expect_topp_list = [False, {'availability': 'Unavailable', 'usability': 'Unusable'}, 1]
step3_expect_other_list = [True, {'availability': 'Available', 'usability': 'Usable'}, 2]

PARAMS_TO_MODIFY_DomainNumber1 = [dict(dist_name=MR_NR_BTS_TOP_NAME, parameter='topDomainNumber', value=5)]
PARAMS_TO_MODIFY_DomainNumber2 = [dict(dist_name=MR_NR_BTS_TOP_NAME, parameter='topDomainNumber', value=0)]
