from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
from NIDD_modify_scf import *
from NIDD_modify_rest_api_2329 import *
testline_name = BuiltIn().get_variable_value('${testline_name}')
adjacent_gnb_tdd_cell_1 = BuiltIn().get_variable_value('${adjacent_gnb_tdd_cell_1}')
adjacent_gnb_fdd_cell_1 = BuiltIn().get_variable_value('${adjacent_gnb_fdd_cell_1}')
A1_THRES_HO_SSB_RSRP_SA = BuiltIn().get_variable_value('${A1_THRES_HO_SSB_RSRP_SA}')
A2_THRES_HO_SSB_RSRP_SA = BuiltIn().get_variable_value('${A2_THRES_HO_SSB_RSRP_SA}')

DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

GNB_INFO = param_modify_lib.get_bts_info_from_scf_file(local_scf_file_path=SCF_DEFAULT_FILE_PATH)

CA_GROUP_INDEX_INTRA_FREQ = BuiltIn().get_variable_value('${CA_GROUP_INDEX_INTRA_FREQ}')
if CA_GROUP_INDEX_INTRA_FREQ is None:
    CA_GROUP_INDEX_INTRA_FREQ = CA_GROUP_INDEX
else:
    CA_GROUP_INDEX_INTRA_FREQ = int(CA_GROUP_INDEX_INTRA_FREQ)

DN_ADJ_GNB = DN_NRBTS + '/NRADJGNB-1'
DN_ADJ_CELL = DN_NRBTS + '/NRADJNRCELL-1'
DN_MOB_REL = DN_PCELL + '/NRREL-2'
DN_TGT_NRBTS = 'NRBTS-' + adjacent_gnb_tdd_cell_1['gNbId']

A1_HYS_SSB_RSRP_SA = 0
A1_TIME_TO_TRIGGER = 'ms80'

A2_HYS_SSB_RSRP_SA = 0
A2_TIME_TO_TRIGGER = 'ms2560'
A3_OFFSET_SSB_RSRP = 6
A3_HYS_SSB_RSRP_SA = 0
A3_TIME_TO_TRIGGER = 'ms80'
mgta = 'ms0dot5'
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
    {'dist_name': DN_ADJ_GNB, 'p_name': 'gNbIdLength', 'value': adjacent_gnb_tdd_cell_1['gNbIdLength']},
    {'dist_name': DN_ADJ_GNB, 'p_name': 'gNodeBId', 'value': adjacent_gnb_tdd_cell_1['gNbId']},
    {'dist_name': DN_ADJ_GNB, 'p_name': 'xnLinkRef', 'value': '1'},
    {'dist_name': DN_ADJ_GNB, 'list_name': 'gnbPlmn',
     'elements': {'mcc': adjacent_gnb_tdd_cell_1['mcc'], 'mnc': adjacent_gnb_tdd_cell_1['mnc'],
                  'mncLength': adjacent_gnb_tdd_cell_1['mncLength']}},
]
if program != '22R3':
    SCF_ADD_MO_ADJ_GNB = SCF_ADD_MO_ADJ_GNB + [
        {'dist_name': DN_ADJ_GNB, 'p_name': 'gNodeBIdCtrl', 'value': 'oamControlled'}
    ]

SCF_ADD_MO_ADJ_GNB_FDD_NRCELL = [
    {'dist_name': DN_ADJ_CELL, 'version': 'NRBTSCL5G21A_2012_200', 'class_name': 'com.nokia.srbts.nrbts:NRADJNRCELL'},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'cellDepType', 'value': adjacent_gnb_fdd_cell_1['cellDepType']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'fiveGsTac', 'value': adjacent_gnb_fdd_cell_1['fiveGsTac']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'gNbId', 'value': adjacent_gnb_fdd_cell_1['gNbId']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'gNbIdLength', 'value': adjacent_gnb_fdd_cell_1['gNbIdLength']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'freqBandIndicatorNR',
     'value': adjacent_gnb_fdd_cell_1['freqBandIndicatorNR']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'lcrId', 'value': adjacent_gnb_fdd_cell_1['lcrId']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'nrarfcn', 'value': adjacent_gnb_fdd_cell_1['nrarfcn']},
    {'dist_name': DN_ADJ_CELL, 'p_name': 'physCellId', 'value': adjacent_gnb_fdd_cell_1['physCellId']},
    {'dist_name': DN_ADJ_CELL, 'list_name': 'gnbPlmn',
     'elements': {'mcc': adjacent_gnb_fdd_cell_1['mcc'], 'mnc': adjacent_gnb_fdd_cell_1['mnc'],
                  'mncLength': adjacent_gnb_fdd_cell_1['mncLength']}},
]

SCF_ADD_MO_NRREL_PCELL_TO_ADJNRCELL = [
    {'dist_name': DN_MOB_REL, 'version': 'NRBTSCL5G21A_2012_200', 'class_name': 'com.nokia.srbts.nrbts:NRREL'},
    {'dist_name': DN_MOB_REL, 'p_name': 'cellIndividualSsbRsrpOffset', 'value': '0dB'},
    {'dist_name': DN_MOB_REL, 'p_name': 'cellIndividualSsbRsrqOffset', 'value': '0dB'},
    {'dist_name': DN_MOB_REL, 'p_name': 'gNbId', 'value': adjacent_gnb_tdd_cell_1['gNbId']},
    {'dist_name': DN_MOB_REL, 'p_name': 'gNbIdLength', 'value': adjacent_gnb_tdd_cell_1['gNbIdLength']},
    {'dist_name': DN_MOB_REL, 'p_name': 'lcrId', 'value': adjacent_gnb_tdd_cell_1['lcrId']},
    {'dist_name': DN_MOB_REL, 'p_name': 'removeNotAllowed', 'value': 'false'},
    {'dist_name': DN_MOB_REL, 'p_name': 'nrRelId', 'value': '2'},
    {'dist_name': DN_MOB_REL, 'list_name': 'gnbPlmn',
     'elements': {'mcc': adjacent_gnb_tdd_cell_1['mcc'], 'mnc': adjacent_gnb_tdd_cell_1['mnc'],
                  'mncLength': adjacent_gnb_tdd_cell_1['mncLength']}},
]

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
         elements=dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='6', a3TimeToTriggerSsbRsrp='ms2560')),
    dict(dist_name=DN_PCELL_HOIF, p_name='cellDepType', value=adjacent_gnb_tdd_cell_1['cellDepType']),
    dict(dist_name=DN_PCELL_HOIF, p_name='chBw', value=adjacent_gnb_tdd_cell_1['chBw']),
    dict(dist_name=DN_PCELL_HOIF, p_name='freqBandIndicatorNR',
         value=adjacent_gnb_tdd_cell_1['freqBandIndicatorNR']),
    dict(dist_name=DN_PCELL_HOIF, p_name='ifhoSsbScs', value=adjacent_gnb_tdd_cell_1['ssbScs']),
    dict(dist_name=DN_PCELL_HOIF, p_name='ifhoSsbSmtcDuration', value='sf3'),
    dict(dist_name=DN_PCELL_HOIF, p_name='ifhoSsbSmtcPeriodicity', value='sf40'),
    dict(dist_name=DN_PCELL_HOIF, p_name='numberOfTransmittedSsBlocks', value='1 beam'),
    dict(dist_name=DN_PCELL_HOIF, p_name='scs', value=adjacent_gnb_tdd_cell_1['scs']),
    dict(dist_name=DN_PCELL_HOIF, p_name='ssBurstSetPeriod', value=adjacent_gnb_tdd_cell_1['ssBurstSetPeriod']),
    dict(dist_name=DN_PCELL_HOIF, p_name='ssbFrequency', value=adjacent_gnb_tdd_cell_1['ssbFrequency']),
    dict(dist_name=DN_PCELL_HOIF,  p_name='a2BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_MOB_REL, p_name='handoverAllowedSA', value='allowed'),
    dict(dist_name=DN_NRBTS, p_name='timerXnDataFwdGuard', value='250'),
    dict(dist_name=DN_PCELL_HOIF, p_name='a4MeasEnDcSteeringEnabled', value='none'),
    dict(dist_name=DN_PCELL_HOIF, p_name='a4MeasHigherPrioFreqEnabled', value='none'),
]
if program != '22R3':
    SCF_ADD_MO_HOIF_A3_A5_MEAS_CONFIG = SCF_ADD_MO_HOIF_A3_A5_MEAS_CONFIG + [
        dict(dist_name=DN_PCELL_HOIF, p_name='a4MeasNrDcEnabled', value='none')
    ]

SCF_DELETE_BEFORE_CASE = [
    dict(dist_name=DN_PCELL_HOIF),
    dict(dist_name=DN_ADJ_CELL),
    dict(dist_name=DN_MOB_REL),
    dict(dist_name=DN_ADJ_GNB),
    dict(dist_name=DN_NRBTS + '/XNLINK-1'),
]

SCF_MODIFY_DEFAULT_MOBILITY = MODIFY_SCF_DEFAULT_20M_100M_1116_3 + SCF_PCELL_MEAS_GAP + \
                              SCF_PCELL_HO_A1_MEAS_CONFIG + SCF_PCELL_HO_A2_MEAS_CONFIG + SCF_ENABLE_HOIF + \
                              SCF_DISABLE_CIPHER

SCF_ADD_MO_DEFAULT_MOBILITY = SCF_ADD_MO_NRREL_PCELL_TO_ADJNRCELL + SCF_ADD_MO_ADJ_GNB + \
                              SCF_ADD_MO_ADJ_GNB_FDD_NRCELL + SCF_ADD_MO_XNLINK + \
                              SCF_ADD_MO_HOIF_A3_A5_MEAS_CONFIG + ADD_SCF_DEFAULT

SCF_DELETE_DEFAULT_MOBILITY = SCF_DELETE_BEFORE_CASE + DELETE_SCF_DEFAULT

SCF_TGT_GNB_MODIFY_DEFAULT_MOBILITY = [
    dict(
        dist_name=DN_TGT_NRBTS + '/SERVEDAMF-1',
        p_name='amfIPAddress',
        value=tl.core.five_g.amf.n2.v4),
]
