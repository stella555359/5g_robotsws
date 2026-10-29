__maintainer__ = 'Li Tao 12'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS'
__email__ = ''

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19B/SBTS5G19B_5g_1595_B_AEWF.xml'


PARAMS_TO_MODIFY = [
    dict(
        value='Nokia_HZSG3_mmW_TL911',
        dist_name='MRBTS-1900',
        p_name='btsName'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1',
        p_name='actPdlRuleValidation'),
    dict(value='27',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1',
        p_name='systemAcctPermEnable'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1',
        p_name='systemAcctPermEnable'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1',
        p_name='actServiceAccountSsh'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1',
        p_name='actServiceAccountSsh'),
    dict(
        value='474612A',
        dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1',
        p_name='prodCodePlanned'),
    dict(
        value='2249947',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='nrarfcn'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='physCellId'),
    dict(
        value='260',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='freqBandIndicatorNR'),
    dict(
        value='2251675',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='nrarfcn'),
    dict(
        value='2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='physCellId'),
    dict(
        value='260',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='freqBandIndicatorNR'),
    dict(
        value='2253403',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='nrarfcn'),
    dict(
        value='3',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='physCellId'),
    dict(
        value='260',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='freqBandIndicatorNR'),
    dict(
        value='2255131',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='nrarfcn'),
    dict(
        value='4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='physCellId'),
    dict(
        value='260',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='freqBandIndicatorNR'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
         dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Mplane', p_name='ipV4AddressDN1'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
         dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Uplane', p_name='ipV4AddressDN1'),
    dict(
        value='SFP',
        dist_name='MRBTS-1900/EQM-1/HWTOP-1/CABLINK-1',
        p_name='firstEndpointLabel'),
    dict(
        value='3',
        dist_name='MRBTS-1900/EQM-1/HWTOP-1/CABLINK-1',
        p_name='firstEndpointPortId'),
    dict(
        value='eCpri25',
        dist_name='MRBTS-1900/EQM-1/HWTOP-1/CABLINK-1',
        p_name='linkSpeed'),
    dict(
        value='SFP',
        dist_name='MRBTS-1900/EQM-1/HWTOP-1/CABLINK-1',
        p_name='secondEndpointLabel'),
    dict(value='TOPP',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1', list_name='syncInputList', p_name='syncInputType')

]

PARAMS_TO_DELETE = [
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3")

]

OBJECTS_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1',
        class_name="com.nokia.srbts.mnl:TOP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        class_name="com.nokia.srbts.mnl:TOPP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        class_name="com.nokia.srbts.tnl:IPRT",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1",
        class_name="com.nokia.srbts.tnl:IPRT",
        version="TNL5G19B_1911_100")

]

LIST_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        list_name="acceptedClockClass"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        list_name="topMasterList"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1",
        list_name="staticRoutes"),


]


LIST_ELEMENT_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        list_name='acceptedClockClass',
        elements=[
            6,
            7,
            13,
            14])

]

PARAMS_TO_ADD_ITEM_TO_LIST = [
    dict(
        value='128',
        dist_name='MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1', list_name='topMasterList',
        p_name="localPriority", version='MNL5G19B_1910_100'),
    dict(
        value='10.57.249.62',
        dist_name='MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        list_name='topMasterList', p_name="masterIpAddr", version='MNL5G19B_1910_100'),
    dict(
        value='0',
        dist_name='MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        list_name='topMasterList', p_name="maximumNetworkTimingError", version='MNL5G19B_1910_100'),
    dict(
        value='0',
        dist_name='MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1', list_name='topMasterList',
        p_name="phaseErrorComp", version='MNL5G19B_1910_100')

]

# parameters with value to add
PARAMS_TO_ADD = [
    dict(
        value='46',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1',
        p_name='sPlaneDscp'),
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1',
        p_name='sPlaneIpAddressDN'),
    dict(
        value='0',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1',
        p_name='topDomainNumber'),
    dict(
        value='RATE_128',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        p_name='syncMessageRate'),
    dict(
        value='Telecom2008',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        p_name='topStandardProfile')

]
