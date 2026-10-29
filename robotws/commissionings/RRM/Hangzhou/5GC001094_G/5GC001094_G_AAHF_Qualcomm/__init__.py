import os

from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_distname = 'MRBTS-1900/NRBTS-1'
_p_name = 'dlFlowControlAlgo'
_p_data = 'ulDataPath'
_dist_name = 'MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1'
_dista = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_NRCELLname2 = 'MRBTS-1900/NRBTS-1/NRCELL-2'
_NRCELLname3 = 'MRBTS-1900/NRBTS-1/NRCELL-3'
scf_below = 'SBTS5G19_5g_pid12_Left_32TRX_3x_classical.xml'

# PARAMS_TO_REMOVE_SCF = [
#     dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
#     dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
#     dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-2'),
#     dict(dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='refNrCellGroup', index=2)
# ]

tl_scf_param_1094 = [
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
    dict(value='Nokia HZ TL040-split-for-QC-UE', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='ethernetPortSecurityEnabled'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='262', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='3', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='false', dist_name=_NRBTSname, p_name='actGnbInitRlf'),
    dict(value='18', dist_name=_NRBTSname, p_name='sCCNumber'),
    dict(value=6363, dist_name=_NRCELLname, p_name='gscn'),
    dict(value=509070, dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value=97, dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value=12, dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname, p_name='zeroCorrelationZoneConfig'),
    dict(value=6363, dist_name=_NRCELLname2, p_name='gscn'),
    dict(value=509070, dist_name=_NRCELLname2, p_name='nrarfcn'),
    dict(value=97, dist_name=_NRCELLname2, p_name='prachConfigurationIndex'),
    dict(value=12, dist_name=_NRCELLname2, p_name='type0CoresetConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname2, p_name='zeroCorrelationZoneConfig'),
    dict(value=6363, dist_name=_NRCELLname3, p_name='gscn'),
    dict(value=509070, dist_name=_NRCELLname3, p_name='nrarfcn'),
    dict(value=97, dist_name=_NRCELLname3, p_name='prachConfigurationIndex'),
    dict(value=12, dist_name=_NRCELLname3, p_name='type0CoresetConfigurationIndex'),
    dict(value=15, dist_name=_NRCELLname3, p_name='zeroCorrelationZoneConfig'),
    dict(value='5G19/5g_pid12_class_eoc_2dl2ul_dedic_3x', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value=0, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea0'),
    dict(value=0, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea1_128'),
    dict(value=9, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea2_128'),
    dict(value=0, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea3_128'),
    dict(value='50', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='physCellId'),
    dict(value='51', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='physCellId'),
    dict(value='52', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='physCellId'),
    dict(value='0', dist_name=_NRCELLname, p_name='dllaIniMcs'),
    dict(value='0', dist_name=_NRCELLname, p_name='ullaIniMcs'),
    dict(value='0', dist_name=_NRCELLname2, p_name='dllaIniMcs'),
    dict(value='0', dist_name=_NRCELLname2, p_name='ullaIniMcs'),
    dict(value='0', dist_name=_NRCELLname3, p_name='dllaIniMcs'),
    dict(value='0', dist_name=_NRCELLname3, p_name='ullaIniMcs'),

]

_PARAMS_MODSCF_1094_G_101 = [
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1', p_name='actIntraFreqIntraGnbMobilityNSA'),
]
scf_1094_G_101 = SCF(project='5G18A', name=scf_below, scf_params=_PARAMS_MODSCF_1094_G_101)
tl_1094_G_101 = CONFIG_5G(scf=scf_1094_G_101)
