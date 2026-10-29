import os
from taf.config.testline.legacy import (CONFIG_5G, SCF)

__maintainer__ = 'Liu Anle'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'anle.liu@nokia-sbell.com'


PARAMS_TO_MODIFY_FEATURE = [
    dict(value='7_5_HZ_TLIV36', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='27', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', p_name='localIpPrefixLength'),
    dict(value='27', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2', p_name='localIpPrefixLength'),
    dict(value='27', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4', p_name='localIpPrefixLength'),
    dict(value='27', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3', p_name='localIpPrefixLength'),
    dict(value='5G18A/5g_pid11_classical_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', list_name='staticRoutes',
         p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', list_name='staticRoutes',
         p_name='destinationIpPrefixLength')
]

PARAMS_TO_MODIFY_FEATURE_TL39 = [
    dict(value='7_5_HZ_TLIV39', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='244', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='9', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='mncLength'),
    dict(value='false', dist_name='MRBTS-1900/NRBTS-1', p_name='actDlDataForwardingX2'),
    # dict(value='509070', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='633356', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='100MHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='chBw'),
    dict(value='230', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMax'),
    dict(value=1, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn'),
    # dict(value=6363, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn'),
    dict(value=98, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value=15, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='zeroCorrelationZoneConfig'),
    dict(value=78, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value=12, dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='type0CoresetConfigurationIndex'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destinationIpPrefixLength'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='5G18A/5g_pid12_classical_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab5', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab6', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab7', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab8', p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab9', p_name='dlFlowControlAlgo'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x', p_name='ulDataPath'),
    dict(value='ulOverNr', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x', p_name='ulDataPath'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value=1, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea0'),
    dict(value=3, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea1_128'),
    dict(value=4, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea2_128'),
    dict(value=2, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea3_128'),
    dict(value='true', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(value='5', dist_name='MRBTS-1900/NRBTS-1', p_name='sCCNumber'),
    dict(value='20', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMaxNROwnCell'),
    dict(value='tdLte', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='frameStructureType'),
    dict(value='4Symbols', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='guardPeriodLength'),
    dict(value='3ms', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='lteToNrFrameShift'),
    dict(value='2/8', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', list_name='tddFrameStructure',
         p_name='ulDlDataSlotRatio'),
]

PARAMS_TO_DELETE_FEATURE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELLGRP-0', list_name='nrCellList', index=1)
]

AMOUNT_OF_CELLS = 1

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_PARAMS_TO_MODIFY_SCF_474_A_001 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='maxNumX2Links'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),

]
scf_474_A_001 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_A_001)
tl_474_A_001 = CONFIG_5G(scf=scf_474_A_001)

_PARAMS_TO_MODIFY_SCF_474_A_002 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
]
scf_474_A_002 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_A_002)
tl_474_A_002 = CONFIG_5G(scf=scf_474_A_002)

_PARAMS_TO_MODIFY_SCF_474_B_001 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
]
scf_474_B_001 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_B_001)
tl_474_B_001 = CONFIG_5G(scf=scf_474_B_001)

_PARAMS_TO_MODIFY_SCF_474_B_002 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='maxNumX2Links'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
]
scf_474_B_002 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_B_002)
tl_474_B_002 = CONFIG_5G(scf=scf_474_B_002)

# parameters_dist_name_cell = "MRBTS-1900/NRBTS-1/NRCELL-1"
# parameters_p_name_cell = "administrativeState"
# modify_cell_value = "Locked"

parameters_dist_name_eNB = "MRBTS-1900/NRBTS-1/LTEENB-1"
parameters_p_name_eNB = "x2LinkLock"
modify_eNB_value = "locked"

_PARAMS_TO_MODIFY_SCF_474_B_004 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
]
scf_474_B_004 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_B_004)
tl_474_B_004 = CONFIG_5G(scf=scf_474_B_004)

_PARAMS_TO_MODIFY_SCF_474_B_005 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='100', dist_name='MRBTS-1900/NRBTS-1', p_name='x2LinkReestabTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
]
scf_474_B_005 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_B_005)
tl_474_B_005 = CONFIG_5G(scf=scf_474_B_005)


_PARAMS_TO_MODIFY_SCF_474_C_001 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='25', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2056666', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
]
scf_474_C_001 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_C_001)
tl_474_C_001 = CONFIG_5G(scf=scf_474_C_001)

_PARAMS_TO_MODIFY_SCF_474_C_008 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='3', dist_name='MRBTS-1900/NRBTS-1', p_name='x2LinkReestabTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='5min', dist_name='MRBTS-1900/NRBTS-1/NRPMRNL-1', p_name='miNrX2CB'),
    dict(value='5min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
]
scf_474_C_008 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_C_008)
tl_474_C_008 = CONFIG_5G(scf=scf_474_C_008)

_PARAMS_TO_MODIFY_SCF_474_G_003 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='maxNumX2Links'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='15min', dist_name='MRBTS-1900/NRBTS-1/NRPMRNL-1', p_name='miNrX2CB'),
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
]
scf_474_G_003 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_G_003)
tl_474_G_003 = CONFIG_5G(scf=scf_474_G_003)

_PARAMS_TO_MODIFY_SCF_474_GE_011 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='x2LinkSupervisionTmr'),
]
scf_474_GE_011 = SCF(project='5G18A',
                     name='SBTS5G18A_5g_pid11_classical.xml',
                     scf_params=_PARAMS_TO_MODIFY_SCF_474_GE_011)
tl_474_GE_011 = CONFIG_5G(scf=scf_474_GE_011)

_PARAMS_TO_MODIFY_SCF_474_G_005 = [
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='maxNumX2Links'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='15min', dist_name='MRBTS-1900/NRBTS-1/NRPMRNL-1', p_name='miNrX2CB'),
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
]
scf_474_G_005 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_G_005)
tl_474_G_005 = CONFIG_5G(scf=scf_474_G_005)

_PARAMS_TO_MODIFY_SCF_474_GE_012 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='x2LinkSupervisionTmr'),
]
scf_474_GE_012 = SCF(project='5G18A',
                     name='SBTS5G18A_5g_pid11_classical.xml',
                     scf_params=_PARAMS_TO_MODIFY_SCF_474_GE_012)
tl_474_GE_012 = CONFIG_5G(scf=scf_474_GE_012)

_PARAMS_TO_MODIFY_SCF_474_GE_013 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='3', dist_name='MRBTS-1900/NRBTS-1', p_name='x2LinkSupervisionTmr'),
]
scf_474_GE_013 = SCF(project='5G18A',
                     name='SBTS5G18A_5g_pid11_classical.xml',
                     scf_params=_PARAMS_TO_MODIFY_SCF_474_GE_013)
tl_474_GE_013 = CONFIG_5G(scf=scf_474_GE_013)

_PARAMS_TO_MODIFY_SCF_474_GE_014 = [
    dict(value='312', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='461', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1', p_name='shutdownNoX2TrafficTmr'),
    dict(value='10', dist_name='MRBTS-1900/NRBTS-1', p_name='enDcX2SetupReqTmr'),
    dict(value='22', dist_name='MRBTS-1900/NRBTS-1', p_name='gNbIdLength'),
    dict(value='2071592', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='257', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='freqBandIndicatorNR'),
    dict(value='240 KHz', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='ssbScs'),
    dict(value='1', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='prachConfigurationIndex'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='x2LinkSupervisionTmr'),
]
scf_474_GE_014 = SCF(project='5G18A',
                     name='SBTS5G18A_5g_pid11_classical.xml',
                     scf_params=_PARAMS_TO_MODIFY_SCF_474_GE_014)
tl_474_GE_014 = CONFIG_5G(scf=scf_474_GE_014)

_PARAMS_TO_MODIFY_SCF_474_D_003 = [
    dict(value='Nokia HZ TL037', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='628333', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='nrarfcn'),
    dict(value='12', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='type0CoresetConfigurationIndex'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destinationIpPrefixLength'),
    dict(value='15min', dist_name='MRBTS-1900/NRBTS-1/NRPMRNL-1', p_name='miNrX2CB'),
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
]
scf_474_D_003 = SCF(project='5G18A',
                    name='SBTS5G18A_5g_pid11_classical.xml',
                    scf_params=_PARAMS_TO_MODIFY_SCF_474_D_003)
tl_474_D_003 = CONFIG_5G(scf=scf_474_D_003)
