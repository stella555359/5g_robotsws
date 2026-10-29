from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_1390 import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_restapi import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.vonr_nidd_add_or_modify import *

# define in commission/<testline>/__init__.py
program = BuiltIn().get_variable_value('${PROGRAM}')
testline_name = BuiltIn().get_variable_value('${testline_name}')

A1_THRES_SCELL_ADD_SSB_RSRP_TDD = 70
A1_HYS_SCELL_ADD_SSB_RSRP = 0
A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP = 'ms320'


A2_THRES_SCELL_ADD_SSB_RSRP_TDD = 87
A2_HYS_SCELL_ADD_SSB_RSRP = 0
A2_TIME_TO_TRIGGER = 'ms480'

A3_OFFSET_SSB_RSRP = 0
A3_HYS_SSB_RSRP_SA = 5
A3_TIME_TO_TRIGGER = 'ms40'
A3_TARGET_SSB_FRE = BuiltIn().get_variable_value('${A3_TARGET_SSB_FRE}')

SCF_SCELL_ADD_CONFIG = [
    dict(
        dist_name=DN_PCELL,
        p_name='a1MeasSCellAddEnabled',
        value='rsrp'),
    dict(
        dist_name=DN_PCELL,
        list_name='a1MeasSCellAddSsbRsrp',
        p_name='a1HysteresisSCellAddSsbRsrp',
        value=A1_HYS_SCELL_ADD_SSB_RSRP),
    dict(
        dist_name=DN_PCELL,
        list_name='a1MeasSCellAddSsbRsrp',
        p_name='a1ThresholdSCellAddSsbRsrpTDD',
        value=A1_THRES_SCELL_ADD_SSB_RSRP_TDD),
    dict(
        dist_name=DN_PCELL,
        list_name='a1MeasSCellAddSsbRsrp',
        p_name='a1TimeToTriggerSCellAddSsbRsrp',
        value='320ms'),
]


SCF_PCELL_MEAS_GAP = [
    dict(
        dist_name=DN_NRBTS + "/NRPMRNL-1",
        p_name='miNrRelReportCu',
        value='5min'),
    dict(
        dist_name=DN_PCELL,
        p_name='mgta',
        value='ms0dot5'),
    dict(
        dist_name=DN_PCELL,
        p_name='gapOffset',
        value=A3_OFFSET_SSB_RSRP),
    dict(
        dist_name=DN_PCELL,
        p_name='measGapSelectionSA',
        value='favourUeThroughput'),
    dict(
        dist_name=DN_PCELL,
        list_name='periodicCsiAcquisition',
        p_name='csiReportPeriodicity',
        value='slots320'),
    dict(
        dist_name=DN_PCELL,
        list_name='csirsForTracking',
        p_name='csirsTrackingPeriod',
        value='80ms'),
    dict(
        dist_name=DN_PCELL,
        p_name='ifhoSsbSmtcOffset',
        value='0'),
]

MODIFY_SCF_FOR_RRE_COMMON_TMP = [
    dict(
        value='sameGNB',
        dist_name=DN_NRBTS,
        p_name='rrcReestabTypeSA'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actGnbInitRlf'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actUeInitRlf'),
    dict(
        value='2000ms',
        dist_name=DN_NRBTS,
        p_name='t310'),
    dict(
        dist_name=DN_PCELL,
        value='2000ms',
        p_name='t310'),
    dict(
        dist_name=DN_SCELL,
        value='2000ms',
        p_name='t310'),
    dict(
        dist_name=DN_NRBTS,
        p_name='t311',
        value='30000ms'),
    dict(
        dist_name=DN_PCELL,
        p_name='t311',
        value='30000ms'),
    dict(
        dist_name=DN_SCELL,
        p_name='t311',
        value='30000ms'),
    dict(
        dist_name=DN_PCELL,
        p_name='t301',
        value='2000ms'),
    dict(
        dist_name=DN_PCELL,
        p_name='n310',
        value='n10'),
    dict(
        dist_name=DN_PCELL,
        p_name='n311',
        value='n1'),
    dict(
        dist_name=DN_SCELL,
        p_name='t301',
        value='2000ms'),
    dict(
        dist_name=DN_SCELL,
        p_name='n310',
        value='n10'),
    dict(
        dist_name=DN_SCELL,
        p_name='n311',
        value='n1'),
    dict(
        dist_name=DN_NRBTS,
        p_name='tRLFindForDU',
        value='3000ms'),
    dict(
        dist_name=DN_NRBTS,
        p_name='tWaitingRlRecover',
        value='10000ms'),
    dict(
        dist_name=DN_PCELL,
        p_name='rlpRecCsiBsiThreshold',
        value='2'),
    dict(
        dist_name=DN_PCELL,
        p_name='actUlDftSOfdm',
        value='false'),
    dict(
        dist_name=DN_PCELL,
        p_name='rlpRecDlHarqThreshold',
        value='5'),
    dict(
        dist_name=DN_PCELL,
        p_name='rlpDetCsiBsiThreshold',
        value='10000'),
    dict(
        dist_name=DN_PCELL,
        p_name='rlpDetDlHarqThreshold',
        value='35'),
    dict(
        dist_name=DN_SCELL,
        p_name='rlpRecCsiBsiThreshold',
        value='2'),
    dict(
        dist_name=DN_SCELL,
        p_name='rlpRecDlHarqThreshold',
        value='5'),
    dict(
        dist_name=DN_SCELL,
        p_name='rlpDetCsiBsiThreshold',
        value='10000'),
    dict(
        dist_name=DN_SCELL,
        p_name='rlpDetDlHarqThreshold',
        value='35'),
    dict(
        value='t32',
        dist_name=DN_NRBTS,
        p_name='dlMaxRetxThreshold',
        list_name='srb2RlcAmProf'),
    dict(
        value='t1',
        dist_name=DN_NRBTS,
        p_name='ulMaxRetxThreshold',
        list_name='srb2RlcAmProf'),
    dict(
        value='t32',
        dist_name=DN_NRBTS,
        p_name='dlMaxRetxThreshold',
        list_name='srb3RlcAmProf'),
    dict(
        value='t1',
        dist_name=DN_NRBTS,
        p_name='ulMaxRetxThreshold',
        list_name='srb3RlcAmProf'),
    dict(
        dist_name=DN_NRBTS + '/NRDRB_RLC_AM-1',
        p_name='dlMaxRetxThreshold',
        value='t32'),
    dict(
        dist_name=DN_NRBTS + '/NRDRB_RLC_AM-1',
        p_name='ulMaxRetxThreshold',
        value='t1'),
    dict(
        dist_name=DN_NRBTS + '/NRDRB_RLC_AM-2',
        p_name='dlMaxRetxThreshold',
        value='t32'),
    dict(
        dist_name=DN_NRBTS + '/NRDRB_RLC_AM-2',
        p_name='ulMaxRetxThreshold',
        value='t1'),
    dict(
        dist_name=DN_PCELL + '/NRREL-1',
        p_name='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
        dist_name=DN_NRBTS,
        p_name='sCellActivationMethod',
        value='bufferBased'),
    dict(
        dist_name=DN_NRBTS,
        value='false',
        p_name='actInterFreqHoSA'),
    dict(
        dist_name=DN_PCELL,
        value='91',
        p_name='a1ThresholdhoSsbRsrpSA',
        list_name='a1MeashoSsbRsrpSA'),
] + SCF_SCELL_ADD_CONFIG + SCF_DISABLE_CIPHER

MODIFY_SCF_NEWLY_INTRODUCED_FROM_23R2 = [
    dict(
        dist_name=DN_NRBTS,
        p_name='tRLFindForDUSA',
        value='3000ms'),
    dict(
        dist_name=DN_NRBTS,
        p_name='tWaitingRlRecoverSA',
        value='10000ms')
]

PARAMS_TO_MODIFY_FOR_TL254_RRE_TRIGGERED_BY_RLC_MAX_RETX = [
    dict(
        value="t32",
        dist_name=DN_NRBTS + "/NRDRB_RLC_AM-1",
        p_name="dlMaxRetxThreshold",
    ),
    dict(
        value="t1",
        dist_name=DN_NRBTS + "/NRDRB_RLC_AM-1",
        p_name="ulMaxRetxThreshold",
    ),
    dict(
        value="t32",
        dist_name=DN_NRBTS + "/NRDRB_RLC_AM-2",
        p_name="dlMaxRetxThreshold",
    ),
    dict(
        value="t1",
        dist_name=DN_NRBTS + "/NRDRB_RLC_AM-2",
        p_name="ulMaxRetxThreshold",
    ),
    dict(
        dist_name=DN_NRBTS,
        list_name="srb1RlcAmProf",
        p_name="dlMaxRetxThreshold",
        value="t32",
    ),
    dict(
        dist_name=DN_NRBTS,
        list_name="srb1RlcAmProf",
        p_name="ulMaxRetxThreshold",
        value="t1",
    ),
    dict(
        dist_name=DN_NRBTS,
        list_name="srb2RlcAmProf",
        p_name="dlMaxRetxThreshold",
        value="t32",
    ),
    dict(
        dist_name=DN_NRBTS,
        list_name="srb2RlcAmProf",
        p_name="ulMaxRetxThreshold",
        value="t1",
    ),
    dict(
        dist_name=DN_NRBTS,
        list_name="srb3RlcAmProf",
        p_name="dlMaxRetxThreshold",
        value="t32",
    ),
    dict(
        dist_name=DN_NRBTS,
        list_name="srb3RlcAmProf",
        p_name="ulMaxRetxThreshold",
        value="t1",
    ),
    dict(
        value="60",
        dist_name=DN_NRBTS,
        p_name="srbInactivityTimerSA",
    ),
    dict(
        value="60",
        dist_name=DN_NRBTS,
        p_name="drbInactivityTimerSA",
    ),
    dict(
        value="60",
        dist_name=DN_NRBTS,
        p_name="drbInactivityTimerSA5qi1",
    ),
    dict(
        value="60",
        dist_name=DN_NRBTS,
        p_name="drbInactivityTimerSA5qi5",
    ),
    dict(value="2000ms", dist_name=DN_PCELL, p_name="t301"),
    dict(value="30000ms", dist_name=DN_PCELL, p_name="t311"),
    dict(
        value="0",
        dist_name=DN_PCELL,
        p_name="rlpDetCsiBsiThreshold",
    ),
]

if program not in ['23R3', '23R4', '24R1']:
    MODIFY_SCF_FOR_RRE_COMMON = MODIFY_SCF_FOR_RRE_COMMON_TMP + MODIFY_SCF_NEWLY_INTRODUCED_FROM_23R2 + [
        dict(value='A1-based', dist_name=DN_NRBTS, list_name='actMeasBasedSCellAdditionSa')]
else:
    MODIFY_SCF_FOR_RRE_COMMON = MODIFY_SCF_FOR_RRE_COMMON_TMP + MODIFY_SCF_NEWLY_INTRODUCED_FROM_23R2 + [
        dict(value='true', dist_name=DN_NRBTS, p_name='actMeasBasedSCellAddition')]

PARAMS_TO_MODIFY_CDRX_VONR_732 = MODIFY_SCF_DEFAULT + MODIFY_NRDRB_10_SCF + \
    create_cdrx_and_vonr_according_to_pcell_to_modify(dn_pcell_list=DN_PCELL_LIST,
                                                      drxInactivityTimer='80ms',
                                                      drxLongCycle='160ms',
                                                      drxOnDurationTimer='10ms')

MODIFY_SCF_ACT_UL_SCHEDULING = [
    dict(
        dist_name=DN_PCELL,
        value='false',
        p_name='actProactUlScheduling'),
]

MODIFY_SCF_FOR_INTERFREQHO_VONR_RRE_TMP = PARAMS_TO_MODIFY_CDRX_VONR_732 + MODIFY_SCF_FOR_RRE_COMMON + [
    dict(
        dist_name=DN_NRBTS,
        value='true',
        p_name='actInterFreqHoSA'),
    dict(
        dist_name=DN_PCELL,
        value='rsrp',
        p_name='a1MeashoEnabledSA'),
    dict(
        dist_name=DN_PCELL,
        value='rsrp',
        p_name='a2MeashoEnabledSA'),
    dict(
        dist_name=DN_PCELL,
        value='none',
        p_name='a2MeashoEnabled'),
    dict(
        value=A2_THRES_SCELL_ADD_SSB_RSRP_TDD,
        dist_name=DN_PCELL,
        p_name='a2ThresholdhoSsbRsrpSA',
        list_name='a2MeashoSsbRsrpSA'),
    dict(
        value=A2_HYS_SCELL_ADD_SSB_RSRP,
        dist_name=DN_PCELL,
        p_name='a2HysteresishoSsbRsrpSA',
        list_name='a2MeashoSsbRsrpSA'),
    dict(
        value=A2_TIME_TO_TRIGGER,
        dist_name=DN_PCELL,
        p_name='a2TimeToTriggerhoSsbRsrpSA',
        list_name='a2MeashoSsbRsrpSA'),
    dict(
        value='rsrp',
        dist_name=DN_PCELL + '/NRHOIF-1',
        p_name='a3MeasEnabled'),
    dict(
        value=A3_OFFSET_SSB_RSRP,
        dist_name=DN_PCELL + '/NRHOIF-1',
        p_name='a3OffsetSsbRsrp',
        list_name='a3MeasSsbRsrp'),
    dict(
        value=A3_HYS_SSB_RSRP_SA,
        dist_name=DN_PCELL + '/NRHOIF-1',
        p_name='a3HysteresisSsbRsrp',
        list_name='a3MeasSsbRsrp'),
    dict(
        value=A3_TIME_TO_TRIGGER,
        dist_name=DN_PCELL + '/NRHOIF-1',
        p_name='a3TimeToTriggerSsbRsrp',
        list_name='a3MeasSsbRsrp'),
    dict(
        value=A3_TARGET_SSB_FRE,
        dist_name=DN_PCELL + '/NRHOIF-1',
        p_name='ssbFrequency'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrRRCC'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrNGCC'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrRRCD'),
] + SCF_PCELL_MEAS_GAP

MODIFY_SCF_FOR_INTERFREQHO_VONR_RRE = MODIFY_SCF_FOR_INTERFREQHO_VONR_RRE_TMP + \
        MODIFY_SCF_ACT_UL_SCHEDULING

PARAMS_TO_ADD_FOR_732_08_CASE = PARAMS_TO_ADD_FOR_VONR_AND_CDRX + [
    dict(
        dist_name=DN_PCELL,
        value='n10',
        p_name='n310VoNR'),
    dict(
        dist_name=DN_PCELL,
        value='2000ms',
        p_name='t310VoNR'),
    dict(
        dist_name=DN_NRBTS,
        p_name='tRLFindForDUVoNR',
        value='3000ms'),
]

PARAMS_TO_DELETE_FOR_732_08_CASE_22R2 = [
    dict(dist_name=DN_PCELL,
         p_name="ulProGrantTimer"),
]

if program == '22R2':
    PARAMS_TO_DELETE_FOR_732_08_CASE = PARAMS_TO_DELETE_FOR_732_08_CASE_22R2
else:
    PARAMS_TO_DELETE_FOR_732_08_CASE = []
