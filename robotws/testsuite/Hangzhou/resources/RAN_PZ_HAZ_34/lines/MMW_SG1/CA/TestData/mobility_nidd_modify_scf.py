from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_1390 import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_restapi import *

# define in commission/<testline>/__init__.py
program = BuiltIn().get_variable_value('${PROGRAM}')
testline_name = BuiltIn().get_variable_value('${testline_name}')
adjacent_gnb = BuiltIn().get_variable_value('${adjacent_gnb}')
CA_GROUP_INDEX_INTRA_FREQ = BuiltIn().get_variable_value('${CA_GROUP_INDEX_INTRA_FREQ}')
if CA_GROUP_INDEX_INTRA_FREQ is None:
    CA_GROUP_INDEX_INTRA_FREQ = CA_GROUP_INDEX
else:
    CA_GROUP_INDEX_INTRA_FREQ = int(CA_GROUP_INDEX_INTRA_FREQ)

DN_ADJ_GNB = DN_NRBTS + '/NRADJGNB-1'
DN_ADJ_CELL = DN_NRBTS + '/NRADJNRCELL-1'
DN_MOB_REL = DN_PCELL + '/NRREL-2'
DN_TGT_NRBTS = 'NRBTS-' + adjacent_gnb['gNbId']

PCELL_ID_INTRA_FREQ = PCELL_LIST[CA_GROUP_INDEX_INTRA_FREQ]['nrCellId']
DN_PCELL_INTRA_FREQ = DN_NRBTS + '/NRCELL-%s' % PCELL_ID_INTRA_FREQ
DN_MOB_REL_INTRA_FREQ = DN_PCELL_INTRA_FREQ + '/NRREL-2'

if testline_name == '7_5_UTE5G402T254':
    A1_THRES_HO_SSB_RSRP_SA = 70
else:
    A1_THRES_HO_SSB_RSRP_SA = 90
A1_HYS_SSB_RSRP_SA = 0
A1_TIME_TO_TRIGGER = 'ms80'
if testline_name == '7_5_UTE5G402T254':
    A2_THRES_HO_SSB_RSRP_SA = 65
else:
    A2_THRES_HO_SSB_RSRP_SA = 85
A2_HYS_SSB_RSRP_SA = 0
A2_TIME_TO_TRIGGER = 'ms80'
A3_OFFSET_SSB_RSRP = 6
A3_HYS_SSB_RSRP_SA = 0
A3_TIME_TO_TRIGGER = 'ms80'

# ##### PART 1: configure neighbour relationship (bi-direction)
SCF_ADD_MO_XNLINK = [
    {'dist_name': DN_NRBTS + '/XNLINK-1', 'version': 'NRBTSCL5G21A_2012_200',
     'class_name': 'com.nokia.srbts.nrbts:XNLINK'},
    {'dist_name': DN_NRBTS + '/XNLINK-1', 'p_name': 'cPlaneIpAddr', 'value': str(tl.gnbs[1].dus[0].f1_m_ip_addr)},
    {'dist_name': DN_NRBTS + '/XNLINK-1', 'p_name': 'xnLinkId', 'value': '1'},
]
if program != '22R3':
    SCF_ADD_MO_XNLINK = SCF_ADD_MO_XNLINK + [
        {'dist_name': DN_NRBTS + '/XNLINK-1', 'p_name': 'cPlaneIpAddrCtrl', 'value': 'oamControlled'}
    ]

SCF_ADD_MO_ADJ_GNB = [
    {'dist_name': DN_ADJ_GNB, 'version': 'NRBTSCL5G21A_2012_200', 'class_name': 'com.nokia.srbts.nrbts:NRADJGNB'},
    {'dist_name': DN_ADJ_GNB, 'p_name': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': DN_ADJ_GNB, 'p_name': 'gNbIdLength', 'value': adjacent_gnb['gNbIdLength']},
    {'dist_name': DN_ADJ_GNB, 'p_name': 'gNodeBId', 'value': adjacent_gnb['gNbId']},
    {'dist_name': DN_ADJ_GNB, 'p_name': 'xnLinkRef', 'value': '1'},
    {'dist_name': DN_ADJ_GNB, 'list_name': 'gnbPlmn',
     'elements': {'mcc': adjacent_gnb['mcc'], 'mnc': adjacent_gnb['mnc'], 'mncLength': adjacent_gnb['mncLength']}},
]
if program != '22R3':
    SCF_ADD_MO_ADJ_GNB = SCF_ADD_MO_ADJ_GNB + [
        {'dist_name': DN_ADJ_GNB, 'p_name': 'gNodeBIdCtrl', 'value': 'oamControlled'}
    ]

SCF_TARGET_GNB_ADD_MO_XNLINK = [
    {'dist_name': DN_TGT_NRBTS + '/XNLINK-1', 'version': 'NRBTSCL5G21A_2012_200',
     'class_name': 'com.nokia.srbts.nrbts:XNLINK'},
    {'dist_name': DN_TGT_NRBTS + '/XNLINK-1', 'p_name': 'cPlaneIpAddr', 'value': str(tl.gnbs[0].dus[0].f1_m_ip_addr)},
]

SCF_TARGET_GNB_ADD_MO_ADJ_GNB = [
    {'dist_name': DN_TGT_NRBTS + '/NRADJGNB-1', 'version': 'NRBTSCL5G21A_2012_200',
     'class_name': 'com.nokia.srbts.nrbts:NRADJGNB'},
    {'dist_name': DN_TGT_NRBTS + '/NRADJGNB-1', 'p_name': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': DN_TGT_NRBTS + '/NRADJGNB-1', 'p_name': 'gNbIdLength', 'value': gnb_info['gNbIdLength']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJGNB-1', 'p_name': 'gNodeBId', 'value': gnb_info['gNbId']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJGNB-1', 'p_name': 'xnLinkRef', 'value': '1'},
    {'dist_name': DN_TGT_NRBTS + '/NRADJGNB-1', 'list_name': 'gnbPlmn',
     'elements': {'mcc': gnb_info['mcc'], 'mnc': gnb_info['mnc'], 'mncLength': gnb_info['mncLength']}},
]

# ##### PART 2: configure neighbour cell
SCF_ADD_MO_ADJ_NRCELL = [
    {'dist_name': DN_ADJ_CELL, 'version': 'NRBTSCL5G21A_2012_200', 'class_name': 'com.nokia.srbts.nrbts:NRADJNRCELL'},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'cellDepType', 'value': adjacent_gnb['cellDepType']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'fiveGsTac', 'value': adjacent_gnb['fiveGsTac']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'gNbId', 'value': adjacent_gnb['gNbId']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'gNbIdLength', 'value': adjacent_gnb['gNbIdLength']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'lcrId', 'value': adjacent_gnb['lcrId']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'nrarfcn', 'value': adjacent_gnb['nrarfcn']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'physCellId', 'value': adjacent_gnb['physCellId']},
    {'dist_name': DN_ADJ_CELL, 'list_name': 'gnbPlmn',
     'elements': {'mcc': adjacent_gnb['mcc'], 'mnc': adjacent_gnb['mnc'], 'mncLength': adjacent_gnb['mncLength']}},
]

SCF_TARGET_GNB_ADD_MO_ADJ_NRCELL = [
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'version': 'NRBTSCL5G21A_2012_200',
     'class_name': 'com.nokia.srbts.nrbts:NRADJNRCELL'},
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'p_name': 'cellDepType', 'value': PCELL_LIST[0]['cellDepType']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'p_name': 'fiveGsTac', 'value': PCELL_LIST[0]['fiveGsTac']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'p_name': 'gNbId', 'value': gnb_info['gNbId']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'p_name': 'gNbIdLength', 'value': gnb_info['gNbIdLength']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'p_name': 'lcrId', 'value': PCELL_LIST[0]['lcrId']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'p_name': 'nrarfcn', 'value': PCELL_LIST[0]['nrarfcn']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'p_name': 'physCellId', 'value': PCELL_LIST[0]['physCellId']},
    {'dist_name': DN_TGT_NRBTS + '/NRADJNRCELL-1', 'list_name': 'gnbPlmn',
     'elements': {'mcc': gnb_info['mcc'], 'mnc': gnb_info['mnc'], 'mncLength': gnb_info['mncLength']}},
]

SCF_ADD_MO_NRREL_PCELL_TO_ADJNRCELL = [
    {'dist_name': DN_MOB_REL, 'version': 'NRBTSCL5G21A_2012_200', 'class_name': 'com.nokia.srbts.nrbts:NRREL'},
    {'dist_name': DN_MOB_REL, 'p_name': 'cellIndividualSsbRsrpOffset', 'value': '0dB'},
    {'dist_name': DN_MOB_REL, 'p_name': 'cellIndividualSsbRsrqOffset', 'value': '0dB'},
    {'dist_name': DN_MOB_REL, 'p_name': 'gNbId', 'value': adjacent_gnb['gNbId']},
    {'dist_name': DN_MOB_REL, 'p_name': 'gNbIdLength', 'value': adjacent_gnb['gNbIdLength']},
    {'dist_name': DN_MOB_REL, 'p_name': 'lcrId', 'value': adjacent_gnb['lcrId']},
    {'dist_name': DN_MOB_REL, 'p_name': 'removeNotAllowed', 'value': 'false'},
    {'dist_name': DN_MOB_REL, 'p_name': 'nrRelId', 'value': '2'},
    {'dist_name': DN_MOB_REL, 'list_name': 'gnbPlmn',
     'elements': {'mcc': adjacent_gnb['mcc'], 'mnc': adjacent_gnb['mnc'], 'mncLength': adjacent_gnb['mncLength']}},
]
if program != '22R3':
    SCF_ADD_MO_NRREL_PCELL_TO_ADJNRCELL = SCF_ADD_MO_NRREL_PCELL_TO_ADJNRCELL + [
        {'dist_name': DN_MOB_REL, 'p_name': 'nrDcAllowed', 'value': 'false'}
    ]

SCF_ADD_MO_NRREL_PCELL_TO_ADJNRCELL_INTRA_FREQ = [
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'version': 'NRBTSCL5G21A_2012_200',
     'class_name': 'com.nokia.srbts.nrbts:NRREL'},
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'p_name': 'cellIndividualSsbRsrpOffset', 'value': '0dB'},
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'p_name': 'cellIndividualSsbRsrqOffset', 'value': '0dB'},
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'p_name': 'gNbId', 'value': adjacent_gnb['gNbId']},
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'p_name': 'gNbIdLength', 'value': adjacent_gnb['gNbIdLength']},
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'p_name': 'lcrId', 'value': adjacent_gnb['lcrId']},
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'p_name': 'removeNotAllowed', 'value': 'false'},
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'p_name': 'nrRelId', 'value': '2'},
    {'dist_name': DN_MOB_REL_INTRA_FREQ, 'list_name': 'gnbPlmn',
     'elements': {'mcc': adjacent_gnb['mcc'], 'mnc': adjacent_gnb['mnc'], 'mncLength': adjacent_gnb['mncLength']}},
]

# ##### PART 3: configure measGap and A1/A2 HO measConfig
if program == '21A' or program == '21B':
    mgta = 'msdot5'
else:
    mgta = 'ms0dot5'

SCF_PCELL_MEAS_GAP = [
    dict(dist_name=DN_NRBTS + "/NRPMRNL-1", p_name='miNrRelReportCu', value='5min'),
    dict(dist_name=DN_PCELL, p_name='mgta', value=mgta),
    dict(dist_name=DN_PCELL, p_name='gapOffset', value='19'),
    dict(dist_name=DN_PCELL, p_name='measGapSelection', value='favourUeThroughput'),
    dict(dist_name=DN_PCELL, p_name='measGapSelectionSA', value='favourUeThroughput'),
    dict(dist_name=DN_PCELL, list_name='periodicCsiAcquisition', p_name='csiReportPeriodicity',
         value='slots320'),
    dict(dist_name=DN_PCELL, list_name='csirsForTracking', p_name='csirsTrackingPeriod',
         value='80ms'),
    dict(dist_name=DN_PCELL, p_name='ifhoSsbSmtcOffset', value='19'),
]

SCF_PCELL_HO_A1_MEAS_CONFIG = [
    dict(dist_name=DN_PCELL, p_name='a1MeashoEnabledSA', value='rsrp'),
    dict(dist_name=DN_PCELL, list_name='a1MeashoSsbRsrpSA', p_name='a1HysteresishoSsbRsrpSA',
         value=A1_HYS_SSB_RSRP_SA),
    dict(dist_name=DN_PCELL, list_name='a1MeashoSsbRsrpSA', p_name='a1ThresholdhoSsbRsrpSA',
         value=A1_THRES_HO_SSB_RSRP_SA),
    dict(dist_name=DN_PCELL, list_name='a1MeashoSsbRsrpSA', p_name='a1TimeToTriggerhoSsbRsrpSA',
         value=A1_TIME_TO_TRIGGER),
]

SCF_PCELL_HO_A2_MEAS_CONFIG = [
    dict(dist_name=DN_PCELL, p_name='a2MeashoEnabledSA', value='rsrp'),
    dict(dist_name=DN_PCELL, list_name='a2MeashoSsbRsrpSA', p_name='a2HysteresishoSsbRsrpSA',
         value=A2_HYS_SSB_RSRP_SA),
    dict(dist_name=DN_PCELL, list_name='a2MeashoSsbRsrpSA', p_name='a2ThresholdhoSsbRsrpSA',
         value=A2_THRES_HO_SSB_RSRP_SA),
    dict(dist_name=DN_PCELL, list_name='a2MeashoSsbRsrpSA', p_name='a2TimeToTriggerhoSsbRsrpSA',
         value=A2_TIME_TO_TRIGGER),
]

# ##### PART 4: configure inter-Freq A3/A5 HO measConfig
SCF_ENABLE_HOIF = [
    dict(dist_name=DN_NRBTS, p_name='actInterFreqHoSA', value='true'),
]

SCF_ADD_MO_HOIF_A3_A5_MEAS_CONFIG = [
    dict(dist_name=DN_PCELL_HOIF, version='NRBTSCL5G21A_2012_200', class_name='com.nokia.srbts.nrbts:NRHOIF'),
    dict(dist_name=DN_PCELL_HOIF, p_name='a1BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_PCELL_HOIF, p_name='a3MeasEnabled', value='rsrp'),
    dict(dist_name=DN_PCELL_HOIF, p_name='a5MeasEnabled', value='none'),
    dict(dist_name=DN_PCELL_HOIF, list_name='a3MeasSsbRsrp',
         elements=dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='6', a3TimeToTriggerSsbRsrp='ms80')),
    dict(dist_name=DN_PCELL_HOIF, p_name='cellDepType', value=adjacent_gnb['cellDepType']),
    dict(dist_name=DN_PCELL_HOIF, p_name='chBw', value=adjacent_gnb['chBw']),
    dict(dist_name=DN_PCELL_HOIF, p_name='freqBandIndicatorNR', value=adjacent_gnb['freqBandIndicatorNR']),
    dict(dist_name=DN_PCELL_HOIF, p_name='ifhoSsbScs', value=adjacent_gnb['ssbScs']),
    dict(dist_name=DN_PCELL_HOIF, p_name='ifhoSsbSmtcDuration', value='sf3'),
    dict(dist_name=DN_PCELL_HOIF, p_name='ifhoSsbSmtcPeriodicity', value='sf40'),
    dict(dist_name=DN_PCELL_HOIF, p_name='numberOfTransmittedSsBlocks', value='1 beam'),
    dict(dist_name=DN_PCELL_HOIF, p_name='scs', value=adjacent_gnb['scs']),
    dict(dist_name=DN_PCELL_HOIF, p_name='ssBurstSetPeriod', value=adjacent_gnb['ssBurstSetPeriod']),
    dict(dist_name=DN_PCELL_HOIF, p_name='ssbFrequency', value=adjacent_gnb['ssbFrequency']),
    dict(dist_name=DN_PCELL_HOIF, p_name='a2BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_MOB_REL, p_name='handoverAllowedSA', value='allowed'),
    dict(dist_name=DN_NRBTS, p_name='timerXnDataFwdGuard', value='250'),
    dict(dist_name=DN_PCELL_HOIF, p_name='a4MeasEnDcSteeringEnabled', value='none'),
    dict(dist_name=DN_PCELL_HOIF, p_name='a4MeasHigherPrioFreqEnabled', value='none'),
]
if program != '22R3':
    SCF_ADD_MO_HOIF_A3_A5_MEAS_CONFIG = SCF_ADD_MO_HOIF_A3_A5_MEAS_CONFIG + [
        dict(dist_name=DN_PCELL_HOIF, p_name='a4MeasNrDcEnabled', value='none')
    ]

# ##### PART 5: other common parameters

SCF_ENABLE_DRX = [
    dict(
        dist_name=DN_PCELL,
        p_name='actCDrx',
        value='true'),
]

SCF_ADJ_GNB_MODIFY_DEFAULT_MOBILITY = [
    dict(
        dist_name=DN_TGT_NRBTS + '/SERVEDAMF-1',
        p_name='amfIPAddress',
        value=tl.core.five_g.amf.n2.v4),
]

SCF_MODIFY_DEFAULT_MOBILITY = MODIFY_SCF_DEFAULT + SCF_ENABLE_DRX + SCF_PCELL_MEAS_GAP + SCF_PCELL_HO_A1_MEAS_CONFIG \
                              + SCF_PCELL_HO_A2_MEAS_CONFIG + SCF_ENABLE_HOIF + SCF_DISABLE_CIPHER + \
                              SCF_CHBW_F20M_T60M + SCF_FRAME_STRUCTURE_1116_0 + SCF_BWP_F20M_T60M_1116

SCF_ADD_MO_DEFAULT_MOBILITY = SCF_ADD_MO_ADJ_NRCELL + \
                              SCF_ADD_MO_NRREL_PCELL_TO_ADJNRCELL + SCF_ADD_MO_ADJ_GNB + SCF_ADD_MO_XNLINK + \
                              SCF_ADD_MO_HOIF_A3_A5_MEAS_CONFIG
if DN_MOB_REL_INTRA_FREQ != DN_MOB_REL:
    SCF_ADD_MO_DEFAULT_MOBILITY = SCF_ADD_MO_DEFAULT_MOBILITY + SCF_ADD_MO_NRREL_PCELL_TO_ADJNRCELL_INTRA_FREQ
SCF_ADJ_GNB_ADD_MO_DEFAULT_MOBILITY = SCF_TARGET_GNB_ADD_MO_ADJ_GNB + SCF_TARGET_GNB_ADD_MO_XNLINK + \
                                      SCF_TARGET_GNB_ADD_MO_ADJ_NRCELL

SCF_DELETE_BEFORE_CASE = [
    dict(dist_name=DN_PCELL_HOIF),
    dict(dist_name=DN_ADJ_CELL),
    dict(dist_name=DN_MOB_REL),
    dict(dist_name=DN_ADJ_GNB),
    dict(dist_name=DN_NRBTS + '/XNLINK-1'),
    dict(dist_name=DN_MOB_REL_INTRA_FREQ)
]

SCF_ADJ_GNB_DELETE_BEFORE_CASE = [
    dict(dist_name=DN_TGT_NRBTS + '/NRADJGNB-1'),
    dict(dist_name=DN_TGT_NRBTS + '/XNLINK-1'),
    dict(dist_name=DN_TGT_NRBTS + '/NRADJNRCELL-1')
]

RESTAPI_maxNumOfUsersPerCell = [
    dict(
        dist_name=DN_TGT_NRBTS + '/NRCELL-1',
        parameter='maxNumOfUsersPerCell',
        value='0'),
    dict(
        dist_name=DN_TGT_NRBTS + '/NRCELL-1',
        parameter='maxNumOfCaUsersNRCell',
        value='0'),
    dict(
        dist_name=DN_TGT_NRBTS + '/NRCELL-1',
        parameter='maxNumOfRrcSA',
        value='0'),
    dict(
        dist_name=DN_TGT_NRBTS + '/NRCELL-1',
        parameter='maxNumOfSCellAlloc',
        value='0'),
    dict(
        dist_name=DN_TGT_NRBTS + '/NRCELL-1',
        parameter='maxNumOfUsersNRCell',
        value='0'),
]

API_ENABLE_HOIF = [
    dict(dist_name=DN_NRBTS, parameter='actInterFreqHoSA', value='true'),
    dict(dist_name=DN_NRBTS + "/NRPMRNL-1", parameter='miNrRelReportCu', value='5min'),
]

API_DISABLE_HOIF = [
    dict(dist_name=DN_NRBTS, parameter='actInterFreqHoSA', value='false'),
    dict(dist_name=DN_NRBTS + "/NRPMRNL-1", parameter='miNrRelReportCu', value='disabled'),
]

API_ENABLE_INTRA_FREQ = [
    dict(dist_name=DN_NRBTS, parameter='actIntraFreqHoSA', value='true'),
    dict(dist_name=DN_NRBTS + "/NRPMRNL-1", parameter='miNrRelReportCu', value='5min'),
]

API_DISABLE_INTRA_FREQ = [
    dict(dist_name=DN_NRBTS, parameter='actIntraFreqHoSA', value='false'),
    dict(dist_name=DN_NRBTS + "/NRPMRNL-1", parameter='miNrRelReportCu', value='disabled'),
]

API_NRARFCN_OF_ADJ_NRCELL_INTRA_FREQ = [
    dict(dist_name=DN_ADJ_CELL, parameter='nrarfcn', value=adjacent_gnb['nrarfcn_intra']),
]

API_NRARFCN_OF_ADJ_NRCELL_INTER_FREQ = [
    dict(dist_name=DN_ADJ_CELL, parameter='nrarfcn', value=adjacent_gnb['nrarfcn']),
]

API_PCELL_HO_A3_MEAS_CONFIG = [
    dict(dist_name=DN_PCELL_INTRA_FREQ, parameter='a3MeasEnabled', value='rsrp'),
    dict(dist_name=DN_PCELL_INTRA_FREQ, parameter='a3MeasSsbRsrp',
         value=[{'a3HysteresisSsbRsrp': '0',
                 'a3OffsetSsbRsrp': '6',
                 'a3TimeToTriggerSsbRsrp': 'ms80'}]),
    dict(dist_name=DN_PCELL_INTRA_FREQ, parameter='absThreshSsbRsrpConsolidation', value='0'),
    dict(dist_name=DN_PCELL_INTRA_FREQ, parameter='filterCoeffSsbRsrp', value='fc4'),
    dict(dist_name=DN_PCELL_INTRA_FREQ, parameter='sMeasConfigSsbRsrp', value='70'),
]

API_CASE_MEAS_GAP = RESTAPI_ENABLE_DRX + API_DISABLE_INTRA_FREQ + API_ENABLE_HOIF + \
                    API_NRARFCN_OF_ADJ_NRCELL_INTER_FREQ
API_CASE_HO_INTER_FREQ = RESTAPI_ENABLE_DRX + API_DISABLE_INTRA_FREQ + API_ENABLE_HOIF + \
                         API_NRARFCN_OF_ADJ_NRCELL_INTER_FREQ
API_CASE_HO_INTRA_FREQ = RESTAPI_ENABLE_DRX + API_DISABLE_HOIF + API_ENABLE_INTRA_FREQ + \
                         API_NRARFCN_OF_ADJ_NRCELL_INTRA_FREQ + API_PCELL_HO_A3_MEAS_CONFIG

TGT_GNB_API_NRARFCN_INTRA_FREQ = [
    dict(dist_name=DN_TGT_NRBTS + '/NRCELL-1/NRCELL_FDD-1', parameter='nrarfcnDl',
         value=adjacent_gnb['nrarfcn_intra'])
]

TGT_GNB_API_NRARFCN_INTER_FREQ = [
    dict(dist_name=DN_TGT_NRBTS + '/NRCELL-1/NRCELL_FDD-1', parameter='nrarfcnDl',
         value=adjacent_gnb['nrarfcn'])
]
