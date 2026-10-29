from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
from NIDD_modify_scf import *

import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value("${PROGRAM}")
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value("${tl}")


# ${GNB_INFO}: Define in NIDD_modify_scf.py
GNB_INFO = BuiltIn().get_variable_value("${GNB_INFO}")

ADD_SCF_MO_NRREL_1390_COMMISSION = param_modify_lib.generate_nrrel_with_cell_for_scf_add(
    program=program, dist_name=DN_FDD_CA_REL, cell_lcrid=TDD_CELLS[0]['lcrId'],
    gNbIdLength=GNB_INFO['gNbIdLength'], mncLength=GNB_INFO['mncLength'])

ADD_SCF_A1BASED_PCELL_SWITCH_HOIF_1390_COMMISSION = [
    dict(dist_name=DN_FDDCELL_HOIF, version='NRBTSCL5G21A_2012_200', class_name='com.nokia.srbts.nrbts:NRHOIF'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a1BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a2BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a3MeasEnabled', value='none'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a5MeasEnabled', value='none'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='cellDepType', value=TDD_CELLS[0]['cellDepType']),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='chBw', value=TDD_CELLS[0]['chBw']),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='freqBandIndicatorNR', value=TDD_CELLS[0]['freqBandIndicatorNR']),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='ifhoSsbScs', value=TDD_CELLS[0]['ssbScs']),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='ifhoSsbSmtcDuration', value='sf3'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='ifhoSsbSmtcPeriodicity', value='sf40'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='numberOfTransmittedSsBlocks', value='1 beam'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='scs', value=TDD_CELLS[0]['scs']),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='ssBurstSetPeriod', value=TDD_CELLS[0]['ssBurstSetPeriod']),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='ssbFrequency', value=TDD_CELLS[0]['ssbFrequency']),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a4MeasEnDcSteeringEnabled', value='none'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a4MeasHigherPrioFreqEnabled', value='none'),
    dict(dist_name=DN_FDDCELL_HOIF, p_name='a4MeasNrDcEnabled', value='none')
]
if program not in ['23R1', '23R2', '23R3']:
    ADD_SCF_A1BASED_PCELL_SWITCH_HOIF_1390_COMMISSION = ADD_SCF_A1BASED_PCELL_SWITCH_HOIF_1390_COMMISSION + [
        dict(dist_name=DN_FDDCELL_HOIF, p_name='a4MeasSCellAddEnabled', value='none')
    ]

ADD_SCF_A2BASED_PCELL_SWITCH_HOIF_2329_COMMISSION = [
    dict(dist_name=DN_TDDCELL_HOIF, version='NRBTSCL5G21A_2012_200', class_name='com.nokia.srbts.nrbts:NRHOIF'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a1BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a2BasedPCellSwitchEnabled', value='false'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a2BasedPCellSwitchPriority', value='1'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a3MeasEnabled', value='none'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a5MeasEnabled', value='none'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='cellDepType', value=FDD_CELLS[0]['cellDepType']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='chBw', value=FDD_CELLS[0]['chBw']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='freqBandIndicatorNR', value=FDD_CELLS[0]['freqBandIndicatorNR']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ifhoSsbScs', value=FDD_CELLS[0]['ssbScs']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ifhoSsbSmtcDuration', value='sf3'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ifhoSsbSmtcPeriodicity', value='sf40'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='numberOfTransmittedSsBlocks', value='1 beam'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='scs', value=FDD_CELLS[0]['scs']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ssBurstSetPeriod', value=FDD_CELLS[0]['ssBurstSetPeriod']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='ssbFrequency', value=FDD_CELLS[0]['ssbFrequency']),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='thresholdPCellSwitchTargetRsrp', value='1'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='thresholdPCellSwitchTargetRsrq', value='1'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a4MeasEnDcSteeringEnabled', value='none'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a4MeasHigherPrioFreqEnabled', value='none'),
    dict(dist_name=DN_TDDCELL_HOIF, p_name='a4MeasNrDcEnabled', value='none')
]

if program not in ['23R1', '23R2', '23R3']:
    ADD_SCF_A2BASED_PCELL_SWITCH_HOIF_2329_COMMISSION = ADD_SCF_A2BASED_PCELL_SWITCH_HOIF_2329_COMMISSION + [
        dict(dist_name=DN_TDDCELL_HOIF, p_name='a4MeasSCellAddEnabled', value='none')
    ]

ADD_SCF_HO_XN_SUPPORT = [
    dict(dist_name=DN_NRBTS, p_name="timerXnDataFwdGuard", value="250"),
    dict(dist_name=DN_FDDCELLS, p_name="measGapSelection", value="favourUeThroughput"),
    dict(dist_name=DN_FDDCELLS, p_name="measGapSelectionSA", value="favourUeThroughput"),
    dict(dist_name=DN_TDDCELLS, p_name="measGapSelection", value="favourUeThroughput"),
    dict(dist_name=DN_TDDCELLS, p_name="measGapSelectionSA", value="favourUeThroughput"),
]

MODIFY_SCF_ENABLE_HOIF_COMMISSION = [
    dict(
        dist_name=DN_NRBTS,
        p_name="actInterFreqHoSA",
        value="true"),
    dict(
        dist_name=DN_NRBTS +
        "/NRPMRNL-1",
        p_name="miNrRelReportCu",
        value="5min"),
    dict(
        dist_name=DN_NRBTS +
        "/NRPMRNL-1",
        p_name="miNrRANS",
        value="5min"),
]

DELETE_SCF_BEFORE_CASE = [
    dict(dist_name=DN_TDDCELL_HOIF),
    dict(dist_name=DN_FDDCELL_HOIF),
    dict(dist_name=DN_FDD_CA_REL),
    dict(dist_name=DN_TDDCELLS, p_name="measGapSelection"),
    dict(dist_name=DN_FDDCELLS, p_name="measGapSelectionSA"),
    dict(dist_name=DN_TDDCELLS, p_name="measGapSelection"),
    dict(dist_name=DN_FDDCELLS, p_name="measGapSelectionSA"),
]

ADD_SCF_PCELL_SWITCH_1390_COMMISSION = (
    ADD_SCF_MO_NRREL_1390_COMMISSION
    + ADD_SCF_A1BASED_PCELL_SWITCH_HOIF_1390_COMMISSION
    + ADD_SCF_A2BASED_PCELL_SWITCH_HOIF_2329_COMMISSION
    + ADD_SCF_HO_XN_SUPPORT
    + ADD_SCF_DEFAULT
)

MODIFY_SCF_PCELL_SWITCH_COMMISSION = (
    MODIFY_SCF_DEFAULT_20M_100M_1116_3 + MODIFY_SCF_ENABLE_HOIF_COMMISSION
)

DELETE_SCF_BEFORE_PCELL_SWITCH = DELETE_SCF_BEFORE_CASE + DELETE_SCF_DEFAULT
