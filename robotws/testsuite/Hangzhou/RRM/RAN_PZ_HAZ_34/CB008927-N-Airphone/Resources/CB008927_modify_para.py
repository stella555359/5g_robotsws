import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# ##gnb1###
GNB_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
GNB_NR_BTS_NAME = GNB_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
GNB_CELL1_NAME = GNB_NR_BTS_NAME + '/NRCELL-1'
GNB_CELL3_NAME = GNB_NR_BTS_NAME + '/NRCELL-3'
GNB_NRRESOURCEGROUP1 = GNB_NR_BTS_NAME + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1'
GNB_NRRESOURCEGROUP2 = GNB_NR_BTS_NAME + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2'
GNB_NRRESOURCEGROUP3 = GNB_NR_BTS_NAME + '/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3'


case5_para = [dict(dist_name=GNB_CELL3_NAME, parameter='dlDmrsType', value='Type2', operation='update')]

case5_para2 = [dict(dist_name=GNB_CELL3_NAME, parameter='actDlDynSwitchAlloc', value='false', operation='update')]

case5_para_recover = [dict(dist_name=GNB_CELL3_NAME, parameter='dlDmrsType', value='Type1', operation='update'),
                      dict(dist_name=GNB_CELL3_NAME, parameter='actDlDynSwitchAlloc', value='true',
                           operation='update')]

case8_para = [dict(dist_name=GNB_CELL3_NAME, parameter='actPdcchSharingWithPdsch', value='true', operation='update')]

case8_para_recover = [dict(dist_name=GNB_CELL3_NAME, parameter='actPdcchSharingWithPdsch', value='false',
                           operation='update')]

case9_para = [dict(dist_name=GNB_NR_BTS_NAME, parameter='actExt2N77Support', value='true', operation='update'),
              dict(dist_name=GNB_CELL3_NAME, parameter='actLegExt2N77Coexist', value='true', operation='update')]

case9_para_recover = [dict(dist_name=GNB_NR_BTS_NAME, parameter='actExt2N77Support',
                           value='false', operation='update'),
                      dict(dist_name=GNB_CELL3_NAME, parameter='actLegExt2N77Coexist',
                           value='false', operation='update')]

case10_para = [dict(dist_name=GNB_NRRESOURCEGROUP1, parameter='schedulerParams',
                    value=[{'maxQuota': 10, 'minQuota': 5}], operation='update'),
               dict(dist_name=GNB_NRRESOURCEGROUP2, parameter='schedulerParams',
                    value=[{'maxQuota': 30, 'minQuota': 20}], operation='update'),
               dict(dist_name=GNB_NRRESOURCEGROUP3, parameter='schedulerParams',
                    value=[{'maxQuota': 100, 'minQuota': 30}], operation='update'),
               dict(dist_name=GNB_NRRESOURCEGROUP1, parameter='nrResourceList',
                    value=[{'resourceDN': GNB_NR_BTS_NAME + '/SNSSAI-1'}], operation='update'),
               dict(dist_name=GNB_NRRESOURCEGROUP2, parameter='nrResourceList',
                    value=[{'resourceDN': GNB_NR_BTS_NAME + '/SNSSAI-2'}], operation='update'),
               dict(dist_name=GNB_NRRESOURCEGROUP3, parameter='nrResourceList',
                    value=[{'resourceDN': GNB_NR_BTS_NAME + '/SNSSAI-3'}], operation='update')
               ]

case10_para_recover = [dict(dist_name=GNB_NRRESOURCEGROUP1, parameter='schedulerParams',
                       value=[{'maxQuota': 100, 'minQuota': 0}], operation='update'),
                       dict(dist_name=GNB_NRRESOURCEGROUP2, parameter='schedulerParams',
                       value=[{'maxQuota': 100, 'minQuota': 0}], operation='update'),
                       dict(dist_name=GNB_NRRESOURCEGROUP3, parameter='schedulerParams',
                       value=[{'maxQuota': 100, 'minQuota': 0}], operation='update'),
                       # dict(dist_name=GNB_NRRESOURCEGROUP1, parameter='nrResourceList',
                       #      value=[{'resourceDN': GNB_NR_BTS_NAME + '/SNSSAI-1'}], operation='update'),
                       # dict(dist_name=GNB_NRRESOURCEGROUP2, parameter='nrResourceList',
                       #      value=[{'resourceDN': GNB_NR_BTS_NAME + '/SNSSAI-2'}], operation='update'),
                       # dict(dist_name=GNB_NRRESOURCEGROUP3, parameter='nrResourceList',
                       #      value=[{'resourceDN': GNB_NR_BTS_NAME + '/SNSSAI-3'}], operation='update')
                       ]

EDA_case1_counter_id_list = ['M55306C06001', 'M55124C01031', 'M55124C01001',
                             'M55308C10002', 'M55308C10004',
                             'M55308C10001', 'M55308C10003',
                             'M55308C00005', 'M55335C02002', 'M55335C05002',
                             'M55308C00006', 'M55335C02001', 'M55335C05001',
                             'M55139C00010', 'M55139C00001',
                             'M55124C01021', 'M55124C01022', 'M55124C01023', 'M55124C01024', 'M55124C01025',
                             'M55124C01026', 'M55124C01027', 'M55124C01028', 'M55124C01029', 'M55124C01030']
