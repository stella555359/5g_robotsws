# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BRGPRT_NAME_1 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-1'
MR_NR_BRGPRT_NAME_2 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2'
MR_NR_L2SWI_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1'
MR_NR_DSCPTOQMAP_NAME = MR_NR_L2SWI_NAME + '/DSCPTOQMAP-1'
MR_NR_PCP2QMAP_NAME = MR_NR_L2SWI_NAME + '/PCP2QMAP-1'


Modify_DU_l2ShaperRate = [dict(dist_name=MR_NR_BRGPRT_NAME_1, p_name='l2ShaperRate', value='10000'),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, p_name='l2ShaperRate', value='10000')]

filter_list1 = ['ip.dsfield.dscp == 20', 'ip.dsfield.dscp == 46']

txt_list1 = ['dscp_20.txt', 'dscp_46.txt']

Modify_011case_step5_1 = [dict(dist_name=MR_NR_BRGPRT_NAME_1, parameter='l2VlanIdList', value={'lowValue': 3}),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, parameter='l2VlanIdList', value={'lowValue': 3})]

Modify_011case_step5_2 = [dict(dist_name=MR_NR_BRGPRT_NAME_1, parameter='portDefaultVlanId', value=2),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, parameter='portDefaultVlanId', value=2)]

keywords_list1 = ['BRGPRT_A-1', 'BRGPRT_A-2']

Modify_011case_step7_1 = [dict(dist_name=MR_NR_BRGPRT_NAME_1, parameter='l2VlanIdList', value={'lowValue': 2}),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, parameter='l2VlanIdList', value={'lowValue': 2})]

Modify_011case_step7_2 = [dict(dist_name=MR_NR_BRGPRT_NAME_1, parameter='portDefaultVlanId', value=1),
                          dict(dist_name=MR_NR_BRGPRT_NAME_1, parameter='portDefaultVlanPriority', value=4),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, parameter='portDefaultVlanId', value=1),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, parameter='portDefaultVlanPriority', value=4)]

Modify_011case_step9_1 = [dict(dist_name=MR_NR_BRGPRT_NAME_1, parameter='portDefaultVlanPriority', value=1),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, parameter='portDefaultVlanPriority', value=1),
                          dict(dist_name=MR_NR_L2SWI_NAME, parameter='vlanAwarenessEnabled', value='false')]

filter_list2 = ['ip.dsfield.dscp == 20', 'ip.dsfield.dscp == 38']

txt_list2 = ['dscp_20.txt', 'dscp_38.txt']

Modify_007case_step1_1 = [dict(dist_name=MR_NR_L2SWI_NAME, parameter='l2QoSEnabled', value='true'),
                          dict(dist_name=MR_NR_L2SWI_NAME, parameter='qosClassificationCriteria', value='PCP'),
                          dict(dist_name=MR_NR_L2SWI_NAME, parameter='vlanAwarenessEnabled', value='true')]

Modify_DU_SCF_Case7 = [dict(dist_name=MR_NR_L2SWI_NAME, p_name='qosClassificationCriteria', value='PCP'),
                       dict(dist_name=MR_NR_BRGPRT_NAME_1, p_name='l2ShaperRate', value='10000'),
                       dict(dist_name=MR_NR_BRGPRT_NAME_2, p_name='l2ShaperRate', value='10000')]

Modify_DU_SCF_Case9 = [dict(dist_name=MR_NR_L2SWI_NAME, p_name='qosClassificationCriteria', value='PCP'),
                       dict(dist_name=MR_NR_L2SWI_NAME, p_name='vlanAwarenessEnabled', value='false'),
                       dict(dist_name=MR_NR_BRGPRT_NAME_1, p_name='l2ShaperRate', value='10000'),
                       dict(dist_name=MR_NR_BRGPRT_NAME_1, p_name='portDefaultVlanPriority', value='7'),
                       dict(dist_name=MR_NR_BRGPRT_NAME_2, p_name='l2ShaperRate', value='10000'),
                       dict(dist_name=MR_NR_BRGPRT_NAME_2, p_name='portDefaultVlanPriority', value='7')]

filter_list_case7 = ['vlan.priority == 1', 'vlan.priority == 7']

txt_list3 = ['VlanPriority1.txt', 'VlanPriority7.txt']

Modify_007case_step5_1 = [dict(dist_name=MR_NR_L2SWI_NAME, parameter='vlanAwarenessEnabled', value='false')]

Modify_007case_step7_1 = [dict(dist_name=MR_NR_PCP2QMAP_NAME, parameter='queueForPcp7', value='AF4')]

filter_list_case9 = ['vlan.priority == 1', '!vlan']

txt_list4 = ['VlanPriority1.txt', 'notvlan.txt']

Modify_009case_step5_1 = [dict(dist_name=MR_NR_BRGPRT_NAME_1, parameter='portDefaultVlanPriority', value='4'),
                          dict(dist_name=MR_NR_BRGPRT_NAME_2, parameter='portDefaultVlanPriority', value='4')]
