__maintainer__ = 'Feng Rita'
__team__ = 'I_NSB_MN_CRAN_PZ_CBTS_SOL6_VRF_GMS'
__email__ = 'rita.feng@nokia.sbell.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19A/SBTS5G19B_5g_1595_A_AEUA.xml'

PARAMS_TO_MODIFY = [
    dict(value='VCP-5gCloud-CBTS4',
         dist_name='MRBTS-3239',
         p_name='btsName'),
    dict(value='AirScaleSubRack',
         dist_name='MRBTS-3239/EQM-1/APEQM-1',
         p_name='rapProductVariantPlanned'),
    dict(dist_name='MRBTS-3239/EQM-1/APEQM-1',
         p_name='rapProfile',
         value='5G19/5g_pid11_abil_l2rt_eoc'),
    dict(dist_name='MRBTS-3239/NRBTS-1/NRCELL-1',
         p_name='nrarfcn',
         value='2059003'),
    dict(value='192.129.20.206',
         dist_name='MRBTS-3239/NRBTS-1/SERVEDAMF-1',
         p_name='amfIPAddress'),
    dict(value='10.57.229.135',
         dist_name='MRBTS-3239/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='localIpAddr'),
    dict(value='false',
         dist_name='MRBTS-3239/MNL-1/MNLENT-1/SECADM-1',
         p_name='ethernetPortSecurityEnabled'),
    dict(value='false',
         dist_name='MRBTS-3239/MNL-1/MNLENT-2/SECADM-1',
         p_name='ethernetPortSecurityEnabled'),
    dict(value='27',
         dist_name='MRBTS-3239/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='localIpPrefixLength'),
    dict(value='10.57.229.135',
         dist_name='MRBTS-3239/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='localIpAddr'),
    dict(value='true',
         dist_name='MRBTS-3239/MNL-1/MNLENT-1/SECADM-1',
         p_name='actServiceAccountSsh'),
    dict(value='true',
         dist_name='MRBTS-3239/MNL-1/MNLENT-2/SECADM-1',
         p_name='actServiceAccountSsh'),
    dict(value='false',
         dist_name='MRBTS-3239/MNL-1/MNLENT-1/FEATCADM-1',
         p_name='systemAcctPermEnable'),
    dict(value='false',
         dist_name='MRBTS-3239/MNL-1/MNLENT-2/FEATCADM-1',
         p_name='systemAcctPermEnable'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='qciTab6Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='qciTab5Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='qciTab69Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='qciTab70Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='qciTab79Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='qciTab7Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='qciTab8Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='qciTab9Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='fiveQiTab5',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='fiveQiTab6',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='fiveQiTab7',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='fiveQiTab8',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl',
         dist_name='MRBTS-3239/NRBTS-1',
         list_name='fiveQiTab9',
         p_name='dlFlowControlAlgo'),
    dict(value='22446', dist_name='MRBTS-3239/NRBTS-1/NRCELL-1',
         p_name='gscn'),
    dict(value='15min', dist_name='MRBTS-3239/MNL-1/PMCADM-1',
         p_name='reportingIntervalPm'),
    dict(
        value='MRBTS-3239/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
        dist_name='MRBTS-3239/NRBTS-1/NRDU-1',
        list_name='f1Mplane',
        p_name='ipV4AddressDN1'),
    dict(value='MRBTS-3239/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
         dist_name='MRBTS-3239/NRBTS-1/NRDU-1',
         list_name='f1Uplane',
         p_name='ipV4AddressDN1')
    ]

LIST_TO_CREATE = [
    dict(
        dist_name="MRBTS-3239/TNLSVC-1/TNL-1/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-3239/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-3239/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-3239/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes")
]

LIST_ITEM_TO_ADD = [
    dict(
        dist_name='MRBTS-3239/TNLSVC-1/TNL-1/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={
            'destIpAddr': '10.57.229.128',
            'destinationIpPrefixLength': '27',
            'gateway': '10.107.50.1',
            'preference': '1'}),
    dict(
        dist_name='MRBTS-3239/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={
            'destIpAddr': '10.57.229.128',
            'destinationIpPrefixLength': '27',
            'gateway': '10.107.54.129',
            'preference': '1'}),
    dict(
        dist_name='MRBTS-3239/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={
            'destIpAddr': '10.57.237.128',
            'destinationIpPrefixLength': '27',
            'gateway': '10.107.54.1',
            'preference': '1'}),
    dict(
        dist_name='MRBTS-3239/TNLSVC-1/TNL-3/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={
            'destIpAddr': '10.57.229.128',
            'destinationIpPrefixLength': '27',
            'gateway': '10.107.54.129',
            'preference': '1'}),
    dict(
        dist_name='MRBTS-3239/TNLSVC-1/TNL-3/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={
            'destIpAddr': '10.57.237.128',
            'destinationIpPrefixLength': '27',
            'gateway': '10.107.54.1',
            'preference': '1'}),
    dict(
        dist_name='MRBTS-3239/TNLSVC-1/TNL-4/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={
            'destIpAddr': '10.0.0.0',
            'destinationIpPrefixLength': '8',
            'gateway': '10.57.229.129',
            'preference': '1'})
]

PARAMS_TO_ADD = [
    dict(value='Main', dist_name='MRBTS-3239/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='userLabel'),
    dict(value='CPIF_Main', dist_name='MRBTS-3239/TNLSVC-1/TNL-2/IPNO-1/IPRT-1', p_name='userLabel'),
    dict(value='UPUE_Main', dist_name='MRBTS-3239/TNLSVC-1/TNL-3/IPNO-1/IPRT-1', p_name='userLabel'),
    dict(value='DU1_Main', dist_name='MRBTS-3239/TNLSVC-1/TNL-2/IPNO-1/IPRT-1', p_name='userLabel')
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2'),
    dict(dist_name='MRBTS-3239/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-3239/NRBTS-1/NRCELL-2')
]

AMOUNT_OF_CELLS = 1
