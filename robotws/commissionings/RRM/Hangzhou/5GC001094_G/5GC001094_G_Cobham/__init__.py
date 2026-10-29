import os

from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELL1name = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_NRCELL2name = 'MRBTS-1900/NRBTS-1/NRCELL-2'
_NRCELL3name = 'MRBTS-1900/NRBTS-1/NRCELL-3'
_NRCELLGRP0 = 'MRBTS-1900/NRBTS-1/NRCELLGRP-0'
_NRCELLGRP1 = 'MRBTS-1900/NRBTS-1/NRCELLGRP-1'
_NRCELLGRP2 = 'MRBTS-1900/NRBTS-1/NRCELLGRP-2'
_p_name = 'dlFlowControlAlgo'

PARAMS_TO_REMOVE_SCF = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRDU-1', list_name='refNrCellGroup', index=2)
]

MODIFY_FOR_COMMON = [
    dict(value='Nokia HZ TL041', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='true', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
    dict(value='262', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='3', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='18', dist_name=_NRBTSname, p_name='sCCNumber'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea0'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea1_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea2_128'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea3_128'),
    dict(value='6363', dist_name=_NRCELL1name, p_name='gscn'),
    dict(value='509070', dist_name=_NRCELL1name, p_name='nrarfcn'),
    dict(value='12', dist_name=_NRCELL1name, p_name='type0CoresetConfigurationIndex'),
    dict(value='15', dist_name=_NRCELL1name, p_name='zeroCorrelationZoneConfig'),
    dict(value='6363', dist_name=_NRCELL2name, p_name='gscn'),
    dict(value='509070', dist_name=_NRCELL2name, p_name='nrarfcn'),
    dict(value='12', dist_name=_NRCELL2name, p_name='type0CoresetConfigurationIndex'),
    dict(value='15', dist_name=_NRCELL2name, p_name='zeroCorrelationZoneConfig'),
    dict(value='51', dist_name=_NRCELL2name, p_name='physCellId'),
    # dict(value='6363', dist_name=_NRCELL3name, p_name='gscn'),
    # dict(value='509070', dist_name=_NRCELL3name, p_name='nrarfcn'),
    # dict(value='12', dist_name=_NRCELL3name, p_name='type0CoresetConfigurationIndex'),
    # dict(value='15', dist_name=_NRCELL3name, p_name='zeroCorrelationZoneConfig'),
    # dict(value='52', dist_name=_NRCELL3name, p_name='physCellId'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
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
    dict(value='5G19/5g_pid12_class_3x1CC_2dl2ul_aahf_rfs', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='tdLte', dist_name=_NRCELL1name, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=_NRCELL1name, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='0ms', dist_name=_NRCELL1name, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    dict(value='2/8', dist_name=_NRCELL1name, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='tdLte', dist_name=_NRCELL2name, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=_NRCELL2name, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='0ms', dist_name=_NRCELL2name, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    dict(value='2/8', dist_name=_NRCELL2name, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    # dict(value='tdLte', dist_name=_NRCELL3name, list_name='tddFrameStructure', p_name='frameStructureType'),
    # dict(value='4Symbols', dist_name=_NRCELL3name, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    # dict(value='0ms', dist_name=_NRCELL3name, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    # dict(value='2/8', dist_name=_NRCELL3name, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='rfSharingEnabled'),
    dict(value='158', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='158', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='prachConfigurationIndex'),
    # dict(value='158', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='prachConfigurationIndex'),
    dict(value='150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ullaDeltaSinrMax'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ullaDeltaSinrMin'),
    dict(value='150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ullaDeltaSinrMax'),
    dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='ullaDeltaSinrMin'),
    # dict(value='150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ullaDeltaSinrMax'),
    # dict(value='-150', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='ullaDeltaSinrMin'),
    dict(value='11', dist_name=_NRCELL1name, p_name='dllaIniMcs'),
    dict(value='11', dist_name=_NRCELL2name, p_name='dllaIniMcs'),
    # dict(value='11', dist_name=_NRCELL3name, p_name='dllaIniMcs'),
    dict(value='11', dist_name=_NRCELL1name, p_name='ullaIniMcs'),
    dict(value='11', dist_name=_NRCELL2name, p_name='ullaIniMcs'),
    # dict(value='11', dist_name=_NRCELL3name, p_name='ullaIniMcs'),
    dict(value='12', dist_name=_NRCELL1name, p_name='ssPbchBlockPower'),
    dict(value='12', dist_name=_NRCELL2name, p_name='ssPbchBlockPower'),
    # dict(value='12', dist_name=_NRCELL3name, p_name='ssPbchBlockPower'),
    dict(value='-96', dist_name=_NRCELL1name, p_name='p0NominalPusch'),
    dict(value='-90', dist_name=_NRCELL1name, p_name='p0NominalPucch'),
    dict(value='-96', dist_name=_NRCELL2name, p_name='p0NominalPusch'),
    dict(value='-90', dist_name=_NRCELL2name, p_name='p0NominalPucch'),
    # dict(value='-96', dist_name=_NRCELL3name, p_name='p0NominalPusch'),
    # dict(value='-90', dist_name=_NRCELL3name, p_name='p0NominalPucch'),
    dict(value='true', dist_name=_NRCELLGRP0, p_name='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELLGRP1, p_name='actProactUlScheduling'),
    # dict(value='true', dist_name=_NRCELLGRP2, p_name='actProactUlScheduling'),
    dict(value='20', dist_name=_NRCELLGRP0, p_name='ssBurstSetPeriod'),
    dict(value='20', dist_name=_NRCELLGRP1, p_name='ssBurstSetPeriod'),
    # dict(value='20', dist_name=_NRCELLGRP2, p_name='ssBurstSetPeriod'),
]

MODIFY_FOR_Case115_01 = [
    dict(value='rsrpCombined', dist_name=_NRCELL1name, p_name='a5MeasEnabled'),
]

MODIFY_FOR_Case105_01 = [
    dict(value='rsrpCombined', dist_name=_NRCELL1name, p_name='a3MeasEnabled'),
]

MODIFY_FOR_Case302_01 = [
    dict(value='0', dist_name=_NRCELL2name, p_name='maxNumOfUsersPerCell'),
]

MODIFY_FOR_Case409_01 = [
    dict(value='n32', dist_name=_NRCELL2name, p_name='cbraPreamblesPerSsb'),
]

MODIFY_FOR_Case501_01 = [
    dict(value='0', dist_name=_NRCELL2name, p_name='maxNumOfUsersPerCell'),
]
