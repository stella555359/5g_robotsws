__maintainer__ = 'Zhao Nana'
__team__ = 'MN 5G RAN I&V  Line HZG 7 GMS'
__email__ = 'nana.zhao@nokia.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19B/SBTS5G19B_5g_1596_G_AEWB_ASOD.xml'


PARAMS_TO_MODIFY = [
    dict(value='Nokia HGZ TL327', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='ASOD', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProductVariantPlanned'),
    dict(value='10.1.1.1', dist_name='MRBTS-1900/NRBTS-1/SERVEDAMF-1', p_name='amfIPAddress'),
    dict(value='10.68.90.47',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpAddr'),
    dict(value='27',
         dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='false',
         dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='backhaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-1', p_name='underLyingInterface'),
    dict(value='fronthaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2', p_name='underLyingInterface'),
    dict(value='backhaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-1', p_name='underLyingInterface'),
    dict(value='fronthaul', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-2', p_name='underLyingInterface'),
    dict(value='475019A', dist_name='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1', p_name='prodCodePlanned'),
    dict(value='474611A', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='prodCodePlanned'),
    dict(value='30', dist_name='MRBTS-1900/EQM-1/APEQM-1/RMOD-1', p_name='cableLength'),
    dict(value='277', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='frequencyDensityThresNrb0'),
    dict(value='277', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='frequencyDensityThresNrb1'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='type0CoresetConfigurationIndex'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn'),
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
    dict(value='false', dist_name='MRBTS-1900/NRBTS-1', p_name='actCarrierAggregation'),
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
    dict(value='262', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='3', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='mncLength'),
    dict(value='3', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='dllaIniMcs'),
    dict(value='16373', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='lcrId'),
    dict(value='2071675', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='160', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMax'),
    dict(value='-13', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssPbchBlockPower'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='freqBandIndicatorNR'),
    dict(value='16374', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='lcrId'),
    dict(value='2073339', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='nrarfcn'),
    dict(value='160', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='pMax'),
    dict(value='-13', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ssPbchBlockPower'),
    dict(value='51', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='physCellId'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ullaDeltaSinrMin'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='freqBandIndicatorNR'),
    dict(value='16375', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='lcrId'),
    dict(value='2075003', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='nrarfcn'),
    dict(value='160', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='pMax'),
    dict(value='-13', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ssPbchBlockPower'),
    dict(value='52', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='physCellId'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ullaDeltaSinrMin'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='freqBandIndicatorNR'),
    dict(value='16376', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='lcrId'),
    dict(value='2076667', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='nrarfcn'),
    dict(value='160', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='pMax'),
    dict(value='-13', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='ssPbchBlockPower'),
    dict(value='53', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='physCellId'),
    dict(value='semiStatic', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='2Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='1/4', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='ullaDeltaSinrMin'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
         dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Mplane', p_name='ipV4AddressDN1'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
         dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='f1Uplane', p_name='ipV4AddressDN1'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1', p_name='actPdlRuleValidation'),
    dict(value='TOPP', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1', list_name='syncInputList',
         p_name='syncInputType'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='maxNoCPUEVMs')
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
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3"),
    dict(dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2"),
    dict(dist_name="MRBTS-1900/NRBTS-1/SERVEDAMF-1", p_name='ngLinkStatus')
]

OBJECTS_TO_CREATE = [
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
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        class_name="com.nokia.srbts.mnl:NTP",
        version="MNL5G19B_1910_100"),

    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        class_name="com.nokia.srbts.tnl:IPRT",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        class_name="com.nokia.srbts.tnl:IPRT",
        version="TNL5G19B_1911_100"),
    dict(
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1",
        class_name="com.nokia.srbts.mnl:TOP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1",
        class_name="com.nokia.srbts.mnl:TOPP",
        version="MNL5G19B_1910_100")
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
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="frRefList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="modDNList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="frRefList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="modDNList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="frRefList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="modDNList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="frRefList"),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="modDNList"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1",
        list_name="acceptedClockClass"),
    dict(
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1",
        list_name="topMasterList")
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
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
            "destIpAddr": "0.0.0.0",
            "destinationIpPrefixLength": "0",
            "gateway": "10.57.159.129"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
            "destIpAddr": "10.68.90.32",
            "destinationIpPrefixLength": "27",
            "gateway": "10.57.159.65"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
              "destIpAddr": "0.0.0.0",
              "destinationIpPrefixLength": "0",
              "gateway": "10.57.159.129"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
              "destIpAddr": "10.68.90.32",
              "destinationIpPrefixLength": "27",
              "gateway": "10.57.159.65"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
              "destIpAddr": "10.57.159.64",
              "destinationIpPrefixLength": "26",
              "gateway": "10.68.90.33"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
              "destIpAddr": "0.0.0.0",
              "destinationIpPrefixLength": "0",
              "gateway": "10.68.90.33"}),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1",
        list_name="staticRoutes",
        elements={
              "destIpAddr": "10.68.90.32",
              "destinationIpPrefixLength": "27",
              "gateway": "10.57.159.65"}),
    dict(
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1",
        list_name="topMasterList",
        elements={
              "localPriority": "128",
              "masterIpAddr": "10.57.249.62",
              "maximumNetworkTimingError": "0",
              "phaseErrorComp": "0"})

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
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="frRefList",
        elements=['FR-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name="modDNList",
        elements=['MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="frRefList",
        elements=['FR-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-2",
        list_name="modDNList",
        elements=['MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="frRefList",
        elements=['FR-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-3",
        list_name="modDNList",
        elements=['MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="frRefList",
        elements=['FR-1']),
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-4",
        list_name="modDNList",
        elements=['MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1']),
    dict(
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1",
        list_name="acceptedClockClass",
        elements=[
            6,
            7])
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
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1',
        p_name='sModDN'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='configuredEpsTac'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='configuredEpsTac'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='configuredEpsTac'),
    dict(
        value='1',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='configuredEpsTac'),
    dict(
        value='ASOD_Main',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1',
        p_name='userLabel'),
    dict(
        value='CPIF_Main',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        p_name='userLabel'),
    dict(
        value='UPUE_Main',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1',
        p_name='userLabel'),
    dict(
        value='OAM_Main',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1',
        p_name='userLabel'),
    dict(
        value='63',
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
