import os

from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_p_name = 'dlFlowControlAlgo'
scf_above = 'SBTS5G18A_5g_pid11_classical.xml'
scf_below = 'SBTS5G18A_5g_pid12_classical.xml'

PARAMS_TO_REMOVE_SCF = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
]

tl_scf_param_479 = [
    dict(value='7_5_HZ_TLIV40', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='262', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='3', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='false', dist_name=_NRBTSname, p_name='actDlDataForwardingX2'),
    # dict(value='509070', dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value='531000', dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value='60MHz', dist_name=_NRCELLname, p_name='chBw'),
    # dict(value=6363, dist_name=_NRCELLname, p_name='gscn'),
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
    dict(value='ulOverNr', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name='ulDataPath'),
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
    # dict(value='tdLte', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    # dict(value='4Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    # dict(value='3ms', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    # dict(value='2/8', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
]

_PARAMS_MODSCF_479_A_4 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actInactDetNSAUe'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='nsaInactivityTimer'),
]
scf_479_A_004 = SCF(project='5G18A', name=scf_below, scf_params=_PARAMS_MODSCF_479_A_4)
tl_479_A_004 = CONFIG_5G(scf=scf_479_A_004)

_PARAMS_MODSCF_479_A_5 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actInactDetNSAUe'),
    dict(value='30', dist_name='MRBTS-1900/NRBTS-1', p_name='nsaInactivityTimer'),
]
scf_479_A_005 = SCF(project='5G18A', name=scf_below, scf_params=_PARAMS_MODSCF_479_A_5)
tl_479_A_005 = CONFIG_5G(scf=scf_479_A_005)

_PARAMS_MODSCF_479_A_6 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actInactDetNSAUe'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='nsaInactivityTimer'),
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
]
scf_479_A_006 = SCF(project='5G18A', name=scf_below, scf_params=_PARAMS_MODSCF_479_A_6)
tl_479_A_006 = CONFIG_5G(scf=scf_479_A_006)
