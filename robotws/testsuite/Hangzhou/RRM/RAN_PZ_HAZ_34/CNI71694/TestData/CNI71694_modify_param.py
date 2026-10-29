from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
import logging

tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
BTS_ID = str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
LNBTS_NAME = 'LNBTS-' + str(tl.enbs[0].global_bts_id)
A1_HYS_SSB_RSRP_SA = 0
A1_TIME_TO_TRIGGER = 'ms80'

A2_HYS_SSB_RSRP_SA = 0
A2_TIME_TO_TRIGGER = 'ms2560'
A3_OFFSET_SSB_RSRP = 6
A3_HYS_SSB_RSRP_SA = 0
A3_TIME_TO_TRIGGER = 'ms80'
mgta = 'ms0dot5'
DN_TDDCELLS_NRREL = DN_TDDCELLS + '/NRREL-4'

# for enb config change
ENABLE_B1_MEAS = [dict(value='true', dist_name=LNBTS_NAME, parameter='actDynTrigLteNrDualConnectivity')]

DISABLE_B1_MEAS = [dict(value='true', dist_name=LNBTS_NAME, parameter='actDynTrigLteNrDualConnectivity')]
# DELETE for HO from TDD to F+T change
DELETE_SCF_BEFORE_HO = [
    dict(dist_name=DN_TDDCELL_HOIF),
    dict(dist_name=DN_FDDCELL_HOIF),
    dict(dist_name=DN_TDDCELLS, p_name="measGapSelection"),
    dict(dist_name=DN_FDDCELLS, p_name="measGapSelectionSA"),
    dict(dist_name=DN_TDDCELLS, p_name="measGapSelection"),
    dict(dist_name=DN_FDDCELLS, p_name="measGapSelectionSA"),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1'),
    dict(dist_name=DN_TDDCELLS, p_name="sMeasConfigSsbRsrp"),
]

ADD_SCF_A3BASED_TDD_HOIF_COMMISSION = [
    dict(dist_name=DN_TDDCELL_HOIF, version='NRBTSCL22R2_2112_200', class_name='com.nokia.srbts.nrbts:NRHOIF'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a1BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a2BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a3MeasEnabled', value='rsrp'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a5MeasEnabled', value='none'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='cellDepType', value=FDD_CELLS[0]['cellDepType']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='freqBandIndicatorNR', value=FDD_CELLS[0]['freqBandIndicatorNR']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ifhoSsbScs', value=FDD_CELLS[0]['ssbScs']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ifhoSsbSmtcDuration', value='sf3'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ifhoSsbSmtcPeriodicity', value='sf40'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='numberOfTransmittedSsBlocks', value='1 beam'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='scs', value=FDD_CELLS[0]['scs']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ssBurstSetPeriod', value=FDD_CELLS[0]['ssBurstSetPeriod']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ssbFrequency', value='128170'),
    dict(dist_name=DN_TDDCELL_HOIF, list_name='a3MeasSsbRsrp',
         elements=dict(a3HysteresisSsbRsrp='0', a3OffsetSsbRsrp='6', a3TimeToTriggerSsbRsrp='ms80')),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a4MeasEnDcSteeringEnabled', value='none'),
]

SCF_DEFAULT_FILE_PATH = BuiltIn().get_variable_value('${SCF_DEFAULT_FILE_PATH}')
GNB_INFO = param_modify_lib.get_bts_info_from_scf_file(local_scf_file_path=SCF_DEFAULT_FILE_PATH)
ADD_SCF_MO_TDD_TAR_NRREL = [
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', version="NRBTSCL22R1_2109_102", class_name="com.nokia.srbts.nrbts:NRREL"),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', p_name="cellIndividualSsbRsrpOffset", value="0dB"),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', p_name="cellIndividualSsbRsrqOffset", value="0dB"),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', p_name="gNbId", value=str(tl.gnbs[0].global_bts_id)),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', p_name="gNbIdLength", value=GNB_INFO['gNbIdLength']),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', p_name="lcrId", value=FDD_CELLS[0]['lcrId']),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', p_name="removeNotAllowed", value="false"),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', p_name="nrRelId", value="1"),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', p_name="handoverAllowedSA", value="allowed"),
    dict(dist_name=DN_TDDCELLS + '/NRREL-1', list_name="gnbPlmn",
         elements=dict(mcc=tl.core.mcc, mnc=tl.core.mnc, mncLength=GNB_INFO['mncLength'])),
]

ADD_SCF_HO_XN_SUPPORT = [
    dict(dist_name=DN_NRBTS, p_name="timerXnDataFwdGuard", value="250"),
    dict(dist_name=DN_FDDCELLS, p_name="measGapSelection", value="favourUeThroughput"),
    dict(dist_name=DN_TDDCELLS, p_name="measGapSelection", value="favourUeThroughput"),
    dict(dist_name=DN_FDDCELLS, p_name="measGapSelectionSA", value="favourUeThroughput"),
    dict(dist_name=DN_TDDCELLS, p_name="sMeasConfigSsbRsrp", value="100"),
]

MOD_SCF_ENABLE_HOIF_NSA = [
    dict(dist_name=DN_NRBTS, p_name="actInterFreqInterGnbMobilityNSA", value="true"),
    dict(dist_name=DN_NRBTS, p_name="actInterFreqIntraGnbMobilityNSA", value="true"),
]

ACT_K1_OPT = param_modify_lib.generate_actK1Opt_for_scf_modify(program=program, dist_name=DN_TDDCELLS,
                                                               is_k1opt_enabled='true') + \
             param_modify_lib.generate_actK1Opt_for_scf_modify(program=program, dist_name=DN_FDDCELLS,
                                                               is_k1opt_enabled='true')
MOD_SCF_COMMON_MEAS_CONFIG = [
    dict(dist_name=DN_TDDCELLS, p_name="actCDrx", value="true"),
    dict(dist_name=DN_TDDCELLS, p_name="a1MeashoEnabled", value="rsrp"),
    dict(dist_name=DN_TDDCELLS, list_name='a1MeashoSsbRsrp', p_name='a1HysteresishoSsbRsrp', value='0'),
    dict(dist_name=DN_TDDCELLS, list_name='a1MeashoSsbRsrp', p_name='a1ThresholdhoSsbRsrp', value='86'),
    dict(dist_name=DN_TDDCELLS, list_name='a1MeashoSsbRsrp', p_name='a1TimeToTriggerhoSsbRsrp', value='ms80'),
    dict(dist_name=DN_TDDCELLS, list_name="a1MeashoSsbRsrq", p_name='a1HysteresishoSsbRsrq', value="0"),
    dict(dist_name=DN_TDDCELLS, list_name="a1MeashoSsbRsrq", p_name='a1ThresholdhoSsbRsrq', value="36"),
    dict(dist_name=DN_TDDCELLS, list_name="a1MeashoSsbRsrq", p_name='a1TimeToTriggerhoSsbRsrq', value="ms480"),

    dict(dist_name=DN_TDDCELLS, p_name="a2MeashoEnabled", value="rsrp"),
    dict(dist_name=DN_TDDCELLS, list_name="a2MeashoSsbRsrp", p_name="a2HysteresishoSsbRsrp", value="0"),
    dict(dist_name=DN_TDDCELLS, list_name="a2MeashoSsbRsrp", p_name="a2ThresholdhoSsbRsrp", value="85"),
    dict(dist_name=DN_TDDCELLS, list_name="a2MeashoSsbRsrp", p_name="a2TimeToTriggerhoSsbRsrp", value="ms80"),

    dict(dist_name=DN_TDDCELLS, list_name="a2MeashoSsbRsrq", p_name="a2HysteresishoSsbRsrq", value="0"),
    dict(dist_name=DN_TDDCELLS, list_name="a2MeashoSsbRsrq", p_name="a2ThresholdhoSsbRsrq", value="31"),
    dict(dist_name=DN_TDDCELLS, list_name="a2MeashoSsbRsrq", p_name="a2TimeToTriggerhoSsbRsrq", value="ms480"),

    dict(dist_name=DN_TDDCELLS, p_name="sMeasConfigSsbRsrp", value="100"),
    dict(dist_name=DN_FDDCELLS, p_name="sMeasConfigSsbRsrp", value="0")
] + ACT_K1_OPT

MOD_SCF_INTER_FRE_NSA = [
    dict(dist_name=DN_TDDCELLS, p_name="ifhoSsbSmtcOffset", value="19"),
    dict(dist_name=DN_TDDCELLS, p_name="gapOffset", value="19"),
    dict(dist_name=DN_TDDCELLS, p_name="enDcSyncStatus", value="synchronous"),

]

MOD_SCF_CA_SUPPORT_LIST = [
    dict(
        value='ca_Fr1Tdd_Fdd_Nsa',
        dist_name=DN_NRBTS + '/NRDU-1',
        list_name='carrierAggregationSupportList',
        index=0),
    dict(
        value='ca_Fdd_Fr1Tdd_Nsa',
        dist_name=DN_NRBTS + '/NRDU-1',
        list_name='carrierAggregationSupportList',
        index=1),

]

if program == '22R3' or program == '22R4':
    SCF_Param_ActK1Opt_Name = [
        dict(dist_name=DN_TDDCELLS, p_name="actK1OptForDPA", value="true"),
        dict(dist_name=DN_FDDCELLS, p_name="actK1OptForDPA", value="true"),
    ]
else:
    SCF_Param_ActK1Opt_Name = [
        dict(dist_name=DN_TDDCELLS, p_name="actK1Opt", value="intra-gNB"),
        dict(dist_name=DN_FDDCELLS, p_name="actK1Opt", value="intra-gNB"),
    ]

MOD_SCF_COMMON_MEAS_CONFIG = MOD_SCF_COMMON_MEAS_CONFIG + SCF_Param_ActK1Opt_Name

ADD_SCF_HO = ADD_SCF_A3BASED_TDD_HOIF_COMMISSION + ADD_SCF_MO_TDD_TAR_NRREL + ADD_SCF_HO_XN_SUPPORT
MODIFY_SCF_MO = MOD_SCF_ENABLE_HOIF_NSA + MOD_SCF_COMMON_MEAS_CONFIG + MOD_SCF_INTER_FRE_NSA + \
                MOD_SCF_CA_SUPPORT_LIST

FDD_CELL_ID = F_T_ALLOCATION['FDD'][0]['nrCellId']

T_NRREL_F_GROUP = {
            'pcell_id': F_T_ALLOCATION['TDD'][0]['nrCellId'],
            'gnb_connection_alias_pcell': 'GNB_OAM',
            'nrrel_info': [
                {
                    'gnb_connection_alias': 'GNB_OAM',
                    'nrrel_config': {
                        FDD_CELL_ID: {'sCellOperationalMode': 'dlOnly', 'sCellAdditionMethod': 'blind'}
                    }
                }
            ]
        }

REST_API_ADD_T_NRREL_F = \
    param_modify_lib.get_nrrel_params_for_online_update_based_on_ca_group_mapping_config(
        program=program, ca_group_mapping=T_NRREL_F_GROUP)

logging.warning("param list {}".format(REST_API_ADD_T_NRREL_F))

if program == '22R3' or program == '22R4':
    REST_API_K1_OPT = [
        dict(dist_name=DN_TDDCELLS, parameter="actK1OptForDPA", value="true"),
        dict(dist_name=DN_FDDCELLS, parameter="actK1OptForDPA", value="true")
    ]
else:
    REST_API_K1_OPT = [
        dict(dist_name=DN_TDDCELLS, parameter="actK1Opt", value="intra-gNB"),
        dict(dist_name=DN_FDDCELLS, parameter="actK1Opt", value="intra-gNB")
    ]

REST_API_CA_SUPPORTLIST = [
    dict(dist_name=DN_NRBTS + '/NRDU-1',
         parameter='carrierAggregationSupportList',
         value=['ca_Fr1Tdd_Fdd_Nsa', 'ca_Fdd_Fr1Tdd_Nsa'])
] + REST_API_K1_OPT

# for PA settting for HO
if BTS_ID == "255":
    # Left: TDD 936, FDD 937; Right: FDD 938, TDD 939
    INIT_PA_INTER_FREQ_TO_TRIGGER_HO = {0: [53, 0], 1: [127, 127]}
    INIT_PA_AFT_INTER_HO = {0: [0, 5], 1: [127, 127]}
elif BTS_ID == "10152":
    INIT_PA_INTER_FREQ_TO_TRIGGER_HO = {0: [46, 0], 1: [127, 127]}
    INIT_PA_AFT_INTER_HO = {0: [0, 0], 1: [127, 127]}
elif BTS_ID == "1170":
    # left: FDD 255, TDD 254; Right: FDD 252, TDD 253
    INIT_PA_INTER_FREQ_TO_TRIGGER_HO = {0: [15, 47], 1: [127, 127]}
    INIT_PA_AFT_INTER_HO = {0: [15, 0], 1: [127, 127]}
else:
    INIT_PA_INTER_FREQ_TO_TRIGGER_HO = {0: [46, 0], 1: [127, 127]}
    INIT_PA_AFT_INTER_HO = {0: [0, 0], 1: [127, 127]}

ONLINE_ENABLE_CB008830_API = [
    dict(
        dist_name=DN_TDDCELLS,
        parameter='dlDmrsType',
        value='Type2'),
]
