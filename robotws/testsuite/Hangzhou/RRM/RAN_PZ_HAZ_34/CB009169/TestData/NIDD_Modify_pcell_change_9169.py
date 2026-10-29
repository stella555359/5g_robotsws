from robot.libraries.BuiltIn import BuiltIn
from NIDD_modify_scf import PCELL_DN, SCELL_UL_DN, FDD_CELLS, TDD_CELLS, LIST_SCELL_ID
from NIDD_modify_scf_4CC_T100M_F20M_F10M_T60M import *
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value("${PROGRAM}")
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value("${tl}")

# ${GNB_INFO}: Define in NIDD_modify_scf.py
GNB_INFO = BuiltIn().get_variable_value('${GNB_INFO}')

# NR_CELL_ID_MAPPING: Get from GNB online by method get_relation_mapping_between_cell_index_and_other_ids
NR_CELL_ID_MAPPING = BuiltIn().get_variable_value('${NR_CELL_ID_MAPPING}')
CA_ALLOCATION_FOR_PCELL_CHANGE = BuiltIn().get_variable_value('${CA_ALLOCATION_FOR_PCELL_CHANGE}')
A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP = BuiltIn().get_variable_value("${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}")
A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP = BuiltIn().get_variable_value("${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}")

A1_HYS_SCELL_ADD_SSB_RSRP = BuiltIn().get_variable_value('${A1_HYS_SCELL_ADD_SSB_RSRP}')
A1_THRES_SCELL_ADD_SSB_RSRP_TDD = BuiltIn().get_variable_value('${A1_THRES_SCELL_ADD_SSB_RSRP_TDD}')
A1_THRES_SCELL_ADD_SSB_RSRP_FDD = BuiltIn().get_variable_value('${A1_THRES_SCELL_ADD_SSB_RSRP_FDD}')
A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP = BuiltIn().get_variable_value('${A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP}')

TDD_CELL_DN_NRREL1 = PCELL_DN + '/NRREL-1'
TDD_CELL_DN_NRREL2 = PCELL_DN + '/NRREL-2'
TDD_CELL_DN_NRREL3 = PCELL_DN + '/NRREL-3'

FDD_CELL_DN_NRREL1 = SCELL_UL_DN + '/NRREL-1'
FDD_CELL_DN_NRREL2 = SCELL_UL_DN + '/NRREL-2'
FDD_CELL_DN_NRREL3 = SCELL_UL_DN + '/NRREL-3'

TDD_CELL_DN_HOIF = PCELL_DN + '/NRHOIF-1'
FDD_CELL_DN_HOIF1 = SCELL_UL_DN + '/NRHOIF-1'
FDD_CELL_DN_HOIF2 = SCELL_UL_DN + '/NRHOIF-2'


carrierAggregationSupportList_T_F_UL_DL_pcell_change = \
    BuiltIn().get_variable_value('${carrierAggregationSupportList_T_F_UL_DL_pcell_change}')

ADD_SCF_A2BASED_PCELL_SWITCH_HOIF = [
    dict(
        dist_name=TDD_CELL_DN_HOIF,
        version="NRBTSCL5G21A_2012_200",
        class_name="com.nokia.srbts.nrbts:NRHOIF",
    ),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="a1BasedPCellSwitchEnabled", value="false"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="a2BasedPCellSwitchEnabled", value="true"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="a2BasedPCellSwitchPriority", value="1"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="a3MeasEnabled", value="none"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="a5MeasEnabled", value="none"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="a4MeasSCellAddEnabled", value="none"),
    dict(
        dist_name=TDD_CELL_DN_HOIF,
        p_name="cellDepType",
        value=CA_ALLOCATION_FOR_PCELL_CHANGE['FDD'][0]["cellDepType"],
    ),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="chBw", value=CA_ALLOCATION_FOR_PCELL_CHANGE['FDD'][0]["chBw"]),
    dict(
        dist_name=TDD_CELL_DN_HOIF,
        p_name="freqBandIndicatorNR",
        value=CA_ALLOCATION_FOR_PCELL_CHANGE['FDD'][0]["freqBandIndicatorNR"],
    ),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="ifhoSsbScs", value=CA_ALLOCATION_FOR_PCELL_CHANGE['FDD'][0]["ssbScs"]),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="ifhoSsbSmtcDuration", value="sf1"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="ifhoSsbSmtcPeriodicity", value="sf20"),
    dict(
        dist_name=TDD_CELL_DN_HOIF, p_name="numberOfTransmittedSsBlocks", value="1 beam"
    ),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="scs", value=CA_ALLOCATION_FOR_PCELL_CHANGE['FDD'][0]["scs"]),
    dict(
        dist_name=TDD_CELL_DN_HOIF,
        p_name="ssBurstSetPeriod",
        value=CA_ALLOCATION_FOR_PCELL_CHANGE['FDD'][0]["ssBurstSetPeriod"],
    ),
    dict(
        dist_name=TDD_CELL_DN_HOIF,
        p_name="ssbFrequency",
        value=CA_ALLOCATION_FOR_PCELL_CHANGE['FDD'][0]["ssbFrequency"],
    ),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="thresholdPCellSwitchTargetRsrp", value="1"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="thresholdPCellSwitchTargetRsrq", value="1"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="a4MeasEnDcSteeringEnabled", value="none"),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name='a4MeasHigherPrioFreqEnabled', value='none'),
    dict(dist_name=TDD_CELL_DN_HOIF, p_name="a4MeasNrDcEnabled", value="none")
]

ADD_SCF_A2BASED_PCELLSWITCH_CELL_LEVEL = [
    dict(
        dist_name=PCELL_DN,
        p_name="a2MeasPCellSwitchEnabled",
        value="rsrp"),
    dict(
        dist_name=PCELL_DN,
        list_name="a2MeasPCellSwitchSsbRsrp",
        elements={
            "a2HysteresisPCellSwitchSsbRsrp": "0",
            "a2ThresholdPCellSwitchSsbRsrp": A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP,
            "a2TimeToTriggerPCellSwitchSsbRsrp": "480ms",
            "pCellSwitchOffsetSsbRsrp": "0",
        },
    ),
]

ADD_SCF_A2BASED_PCELL_SWITCH = (
    ADD_SCF_A2BASED_PCELLSWITCH_CELL_LEVEL + ADD_SCF_A2BASED_PCELL_SWITCH_HOIF
)

ADD_SCF_A1BASED_PCELL_SWITCH_HOIF = [
    dict(
        dist_name=FDD_CELL_DN_HOIF1,
        version="NRBTSCL5G21A_2012_200",
        class_name="com.nokia.srbts.nrbts:NRHOIF",
    ),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="a1BasedPCellSwitchEnabled", value="true"),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="a2BasedPCellSwitchEnabled", value="false"),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="a3MeasEnabled", value="none"),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="a5MeasEnabled", value="none"),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="a4MeasSCellAddEnabled", value="none"),
    dict(
        dist_name=FDD_CELL_DN_HOIF1,
        p_name="cellDepType",
        value=CA_ALLOCATION_FOR_PCELL_CHANGE['TDD'][0]["cellDepType"],
    ),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="chBw", value="100MHz"),
    dict(
        dist_name=FDD_CELL_DN_HOIF1,
        p_name="freqBandIndicatorNR",
        value=CA_ALLOCATION_FOR_PCELL_CHANGE['TDD'][0]["freqBandIndicatorNR"],
    ),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="ifhoSsbScs", value=CA_ALLOCATION_FOR_PCELL_CHANGE['TDD'][0]["ssbScs"]),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="ifhoSsbSmtcDuration", value="sf1"),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="ifhoSsbSmtcPeriodicity", value="sf20"),
    dict(
        dist_name=FDD_CELL_DN_HOIF1, p_name="numberOfTransmittedSsBlocks", value="1 beam"
    ),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name="scs", value=CA_ALLOCATION_FOR_PCELL_CHANGE['TDD'][0]["scs"]),
    dict(
        dist_name=FDD_CELL_DN_HOIF1,
        p_name="ssBurstSetPeriod",
        value=CA_ALLOCATION_FOR_PCELL_CHANGE['TDD'][0]["ssBurstSetPeriod"],
    ),
    dict(
        dist_name=FDD_CELL_DN_HOIF1,
        p_name="ssbFrequency",
        value=CA_ALLOCATION_FOR_PCELL_CHANGE['TDD'][0]["ssbFrequency"],
    ),
    dict(
        dist_name=FDD_CELL_DN_HOIF1, p_name="a4MeasEnDcSteeringEnabled", value="none",
    ),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name='a4MeasHigherPrioFreqEnabled', value='none'),
    dict(dist_name=FDD_CELL_DN_HOIF1, p_name='a4MeasNrDcEnabled', value='none')
]

ADD_SCF_A1BASED_PCELL_SWITCH_CELL_LEVEL = [
    dict(
        dist_name=PCELL_DN,
        p_name="a1MeasPCellSwitchEnabled",
        value="rsrp"),
    dict(
        dist_name=PCELL_DN,
        list_name="a1MeasPCellSwitchSsbRsrp",
        elements={
            "a1HysteresisPCellSwitchSsbRsrp": "0",
            "a1ThresholdPCellSwitchSsbRsrp": A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP,
            "a1TimeToTriggerPCellSwitchSsbRsrp": "480ms",
        },
    ),
]

ADD_SCF_A1BASED_PCELL_SWITCH = (
    ADD_SCF_A1BASED_PCELL_SWITCH_CELL_LEVEL + ADD_SCF_A1BASED_PCELL_SWITCH_HOIF
)

MODIFY_SCF_ENABLE_HOIF_COMMISSION = [
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        p_name="actInterFreqHoSA",
        value="true"),
    dict(
        value='ConfigurationIndependent',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='flexibleCAMode'),
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='actConnectedModeMobilityCA'),
    # dict(
    #     value="covBasedA1",
    #     dist_name=DN_TDD_CA_REL,
    #     p_name="sCellAdditionMethod"),
    # dict(
    #     value="covBasedA1",
    #     dist_name=DN_FDD_CA_REL,
    #     p_name="sCellAdditionMethod"),
    # dict(
    #     dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
    #     p_name="actConnectedModeMobilityCA",
    #     value="true"),
    dict(dist_name=param_modify_lib.DN_NRBTS + "/NRPMRNL-1", p_name="miNrRANS", value="5min"),
]

if program not in ['23R3', '23R4', '24R1']:
    MODIFY_SCF_ENABLE_HOIF_COMMISSION = MODIFY_SCF_ENABLE_HOIF_COMMISSION + [
        dict(value='A1-based', dist_name=param_modify_lib.DN_NRBTS, list_name='actMeasBasedSCellAdditionSa')]
else:
    MODIFY_SCF_ENABLE_HOIF_COMMISSION = MODIFY_SCF_ENABLE_HOIF_COMMISSION + [
        dict(value='true', dist_name=param_modify_lib.DN_NRBTS, p_name='actMeasBasedSCellAddition')]

MODIFY_SCF_A1_SCELL_ADDITION = [
    dict(
        dist_name=PCELL_DN,
        p_name='a1MeasSCellAddEnabled',
        value='rsrp'),
    dict(
        dist_name=SCELL_UL_DN,
        p_name="a1MeasSCellAddEnabled",
        value="rsrp"),
    dict(dist_name=PCELL_DN,
         list_name='a1MeasSCellAddSsbRsrp',
         p_name='a1HysteresisSCellAddSsbRsrp',
         value=A1_HYS_SCELL_ADD_SSB_RSRP),
    dict(dist_name=PCELL_DN,
         list_name='a1MeasSCellAddSsbRsrp',
         p_name='a1ThresholdSCellAddSsbRsrpFDD',
         value=A1_THRES_SCELL_ADD_SSB_RSRP_FDD),
    dict(dist_name=PCELL_DN,
         list_name='a1MeasSCellAddSsbRsrp',
         p_name='a1ThresholdSCellAddSsbRsrpTDD',
         value=A1_THRES_SCELL_ADD_SSB_RSRP_TDD),
    dict(dist_name=PCELL_DN,
         list_name='a1MeasSCellAddSsbRsrp',
         p_name='a1TimeToTriggerSCellAddSsbRsrp',
         value=A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP),
    dict(dist_name=SCELL_UL_DN,
         list_name='a1MeasSCellAddSsbRsrp',
         p_name='a1HysteresisSCellAddSsbRsrp',
         value=A1_HYS_SCELL_ADD_SSB_RSRP),
    dict(dist_name=SCELL_UL_DN,
         list_name='a1MeasSCellAddSsbRsrp',
         p_name='a1ThresholdSCellAddSsbRsrpTDD',
         value=A1_THRES_SCELL_ADD_SSB_RSRP_TDD),
    dict(dist_name=SCELL_UL_DN,
         list_name='a1MeasSCellAddSsbRsrp',
         p_name='a1TimeToTriggerSCellAddSsbRsrp',
         value=A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP)
]

DELETE_SCF_BEFORE_CASE = [
    # dict(dist_name=TDD_CELL_DN_NRREL1),
    # dict(dist_name=TDD_CELL_DN_NRREL2),
    # dict(dist_name=TDD_CELL_DN_NRREL3),
    dict(dist_name=FDD_CELL_DN_NRREL1),
    # dict(dist_name=FDD_CELL_DN_NRREL2),
    # dict(dist_name=FDD_CELL_DN_NRREL3),
    # dict(dist_name=TDD_CELL_DN_HOIF),
    # dict(dist_name=FDD_CELL_DN_HOIF1),
    dict(dist_name=FDD_CELL_DN_HOIF2),
]

DELETE_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=param_modify_lib.DN_NRDU1,
        list_name='carrierAggregationSupportList')
]

DELETE_SCF_BEFORE_PCELL_SWITCH = DELETE_SCF_BEFORE_CASE + DELETE_SCF_CA_SUPPORT_LIST

ADD_SCF_MAX_SCELLS_DL = [
    dict(
        value='3',
        dist_name=PCELL_DN,
        p_name='maxNumScellsDlFr1'),
    dict(
        value='3',
        dist_name=SCELL_UL_DN,
        p_name='maxNumScellsDlFr1'),
]

# ADD_SCF_ACTIVE_T_F_AND_F_T_UL_DL_CA = [
#     dict(
#         value=carrierAggregationSupportList_T_F_UL_DL_pcell_change,
#         dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
#         p_name='carrierAggregationSupportList')
# ]

ADD_SCF_ACTIVE_T_F_AND_F_T_UL_DL_CA = [
    dict(
        elements=carrierAggregationSupportList_T_F_UL_DL_pcell_change,
        dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
        list_name='carrierAggregationSupportList')
]

ADD_SCF_PSCELL_SWITCH = (
    ADD_SCF_ACTIVE_T_F_AND_F_T_UL_DL_CA
    + ADD_SCF_MAX_SCELLS_DL
    + ADD_SCF_A1BASED_PCELL_SWITCH
    + ADD_SCF_A2BASED_PCELL_SWITCH
)

MODIFY_SCF_PCELL_SWITCH_COMMISSION = (
        MODIFY_SCF_A1_SCELL_ADDITION + MODIFY_SCF_ENABLE_HOIF_COMMISSION + MODIFY_SCF_DEFAULT_1116
)
