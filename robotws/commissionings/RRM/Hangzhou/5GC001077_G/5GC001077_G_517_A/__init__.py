import os

# from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MODIFY_SCF_FOR_TESTLINE = [
    dict(
        value='262',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='mcc'),
    dict(
        value='3',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='mnc'),
    dict(
        value='2',
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='mncLength'),
    dict(
        value='-108',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='ulPowerControlCommon',
        p_name='p0NominalPucch'),
    dict(
        value='49',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='physCellId'
         ),
    dict(
        value='15',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='zeroCorrelationZoneConfig'),
    dict(
        value='-104',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='initialPreambleReceivedTargetPower'),
    dict(
        value='522078',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='nrarfcn'),
    dict(
        value='12',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='type0CoresetConfigurationIndex'),
    # This is used for ssh to ASIK
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1',
        p_name='systemAcctPermEnable'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1',
        p_name='actServiceAccountSsh'),
    # ulDataPath(8)
    dict(
        value='ulOverNr',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab5Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab69Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab6Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab70Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab79Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab7Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab8Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab9Nsa3x',
        p_name='ulDataPath'),
    # original:nokiaFlowControl to 3gppFlowControl(13)
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab5Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab69Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab6Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab70Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab79Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab7Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab8Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab9Nsa3x',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='fiveQiTab5',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='fiveQiTab6',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='fiveQiTab7',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='fiveQiTab8',
        p_name='dlFlowControlAlgo'),
    dict(
        value='3gppFlowControl',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='fiveQiTab9',
        p_name='dlFlowControlAlgo'),
    # cipher_algorithm_for_master_branch
    dict(
        value='9',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='cipherPrefL',
        p_name='nea0'),
    # datasplit only towards F1U---8 parameters
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab5Nsa3x',
        p_name='dlDataSplitMode'),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab69Nsa3x',
        p_name='dlDataSplitMode'),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab6Nsa3x',
        p_name='dlDataSplitMode'),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab70Nsa3x',
        p_name='dlDataSplitMode'),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab79Nsa3x',
        p_name='dlDataSplitMode'),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab7Nsa3x',
        p_name='dlDataSplitMode'),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab8Nsa3x',
        p_name='dlDataSplitMode'),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab9Nsa3x',
        p_name='dlDataSplitMode'),
    # ethernetPort security --which related with the ssh service
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1',
        p_name='ethernetPortSecurityEnabled'),
    # 40M Bandwidth
    dict(
        value='40MHz',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='chBw'),
    dict(
        value='6546',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='gscn'),
    dict(
        value='10.57.237.33',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1',
        list_name='staticRoutes',
        p_name='gateway'),
    # The parameters for PDL rule activation
    dict(
        value='true',
        dist_name="MRBTS-1900/NRBTS-1",
        p_name='actGeneralConnectivityBronze'),
    dict(
        value='true',
        dist_name="MRBTS-1900/NRBTS-1",
        p_name='actDlDataForwardingX2Limit'),
    dict(
        value='1',
        dist_name="MRBTS-1900/NRBTS-1/TRACKINGAREA-1",
        p_name='fiveGsTac'),
    dict(
        value='1',
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        p_name='fiveGsTac'),
    dict(
        value='infinity',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='qciTab5Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='qciTab69Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='qciTab6Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='qciTab70Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='qciTab79Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='qciTab7Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='qciTab8Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='qciTab9Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='false',
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name='beamSet',
        p_name='nrBtsBeamRefinementP2'),
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='x2Cplane',
        p_name='ipV4AddressDN1'),
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3',
        dist_name="MRBTS-1900/NRBTS-1",
        list_name='x2Uplane',
        p_name='ipV4AddressDN1')
]

MODIFY_SCF_1077_G_MCS0 = [
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='tdLte',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='97',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='prachConfigurationIndex')
]

MODIFY_SCF_1077_G_MCS11 = [
    dict(
        value='11',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='11',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='tdLte',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='0ms',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='lteToNrFrameShift'),
    dict(
        value='2/8',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='97',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='prachConfigurationIndex')
]

LIST_PARAMS_TO_ADD = [
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name='csirsForTracking'),
]

# ELEMENTS_PARAMS_TO_ADD= [
#     dict(dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
#          list_name='csirsForTracking',
#          elements=dict()),
#     dict(dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
#          list_name='csirsForTracking',
#          elements=dict()),
# ]


ITEMS_PARAMS_TO_ADD = [
    dict(dist_name="MRBTS-1900/NRBTS-1/NRCELL-1", list_name='csirsForTracking',
         elements=dict(csirsTrackingPeriod='ssBurstSetPeriod', firstRE='0', rbAllocation='BWP', startRB='0'))
    # dict(dist_name="MRBTS-1900/NRBTS-1/NRCELL-1", list_name='csirsForTracking',
    #      elements=dict(firstRE='0')),
    # dict(dist_name="MRBTS-1900/NRBTS-1/NRCELL-1", list_name='csirsForTracking',
    #      elements=dict(rbAllocation='BWP')),
    # dict(dist_name="MRBTS-1900/NRBTS-1/NRCELL-1", list_name='csirsForTracking',
    #      elements=dict(startRB='0')),
]

PDL_ELEMENTS_PARAMS_TO_REMOVE = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='e1SetupTimeToWait'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1',
        p_name='timerE1BearerProcGuard'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCUUP-1',
        p_name='e1NbSetupRetryForFault'),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCUUP-1',
        p_name='e1SetupRspTmr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2',
        p_name='ipAddressAllocationMethod'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4',
        p_name='ipAddressAllocationMethod')
]

PDL_MOS_PARAMS_TO_ADD = [
    dict(
        dist_name="MRBTS-1900/EQM-1/SMOD_EXT-1",
        class_name='com.nokia.srbts.eqm:SMOD_EXT',
        version='EQM5G19_1901_010')
]

PDL_MOS_PARAMS_TO_REMOVE = [
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4")
]

PDL_ELEMENTS_PARAMS_TO_ADD = [
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/SMOD-1',
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/CERTHENT-1",
        p_name='sModDN'),
    dict(
        value='Disabled',
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1",
        p_name='outputConfiguration1Pps'),
    dict(
        value='Disabled',
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1",
        p_name='outputConfiguration2M048'),
    dict(
        value='250',
        dist_name="MRBTS-1900/NRBTS-1",
        p_name='timerX2DataFwdGuard'),
    dict(
        value='true',
        dist_name="MRBTS-1900/EQM-1/SMOD_EXT-1",
        p_name='eutraSupport'),
    dict(
        value='1',
        dist_name="MRBTS-1900/EQM-1/SMOD_EXT-1",
        p_name='sModExtId'),
    dict(
        value='1',
        dist_name="MRBTS-1900/NRBTS-1/TRACKINGAREA-1",
        p_name='trackingAreaId')
]

PDL_LIST_PARAMS_TO_ADD = [
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name='csirsForTracking')
]

PDL_ITEMS_PARAMS_TO_ADD = [
    dict(
        dist_name="MRBTS-1900/NRBTS-1/NRCELL-1",
        list_name='csirsForTracking',
        elements=dict(
            csirsTrackingPeriod='ssBurstSetPeriod',
            firstRE='0',
            rbAllocation='52RB',
            startRB='0'))
]
