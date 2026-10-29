from robot.libraries.BuiltIn import BuiltIn
from NIDD_modify_scf import PCELL_DN, SCELL_UL_DN, FDD_CELLS, TDD_CELLS, LIST_SCELL_ID, CELL5_AEHC_DN
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
# from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value('${PROGRAM}')
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')
# ININUMSCELLSTOACTIVATE = BuiltIn().get_variable_value('${ININUMSCELLSTOACTIVATE}')

# ${GNB_INFO}: Define in NIDD_modify_scf.py
GNB_INFO = BuiltIn().get_variable_value('${GNB_INFO}')

# NR_CELL_ID_MAPPING: Get from GNB online by method get_relation_mapping_between_cell_index_and_other_ids
NR_CELL_ID_MAPPING = BuiltIn().get_variable_value('${NR_CELL_ID_MAPPING}')
A1_HYS_SCELL_ADD_SSB_RSRP_BC_7 = BuiltIn().get_variable_value('${A1_HYS_SCELL_ADD_SSB_RSRP_BC_7}')
A1_THRES_SCELL_ADD_SSB_RSRP_TDD_BC_7 = BuiltIn().get_variable_value('${A1_THRES_SCELL_ADD_SSB_RSRP_TDD_BC_7}')
A1_THRES_SCELL_ADD_SSB_RSRP_FDD_BC_7 = BuiltIn().get_variable_value('${A1_THRES_SCELL_ADD_SSB_RSRP_FDD_BC_7}')
A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP_BC_7 = \
    BuiltIn().get_variable_value('${A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP_BC_7}')

A2_HYS_SCELL_REL_SSB_RSRP_BC_7 = BuiltIn().get_variable_value('${A2_HYS_SCELL_REL_SSB_RSRP_BC_7}')
A2_THRES_SCELL_REL_SSB_RSRP_BC_7 = BuiltIn().get_variable_value('${A2_THRES_SCELL_REL_SSB_RSRP_BC_7}')
A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP_BC_7 = \
    BuiltIn().get_variable_value('${A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP_BC_7}')

A1_HYS_SCELL_ADD_SSB_RSRP = '0'
A1_THRES_SCELL_ADD_SSB_RSRP_TDD = '70'
A1_THRES_SCELL_ADD_SSB_RSRP_FDD = '65'
A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP = '320ms'

A2_HYS_SCELL_REL_SSB_RSRP = '0'
# A2_THRES_SCELL_REL_SSB_RSRP = '60'
A2_THRES_SCELL_REL_SSB_RSRP = BuiltIn().get_variable_value('${A2_THRES_SCELL_REL_SSB_RSRP}')
A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP = '100ms'


# Parameter dedined in 5GC006137_variables.robot
carrierAggregationSupportList_T_F_UL_DL = BuiltIn().get_variable_value('${carrierAggregationSupportList_T_F_UL_DL}')

MODIFY_ACTIVE_F_T_UL_DL_CA_RESTAPI = [
    dict(
        value=carrierAggregationSupportList_T_F_UL_DL,
        dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList')
]
# enable A1 scell addition and A2 Scell release
MODIFY_SCF_A1_SCELL_ADDITION_API = [
    dict(
        dist_name=PCELL_DN + '/NRREL-1',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
        dist_name=PCELL_DN + '/NRREL-2',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
        dist_name=PCELL_DN + '/NRREL-3',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
         dist_name=PCELL_DN,
         parameter='a1MeasSCellAddSsbRsrp',
         value=[dict(a1HysteresisSCellAddSsbRsrp=A1_HYS_SCELL_ADD_SSB_RSRP,
                     a1ThresholdSCellAddSsbRsrpFDD=A1_THRES_SCELL_ADD_SSB_RSRP_FDD,
                     a1ThresholdSCellAddSsbRsrpTDD=A1_THRES_SCELL_ADD_SSB_RSRP_TDD,
                     a1TimeToTriggerSCellAddSsbRsrp=A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP)]),
]

MODIFY_SCF_A2_SCELL_RELEASE_API = [
    dict(
         dist_name=SCELL_UL_DN,
         parameter='a2MeasSCellRelSsbRsrp',
         value=[dict(a2HysteresisSCellRelSsbRsrp=A2_HYS_SCELL_REL_SSB_RSRP,
                     a2ThresholdSCellRelSsbRsrp=A2_THRES_SCELL_REL_SSB_RSRP,
                     a2TimeToTriggerSCellRelSsbRsrp=A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP)]),
]

MODIFY_SCF_A1_SCELL_ADD_A2_SCELL_RELEASE_API = MODIFY_SCF_A1_SCELL_ADDITION_API + MODIFY_SCF_A2_SCELL_RELEASE_API


ENABLE_A1_SCELL_ADDITION_API = [
    dict(
        dist_name=PCELL_DN,
        parameter='a1MeasSCellAddEnabled',
        value='rsrp'),
]
ENABLE_A2_SCELL_RELEASE_API = [
    dict(
        dist_name=SCELL_UL_DN,
        parameter='a2MeasSCellRelEnabled',
        value='rsrp'),
]
AVOID_RLQ_SCELL_SUSPEND = [
    dict(
        dist_name=PCELL_DN,
        parameter='sCellBadChannelQualityThreshold',
        value='1'),
]

ENABLE_A1_SCELL_ADDITION_A2_SCELL_RELEASE_API = ENABLE_A1_SCELL_ADDITION_API + \
                                                ENABLE_A2_SCELL_RELEASE_API + \
                                                MODIFY_SCF_A1_SCELL_ADD_A2_SCELL_RELEASE_API + \
                                                AVOID_RLQ_SCELL_SUSPEND

SCF_SCELL_ACTIVATION_BUFFERBASED_API = [
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='sCellActivationMethod',
        value='bufferBased'),

    dict(
        dist_name=PCELL_DN,
        parameter='sCellDeactivationTimerGNB',
        value='ms1280'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellDeactivationTimerGNB',
        value='ms1280'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[1]),
        parameter='sCellDeactivationTimerGNB',
        value='ms1280'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[2]),
        parameter='sCellDeactivationTimerGNB',
        value='ms1280'),
    dict(
        dist_name=PCELL_DN,
        parameter='sCellActivationLevel',
        value='1TTI'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellActivationLevel',
        value='1TTI'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[1]),
        parameter='sCellActivationLevel',
        value='1TTI'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[2]),
        parameter='sCellActivationLevel',
        value='1TTI'),
    dict(
        dist_name=PCELL_DN,
        parameter='sCellActivationLevelUL',
        value='1TTI'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellActivationLevelUL',
        value='1TTI'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[1]),
        parameter='sCellActivationLevelUL',
        value='1TTI'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[2]),
        parameter='sCellActivationLevelUL',
        value='1TTI'),

]

SCF_SCELL_ACTIVE_ONE_BY_ONE_API = [
    dict(
        dist_name=PCELL_DN,
        parameter='iniNumSCellsToActivate',
        value='1'),
    # dict(
    #     dist_name=PCELL_DN,
    #     parameter='bufferThesholdScellDePrioritize',
    #     value='200'),
    # dict(
    #     dist_name=SCELL_UL_DN,
    #     parameter='bufferThesholdScellDePrioritize',
    #     value='200'),
    # dict(
    #     dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[1]),
    #     parameter='bufferThesholdScellDePrioritize',
    #     value='200'),
    # dict(
    #     dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[2]),
    #     parameter='bufferThesholdScellDePrioritize',
    #     value='200'),
    # dict(
    #     dist_name=PCELL_DN,
    #     parameter='ScellDePrioritizeEvalPeriod',
    #     value='50'),
    # dict(
    #     dist_name=SCELL_UL_DN,
    #     parameter='ScellDePrioritizeEvalPeriod',
    #     value='50'),
    # dict(
    #     dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[1]),
    #     parameter='ScellDePrioritizeEvalPeriod',
    #     value='50'),
    # dict(
    #     dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_ID[2]),
    #     parameter='ScellDePrioritizeEvalPeriod',
    #     value='50')
]

MODIFY_TDD_SCF_A1_COVBASEDA1 = [
    dict(
        dist_name=PCELL_DN + '/NRREL-1',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
        dist_name=PCELL_DN + '/NRREL-2',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
        dist_name=PCELL_DN + '/NRREL-3',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
]

MODIFY_SCF_TDD_A1_SCELL_ADDITION_TO_COVBASEDA1_API = [
    dict(
         dist_name=PCELL_DN,
         parameter='a1MeasSCellAddSsbRsrp',
         value=[dict(a1HysteresisSCellAddSsbRsrp=A1_HYS_SCELL_ADD_SSB_RSRP,
                     a1ThresholdSCellAddSsbRsrpFDD=A1_THRES_SCELL_ADD_SSB_RSRP_FDD,
                     a1ThresholdSCellAddSsbRsrpTDD=A1_THRES_SCELL_ADD_SSB_RSRP_TDD,
                     a1TimeToTriggerSCellAddSsbRsrp=A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP)]),
] + MODIFY_TDD_SCF_A1_COVBASEDA1

MODIFY_SCF_FDD_A1_SCELL_ADDITION_TO_COVBASEDA1_API = [
    dict(
        dist_name=SCELL_UL_DN + '/NRREL-1',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
        dist_name=SCELL_UL_DN + '/NRREL-2',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
        dist_name=SCELL_UL_DN + '/NRREL-3',
        parameter='sCellAdditionMethod',
        value='covBasedA1'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='a1MeasSCellAddSsbRsrp',
        value=[dict(a1HysteresisSCellAddSsbRsrp=A1_HYS_SCELL_ADD_SSB_RSRP,
                    a1ThresholdSCellAddSsbRsrpFDD=A1_THRES_SCELL_ADD_SSB_RSRP_FDD,
                    a1ThresholdSCellAddSsbRsrpTDD=A1_THRES_SCELL_ADD_SSB_RSRP_TDD,
                    a1TimeToTriggerSCellAddSsbRsrp=A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP)]),
]

SCF_CASE_AB_B5_007 = SCF_SCELL_ACTIVATION_BUFFERBASED_API\
                  + SCF_SCELL_ACTIVE_ONE_BY_ONE_API\
                  + MODIFY_SCF_TDD_A1_SCELL_ADDITION_TO_COVBASEDA1_API\
                  + MODIFY_SCF_FDD_A1_SCELL_ADDITION_TO_COVBASEDA1_API

# RLQ related paras
MODIFY_SCF_BC_B7_007_RLQ_API = [
    dict(
        dist_name=SCELL_UL_DN,
        parameter='actUl256Qam',
        value='false'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellBadChannelQualityThUL',
        value='15'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellBadChannelQualityThreshold',
        value='3'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellGoodChannelQualityThreshold',
        value='20'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellChannelEstimationPeriod',
        value='2000'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='sCellDeactivationBadRlqCount',
        value='90'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='a2MeasSCellRelEnabled',
        value='rsrp'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[1]),
        parameter='a2MeasSCellRelEnabled',
        value='rsrp'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(FDD_CELLS[1]),
        parameter='a2MeasSCellRelEnabled',
        value='rsrp'),
    dict(
         dist_name=SCELL_UL_DN,
         parameter='a2MeasSCellRelSsbRsrp',
         value=[dict(a2HysteresisSCellRelSsbRsrp=A2_HYS_SCELL_REL_SSB_RSRP_BC_7,
                     a2ThresholdSCellRelSsbRsrp=A2_THRES_SCELL_REL_SSB_RSRP_BC_7,
                     a2TimeToTriggerSCellRelSsbRsrp=A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP_BC_7)]),
    dict(
         dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[1]),
         parameter='a2MeasSCellRelSsbRsrp',
         value=[dict(a2HysteresisSCellRelSsbRsrp=A2_HYS_SCELL_REL_SSB_RSRP_BC_7,
                     a2ThresholdSCellRelSsbRsrp=A2_THRES_SCELL_REL_SSB_RSRP_BC_7,
                     a2TimeToTriggerSCellRelSsbRsrp=A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP_BC_7)]),
    dict(
         dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(FDD_CELLS[1]),
         parameter='a2MeasSCellRelSsbRsrp',
         value=[dict(a2HysteresisSCellRelSsbRsrp=A2_HYS_SCELL_REL_SSB_RSRP_BC_7,
                     a2ThresholdSCellRelSsbRsrp=A2_THRES_SCELL_REL_SSB_RSRP_BC_7,
                     a2TimeToTriggerSCellRelSsbRsrp=A2_TIME_TO_TRIGGER_SCELL_REL_SSB_RSRP_BC_7)]),
    dict(
         dist_name=PCELL_DN,
         parameter='a1MeasSCellAddSsbRsrp',
         value=[dict(a1HysteresisSCellAddSsbRsrp=A1_HYS_SCELL_ADD_SSB_RSRP_BC_7,
                     a1ThresholdSCellAddSsbRsrpFDD=A1_THRES_SCELL_ADD_SSB_RSRP_FDD_BC_7,
                     a1ThresholdSCellAddSsbRsrpTDD=A1_THRES_SCELL_ADD_SSB_RSRP_TDD_BC_7,
                     a1TimeToTriggerSCellAddSsbRsrp=A1_TIME_TO_TRIGGER_SCELL_ADD_SSB_RSRP_BC_7)]),
] + MODIFY_TDD_SCF_A1_COVBASEDA1 + ENABLE_A1_SCELL_ADDITION_API

SCF_ENABLE_CNI81817_API = [
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actHighestEstNrTputBcSel',
        value='true')
]

SCF_UPDATE_FR1ULCAPREFERRED_DATARATEPREFERRED_API = [
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
        parameter='fr1UlCaPreferred',
        value='dataRatePreferred')
]

SCF_UPDATE_FR1ULCAPREFERRED_ULCAPREFERRED_API = [
    dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
        parameter='fr1UlCaPreferred',
        value='ulCaPreferred')
]

SCF_ENABLE_CB008830_API = [
    dict(
        dist_name=PCELL_DN,
        parameter='dlDmrsType',
        value='Type2'),
    dict(
        dist_name=CELL5_AEHC_DN,
        parameter='dlDmrsType',
        value='Type2')
]

SCF_DISABLE_CB008830_API = [
    dict(
        dist_name=PCELL_DN,
        parameter='dlDmrsType',
        value='Type1'),
    dict(
        dist_name=CELL5_AEHC_DN,
        parameter='dlDmrsType',
        value='Type1')
]
