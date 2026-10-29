__maintainer__ = 'Cris cai'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'cris.cai@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

PATH_TO_SCF = ''

PARAMS_TO_DELETE_LOCAL = [
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngCplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='xnCplane'),
]

PARAMS_TO_DELETE_PEER = [
    dict(dist_name='MRBTS-1900/NRBTS-3', list_name='ngCplane'),
    dict(dist_name='MRBTS-1900/NRBTS-3', list_name='xnCplane'),
]

PARAMS_TO_MODIY_FOR_FEATURE_LOCAL = [
    dict(value='10.57.223.97', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='gateway'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destinationIpPrefixLength'),
    dict(value='SA', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbCuType'),
    dict(value='262', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='3', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='mncLength'),
    dict(value='5G18A/5g_pid12_classical_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='10.57.157.24', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='fiveGsTac'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-1', p_name='fiveGsTac'),
]

PARAMS_TO_MODIY_FOR_FEATURE_PEER = [
    dict(value='10.57.223.97', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='gateway'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destinationIpPrefixLength'),
    dict(value='10.57.157.24', dist_name='MRBTS-1900/NRBTS-3/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='SA', dist_name='MRBTS-1900/NRBTS-3', p_name='gNbCuType'),
    dict(value='262', dist_name='MRBTS-1900/NRBTS-3', p_name='mcc'),
    dict(value='3', dist_name='MRBTS-1900/NRBTS-3', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-3', p_name='mncLength'),
    dict(value='5G18A/5g_pid12_classical_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-3/NRCELL-1', p_name='fiveGsTac'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-3/TRACKINGAREA-1', p_name='fiveGsTac'),
]

ADD_GNBADJGNB_XNLINK_OBJECT_LOCAL = [
    dict(class_name='com.nokia.srbts.nrbts:XNLINK',
         dist_name='MRBTS-1900/NRBTS-1/XNLINK-1', version='NRBTS5G19A_1904_201'),
    dict(class_name='com.nokia.srbts.nrbts:GNBADJGNB',
         dist_name='MRBTS-1900/NRBTS-1/GNBADJGNB-3', version='NRBTS5G19A_1904_201'),
    dict(class_name='com.nokia.srbts.nrbts:SNSSAI', dist_name='MRBTS-1900/NRBTS-1/SNSSAI-1',
         version='NRBTS5G19A_1904_201')
]

PARAMS_TO_ADD_GNBADJGNB_LOCAL = [
    dict(value='3', dist_name='MRBTS-1900/NRBTS-1/GNBADJGNB-3', p_name='gNodeBId'),
    dict(value='unlocked', dist_name='MRBTS-1900/NRBTS-1/GNBADJGNB-3', p_name='xnLinkLock'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/GNBADJGNB-3', p_name='xnLinkRef'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1/GNBADJGNB-3', p_name='gNbIdLength'),
    dict(value='10.57.223.101', dist_name='MRBTS-1900/NRBTS-1/XNLINK-1', p_name='cPlaneIpAddr'),
    dict(value='128', dist_name='MRBTS-1900/NRBTS-1/SNSSAI-1', p_name='sd'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/SNSSAI-1', p_name='sst')
]

ADD_GNBPLMN_MO_LOCAL = [
    dict(dist_name='MRBTS-1900/NRBTS-1/GNBADJGNB-3', list_name='gnbPlmn')
]

ADD_NG_XN_LIST_OB_LOCAL = [
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngCplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='xnCplane'),
    dict(dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-1', list_name='snssaiDNList')
]

ADD_NG_XN_ITEM_TO_LIST_LOCAL = [
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='ngCplane',
         elements=dict(ipV4AddressDN1='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')),
    dict(dist_name='MRBTS-1900/NRBTS-1', list_name='xnCplane',
         elements=dict(ipV4AddressDN1='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2')),
]

ADD_GNBPLMN_list_LOCAL = [
    dict(dist_name='MRBTS-1900/NRBTS-1/GNBADJGNB-3', list_name='gnbPlmn',
         elements=dict(mcc='262', mnc='03', mncLength='2'))
]

ADD_Elements_TO_List_LOCAL = [
    dict(dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-1', list_name='snssaiDNList',
         elements=['MRBTS-1900/NRBTS-1/SNSSAI-1']),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='fPdcchMonOccsnPo',
         elements=['154']),
]

PARAMS_NG_XN_LOCAL = [
    PARAMS_TO_DELETE_LOCAL,
    ADD_NG_XN_LIST_OB_LOCAL,
    ADD_NG_XN_ITEM_TO_LIST_LOCAL
]

PARAMS_TO_ADD_LOCAL_XN = [
    ADD_GNBADJGNB_XNLINK_OBJECT_LOCAL,
    PARAMS_TO_ADD_GNBADJGNB_LOCAL,
    ADD_GNBPLMN_MO_LOCAL,
    ADD_GNBPLMN_list_LOCAL,
    ADD_Elements_TO_List_LOCAL
]

ADD_GNBADJGNB_XNLINK_OBJECT_PEER = [
    dict(class_name='com.nokia.srbts.nrbts:XNLINK',
         dist_name='MRBTS-1900/NRBTS-3/XNLINK-1', version='NRBTS5G19A_1904_201'),
    dict(class_name='com.nokia.srbts.nrbts:GNBADJGNB',
         dist_name='MRBTS-1900/NRBTS-3/GNBADJGNB-1', version='NRBTS5G19A_1904_201'),
    dict(class_name='com.nokia.srbts.nrbts:SNSSAI', dist_name='MRBTS-1900/NRBTS-3/SNSSAI-1',
         version='NRBTS5G19A_1904_201')
]

PARAMS_TO_ADD_GNBADJGNB_PEER = [
    dict(value='1', dist_name='MRBTS-1900/NRBTS-3/GNBADJGNB-1', p_name='gNodeBId'),
    dict(value='unlocked', dist_name='MRBTS-1900/NRBTS-3/GNBADJGNB-1', p_name='xnLinkLock'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-3/GNBADJGNB-1', p_name='xnLinkRef'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-3/GNBADJGNB-1', p_name='gNbIdLength'),
    dict(value='10.57.223.100', dist_name='MRBTS-1900/NRBTS-3/XNLINK-1', p_name='cPlaneIpAddr'),
    dict(value='128', dist_name='MRBTS-1900/NRBTS-3/SNSSAI-1', p_name='sd'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-3/SNSSAI-1', p_name='sst')
]

ADD_GNBPLMN_MO_PEER = [
    dict(dist_name='MRBTS-1900/NRBTS-3/GNBADJGNB-1', list_name='gnbPlmn')
]

ADD_GNBPLMN_list_PEER = [
    dict(dist_name='MRBTS-1900/NRBTS-3/GNBADJGNB-1', list_name='gnbPlmn',
         elements=dict(mcc='262', mnc='03', mncLength='2'))
]

ADD_NG_XN_LIST_OB_PEER = [
    dict(dist_name='MRBTS-1900/NRBTS-3', list_name='ngCplane'),
    dict(dist_name='MRBTS-1900/NRBTS-3', list_name='xnCplane'),
    dict(dist_name='MRBTS-1900/NRBTS-3/TRACKINGAREA-1', list_name='snssaiDNList')
]

ADD_NG_XN_ITEM_TO_LIST_PEER = [
    dict(dist_name='MRBTS-1900/NRBTS-3', list_name='ngCplane',
         elements=dict(ipV4AddressDN1='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')),
    dict(dist_name='MRBTS-1900/NRBTS-3', list_name='xnCplane',
         elements=dict(ipV4AddressDN1='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2')),
]

ADD_Elements_TO_List_PEER = [
    dict(dist_name='MRBTS-1900/NRBTS-3/TRACKINGAREA-1', list_name='snssaiDNList',
         elements=['MRBTS-1900/NRBTS-3/SNSSAI-1']),
    dict(dist_name='MRBTS-1900/NRBTS-3/NRCELL-1', list_name='fPdcchMonOccsnPo',
         elements=['154']),
]

PARAMS_TO_ADD_PEER_XN = [
    ADD_GNBADJGNB_XNLINK_OBJECT_PEER,
    PARAMS_TO_ADD_GNBADJGNB_PEER,
    ADD_GNBPLMN_MO_PEER,
    ADD_GNBPLMN_list_PEER,
    ADD_Elements_TO_List_PEER
]

PARAMS_NG_XN_PEER = [
    PARAMS_TO_DELETE_PEER,
    ADD_NG_XN_LIST_OB_PEER,
    ADD_NG_XN_ITEM_TO_LIST_PEER
]

AMOUNT_OF_CELLS = 1
