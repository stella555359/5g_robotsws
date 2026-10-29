import os

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# number of active cells. The rest of the cells in the SCF will be deleted
AMOUNT_OF_CELLS = 1

# path to SCF file on OAM on gNb to be modified and commissioned
PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/SBTS5G19_5g_pid11.xml'

_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_p_name = 'dlFlowControlAlgo'

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1', p_name='btsSyncMode'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/ECPRIMASTER-1'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1', p_name='timeZone'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-1'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-1', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-1', p_name='speedAndDuplex'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-3/ETHSVC-1/ETHLK-2', p_name='speedAndDuplex')
]

PARAMS_TO_MODIFY = [
    dict(value='Hangzhou_OAM_Cloud_TL270', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='Nokia Hangzhou', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='5G19/5g_pid11_abil_l2rt_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1', p_name='actPdlRuleValidation'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actDlDataForwardingX2Limit'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actGeneralConnectivityBronze'),
    dict(value='6000', dist_name='MRBTS-1900/NRBTS-1', p_name='timerX2UeProcGuard'),
    dict(value='362', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='3', dist_name=_NRBTSname, p_name='mnc'),
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
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='No additional DMRS', dist_name=_NRCELLname, p_name='dlDMRSAdditionalPosition'),
    dict(value='No additional DMRS', dist_name=_NRCELLname, p_name='ulDMRSAdditionalPosition'),
    dict(value='2071591', dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value='22446', dist_name=_NRCELLname, p_name='gscn'),
    dict(value='true', dist_name=_NRCELLname, p_name='actBeamforming'),
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='false', dist_name='MRBTS-1900/NRBTS-1', p_name='actOAMResiliency'),
    dict(
        value='disabled',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/PMTNL-1',
        p_name='firstLevelSchedulerStatisticsInterval'),
    dict(
        value='disabled',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/PMTNL-1',
        p_name='secondLevelSchedulerStatisticsInterval'),
    dict(
        value='disabled',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/PMTNL-1',
        p_name='firstLevelSchedulerStatisticsInterval'),
    dict(
        value='disabled',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/PMTNL-1',
        p_name='secondLevelSchedulerStatisticsInterval'),
    dict(
        value='disabled',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/PMTNL-1',
        p_name='firstLevelSchedulerStatisticsInterval'),
    dict(
        value='disabled',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/PMTNL-1',
        p_name='secondLevelSchedulerStatisticsInterval'),
    dict(
        value='disabled',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/PMTNL-1',
        p_name='firstLevelSchedulerStatisticsInterval'),
    dict(
        value='disabled',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/PMTNL-1',
        p_name='secondLevelSchedulerStatisticsInterval'),
    dict(
        value='172.16.5.114',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        value='172.16.5.113',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2',
        p_name='localIpAddr'),
    dict(
        value='172.16.5.112',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3',
        p_name='localIpAddr'),
    dict(value='0', dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value='277', dist_name=_NRCELLname, p_name='frequencyDensityThresNrb0'),
    dict(value='277', dist_name=_NRCELLname, p_name='frequencyDensityThresNrb1')
]

OBJECTS_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-0',
        class_name='com.nokia.srbts.nrbts:TRACKINGAREA',
        version='NRBTS5G19A_1904_201'),
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
        version="MNL5G19A_1904_200")
]

LIST_TO_CREATE = [
    dict(
        dist_name=_NRCELLname,
        list_name="csirsBeamMgmt"),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        list_name="staticRoutes"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name="targetDNList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="acceptedClockClass"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="topMasterList")
]

LIST_ITEM_TO_ADD = [
    dict(
        dist_name=_NRCELLname,
        list_name='csirsBeamMgmt',
        elements={
            'csirsBmMgmtDensity': 'density3',
            'csirsBmMgmtReIndex': '1',
            'csirsBmMgmtSubband': 'aboveSSPBCHBlock'}),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        elements={
            'destIpAddr': '0.0.0.0',
            'destinationIpPrefixLength': '0',
            'gateway': '10.57.250.129',
            'preference': '1'}),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='topMasterList',
        elements={
            'phaseErrorComp': '0'})
]

LIST_ELEMENT_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='fPdcchMonOccsnPo',
        elements=['154']),
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
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='freqBandIndicatorEutra',
        elements=['1'])
]

# parameters with value to add
PARAMS_TO_ADD = [
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1',
        p_name='sModDN'),
    dict(
        value='false',
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
        value='3',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='e1NbResetRetryForFault'),
    dict(
        value='250',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='timerX2DataFwdGuard'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='configuredEpsTac'),
    dict(
        value='MRBTS-1900/NRBTS-1/TRACKINGAREA-0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='trackingAreaDN'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-0',
        p_name='fiveGsTac'),
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
        value='(GMT+8) Asia/Shanghai',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/TIME-1',
        p_name='timeZone')
]
