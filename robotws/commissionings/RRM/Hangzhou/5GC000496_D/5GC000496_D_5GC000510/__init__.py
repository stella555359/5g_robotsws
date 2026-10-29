__maintainer__ = 'kk'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'kk.wang@nokia-sbell.com'


_distname = 'MRBTS-1900/NRBTS-1'
_p_name = 'dlFlowControlAlgo'
_p_data = 'ulDataPath'
_dist_name = 'MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1'
_dista = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_NRCELLname2 = 'MRBTS-1900/NRBTS-1/NRCELL-2'
_NRCELLname3 = 'MRBTS-1900/NRBTS-1/NRCELL-3'
_CCLOCK = 'MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1'
_lIP = 'localIpAddr'

PARAMS_TO_MODIFY_FOR_DEFAULT = [
    dict(value='Nokia Hangzhou', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='Nokia HZ TL029', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='38', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='15', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='zeroCorrelationZoneConfig'),
    dict(value='2073343', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='5G18A/5g_pid11_classical_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='0.0.0.0', dist_name=_dist_name, list_name='staticRoutes', p_name='destIpAddr'),
    dict(value='0', dist_name=_dist_name, list_name='staticRoutes', p_name='destinationIpPrefixLength'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-108', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch')
]

tl_scf_param_flow = [
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab5', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab6', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab7', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab8', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab9', p_name=_p_name),
    dict(value='semiStatic', dist_name=_dista, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_dista, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_dista, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='16', dist_name=_dista, p_name='nrofHARQProcessesForPDSCH')
]

tl_scf_param_flow_tl40 = [
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_data),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value=1, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea0'),
    dict(value=3, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea1_128'),
    dict(value=4, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea2_128'),
    dict(value=2, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea3_128'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab5', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab6', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab7', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab8', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab9', p_name=_p_name),
    # dict(value='tdLte', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    # dict(value='4Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    # dict(value='3ms', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    # dict(value='2/8', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio')
]

MODIFY_FOR_COMMON = [
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab5', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab6', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab7', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab8', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab9', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='tdLte', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='0ms', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    dict(value='2/8', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='tdLte', dist_name=_NRCELLname2, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=_NRCELLname2, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='0ms', dist_name=_NRCELLname2, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    dict(value='2/8', dist_name=_NRCELLname2, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='tdLte', dist_name=_NRCELLname3, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=_NRCELLname3, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='0ms', dist_name=_NRCELLname3, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    dict(value='2/8', dist_name=_NRCELLname3, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='Nokia HZ', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='HZTL77 gNB', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='244', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='9', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='true', dist_name=_NRBTSname, p_name='actGnbInitRlf'),
    dict(value='12', dist_name=_NRBTSname, p_name='sCCNumber'),
    dict(value='40MHz', dist_name=_NRCELLname, p_name='chBw'),
    dict(value=6525, dist_name=_NRCELLname, p_name='gscn'),
    dict(value=522000, dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value=158, dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value=12, dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname, p_name='zeroCorrelationZoneConfig'),
    dict(value='40MHz', dist_name=_NRCELLname2, p_name='chBw'),
    dict(value=6525, dist_name=_NRCELLname2, p_name='gscn'),
    dict(value=522000, dist_name=_NRCELLname2, p_name='nrarfcn'),
    dict(value=97, dist_name=_NRCELLname2, p_name='prachConfigurationIndex'),
    dict(value=12, dist_name=_NRCELLname2, p_name='type0CoresetConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname2, p_name='zeroCorrelationZoneConfig'),
    dict(value='40MHz', dist_name=_NRCELLname3, p_name='chBw'),
    dict(value=6525, dist_name=_NRCELLname3, p_name='gscn'),
    dict(value=522000, dist_name=_NRCELLname3, p_name='nrarfcn'),
    dict(value=158, dist_name=_NRCELLname3, p_name='prachConfigurationIndex'),
    dict(value=12, dist_name=_NRCELLname3, p_name='type0CoresetConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname3, p_name='zeroCorrelationZoneConfig'),
    dict(value='5G19/5g_pid12_class_eoc_2dl2ul_rfs_3x', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value=1, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea0'),
    dict(value=3, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea1_128'),
    dict(value=4, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea2_128'),
    dict(value=2, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea3_128'),
    dict(value='51', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='physCellId'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='rfSharingEnabled'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='1pps/ToD from Sync Hub Master', dist_name=_CCLOCK, list_name='syncInputList', p_name='syncInputType'),
    dict(value='29', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(value='29', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpPrefixLength'),
    dict(value='29', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpPrefixLength'),
    dict(value='29', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name='localIpPrefixLength'),
]

MODIFY_FOR_1CELLCOMMON = [
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab5', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab6', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab7', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab8', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='fiveQiTab9', p_name=_p_name),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab5Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab69Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab6Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab70Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab79Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab7Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab8Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='3gppFlowControl', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_name),
    dict(value='ulOverNr', dist_name=_distname, list_name='qciTab9Nsa3x', p_name=_p_data),
    dict(value='dlOverF1U', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='tdLte', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='0ms', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    dict(value='2/8', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='Nokia HZ', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='location'),
    dict(value='HZTL77 gNB', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='244', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='9', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='true', dist_name=_NRBTSname, p_name='actGnbInitRlf'),
    dict(value='12', dist_name=_NRBTSname, p_name='sCCNumber'),
    dict(value='40MHz', dist_name=_NRCELLname, p_name='chBw'),
    dict(value=6525, dist_name=_NRCELLname, p_name='gscn'),
    dict(value=522000, dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value=158, dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value=12, dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname, p_name='zeroCorrelationZoneConfig'),
    dict(value='5G19/5g_pid12_class_eoc_2dl2ul_rfs', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value=1, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea0'),
    dict(value=3, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea1_128'),
    dict(value=4, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea2_128'),
    dict(value=2, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea3_128'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='rfSharingEnabled'),
    dict(value='(GMT+8) Asia/Shanghai', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1', p_name='timeZone'),
    dict(value='1pps/ToD from Sync Hub Master', dist_name=_CCLOCK, list_name='syncInputList', p_name='syncInputType'),
    dict(value='29', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(value='29', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpPrefixLength'),
    dict(value='29', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpPrefixLength'),
    dict(value='29', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name='localIpPrefixLength'),
]

MODIFY_FOR_case1_01 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-108', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch')
]

MODIFY_FOR_case1_02 = [
    dict(value='false', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-108', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch')
]

MODIFY_FOR_case2_01 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl'),
    dict(value='-92', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch')
]

MODIFY_FOR_case3_01 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl'),
    dict(value='-82', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch')
]

MODIFY_FOR_case4_01 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl'),
    dict(value='-82', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch'),
    dict(value='al1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='alpha')
]

MODIFY_FOR_case6_01 = [
    dict(value='false', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl'),
    dict(value='-82', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch')
]

MODIFY_FOR_case7_01 = [
    dict(value='false', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl'),
    dict(value='-82', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-72', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch')
]

MODIFY_FOR_case8_01 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMaxNROwnCell')
]

PARAMS_TO_MODIFY_FOR_case2_001 = [
    dict(value='60MHz', dist_name=_NRCELLname, p_name='chBw'),
    dict(value=6633, dist_name=_NRCELLname, p_name='gscn'),
    dict(value=90, dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname, p_name='zeroCorrelationZoneConfig'),
    dict(value=41, dist_name=_NRCELLname, p_name='freqBandIndicatorNR'),
    dict(value=12, dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destinationIpPrefixLength'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='5G19/5g_pid12_class_eoc_2dl2ul_dedic', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='-100', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-108', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch')
]

PARAMS_TO_MODIFY_FOR_case6_001 = [
    dict(value='60MHz', dist_name=_NRCELLname, p_name='chBw'),
    dict(value=6633, dist_name=_NRCELLname, p_name='gscn'),
    dict(value=90, dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname, p_name='zeroCorrelationZoneConfig'),
    dict(value=41, dist_name=_NRCELLname, p_name='freqBandIndicatorNR'),
    dict(value=12, dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destinationIpPrefixLength'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='5G19/5g_pid12_class_eoc_2dl2ul_dedic', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='-100', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPusch'),
    dict(value='-108', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='p0NominalPucch'),
    dict(value='false', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='actUlOpenLoopPwrCtrl')
]

PARAMS_TO_MODIFY_FOR_case8_001 = [
    dict(value='7_5_HZ_TLIV40', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='262', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='3', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='531000', dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value='60MHz', dist_name=_NRCELLname, p_name='chBw'),
    dict(value=6633, dist_name=_NRCELLname, p_name='gscn'),
    dict(value=90, dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname, p_name='zeroCorrelationZoneConfig'),
    dict(value=41, dist_name=_NRCELLname, p_name='freqBandIndicatorNR'),
    dict(value=12, dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destinationIpPrefixLength'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='5G19/5g_pid12_class_eoc_2dl2ul_dedic', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMaxNROwnCell')
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
]

PARAMS_TO_MODIFY_TL = [
    dict(value='10.57.224.33', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='gateway'),
    dict(value='10.57.224.35', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name=_lIP),
    dict(value='10.57.224.34', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name=_lIP),
    dict(value='10.57.224.34', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name=_lIP),
    dict(value='10.57.224.34', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name=_lIP),
]

ADD_TO_SCF = [
    dict(value='ssBurstSetPeriod', dist_name=_NRCELLname, list_name='csirsForTracking', p_name='csirsTrackingPeriod'),
    dict(value='0', dist_name=_NRCELLname, list_name='csirsForTracking', p_name='firstRE'),
    dict(value='52RB', dist_name=_NRCELLname, list_name='csirsForTracking', p_name='rbAllocation'),
    dict(value='0', dist_name=_NRCELLname, list_name='csirsForTracking', p_name='startRB'),
    dict(value='ssBurstSetPeriod', dist_name=_NRCELLname2, list_name='csirsForTracking', p_name='csirsTrackingPeriod'),
    dict(value='0', dist_name=_NRCELLname2, list_name='csirsForTracking', p_name='firstRE'),
    dict(value='52RB', dist_name=_NRCELLname2, list_name='csirsForTracking', p_name='rbAllocation'),
    dict(value='0', dist_name=_NRCELLname2, list_name='csirsForTracking', p_name='startRB'),
    dict(value='ssBurstSetPeriod', dist_name=_NRCELLname3, list_name='csirsForTracking', p_name='csirsTrackingPeriod'),
    dict(value='0', dist_name=_NRCELLname3, list_name='csirsForTracking', p_name='firstRE'),
    dict(value='52RB', dist_name=_NRCELLname3, list_name='csirsForTracking', p_name='rbAllocation'),
    dict(value='0', dist_name=_NRCELLname3, list_name='csirsForTracking', p_name='startRB')
]

AMOUNT_OF_CELLS = 1
