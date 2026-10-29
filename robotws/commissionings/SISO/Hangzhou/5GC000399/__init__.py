import os

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# number of active cells. The rest of the cells in the SCF will be deleted
AMOUNT_OF_CELLS = 1

# path to SCF file on OAM on gNb to be modified and commissioned
PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19A/SBTS5G19A_5g_716_9_AEUB.xml'

_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_p_name = 'dlFlowControlAlgo'

PARAMS_TO_DELETE = [
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpAddr')
]

PARAMS_TO_MODIFY = [
    dict(value='Hangzhou_TL076', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='262', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='03', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab5', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab6', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab7', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab8', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab9', p_name=_p_name),
    dict(value='2076443', dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value=1, dist_name=_NRCELLname, p_name='gscn'),
    dict(value=0, dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value=1, dist_name=_NRCELLname, p_name='frequencyDensityThresNrb0'),
    dict(value=1, dist_name=_NRCELLname, p_name='frequencyDensityThresNrb1'),
    dict(value='Nokia HZ', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='172.16.1.30', dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='172.16.1.31', dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpAddr'),
    dict(value='172.16.1.32', dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpAddr'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod')
]

OBJECTS_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/TIME-1',
        class_name="com.nokia.srbts.mnl:TIME",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        class_name="com.nokia.srbts.mnl:TOPP",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
        class_name="com.nokia.srbts.mnl:TOP",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1',
        class_name="com.nokia.srbts.mnl:CLOCK",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        class_name="com.nokia.srbts.mnl:SYNC",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/MPLANENW-1',
        class_name="com.nokia.srbts.mnl:MPLANENW",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/MPLANENW-1',
        class_name="com.nokia.srbts.mnl:MPLANENW",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        class_name="com.nokia.srbts.mnl:NTP",
        version="MNL5G19A_1904_200")
]

LIST_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name="targetDNList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="acceptedClockClass"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="topMasterList"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        list_name="staticRoutes"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name="ntpServerList")
]

LIST_ITEM_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='topMasterList',
        elements={
            'phaseErrorComp': '0'}),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={
            'destIpAddr': '10.57.229.0',
            'destinationIpPrefixLength': '24',
            'gateway': '10.57.173.129',
            'preference': '1'}),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name='ntpServerList',
        elements={
            'ntpServerIpAddr': '10.56.126.22'})]

LIST_ELEMENT_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='acceptedClockClass',
        elements=[
            6,
            7]),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name='targetDNList',
        elements=['MRBTS-1900/EQM-1/APEQM-1/RMOD-1'])
]

# parameters with value to add
PARAMS_TO_ADD = [
    dict(
        value='G.8275.1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        p_name='topStandardProfile'),
    dict(
        value='01-80-C2-00-00-0E',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        p_name='topEthMulticastAddress'),
    dict(
        value=24,
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
        p_name='topDomainNumber'),
    dict(
        value='RU',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        p_name='profileType'),
    dict(
        value='F1-M',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='X2-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='F1-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='X2-U S1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='F1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='off',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/MPLANENW-1',
        p_name='oamTls'),
    dict(
        value='off',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/MPLANENW-1',
        p_name='oamTls')
]
