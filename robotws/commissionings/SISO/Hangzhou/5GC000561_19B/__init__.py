import os

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# number of active cells. The rest of the cells in the SCF will be deleted
AMOUNT_OF_CELLS = 1

# path to SCF file on OAM on gNb to be modified and commissioned
PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19A/SBTS5G19A_5g_716_9_AEUD.xml'

_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_p_name = 'dlFlowControlAlgo'

PARAMS_TO_DELETE = [
    dict(
        dist_name=_NRBTSname,
        p_name='sCCNumber'),
    dict(
        dist_name=_NRCELLname,
        list_name='beamSet',
        p_name='nrBtsBeamRefinementP2'),
    dict(
        dist_name=_NRCELLname,
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        dist_name=_NRCELLname,
        p_name='trackingAreaDN'),
    dict(
        dist_name='MRBTS-1900/EQM-1/SMOD_EXT-1',
        p_name=None),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1',
        p_name='btsSyncMode'),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/ECPRIMASTER-1',
        p_name=None),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1',
        p_name='timeZone'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1',
        p_name='speedAndDuplex'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-1',
        p_name='speedAndDuplex'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2',
        p_name='speedAndDuplex'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-1',
        p_name='speedAndDuplex'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-2',
        p_name='speedAndDuplex'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod')
]


PARAMS_TO_MODIFY = [
    dict(value='Nokia HZ Cloud-TL551', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='262', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='03', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='6000', dist_name=_NRBTSname, p_name='timerX2UeProcGuard'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name=_p_name),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name=_p_name),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name=_p_name),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name=_p_name),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name=_p_name),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name=_p_name),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name=_p_name),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab5', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab6', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab7', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab8', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_NRBTSname, list_name='fiveQiTab9', p_name=_p_name),
    dict(value='true', dist_name=_NRBTSname, p_name='actDlDataForwardingX2Limit'),
    dict(value='true', dist_name=_NRBTSname, p_name='actGeneralConnectivityBronze'),
    dict(value='250', dist_name=_NRCELLname, p_name='pMax'),
    dict(value='2076443', dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value='22464', dist_name=_NRCELLname, p_name='gscn'),
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='1', dist_name=_NRCELLname, p_name='frequencyDensityThresNrb0'),
    dict(value='1', dist_name=_NRCELLname, p_name='frequencyDensityThresNrb1'),
    dict(value='-86', dist_name=_NRCELLname, list_name='ulPowerControlCommon', p_name='p0NominalPusch'),
    dict(value='-80', dist_name=_NRCELLname, list_name='ulPowerControlCommon', p_name='p0NominalPucch'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-1', p_name='fiveGsTac'),
    dict(value='Nokia HZ', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='474608A', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='prodCodePlanned'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='5min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
    dict(value='5min', dist_name='MRBTS-1900/MNL-1/PMMNL-1', p_name='eCpriMasterStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/PMTNL-1', p_name='ipV4InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/PMTNL-1', p_name='ipV6InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/PMTNL-1', p_name='ipV4InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/PMTNL-1', p_name='ipV6InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/PMTNL-1', p_name='ipV4InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/PMTNL-1', p_name='ipV6InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-4/PMTNL-1', p_name='ipV4InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-4/PMTNL-1', p_name='ipV6InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-5/PMTNL-1', p_name='ipV4InterfaceStatisticsInterval'),
    dict(value='disabled', dist_name='MRBTS-1900/TNLSVC-1/TNL-5/PMTNL-1', p_name='ipV6InterfaceStatisticsInterval'),
    dict(value='172.18.5.30', dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='172.18.5.31', dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpAddr'),
    dict(value='172.18.5.32', dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpAddr')
]

OBJECTS_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1',
        class_name="com.nokia.srbts.tnl:IPRTV6",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/TIME-1',
        class_name="com.nokia.srbts.mnl:TIME",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        class_name="com.nokia.srbts.mnl:TOPP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
        class_name="com.nokia.srbts.mnl:TOP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1',
        class_name="com.nokia.srbts.mnl:CLOCK",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        class_name="com.nokia.srbts.mnl:SYNC",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCKSTATUS-1',
        class_name="com.nokia.srbts.mnl:CLOCKSTATUS",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        class_name="com.nokia.srbts.mnl:NTP",
        version="MNL5G19B_1910_100")
]

LIST_TO_CREATE = [
    dict(
        dist_name=_NRBTSname,
        list_name="mPlane"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="acceptedClockClass"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="topMasterList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name="targetDNList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name="ntpServerList"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        list_name="staticRoutes"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1',
        list_name="staticRoutes")
]

LIST_ITEM_TO_ADD = [
    dict(
        dist_name=_NRBTSname,
        list_name='mPlane',
        elements={'ipV4AddressDN1': 'MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3'}),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='topMasterList',
        elements={'phaseErrorComp': '0'}),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name='ntpServerList',
        elements={'ntpServerIpAddr': '10.171.8.4', 'ntpStatus': 'ntpOk'}),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={'destIpAddr': '0.0.0.0',
                  'destinationIpPrefixLength': '0',
                  'gateway': '10.57.159.129',
                  'preference': '1'}),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={'destIpAddr': '0.0.0.0',
                  'destinationIpPrefixLength': '0',
                  'gateway': '10.57.159.129',
                  'preference': '1'})
]

LIST_ELEMENT_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='acceptedClockClass',
        elements=['6', '7']),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name='targetDNList',
        elements=['MRBTS-1900/EQM-1/APEQM-1/RMOD-1'])
]

# parameters with value to add
PARAMS_TO_ADD = [
    dict(
        value='3',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='e1NbResetRetryForFault'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='timerX2DataFwdGuard'),
    dict(
        value='4477',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='configuredEpsTac'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1',
        p_name='actEcpriMasterClock'),
    dict(
        value='Disabled',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        p_name='outputConfiguration1Pps'),
    dict(
        value='Disabled',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        p_name='outputConfiguration2M048'),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1',
        p_name='sModDN'),
    dict(
        value='(GMT+8) Asia/Shanghai',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/TIME-1',
        p_name='timeZone'),
    dict(
        value='G.8275.1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        p_name='topStandardProfile'),
    dict(
        value='01-80-C2-00-00-0E',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        p_name='topEthMulticastAddress'),
    dict(
        value='24',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
        p_name='topDomainNumber'),
    dict(
        value='RU',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        p_name='profileType'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='F1-M',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='X2-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='F1-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='X2-U S1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='DISCOVERED',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='ipAddressAllocationMethod'),
    dict(
        value='F1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='10.10.10.10',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        value='24',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-5/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength')

]
