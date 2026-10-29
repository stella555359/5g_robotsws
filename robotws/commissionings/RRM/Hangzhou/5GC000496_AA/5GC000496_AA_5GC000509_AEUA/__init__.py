import os

from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELL1name = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_NRCELL2name = 'MRBTS-1900/NRBTS-1/NRCELL-2'
_NRCELL3name = 'MRBTS-1900/NRBTS-1/NRCELL-3'
_p_name = 'dlFlowControlAlgo'
scf_above = 'SBTS5G19_5g_pid16_class_eoc_3x1CC.xml'

tl_scf_param_509 = [
    dict(value='Nokia HZ TL042', dist_name='MRBTS-1900', p_name='btsName'),
    # dict(value='true', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
    dict(value='262', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='3', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='2073343', dist_name=_NRCELL1name, p_name='nrarfcn'),
    dict(value='2073343', dist_name=_NRCELL2name, p_name='nrarfcn'),
    dict(value='51', dist_name=_NRCELL2name, p_name='physCellId'),
    dict(value='2073343', dist_name=_NRCELL3name, p_name='nrarfcn'),
    dict(value='52', dist_name=_NRCELL3name, p_name='physCellId'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
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
    dict(value='infinity', dist_name=_NRBTSname, list_name='qciTab5Nsa3x', p_name='ulDataSplitThreshold'),
    dict(value='infinity', dist_name=_NRBTSname, list_name='qciTab69Nsa3x', p_name='ulDataSplitThreshold'),
    dict(value='infinity', dist_name=_NRBTSname, list_name='qciTab6Nsa3x', p_name='ulDataSplitThreshold'),
    dict(value='infinity', dist_name=_NRBTSname, list_name='qciTab70Nsa3x', p_name='ulDataSplitThreshold'),
    dict(value='infinity', dist_name=_NRBTSname, list_name='qciTab79Nsa3x', p_name='ulDataSplitThreshold'),
    dict(value='infinity', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='ulDataSplitThreshold'),
    dict(value='infinity', dist_name=_NRBTSname, list_name='qciTab8Nsa3x', p_name='ulDataSplitThreshold'),
    dict(value='infinity', dist_name=_NRBTSname, list_name='qciTab9Nsa3x', p_name='ulDataSplitThreshold'),
    dict(value='semiStatic', dist_name=_NRCELL1name, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELL1name, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELL1name, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name=_NRCELL2name, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELL2name, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELL2name, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='semiStatic', dist_name=_NRCELL3name, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELL3name, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELL3name, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio')
]

_PARAMS_MODSCF_509_B_11 = [
    # dict(value='false', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
]

scf_509_B_11 = SCF(project='5G19', name=scf_above, scf_params=_PARAMS_MODSCF_509_B_11)
tl_509_B_011 = CONFIG_5G(scf=scf_509_B_11)
