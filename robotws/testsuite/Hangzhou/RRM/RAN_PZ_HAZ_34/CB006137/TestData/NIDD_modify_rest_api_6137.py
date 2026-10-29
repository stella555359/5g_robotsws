from robot.libraries.BuiltIn import BuiltIn
from NIDD_modify_scf import PCELL_DN, SCELL_UL_DN, FDD_CELLS, TDD_CELLS
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
import NIDD_Modify_data_template as data_template
# from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value('${PROGRAM}')
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')

# ${GNB_INFO}: Define in NIDD_modify_scf.py
GNB_INFO = BuiltIn().get_variable_value('${GNB_INFO}')

# NR_CELL_ID_MAPPING: Get from GNB online by method get_relation_mapping_between_cell_index_and_other_ids
NR_CELL_ID_MAPPING = BuiltIn().get_variable_value('${NR_CELL_ID_MAPPING}')

# Params defined in CB006137_keywords.Decode CA group mapping and set global variable
PCELL_ID = BuiltIn().get_variable_value('${PCELL_ID}')
SCELL_ID_UL_ADD = BuiltIn().get_variable_value('${SCELL_ID_UL_ADD}')
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
# Parameter dedined in 5GC006137_variables.robot
carrierAggregationSupportList_F_T_UL_DL = BuiltIn().get_variable_value('${carrierAggregationSupportList_F_T_UL_DL}')
carrierAggregationSupportList_F_T_NO_UL = BuiltIn().get_variable_value(
    '${carrierAggregationSupportList_F_T_NO_UL}')
carrierAggregationSupportList_F_T_NO_ULDL = BuiltIn().get_variable_value(
    '${carrierAggregationSupportList_F_T_NO_ULDL}')
ULTRANSPRECODEOFFSINRTHRESH = BuiltIn().get_variable_value('${ULTRANSPRECODEOFFSINRTHRESH}')
ULTRANSPRECODEONSINRTHRESH = BuiltIn().get_variable_value('${ULTRANSPRECODEONSINRTHRESH}')

MODIFY_ACTIVE_F_T_UL_DL_CA_RESTAPI = [
    dict(
        value=carrierAggregationSupportList_F_T_UL_DL,
        dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='increasePUSCHPrepTimeULCA',
        value='true')
]

MODIFY_DEACTIVE_F_T_NO_UL_CA_RESTAPI = [
    dict(
        value=carrierAggregationSupportList_F_T_NO_UL,
        dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='increasePUSCHPrepTimeULCA',
        value='false')
]

MODIFY_DEACTIVE_F_T_NO_UL_DL_CA_RESTAPI = [
    dict(
        value=carrierAggregationSupportList_F_T_NO_ULDL,
        dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList')
]

# RLQ related paras
MODIFY_SCF_RLQ_API = [
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
        value='15'),
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
        value='3')
]

# power split related paras
MODIFY_SCF_POWERSPLIT_PC3_API = [
    dict(
        dist_name=PCELL_DN,
        parameter='pMaxNROwnCell',
        value='23'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='pMaxNROwnCell',
        value='23'),
    dict(
        dist_name=PCELL_DN,
        parameter='weightRatioOfUePwrScellVsPcell',
        value='WeightRatio 1'),
    dict(
        dist_name=PCELL_DN,
        parameter='sCellBadChannelQualityThUL',
        value='0'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellBadChannelQualityThUL',
        value='0'),
    dict(
        dist_name=PCELL_DN,
        parameter='sCellBadChannelQualityThreshold',
        value='0'),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='sCellBadChannelQualityThreshold',
        value='0'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='sCellDeactivationBadRlqCount',
        value='0')
]

MODIFY_weightForSCellSelection_3CC = [
    dict(
        value='90',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(FDD_CELLS[1]),
        parameter='weightForSCellSelection'),
    dict(
        value='5',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[0]),
        parameter='weightForSCellSelection'),
    dict(
        value='50',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[1]),
        parameter='weightForSCellSelection'),
]

MODIFY_weightForSCellSelection_4CC = [
    dict(
        value='50',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(FDD_CELLS[1]),
        parameter='weightForSCellSelection'),
    dict(
        value='10',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[0]),
        parameter='weightForSCellSelection'),
    dict(
        value='50',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[1]),
        parameter='weightForSCellSelection'),
    dict(
        value='60',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[2]),
        parameter='weightForSCellSelection')
]

MODIFY_weightForSCellSelection_4CC_X75 = [
    dict(
        value='90',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(FDD_CELLS[1]),
        parameter='weightForSCellSelection'),
    dict(
        value='5',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[0]),
        parameter='weightForSCellSelection'),
    dict(
        value='50',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[1]),
        parameter='weightForSCellSelection'),
    dict(
        value='60',
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[2]),
        parameter='weightForSCellSelection')
]

# RESTAPI_DISABLE_A6_SCELL_SWAP = [
#     dict(
#         dist_name=param_modify_lib.DN_NRBTS,
#         parameter='actSCellSwapFr1',
#         value='disabled')
# ]

# For case C_B27_01. Will active on pcell and scell with ul CA
RESTAPI_ACT_actUlDftSOfdm = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.RESTAPI_MODIFY_actUlDftSOfdm, list_cell_id=[PCELL_ID]+SCELL_ID_UL_ADD, value='true')

RESTAPI_ACT_actUlDftSOfdm_AND_SET_THRESH_FOR_ulTransPrecodeCtl = RESTAPI_ACT_actUlDftSOfdm + [
    dict(
        dist_name=PCELL_DN,
        parameter='ulTransPrecodeCtl',
        value=[
            dict(
                ulTransPrecodeOffSinrThresh=str(ULTRANSPRECODEOFFSINRTHRESH),
                ulTransPrecodeOffSinrThrRedCap=str(ULTRANSPRECODEOFFSINRTHRESH),
                ulTransPrecodeOnSinrThresh=str(ULTRANSPRECODEONSINRTHRESH),
                ulTransPrecodeOnSinrThrRedCap=str(ULTRANSPRECODEONSINRTHRESH),
                ulTransPrecodePi2Bpsk='true',
                ulTransPrePi2BpskPwrBoost='false'
            )
        ]
    ),
    dict(
        dist_name=SCELL_UL_DN,
        parameter='ulTransPrecodeCtl',
        value=[
            dict(
                ulTransPrecodeOffSinrThresh=str(ULTRANSPRECODEOFFSINRTHRESH),
                ulTransPrecodeOffSinrThrRedCap=str(ULTRANSPRECODEOFFSINRTHRESH),
                ulTransPrecodeOnSinrThresh=str(ULTRANSPRECODEONSINRTHRESH),
                ulTransPrecodeOnSinrThrRedCap=str(ULTRANSPRECODEONSINRTHRESH),
                ulTransPrecodePi2Bpsk='true',
                ulTransPrePi2BpskPwrBoost='false'
            )
        ]
    )
]

# For case CB006137-AB_01_US01, will enable CB008311 in case setup

RESTAPI_ACT_CB008311_BTS_LEVEL = [
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actBufferBasedSCellAddition',
        value='oneShot_Dl_Fr1'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actSCellReleaseForInactiveSCell',
        value='timer_based_Fr1'),
    # disabled badRLQ in case case behaviors are affected
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actSCellReleaseBadSCellRlq',
        value='disabled')

]
_RESTAPI_ACT_CB008311_CELLS_LEVEL = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.RESTAPI_ADD_CB008311_PARAMS_CELLS, list_cell_id=ALL_CELLS)

RESTAPI_ACT_CB008311_DICT = {
    'param_to_upd': RESTAPI_ACT_CB008311_BTS_LEVEL,
    'param_to_add': _RESTAPI_ACT_CB008311_CELLS_LEVEL
}

RESTAPI_DISABLE_CB008311_BTS_LEVEL = [
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actBufferBasedSCellAddition',
        value='disabled'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actSCellReleaseForInactiveSCell',
        value='disabled')
]

# Fix issue of tput not stable after change one radio of TL254, so this need to active CB012269
RESTAPI_ACT_CB012269_NIDD_update = [
     dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actTddCsiRsOpt',
        value='true'),
     dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actBbPoolTddFr1',
        value='true'),
     dict(
        dist_name=param_modify_lib.DN_NRBTS,
        parameter='actBbPoolTddFr1AlgEnh',
        value='true'),
     dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[0]),
        parameter='csirsForTracking',
        value=[dict(rbAllocation='52RB')]),
     dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[2]),
        parameter='csirsForTracking',
        value=[dict(rbAllocation='52RB')]),
     dict(
        dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1',
        parameter='refNrCellGroup',
        value=['0',
               '1',
               '2',
               '4'])
]

# After actived CB012269, need to set all TDD cells to 4x4, but AWHHH of TL254 is 2T2R, so delete this cell
RESTAPI_delete_object_to_fix_PDL = [
     dict(dist_name=param_modify_lib.DN_NRBTS + '/NRCELLGRP-3'),
     dict(dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-4'),
     dict(dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-2/NRREL-4'),
     dict(dist_name=param_modify_lib.DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4')
]

RESTAPI_ACT_CB012269 = {
    'param_to_upd': RESTAPI_ACT_CB012269_NIDD_update,
    'object_to_del': RESTAPI_delete_object_to_fix_PDL
}

# RESTAPI_ENABLE_DRX = [
#     dict(
#         dist_name=DN_PCELL,
#         parameter='actCDrx',
#         value='true'),
#     dict(
#         dist_name=DN_PCELL,
#         parameter='drxProfile1',
#         value=[dict(drxInactivityTimer='80ms', drxLongCycle='160ms', drxOnDurationTimer='10ms',
#                     drxRetransTimerDl='0slot', drxRetransTimerUl='0slot')]),
# ]
#
# RESTAPI_ENABLE_DRX_BELOW80 = [
#     dict(
#         dist_name=DN_PCELL,
#         parameter='actCDrx',
#         value='true'),
#     dict(
#         dist_name=DN_PCELL,
#         parameter='drxProfile1',
#         value=[dict(drxInactivityTimer='4ms', drxLongCycle='40ms', drxOnDurationTimer='6ms',
#                     drxRetransTimerDl='0slot', drxRetransTimerUl='0slot')]),
# ]
#
# RESTAPI_DISABLE_DRX = [
#     dict(
#         dist_name=DN_PCELL,
#         parameter='actCDrx',
#         value='false'),
# ]
#
# RESTAPI_DISABLE_A2_PCELL_CHANGE = [
#     dict(
#         dist_name=DN_TDDCELL_HOIF,
#         parameter='a2BasedPCellSwitchEnabled',
#         value='false'),
#     dict(
#         dist_name=DN_TDDCELLS,
#         parameter='a2MeasPCellSwitchEnabled',
#         value='none'),
#     dict(
#         dist_name=DN_FDDCELLS,
#         parameter='a2MeasSCellRelEnabled',
#         value='none'),
# ]
