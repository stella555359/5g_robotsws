from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
from NIDD_modify_scf import *

import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib as param_modify_lib


# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value("${PROGRAM}")
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value("${tl}")
# # Defined in CB008542_variables.robot
# carrierAggregationSupportList_With_T_F = BuiltIn().get_variable_value(
#     '${carrierAggregationSupportList_With_T_F}')


# ${GNB_INFO}: Define in NIDD_modify_scf.py
GNB_INFO = BuiltIn().get_variable_value("${GNB_INFO}")

A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP = BuiltIn().get_variable_value("${A1_THRESHOLD_PCELL_SWITCH_SSB_RSRP}")
A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP = BuiltIn().get_variable_value("${A2_THRESHOLD_PCELL_SWITCH_SSB_RSRP}")

# only for one FDD and one TDD test line
ADD_SCF_CA_NRREL_FOR_FDD = param_modify_lib.generate_nrrel_with_cell_for_scf_add(
    program=program,
    dist_name=DN_FDD_CA_REL,
    cell_lcrid=TDD_CELLS[0]["lcrId"],
    gNbIdLength=GNB_INFO["gNbIdLength"],
    mncLength=GNB_INFO["mncLength"],
)

ADD_SCF_CA_NRREL_FOR_TDD = param_modify_lib.generate_nrrel_with_cell_for_scf_add(
    program=program,
    dist_name=DN_TDD_CA_REL,
    cell_lcrid=FDD_CELLS[0]["lcrId"],
    gNbIdLength=GNB_INFO["gNbIdLength"],
    mncLength=GNB_INFO["mncLength"],
)

ADD_SCF_A1_SCELL_ADDITION = [
    dict(
        dist_name=DN_TDDCELLS,
        p_name="a1MeasSCellAddEnabled",
        value="rsrp"),
    dict(dist_name=DN_TDDCELLS,
         list_name='a1MeasSCellAddSsbRsrp',
         elements={"a1HysteresisSCellAddSsbRsrp": "0",
                   "a1ThresholdSCellAddSsbRsrpFDD": "71",
                   "a1ThresholdSCellAddSsbRsrpTDD": "70",
                   "a1TimeToTriggerSCellAddSsbRsrp": "320ms"})
]

ADD_SCF_A1BASED_PCELL_SWITCH_HOIF = [
    dict(
        dist_name=DN_FDDCELL_HOIF,
        version="NRBTSCL5G21A_2012_200",
        class_name="com.nokia.srbts.nrbts:NRHOIF",
    ),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="a1BasedPCellSwitchEnabled", value="true"),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="a2BasedPCellSwitchEnabled", value="false"),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="a3MeasEnabled", value="none"),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="a5MeasEnabled", value="none"),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="a4MeasSCellAddEnabled", value="none"),
    dict(
        dist_name=DN_FDDCELL_HOIF,
        p_name="cellDepType",
        value=TDD_CELLS[0]["cellDepType"],
    ),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="chBw", value="100MHz"),
    dict(
        dist_name=DN_FDDCELL_HOIF,
        p_name="freqBandIndicatorNR",
        value=TDD_CELLS[0]["freqBandIndicatorNR"],
    ),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="ifhoSsbScs", value=TDD_CELLS[0]["ssbScs"]),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="ifhoSsbSmtcDuration", value="sf1"),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="ifhoSsbSmtcPeriodicity", value="sf20"),
    dict(
        dist_name=DN_FDDCELL_HOIF, p_name="numberOfTransmittedSsBlocks", value="1 beam"
    ),
    dict(dist_name=DN_FDDCELL_HOIF, p_name="scs", value=TDD_CELLS[0]["scs"]),
    dict(
        dist_name=DN_FDDCELL_HOIF,
        p_name="ssBurstSetPeriod",
        value=TDD_CELLS[0]["ssBurstSetPeriod"],
    ),
    dict(
        dist_name=DN_FDDCELL_HOIF,
        p_name="ssbFrequency",
        value=TDD_CELLS[0]["ssbFrequency"],
    ),
    dict(
        dist_name=DN_FDDCELL_HOIF, p_name="a4MeasEnDcSteeringEnabled", value="none",
    ),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a4MeasHigherPrioFreqEnabled', value='none'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a4MeasNrDcEnabled', value='none')
]

ADD_SCF_A1BASED_PCELL_SWITCH_CELL_LEVEL = [
    dict(
        dist_name=DN_TDDCELLS,
        p_name="a1MeasPCellSwitchEnabled",
        value="rsrp"),
    dict(
        dist_name=DN_TDDCELLS,
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

ADD_SCF_A2BASED_PCELL_SWITCH_HOIF = [
    dict(
        dist_name=DN_TDDCELL_HOIF,
        version="NRBTSCL5G21A_2012_200",
        class_name="com.nokia.srbts.nrbts:NRHOIF",
    ),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="a1BasedPCellSwitchEnabled", value="false"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="a2BasedPCellSwitchEnabled", value="true"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="a2BasedPCellSwitchPriority", value="1"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="a3MeasEnabled", value="none"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="a5MeasEnabled", value="none"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="a4MeasSCellAddEnabled", value="none"),
    dict(
        dist_name=DN_TDDCELL_HOIF,
        p_name="cellDepType",
        value=FDD_CELLS[0]["cellDepType"],
    ),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="chBw", value=FDD_CELLS[0]["chBw"]),
    dict(
        dist_name=DN_TDDCELL_HOIF,
        p_name="freqBandIndicatorNR",
        value=FDD_CELLS[0]["freqBandIndicatorNR"],
    ),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="ifhoSsbScs", value=FDD_CELLS[0]["ssbScs"]),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="ifhoSsbSmtcDuration", value="sf1"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="ifhoSsbSmtcPeriodicity", value="sf20"),
    dict(
        dist_name=DN_TDDCELL_HOIF, p_name="numberOfTransmittedSsBlocks", value="1 beam"
    ),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="scs", value=FDD_CELLS[0]["scs"]),
    dict(
        dist_name=DN_TDDCELL_HOIF,
        p_name="ssBurstSetPeriod",
        value=FDD_CELLS[0]["ssBurstSetPeriod"],
    ),
    dict(
        dist_name=DN_TDDCELL_HOIF,
        p_name="ssbFrequency",
        value=FDD_CELLS[0]["ssbFrequency"],
    ),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="thresholdPCellSwitchTargetRsrp", value="1"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="thresholdPCellSwitchTargetRsrq", value="1"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="a4MeasEnDcSteeringEnabled", value="none"),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a4MeasHigherPrioFreqEnabled', value='none'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name="a4MeasNrDcEnabled", value="none")
]


ADD_SCF_A2BASED_PCELLSWITCH_CELL_LEVEL = [
    dict(
        dist_name=DN_TDDCELLS,
        p_name="a2MeasPCellSwitchEnabled",
        value="rsrp"),
    dict(
        dist_name=DN_TDDCELLS,
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

MODIFY_SCF_ENABLE_HOIF_COMMISSION = [
    dict(
        dist_name=DN_NRBTS,
        p_name="actInterFreqIntraGnbMobilityNSA",
        value="true"),
    dict(
        value="covBasedA1",
        dist_name=DN_TDD_CA_REL,
        p_name="sCellAdditionMethod"),
    dict(
        value="covBasedA1",
        dist_name=DN_FDD_CA_REL,
        p_name="sCellAdditionMethod"),
    dict(
        dist_name=DN_NRBTS + '/NRDU-1',
        p_name="actConnectedModeMobilityCA",
        value="true"),
    dict(
        dist_name=DN_NRBTS,
        p_name='actMeasBasedSCellAdditionNsa',
        value='true'),
    dict(dist_name=DN_NRBTS + "/NRPMRNL-1", p_name="miNrRANS", value="5min"),
]

if program not in ['23R3', '23R4', '24R1']:
    MODIFY_SCF_ENABLE_HOIF_COMMISSION = MODIFY_SCF_ENABLE_HOIF_COMMISSION + [
        dict(value='A1-based', dist_name=param_modify_lib.DN_NRBTS, list_name='actMeasBasedSCellAdditionSa')]
else:
    MODIFY_SCF_ENABLE_HOIF_COMMISSION = MODIFY_SCF_ENABLE_HOIF_COMMISSION + [
        dict(value='true', dist_name=param_modify_lib.DN_NRBTS, p_name='actMeasBasedSCellAddition')]

DELETE_SCF_BEFORE_CASE = [
    #    dict(dist_name=DN_TDDCELL_HOIF),
    dict(dist_name=DN_FDDCELL_HOIF),
    dict(dist_name=DN_FDD_CA_REL),
    #    dict(dist_name=DN_TDD_CA_REL),
]

DELETE_SCF_BEFORE_PCELL_SWITCH = [
    dict(dist_name=DN_TDDCELLS, list_name='a1MeasSCellAddSsbRsrp'),
    ] + DELETE_SCF_BEFORE_CASE + DELETE_SCF_DEFAULT

ADD_SCF_PSCELL_SWITCH = (
    ADD_SCF_CA_SUPPORT_LIST
    + ADD_SCF_CA_NRREL_FOR_FDD
    + ADD_SCF_CA_NRREL_FOR_TDD
    + ADD_SCF_A1BASED_PCELL_SWITCH
    + ADD_SCF_A2BASED_PCELL_SWITCH
    + ADD_SCF_A1_SCELL_ADDITION
)

MODIFY_SCF_PCELL_SWITCH_COMMISSION = (
    MODIFY_SCF_DEFAULT + MODIFY_SCF_ENABLE_HOIF_COMMISSION
)
