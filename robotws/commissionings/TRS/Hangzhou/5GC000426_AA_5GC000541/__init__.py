__maintainer__ = 'Zhang Qionghua'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

PATH_TO_SCF = ''


PARAMS_TO_MODIFY_FOR_FEATURE = [
    dict(value=1, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
]

PARAMS_TO_MODIFY_FOR_FEATURE_8351 = [
    dict(value=90, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1)
]


PARAMS_TO_ADD_NetAct_TL = [
    dict(value='forced', dist_name='MRBTS-1931/MNL-1/MNLENT-1/MPLANENW-1', p_name='oamTls'),
]

ADD_Elements_TO_List_LOCAL = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='fPdcchMonOccsnPo',
         elements=['154'])
]

PARAMS_TO_DELETE_NetAct = [
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1931/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1)
]

PARAMS_TO_MODIFY_FOR_FEATURE_NetAct = [
    dict(value=1, dist_name='MRBTS-1931/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='true', dist_name='MRBTS-1931/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1931/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1931/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='27', dist_name='MRBTS-1931/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength')
]


PARAMS_TO_ADD_NetAct_TL_2 = [
    dict(class_name=_class_name, dist_name='MRBTS-1931/MNL-1/MNLENT-1/MPLANENW-1', version='MNL5G19_1901_010'),
]


AMOUNT_OF_CELLS = 1
