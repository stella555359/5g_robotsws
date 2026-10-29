import os

from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_NRBTSname = 'MRBTS-1900/NRBTS-1'
_NRCELLname = 'MRBTS-1900/NRBTS-1/NRCELL-1'
_NRCELLGRP = 'MRBTS-1900/NRBTS-1/NRCELLGRP-0'
_p_name = 'dlFlowControlAlgo'
tl_scf_filename = 'SBTS5G19_5g_pid12_classical.xml'
_ipv6route = '2a00:8a00:8000:136:10:57:227:1'
_ipv6addr = 'MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'
_ipv6router = '0000:0000:0000:0000:0000:0000:0000:0000'

PARAMS_Modify_AES_IPV6 = [
    dict(value='123', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-2', p_name='localIpPrefixLength'),
    dict(value='123', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-3', p_name='localIpPrefixLength'),
    dict(value='123', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-4', p_name='localIpPrefixLength'),
    dict(value=_ipv6router, dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1', p_name='destIpv6Addr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1', p_name='destinationIpv6PrefixLength'),
    dict(value=_ipv6route, dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1', p_name='gatewayIpv6Addr'),
    dict(value=1, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea0'),
    dict(value=3, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea1_128'),
    dict(value=9, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea2_128'),
    dict(value=2, dist_name='MRBTS-1900/NRBTS-1', list_name='cipherPrefL', p_name='nea3_128'),
]

PARAMS_TO_REMOVE_SCF = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
]

tl_scf_param_509 = [
    dict(value='7_5_HZ_TLIV39', dist_name='MRBTS-1900', p_name='btsName'),
    dict(value='302', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='610', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='3', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='false', dist_name=_NRBTSname, p_name='actDlDataForwardingX2'),
    dict(value='t32', dist_name=_NRBTSname, list_name='rlcProf4', p_name='maxRetxThreshold'),
    dict(value='636666', dist_name=_NRCELLname, p_name='nrarfcn'),
    dict(value='100MHz', dist_name=_NRCELLname, p_name='chBw'),
    dict(value='230', dist_name=_NRCELLname, p_name='pMax'),
    dict(value='0', dist_name=_NRCELLname, p_name='dllaIniMcs'),
    dict(value='0', dist_name=_NRCELLname, p_name='ullaIniMcs'),
    dict(value='51', dist_name=_NRCELLname, p_name='physCellId'),
    dict(value=7880, dist_name=_NRCELLname, p_name='gscn'),
    dict(value=98, dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value=13, dist_name=_NRCELLname, p_name='zeroCorrelationZoneConfig'),
    dict(value=78, dist_name=_NRCELLname, p_name='freqBandIndicatorNR'),
    dict(value=12, dist_name=_NRCELLname, p_name='type0CoresetConfigurationIndex'),
    dict(value='0.0.0.0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destIpAddr'),
    dict(value='0', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='destinationIpPrefixLength'),
    dict(value='1500', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPRT-1', p_name='routeIpMtu'),
    dict(value='true', dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1', p_name='actServiceAccountSsh'),
    dict(value='false', dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1', p_name='systemAcctPermEnable'),
    dict(value='5G19/5g_pid12_class_eoc', dist_name='MRBTS-1900/EQM-1/APEQM-1', p_name='rapProfile'),
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
    dict(value='true', dist_name=_NRCELLname, list_name='beamSet', p_name='nrBtsBeamRefinementP2'),
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='sCCNumber'),
    dict(value='20', dist_name=_NRCELLname, p_name='pMaxNROwnCell'),
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='0ms', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='20', dist_name=_NRCELLGRP, p_name='ssBurstSetPeriod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actUeInitRlf'),
    dict(value='false', dist_name=_NRBTSname, p_name='actGnbInitRlf'),
    dict(value='150', dist_name=_NRCELLname, p_name='ullaDeltaSinrMax'),
    dict(value='-150', dist_name=_NRCELLname, p_name='ullaDeltaSinrMin'),
    dict(value='100', dist_name=_NRCELLname, p_name='ullaDeltaSinrStepdown'),
]

_PARAMS_MODSCF_509_B_7 = [
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
    dict(value='false', dist_name=_NRBTSname, list_name='qciTab7Nsa3x', p_name='nsa3xBearerAllowed'),
]
scf_509_B_007 = SCF(project='5G18A', name=tl_scf_filename, scf_params=_PARAMS_MODSCF_509_B_7)
tl_509_B_007 = CONFIG_5G(scf=scf_509_B_007)

_PARAMS_MODSCF_509_B_8 = [
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
]
scf_509_B_008 = SCF(project='5G18A', name=tl_scf_filename, scf_params=_PARAMS_MODSCF_509_B_8)
tl_509_B_008 = CONFIG_5G(scf=scf_509_B_008)

_PARAMS_MODSCF_509_B_12 = [
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
    dict(value='false', dist_name=_NRBTSname, p_name='actUeInitRlf'),
    dict(value='false', dist_name=_NRBTSname, p_name='actGnbInitRlf'),
    dict(value='t1', dist_name='MRBTS-1900/NRBTS-1', list_name='rlcProf4', p_name='maxRetxThreshold'),
]
scf_509_B_012 = SCF(project='5G18A', name=tl_scf_filename, scf_params=_PARAMS_MODSCF_509_B_12)
tl_509_B_012 = CONFIG_5G(scf=scf_509_B_012)

_PARAMS_MODSCF_509_B_13 = [
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
    dict(value='4294967000', dist_name='MRBTS-1900/NRBTS-1', p_name='keyRefrMarg'),
]
scf_509_B_013 = SCF(project='5G18A', name=tl_scf_filename, scf_params=_PARAMS_MODSCF_509_B_13)
tl_509_B_013 = CONFIG_5G(scf=scf_509_B_013)

_PARAMS_MODSCF_509_B_14 = [
    dict(value='15min', dist_name='MRBTS-1900/MNL-1/PMCADM-1', p_name='reportingIntervalPm'),
    dict(value='4294960000', dist_name='MRBTS-1900/NRBTS-1', p_name='keyRefrMarg'),
]
scf_509_B_014 = SCF(project='5G18A', name=tl_scf_filename, scf_params=_PARAMS_MODSCF_509_B_14)
tl_509_B_014 = CONFIG_5G(scf=scf_509_B_014)

parameter_509_B_24_01 = [
    dict(value='ms0', dist_name='MRBTS-1900/NRBTS-1', list_name='pdcpProf2', p_name='tReordering'),
]

parameter_509_B_24_02 = [
    dict(value='ms160', dist_name='MRBTS-1900/NRBTS-1', list_name='pdcpProf2', p_name='tReordering'),
]

parameter_509_B_24_03 = [
    dict(value='ms3000', dist_name='MRBTS-1900/NRBTS-1', list_name='pdcpProf2', p_name='tReordering'),
]

_PARAMS_MODSCF_509_B_25 = [
    dict(value='0', dist_name='MRBTS-1900/NRBTS-1', p_name='keyRefrMarg'),
]
scf_509_B_025 = SCF(project='5G18A', name=tl_scf_filename, scf_params=_PARAMS_MODSCF_509_B_25)
tl_509_B_025 = CONFIG_5G(scf=scf_509_B_025)
