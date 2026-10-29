# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)
TNLSVC = MR_BTS_NAME + '/TNLSVC-1' + '/TNL-1'
ETHSVC = TNLSVC + '/ETHSVC-1'
IPIF = TNLSVC + '/IPNO-1' + '/IPIF-1'
OBJ_TO_DELETE = [dict(dist_name=ETHSVC + '/ETHIF-4'), dict(dist_name=ETHSVC + '/ETHLK-3'),
                 dict(dist_name=ETHSVC + '/L2SWI-1' + '/BRGPRT-3'), dict(dist_name=TNLSVC + '/IPNO-1' + '/IPIF-4')]

MODIFY_SCF_1 = [dict(value='EIF2', dist_name=ETHSVC + '/ETHLK-1', p_name='connectorLabel'),
                dict(value='10.68.88.234', dist_name=IPIF + '/IPADDRESSV4-1', p_name='localIpAddr')]
