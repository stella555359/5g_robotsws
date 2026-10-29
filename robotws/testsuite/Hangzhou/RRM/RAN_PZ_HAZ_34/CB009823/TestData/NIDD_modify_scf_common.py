import math
from robot.libraries.BuiltIn import BuiltIn
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')

tl = BuiltIn().get_variable_value("${tl}")
PROGRAM = BuiltIn().get_variable_value("${PROGRAM}")
TCE_IP_ADDR = BuiltIn().get_variable_value("${TCE_IP_ADDR}")
TCE_PORT = BuiltIn().get_variable_value("${TCE_PORT}")
DN_MRBTS = "MRBTS-" + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + "/NRBTS-" + str(tl.gnbs[0].global_bts_id)

TDD_CELL_ID = 1
TDD_CELL_ID_GNB1 = 1

TDD_CELL_ID_LIST = [TDD_CELL_ID]
CELL_LIST_GNB0 = [TDD_CELL_ID]
CELL_LIST_GNB1 = [TDD_CELL_ID_GNB1]

DN_TDDCELL = DN_NRBTS + "/NRCELL-%s" % TDD_CELL_ID
DN_NRRIM = DN_TDDCELL + "/NRRIM_PROFILE-1"
DN_MRBTS_GNB1 = "MRBTS-" + str(tl.gnbs[1].instance_id)
DN_NRBTS_GNB1 = DN_MRBTS_GNB1 + "/NRBTS-" + str(tl.gnbs[1].global_bts_id)
DN_TDDCELL_GNB1 = DN_NRBTS_GNB1 + "/NRCELL-" + str(TDD_CELL_ID_GNB1)
DN_SYNC_GNB1 = DN_MRBTS_GNB1 + "/MNL-1/MNLENT-1/SYNC-1"
DN_NRRIM_GNB1 = DN_TDDCELL_GNB1 + "/NRRIM_PROFILE-1"

# add begin by 10437-jx
TCEADM = DN_MRBTS + '/MNL-1/TCEADM-1'
TCE = TCEADM + '/TCE-1'
NRMTRACECU = DN_NRBTS + '/NRCTRLTS-1/NRMTRACECU-1'
NRMTRACEDU = DN_NRBTS + '/NRDU-1/NRCTRLTSDU-1/NRMTRACEDU-1'
# add end

PARAMS_TO_ADD_VICTIM = []
PARAMS_TO_MODIFY_VICTIM = []
RESTAPI_PARAMS_TO_MODIFY = []
RESTAPI_PARAMS_TO_MODIFY_VICTIM = []

NRARFCN_PARA = BuiltIn().get_variable_value('${NRARFCN_PARA}')

RI_WINDOW = 1 if PROGRAM >= "24R3" else 5
RI_TIMEOUT = '3min' if PROGRAM >= "24R3" else '10min'

PARAMS_TO_MODIFY_72E_AGGRESSOR = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_72E_AGGRESSOR}')
PARAMS_TO_MODIFY_72E_VICTIM = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_72E_VICTIM}')
PARAMS_TO_MODIFY_72E_AGGRESSOR = [] if PARAMS_TO_MODIFY_72E_AGGRESSOR is None \
    else PARAMS_TO_MODIFY_72E_AGGRESSOR
PARAMS_TO_MODIFY_72E_VICTIM = [] if PARAMS_TO_MODIFY_72E_VICTIM is None \
    else PARAMS_TO_MODIFY_72E_VICTIM


def default_globalF0ForRs(nrarfcn, bandwidth):
    """
    author: Wang Yixiang
    nrarfcn is same value of NIDD nrarfcn
    bandwidth is the value of NIDD chbw
    """
    bandwidth_2_RB = {"20": 51, "30": 78, "40": 106, "50": 133, "60": 162, "70": 189, "80": 217, "90": 245, "100": 273}
    divide_value = 0
    nrarfcn = int(nrarfcn)
    bandwidth = str(bandwidth)

    if nrarfcn < 600000:
        divide_value = 5
    else:
        divide_value = 15

    globalF0ForRs = nrarfcn - 30 * bandwidth_2_RB[bandwidth] * 6 / divide_value

    return str(int(globalF0ForRs))


def caculate_nrarfcn(nrarfcn, shift_bandwidth, up_down):
    """
    author: Wang Yixiang
    nrarfcn is same value of NIDD nrarfcn
    shift_bandwidth means bandwidth shift base on nrarfcn
    up_down can be up or down
    """

    freq_per_6 = 0
    nrarfcn_ret = 0
    nrarfcn = int(nrarfcn)
    shift_bandwidth = int(shift_bandwidth)

    if nrarfcn < 600000:
        freq_per_6 = 0.03
    else:
        freq_per_6 = 0.09

    shift_num = math.floor(shift_bandwidth / freq_per_6) * 6

    if up_down == 'up':
        nrarfcn_ret = nrarfcn + shift_num
    else:
        nrarfcn_ret = nrarfcn - shift_num

    return str(nrarfcn_ret)


# ################################### For SCF modification part
# Set counter report period
MODIFY_SCF_DEFAULT_COUNTER = [
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaCu'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaDu'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrLowRlcReport'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrRim')
]

ACT_BBPOOLING = [
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1AlgEnh'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actBbPoolExtensionTddFr1'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1Enh'),
    dict(
        value='true',
        dist_name=DN_TDDCELL,
        p_name='actShortBsrLimitAdaptation'),
    dict(
        value='false',
        dist_name=DN_TDDCELL,
        p_name='actDlMuMimo'),
    dict(
        value='longPucch',
        dist_name=DN_TDDCELL,
        p_name='pucchModeSelect'),
    dict(
        value='80ms',
        dist_name=DN_TDDCELL,
        list_name='csirsForTracking',
        p_name='csirsTrackingPeriod'),
    dict(
        value="true",
        dist_name=DN_NRBTS,
        p_name="actPaging"),
    dict(
        value="quaterT",
        dist_name=DN_TDDCELL,
        p_name="numOfPagingFrames"),
    dict(
        value="1",
        dist_name=DN_TDDCELL,
        p_name="pagingOffset"),
    dict(
        value="one",
        dist_name=DN_TDDCELL,
        p_name="numPagingOccsnPagingFrame"),
    dict(
        value="2",
        dist_name=DN_TDDCELL,
        list_name="fPdcchMonOccsnPo")
]

DIS_BBPOOLING = [
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1AlgEnh'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actBbPoolExtensionTddFr1'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actLargeBbPoolTddFr1'),
    dict(
        value='disabled',
        dist_name=DN_NRBTS,
        p_name='actFlexibleBISlotDurationMode'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actBbPoolTddFr1Enh'),
    dict(
        value='true',
        dist_name=DN_TDDCELL,
        p_name='actShortBsrLimitAdaptation'),
    dict(
        value='false',
        dist_name=DN_TDDCELL,
        p_name='actDlMuMimo'),
    dict(
        value='longPucch',
        dist_name=DN_TDDCELL,
        p_name='pucchModeSelect'),
    dict(
        value='80ms',
        dist_name=DN_TDDCELL,
        list_name='csirsForTracking',
        p_name='csirsTrackingPeriod'),
    dict(
        value="true",
        dist_name=DN_NRBTS,
        p_name="actPaging"),
    dict(
        value="quaterT",
        dist_name=DN_TDDCELL,
        p_name="numOfPagingFrames"),
    dict(
        value="1",
        dist_name=DN_TDDCELL,
        p_name="pagingOffset"),
    dict(
        value="one",
        dist_name=DN_TDDCELL,
        p_name="numPagingOccsnPagingFrame"),
    dict(
        value="0",
        dist_name=DN_TDDCELL,
        list_name="fPdcchMonOccsnPo")
]

MODIFY_SCF_LOAD_GNB1 = [
    dict(value=0, dist_name=DN_TDDCELL_GNB1, p_name="targetTotalLoad"),
    dict(value=0, dist_name=DN_TDDCELL_GNB1, p_name="targetTotalLoadSectorBeam"),
    dict(value='PDSCH+PDCCH+TRS+SSB', dist_name=DN_TDDCELL_GNB1, p_name="actConfDlInterferenceGen"),
    dict(value=28, dist_name=DN_TDDCELL_GNB1, p_name="mcsIndexForArtificialLoad"),
    dict(value='enhanced', dist_name=DN_TDDCELL_GNB1, p_name="actDlRbgRandomization"),
]


# need to set true for 1116 framestructure
ACT_PDSCHSchSplSlot = [
    dict(value='true', dist_name=DN_TDDCELL, p_name="actEnhancedPDSCHSchSplSlot"),
]
ACT_PDSCHSchSplSlot_GNB1 = [
    dict(value='true', dist_name=DN_TDDCELL_GNB1, p_name="actEnhancedPDSCHSchSplSlot"),
]
DISABLE_PDSCHSchSplSlot = [
    dict(value='false', dist_name=DN_TDDCELL, p_name="actEnhancedPDSCHSchSplSlot"),
]
DISABLE_PDSCHSchSplSlot_GNB1 = [
    dict(value='false', dist_name=DN_TDDCELL_GNB1, p_name="actEnhancedPDSCHSchSplSlot"),
]

PARAMS_TO_ADD_TRACE_CU_ACTIVE_PCMD = [
    dict(dist_name=DN_NRBTS, p_name='actPCMDReport', value='true'),
    dict(dist_name=NRMTRACECU, version="NRBTSCL24R1_2322_110", class_name="com.nokia.srbts.nrbts:NRMTRACECU"),
    dict(dist_name=NRMTRACECU, p_name='actCellTraceReportingCU', value='false'),
    dict(dist_name=NRMTRACECU, p_name='actPCMDReporting', value='false'),
    dict(dist_name=NRMTRACECU, p_name='cellMaxActiveUEsTraced', value='100'),
    dict(dist_name=NRMTRACECU, p_name='jobType', value='TraceOnly'),
    dict(dist_name=NRMTRACECU, p_name='nrTceIdentifier', value='1'),
    dict(dist_name=NRMTRACECU, p_name='scope', value='specificResources'),
    dict(dist_name=NRMTRACECU, p_name='traceNGAPSetting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceNRRRCSetting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceX2Setting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceXNSetting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceE1Setting', value='none'),
    dict(dist_name=NRMTRACECU, p_name='traceF1Setting', value='none'),
    dict(dist_name=NRMTRACECU, list_name='nrRanTraceReference',
         elements={"mcc": "310", "mnc": "260", "mncLength": "3", "traceId": "1"}),
    dict(dist_name=NRMTRACECU + '/NRRESOURCECU-1', version="NRBTSCL24R1_2322_110",
         class_name="com.nokia.srbts.nrbts:NRRESOURCECU"),
    dict(dist_name=NRMTRACECU + '/NRRESOURCECU-1', p_name='resourceDN', value=DN_TDDCELL),
    dict(dist_name=NRMTRACECU + '/NRRESOURCECU-1', p_name='typeNrCu', value='cell'),
]


PARAMS_TO_ADD_TRACE_DU_ACTIVE_PCMD_RIREPORT = [
    dict(dist_name=NRMTRACEDU, version="NRBTSCL24R1_2322_110", class_name="com.nokia.srbts.nrbts:NRMTRACEDU"),
    dict(dist_name=NRMTRACEDU, p_name='actPCMDReporting', value='false'),
    dict(dist_name=NRMTRACEDU, p_name='actRIReporting', value='true'),
    dict(dist_name=NRMTRACEDU, p_name='cellMaxActiveUEsTraced', value='100'),
    dict(dist_name=NRMTRACEDU, p_name='jobType', value='TraceOnly'),
    dict(dist_name=NRMTRACEDU, p_name='nrTceIdentifier', value='1'),
    dict(dist_name=NRMTRACEDU, p_name='riReportInterval', value='s5'),
    dict(dist_name=NRMTRACEDU, p_name='scope', value='allResources'),
    dict(dist_name=NRMTRACEDU, list_name='nrRanTraceReference',
         elements={"mcc": "310", "mnc": "260", "mncLength": "3", "traceId": "1"}),
]

PARAMS_TO_ADD_NRMTRACEDU_25R3 = [
    dict(dist_name=NRMTRACEDU, p_name='tracePCMDCoordinateSystem', value='DoA'),
    dict(dist_name=NRMTRACEDU, list_name='tracePCMDSetting',
         elements={"RI Slope Measurement", "RIM-RS Monitoring", "RIM-RS Transmission"}),
]

PARAMS_TO_ADD_NRMTRACEDU_26R1 = [
    dict(dist_name=NRMTRACEDU, list_name='tracePCMDSetting',
         elements={"RI Slope Measurement", "RIM-RS Monitoring", "RIM-RS Transmission"}),
]

PARAMS_TO_ADD_TCE_1 = [
    dict(dist_name=TCE, version="MNL24R1_2322_100", class_name="com.nokia.srbts.mnl:TCE"),
    dict(dist_name=TCE, p_name='certTypeForTlsAuth', value='RSA'),
    dict(dist_name=TCE, p_name='tceIdentifier', value='1'),
    dict(dist_name=TCE, p_name='tceIpAddress', value=TCE_IP_ADDR),
    dict(dist_name=TCE, p_name='tcePortNumber', value=TCE_PORT),
    dict(dist_name=TCE, p_name='tlsEnabled', value='false'),
]


PARAMS_TO_DELETE_NRMTRACECU_1 = [
    dict(dist_name=NRMTRACECU),

]

PARAMS_TO_DELETE_NRMTRACEDU_1 = [
    dict(dist_name=NRMTRACEDU),
]

PARAMS_TO_DELETE_TCE_1 = [
    dict(dist_name=TCE),
]

PARAMS_TO_DELETE_PCMD = PARAMS_TO_DELETE_NRMTRACECU_1 + PARAMS_TO_DELETE_NRMTRACEDU_1 + PARAMS_TO_DELETE_TCE_1
PARAMS_TO_ADD_PCMD = PARAMS_TO_ADD_TRACE_CU_ACTIVE_PCMD + PARAMS_TO_ADD_TRACE_DU_ACTIVE_PCMD_RIREPORT + \
                     PARAMS_TO_ADD_TCE_1
PARAMS_TO_ADD_PCMD = PARAMS_TO_ADD_PCMD + PARAMS_TO_ADD_NRMTRACEDU_25R3 if PROGRAM == '25R3' else PARAMS_TO_ADD_PCMD
PARAMS_TO_ADD_PCMD = PARAMS_TO_ADD_PCMD + PARAMS_TO_ADD_NRMTRACEDU_26R1 if PROGRAM >= '26R1' else PARAMS_TO_ADD_PCMD

GET_VALUE_FROM_GNB = [
    dict(
        dist_name=DN_NRRIM,
        p_name='repetitionRsType1'),
    dict(
        dist_name=DN_NRRIM,
        p_name='repetitionRsType2'),
    dict(
        dist_name=DN_NRRIM,
        p_name='rsNearFarConfig'),
    dict(
        dist_name=DN_NRRIM,
        p_name='maxRsDetectDurationWithoutRi'),
    dict(
        dist_name=DN_NRRIM,
        p_name='rimAsymmetricDetectionWindow'),
    dict(
        dist_name=DN_NRRIM,
        p_name='rsType1NScId'),
    dict(
        dist_name=DN_NRRIM,
        p_name='rsType2NScId'),
    dict(
        dist_name=DN_NRRIM,
        p_name='rsSetId')
]

GET_VALUE_FROM_GNB1 = [
    dict(
        dist_name=DN_NRRIM_GNB1,
        p_name='rsSetId')
]
