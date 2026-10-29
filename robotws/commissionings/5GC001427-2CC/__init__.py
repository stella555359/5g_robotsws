__maintainer__ = 'Zhao Nana'
__team__ = 'MN 5G RAN I&V  Line HZG 7 GMS'
__email__ = 'nana.zhao@nokia.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19A/SBTS5G19A_5g_1427_1_AEUB.xml'

PARAMS_TO_MODIFY = [
    dict(value='Nokia HGZ TL126', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='ASOD', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProductVariantPlanned'),
    dict(value='10.57.237.164', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='172.16.2.36',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='24',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(value='172.16.2.37',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpAddr'),
    dict(value='24',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpPrefixLength'),
    dict(value='172.16.2.35',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpAddr'),
    dict(value='24',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpPrefixLength'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='backhaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-1', p_name='underLyingInterface'),
    dict(value='fronthaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2', p_name='underLyingInterface'),
    dict(value='backhaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-1', p_name='underLyingInterface'),
    dict(value='fronthaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-2', p_name='underLyingInterface'),
    dict(value='474608A', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='prodCodePlanned'),
    dict(value='30', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='cableLength'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='frequencyDensityThresNrb0'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='frequencyDensityThresNrb1'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='type0CoresetConfigurationIndex'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='22452', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actCarrierAggregation'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab5',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab6',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab7',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab8',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab9',
         p_name='dlFlowControlAlgo'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='dllaIniMcs'),
    dict(value='16380', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='lcrId'),
    dict(value='2073115', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='200', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMax')
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1")
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
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        class_name="com.nokia.srbts.mnl:NTP",
        version="MNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        class_name="com.nokia.srbts.nrbts:NRCELL",
        version="NRBTS5G19A_1904_201"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1',
        class_name="com.nokia.srbts.nrbts:NRCELL_FDD",
        version="NRBTS5G19A_1904_201"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        class_name="com.nokia.srbts.tnl:IPRT",
        version="TNL5G19A_1904_200"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        class_name="com.nokia.srbts.tnl:IPRT",
        version="TNL5G19A_1904_200"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        class_name="com.nokia.srbts.nrbts:NRCELL",
        version="NRBTS5G19A_1904_201"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1',
        class_name="com.nokia.srbts.nrbts:NRCELL_FDD",
        version="NRBTS5G19A_1904_201"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        class_name="com.nokia.srbts.nrbts:NRCELL",
        version="NRBTS5G19A_1904_201"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1',
        class_name="com.nokia.srbts.nrbts:NRCELL_FDD",
        version="NRBTS5G19A_1904_201"),
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
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name="ntpServerList"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="a1MeashoSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="a1MeashoSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="a2MeasRedirectSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="a2MeasRedirectSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="a2MeashoSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="a2MeashoSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="beamSet"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="csirsForTracking"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="drxProfile1"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="fPdcchMonOccsnPo"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="rModDNList"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="tddFrameStructure"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name="ulPowerControlCommon"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="a1MeashoSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="a1MeashoSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="a2MeasRedirectSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="a2MeasRedirectSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="a2MeashoSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="a2MeashoSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="beamSet"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="csirsForTracking"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="drxProfile1"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="fPdcchMonOccsnPo"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="rModDNList"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="tddFrameStructure"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name="ulPowerControlCommon"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="a1MeashoSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="a1MeashoSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="a2MeasRedirectSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="a2MeasRedirectSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="a2MeashoSsbRsrp"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="a2MeashoSsbRsrq"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="beamSet"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="csirsForTracking"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="drxProfile1"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="fPdcchMonOccsnPo"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="rModDNList"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="tddFrameStructure"),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name="ulPowerControlCommon")
]

LIST_ITEM_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='topMasterList',
        elements={
            'phaseErrorComp': '0'}),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name='ntpServerList',
        elements={
            'ntpServerIpAddr': '10.171.8.4'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='a1MeashoSsbRsrp',
        elements={
            'a1HysteresishoSsbRsrp': '0',
            'a1ThresholdhoSsbRsrp': '34',
            'a1TimeToTriggerhoSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='a1MeashoSsbRsrq',
        elements={
            'a1HysteresishoSsbRsrq': '0',
            'a1ThresholdhoSsbRsrq': '31',
            'a1TimeToTriggerhoSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='a2MeasRedirectSsbRsrp',
        elements={
            'a2HysteresisRedirectSsbRsrp': '0',
            'a2ThresholdRedirectSsbRsrp': '34',
            'a2TimeToTriggerRedirectSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='a2MeasRedirectSsbRsrq',
        elements={
            'a2HysteresisRedirectSsbRsrq': '0',
            'a2ThresholdRedirectSsbRsrq': '49',
            'a2TimeToTriggerRedirectSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='a2MeashoSsbRsrp',
        elements={
            'a2HysteresishoSsbRsrp': '0',
            'a2ThresholdhoSsbRsrp': '34',
            'a2TimeToTriggerhoSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='a2MeashoSsbRsrq',
        elements={
            'a2HysteresishoSsbRsrq': '0',
            'a2ThresholdhoSsbRsrq': '31',
            'a2TimeToTriggerhoSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='beamSet',
        elements={
            'basicBeamSet': 'beamSetAbf_1A',
            'nrBtsBeamRefinementP2': 'false',
            'leftEdgeAngle': '60',
            'rightEdgeAngle': '60'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='csirsForTracking',
        elements={
            'csirsTrackingPeriod': '80ms'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='drxProfile1',
        elements={
            'drxInactivityTimer': '10ms',
            'drxLongCycle': '40ms',
            'drxOnDurationTimer': '10ms',
            'drxRetransTimerDl': '8slot',
            'drxRetransTimerUl': '8slot'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='tddFrameStructure',
        elements={
            'frameStructureType': 'semiStatic',
            'guardPeriodLength': '2Symbols',
            'lteToNrFrameShift': '0ms',
            'ulDlDataSlotRatio': '1/4'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='ulPowerControlCommon',
        elements={
            'actUlOpenLoopPwrCtrl': 'true',
            'alpha': 'al1',
            'alphaSrs': 'alpha1',
            'p0NominalPusch': '-72',
            'p0NominalPucch': '-108',
            'p0NominalSrs': '-72'}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
            "destIpAddr": "0.0.0.0",
            "destinationIpPrefixLength": "0",
            "gateway": "10.57.250.129",
            "preference": "1"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
              "destIpAddr": "0.0.0.0",
              "destinationIpPrefixLength": "0",
              "gateway": "10.57.250.129",
              "preference": "1"}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='a1MeashoSsbRsrp',
        elements={
            'a1HysteresishoSsbRsrp': '0',
            'a1ThresholdhoSsbRsrp': '34',
            'a1TimeToTriggerhoSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='a1MeashoSsbRsrq',
        elements={
            'a1HysteresishoSsbRsrq': '0',
            'a1ThresholdhoSsbRsrq': '31',
            'a1TimeToTriggerhoSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='a2MeasRedirectSsbRsrp',
        elements={
            'a2HysteresisRedirectSsbRsrp': '0',
            'a2ThresholdRedirectSsbRsrp': '34',
            'a2TimeToTriggerRedirectSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='a2MeasRedirectSsbRsrq',
        elements={
            'a2HysteresisRedirectSsbRsrq': '0',
            'a2ThresholdRedirectSsbRsrq': '49',
            'a2TimeToTriggerRedirectSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='a2MeashoSsbRsrp',
        elements={
            'a2HysteresishoSsbRsrp': '0',
            'a2ThresholdhoSsbRsrp': '34',
            'a2TimeToTriggerhoSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='a2MeashoSsbRsrq',
        elements={
            'a2HysteresishoSsbRsrq': '0',
            'a2ThresholdhoSsbRsrq': '31',
            'a2TimeToTriggerhoSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='beamSet',
        elements={
            'basicBeamSet': 'beamSetAbf_1A',
            'nrBtsBeamRefinementP2': 'false',
            'leftEdgeAngle': '60',
            'rightEdgeAngle': '60'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='csirsForTracking',
        elements={
            'csirsTrackingPeriod': '80ms'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='drxProfile1',
        elements={
            'drxInactivityTimer': '10ms',
            'drxLongCycle': '40ms',
            'drxOnDurationTimer': '10ms',
            'drxRetransTimerDl': '8slot',
            'drxRetransTimerUl': '8slot'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='tddFrameStructure',
        elements={
            'frameStructureType': 'semiStatic',
            'guardPeriodLength': '2Symbols',
            'lteToNrFrameShift': '0ms',
            'ulDlDataSlotRatio': '1/4'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='ulPowerControlCommon',
        elements={
            'actUlOpenLoopPwrCtrl': 'true',
            'alpha': 'al1',
            'alphaSrs': 'alpha1',
            'p0NominalPusch': '-72',
            'p0NominalPucch': '-108',
            'p0NominalSrs': '-72'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='a1MeashoSsbRsrp',
        elements={
            'a1HysteresishoSsbRsrp': '0',
            'a1ThresholdhoSsbRsrp': '34',
            'a1TimeToTriggerhoSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='a1MeashoSsbRsrq',
        elements={
            'a1HysteresishoSsbRsrq': '0',
            'a1ThresholdhoSsbRsrq': '31',
            'a1TimeToTriggerhoSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='a2MeasRedirectSsbRsrp',
        elements={
            'a2HysteresisRedirectSsbRsrp': '0',
            'a2ThresholdRedirectSsbRsrp': '34',
            'a2TimeToTriggerRedirectSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='a2MeasRedirectSsbRsrq',
        elements={
            'a2HysteresisRedirectSsbRsrq': '0',
            'a2ThresholdRedirectSsbRsrq': '49',
            'a2TimeToTriggerRedirectSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='a2MeashoSsbRsrp',
        elements={
            'a2HysteresishoSsbRsrp': '0',
            'a2ThresholdhoSsbRsrp': '34',
            'a2TimeToTriggerhoSsbRsrp': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='a2MeashoSsbRsrq',
        elements={
            'a2HysteresishoSsbRsrq': '0',
            'a2ThresholdhoSsbRsrq': '31',
            'a2TimeToTriggerhoSsbRsrq': 'ms480'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='beamSet',
        elements={
            'basicBeamSet': 'beamSetAbf_1A',
            'nrBtsBeamRefinementP2': 'false',
            'leftEdgeAngle': '60',
            'rightEdgeAngle': '60'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='csirsForTracking',
        elements={
            'csirsTrackingPeriod': '80ms'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='drxProfile1',
        elements={
            'drxInactivityTimer': '10ms',
            'drxLongCycle': '40ms',
            'drxOnDurationTimer': '10ms',
            'drxRetransTimerDl': '8slot',
            'drxRetransTimerUl': '8slot'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='tddFrameStructure',
        elements={
            'frameStructureType': 'semiStatic',
            'guardPeriodLength': '2Symbols',
            'lteToNrFrameShift': '0ms',
            'ulDlDataSlotRatio': '1/4'}),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='ulPowerControlCommon',
        elements={
            'actUlOpenLoopPwrCtrl': 'true',
            'alpha': 'al1',
            'alphaSrs': 'alpha1',
            'p0NominalPusch': '-72',
            'p0NominalPucch': '-108',
            'p0NominalSrs': '-72'})
    ]

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
        elements=['MRBTS-1900/EQM-1/APEQM-1/RMOD-1']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='rModDNList',
        elements=['MRBTS-1900/EQM-1/APEQM-1/RMOD-1']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0',
        list_name='nrCellList',
        elements=['2']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='rModDNList',
        elements=['MRBTS-1900/EQM-1/APEQM-1/RMOD-1']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0',
        list_name='nrCellList',
        elements=['3']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='rModDNList',
        elements=['MRBTS-1900/EQM-1/APEQM-1/RMOD-1']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0',
        list_name='nrCellList',
        elements=['4'])
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
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='a1MeashoEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='a2MeasRedirectEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='a2MeashoEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='actBeamforming'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='actCDrx'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='actDl256Qam'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='actDlMuMimo'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='actDynUlDataSplitMode'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='actEirpControl'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='actSUL'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='actUlMuMimo'),
    dict(
        value='Unlocked',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='administrativeState'),
    dict(
        value='4CCEs',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='aggregationLevel'),
    dict(
        value='report',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='beamManagementType'),
    dict(
        value='n64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='cbraPreamblesPerSsb'),
    dict(
        value='notBarred',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='cellBarred'),
    dict(
        value='initCellName2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='cellName'),
    dict(
        value='notReserved',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='cellReservedForOperatorUse'),
    dict(
        value='FALSE',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='cellReservedForOtherUse'),
    dict(
        value='TDD',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='cellTechnology'),
    dict(
        value='100MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='chBw'),
    dict(
        value='4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dciSiAggregationLevel'),
    dict(
        value='Automatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dlDMRSAdditionalPosition'),
    dict(
        value='2x2 Closed Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dlMimoMode'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dlMuMaxNumPairedUEs'),
    dict(
        value='15',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dlQam256PowerBackoffSub6'),
    dict(
        value='10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dllaBlerTarget'),
    dict(
        value='30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dllaDeltaCqiMax'),
    dict(
        value='-30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dllaDeltaCqiMin'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dllaDeltaCqiStepdown'),
    dict(
        value='pos3',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dmrsTypeAPosition'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='drxWactDlEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='drxWactUlEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='enDcSyncStatus'),
    dict(
        value='15km',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='expectedCellSize'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='fiveGsTac'),
    dict(
        value='257',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='freqBandIndicatorNR'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='frequencyDensityThresNrb0'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='frequencyDensityThresNrb1'),
    dict(
        value='22458',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='gscn'),
    dict(
        value='-104',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='initialPreambleReceivedTargetPower'),
    dict(
        value='allowed',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='intraFreqReselection'),
    dict(
        value='16381',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='lcrId'),
    dict(
        value='500',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='maxNumOfNonGBRBearersSA'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='maxNumOfRrcSA'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='maxNumOfSCellAlloc'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='maxNumOfUsersPerCell'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='mcsIndexForArtificialLoad'),
    dict(
        value='n2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='modPeriodCoeff'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='msg1FrequencyStart'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='msg3DeltaPreamble'),
    dict(
        value='n10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='n310'),
    dict(
        value='n1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='n311'),
    dict(
        value='one',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='nbrOfSsbPerRachOccasion'),
    dict(
        value='2DL0UL',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='nrCellType'),
    dict(
        value='2074779',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='nrarfcn'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='nrofHARQProcessesForPDSCH'),
    dict(
        value='halfT',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='numOfPagingFrames'),
    dict(
        value='one',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='numPagingOccsnPagingFrame'),
    dict(
        value='200',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='pMax'),
    dict(
        value='20',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='pMaxNROwnCell'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='pagingOffset'),
    dict(
        value='51',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='physCellId'),
    dict(
        value='dB2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='powerRampingStep'),
    dict(
        value='dB2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='powerRampingStepHighPriorityCfra'),
    dict(
        value='38',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='prachConfigurationIndex'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='prachRootSequenceIndex'),
    dict(
        value='Unrestricted',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='prachSequenceType'),
    dict(
        value='n10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='preambleTransMax'),
    dict(
        value='100',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='100',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='-65',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='qRxLevMin'),
    dict(
        value='sf64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='raContentionResolutionTmr'),
    dict(
        value='sl80',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='raResponseWindow'),
    dict(
        value='2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='rloConsecDtxThreshold'),
    dict(
        value='50',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='rloDtxRatioThreshold'),
    dict(
        value='130',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='rloPathLossThreshold'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='rloSinrThreshold'),
    dict(
        value='11',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='rsrpThresholdSSB'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ssPbchBlockPower'),
    dict(
        value='240 KHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ssbScs'),
    dict(
        value='sf1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ssbSmtc1Duration'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ssbSmtc1Offset'),
    dict(
        value='sf5',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ssbSmtc1Periodicity'),
    dict(
        value='400ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='t300'),
    dict(
        value='400ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='t301'),
    dict(
        value='2000ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='t310'),
    dict(
        value='3000ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='t311'),
    dict(
        value='0Percent',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='targetSUOMeNBULSubframes'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='targetTotalLoad'),
    dict(
        value='n13792',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='timingAdvanceOffset'),
    dict(
        value='64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='totalNumberOfRAPreambles'),
    dict(
        value='MRBTS-1900/NRBTS-1/TRACKINGAREA-1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='trackingAreaDN'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='type0CoresetConfigurationIndex'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='type0SearchSpaceConfigurationIndex'),
    dict(
        value='Automatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ulDMRSAdditionalPosition'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ulMimoMode'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ulMuMaxNumPairedUEs'),
    dict(
        value='10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ullaBlerTarget'),
    dict(
        value='30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ullaDeltaSinrMax'),
    dict(
        value='-30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ullaDeltaSinrMin'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ullaDeltaSinrStepdown'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='ullaIniMcs'),
    dict(
        value='13',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='zeroCorrelationZoneConfig'),
    dict(
        value='5MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value='5MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1',
        p_name='nrarfcnDl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1',
        p_name='nrarfcnUl'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='maxNumScellsDl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='maxNumScellsUl'),
    dict(
        value='blind',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='sCellActivationMethod'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='dllaIniMcs'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='a1MeashoEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='a2MeasRedirectEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='a2MeashoEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='actBeamforming'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='actCDrx'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='actDl256Qam'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='actDlMuMimo'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='actDynUlDataSplitMode'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='actEirpControl'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='actSUL'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='actUlMuMimo'),
    dict(
        value='Unlocked',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='administrativeState'),
    dict(
        value='4CCEs',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='aggregationLevel'),
    dict(
        value='report',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='beamManagementType'),
    dict(
        value='n64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='cbraPreamblesPerSsb'),
    dict(
        value='notBarred',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='cellBarred'),
    dict(
        value='initCellName3',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='cellName'),
    dict(
        value='notReserved',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='cellReservedForOperatorUse'),
    dict(
        value='FALSE',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='cellReservedForOtherUse'),
    dict(
        value='TDD',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='cellTechnology'),
    dict(
        value='100MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='chBw'),
    dict(
        value='4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dciSiAggregationLevel'),
    dict(
        value='Automatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dlDMRSAdditionalPosition'),
    dict(
        value='2x2 Closed Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dlMimoMode'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dlMuMaxNumPairedUEs'),
    dict(
        value='15',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dlQam256PowerBackoffSub6'),
    dict(
        value='10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dllaBlerTarget'),
    dict(
        value='30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dllaDeltaCqiMax'),
    dict(
        value='-30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dllaDeltaCqiMin'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dllaDeltaCqiStepdown'),
    dict(
        value='pos3',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dmrsTypeAPosition'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='drxWactDlEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='drxWactUlEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='enDcSyncStatus'),
    dict(
        value='15km',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='expectedCellSize'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='fiveGsTac'),
    dict(
        value='257',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='freqBandIndicatorNR'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='frequencyDensityThresNrb0'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='frequencyDensityThresNrb1'),
    dict(
        value='22464',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='gscn'),
    dict(
        value='-104',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='initialPreambleReceivedTargetPower'),
    dict(
        value='allowed',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='intraFreqReselection'),
    dict(
        value='16382',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='lcrId'),
    dict(
        value='500',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='maxNumOfNonGBRBearersSA'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='maxNumOfRrcSA'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='maxNumOfSCellAlloc'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='maxNumOfUsersPerCell'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='mcsIndexForArtificialLoad'),
    dict(
        value='n2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='modPeriodCoeff'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='msg1FrequencyStart'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='msg3DeltaPreamble'),
    dict(
        value='n10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='n310'),
    dict(
        value='n1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='n311'),
    dict(
        value='one',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='nbrOfSsbPerRachOccasion'),
    dict(
        value='2DL0UL',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='nrCellType'),
    dict(
        value='2076443',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='nrarfcn'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='nrofHARQProcessesForPDSCH'),
    dict(
        value='halfT',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='numOfPagingFrames'),
    dict(
        value='one',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='numPagingOccsnPagingFrame'),
    dict(
        value='200',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='pMax'),
    dict(
        value='20',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='pMaxNROwnCell'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='pagingOffset'),
    dict(
        value='52',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='physCellId'),
    dict(
        value='dB2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='powerRampingStep'),
    dict(
        value='dB2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='powerRampingStepHighPriorityCfra'),
    dict(
        value='38',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='prachConfigurationIndex'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='prachRootSequenceIndex'),
    dict(
        value='Unrestricted',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='prachSequenceType'),
    dict(
        value='n10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='preambleTransMax'),
    dict(
        value='100',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='100',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='-65',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='qRxLevMin'),
    dict(
        value='sf64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='raContentionResolutionTmr'),
    dict(
        value='sl80',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='raResponseWindow'),
    dict(
        value='2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='rloConsecDtxThreshold'),
    dict(
        value='50',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='rloDtxRatioThreshold'),
    dict(
        value='130',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='rloPathLossThreshold'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='rloSinrThreshold'),
    dict(
        value='11',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='rsrpThresholdSSB'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ssPbchBlockPower'),
    dict(
        value='240 KHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ssbScs'),
    dict(
        value='sf1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ssbSmtc1Duration'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ssbSmtc1Offset'),
    dict(
        value='sf5',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ssbSmtc1Periodicity'),
    dict(
        value='400ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='t300'),
    dict(
        value='400ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='t301'),
    dict(
        value='2000ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='t310'),
    dict(
        value='3000ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='t311'),
    dict(
        value='0Percent',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='targetSUOMeNBULSubframes'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='targetTotalLoad'),
    dict(
        value='n13792',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='timingAdvanceOffset'),
    dict(
        value='64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='totalNumberOfRAPreambles'),
    dict(
        value='MRBTS-1900/NRBTS-1/TRACKINGAREA-1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='trackingAreaDN'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='type0CoresetConfigurationIndex'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='type0SearchSpaceConfigurationIndex'),
    dict(
        value='Automatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ulDMRSAdditionalPosition'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ulMimoMode'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ulMuMaxNumPairedUEs'),
    dict(
        value='10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ullaBlerTarget'),
    dict(
        value='30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ullaDeltaSinrMax'),
    dict(
        value='-30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ullaDeltaSinrMin'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ullaDeltaSinrStepdown'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='ullaIniMcs'),
    dict(
        value='13',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='zeroCorrelationZoneConfig'),
    dict(
        value='5MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value='5MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1',
        p_name='nrarfcnDl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1',
        p_name='nrarfcnUl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='dllaIniMcs'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='a1MeashoEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='a2MeasRedirectEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='a2MeashoEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='actBeamforming'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='actCDrx'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='actDl256Qam'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='actDlMuMimo'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='actDynUlDataSplitMode'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='actEirpControl'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='actSUL'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='actUlMuMimo'),
    dict(
        value='Unlocked',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='administrativeState'),
    dict(
        value='4CCEs',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='aggregationLevel'),
    dict(
        value='report',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='beamManagementType'),
    dict(
        value='n64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='cbraPreamblesPerSsb'),
    dict(
        value='notBarred',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='cellBarred'),
    dict(
        value='initCellName4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='cellName'),
    dict(
        value='notReserved',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='cellReservedForOperatorUse'),
    dict(
        value='FALSE',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='cellReservedForOtherUse'),
    dict(
        value='TDD',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='cellTechnology'),
    dict(
        value='100MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='chBw'),
    dict(
        value='4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dciSiAggregationLevel'),
    dict(
        value='Automatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dlDMRSAdditionalPosition'),
    dict(
        value='2x2 Closed Loop Spatial Multiplexing',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dlMimoMode'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dlMuMaxNumPairedUEs'),
    dict(
        value='15',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dlQam256PowerBackoffSub6'),
    dict(
        value='10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dllaBlerTarget'),
    dict(
        value='30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dllaDeltaCqiMax'),
    dict(
        value='-30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dllaDeltaCqiMin'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dllaDeltaCqiStepdown'),
    dict(
        value='pos3',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dmrsTypeAPosition'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='drxWactDlEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='drxWactUlEnabled'),
    dict(
        value='none',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='enDcSyncStatus'),
    dict(
        value='15km',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='expectedCellSize'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='fiveGsTac'),
    dict(
        value='257',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='freqBandIndicatorNR'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='frequencyDensityThresNrb0'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='frequencyDensityThresNrb1'),
    dict(
        value='22470',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='gscn'),
    dict(
        value='-104',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='initialPreambleReceivedTargetPower'),
    dict(
        value='allowed',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='intraFreqReselection'),
    dict(
        value='16383',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='lcrId'),
    dict(
        value='500',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='maxNumOfNonGBRBearersSA'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='maxNumOfRrcSA'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='maxNumOfSCellAlloc'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='maxNumOfUsersPerCell'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='mcsIndexForArtificialLoad'),
    dict(
        value='n2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='modPeriodCoeff'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='msg1FrequencyStart'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='msg3DeltaPreamble'),
    dict(
        value='n10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='n310'),
    dict(
        value='n1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='n311'),
    dict(
        value='one',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='nbrOfSsbPerRachOccasion'),
    dict(
        value='2DL0UL',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='nrCellType'),
    dict(
        value='2078107',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='nrarfcn'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='nrofHARQProcessesForPDSCH'),
    dict(
        value='halfT',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='numOfPagingFrames'),
    dict(
        value='one',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='numPagingOccsnPagingFrame'),
    dict(
        value='200',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='pMax'),
    dict(
        value='20',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='pMaxNROwnCell'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='pagingOffset'),
    dict(
        value='53',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='physCellId'),
    dict(
        value='dB2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='powerRampingStep'),
    dict(
        value='dB2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='powerRampingStepHighPriorityCfra'),
    dict(
        value='38',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='prachConfigurationIndex'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='prachRootSequenceIndex'),
    dict(
        value='Unrestricted',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='prachSequenceType'),
    dict(
        value='n10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='preambleTransMax'),
    dict(
        value='100',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='100',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='-65',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='qRxLevMin'),
    dict(
        value='sf64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='raContentionResolutionTmr'),
    dict(
        value='sl80',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='raResponseWindow'),
    dict(
        value='2',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='rloConsecDtxThreshold'),
    dict(
        value='50',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='rloDtxRatioThreshold'),
    dict(
        value='130',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='rloPathLossThreshold'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='rloSinrThreshold'),
    dict(
        value='11',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='rsrpThresholdSSB'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ssPbchBlockPower'),
    dict(
        value='240 KHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ssbScs'),
    dict(
        value='sf1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ssbSmtc1Duration'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ssbSmtc1Offset'),
    dict(
        value='sf5',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ssbSmtc1Periodicity'),
    dict(
        value='400ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='t300'),
    dict(
        value='400ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='t301'),
    dict(
        value='2000ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='t310'),
    dict(
        value='3000ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='t311'),
    dict(
        value='0Percent',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='targetSUOMeNBULSubframes'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='targetTotalLoad'),
    dict(
        value='n13792',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='timingAdvanceOffset'),
    dict(
        value='64',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='totalNumberOfRAPreambles'),
    dict(
        value='MRBTS-1900/NRBTS-1/TRACKINGAREA-1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='trackingAreaDN'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='type0CoresetConfigurationIndex'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='type0SearchSpaceConfigurationIndex'),
    dict(
        value='Automatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ulDMRSAdditionalPosition'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ulMimoMode'),
    dict(
        value='8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ulMuMaxNumPairedUEs'),
    dict(
        value='10',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ullaBlerTarget'),
    dict(
        value='30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ullaDeltaSinrMax'),
    dict(
        value='-30',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ullaDeltaSinrMin'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ullaDeltaSinrStepdown'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='ullaIniMcs'),
    dict(
        value='13',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='zeroCorrelationZoneConfig'),
    dict(
        value='5MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1',
        p_name='chBwDl'),
    dict(
        value='5MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1',
        p_name='chBwUl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1',
        p_name='nrarfcnDl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1',
        p_name='nrarfcnUl'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='dllaIniMcs'),
]
