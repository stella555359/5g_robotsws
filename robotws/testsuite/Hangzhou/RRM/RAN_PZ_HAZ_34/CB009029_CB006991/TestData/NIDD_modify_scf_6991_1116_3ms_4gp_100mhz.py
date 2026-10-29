from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB009029_CB006991.TestData.NIDD_modify_scf_6991_base import *

CONFIG_1116_3MS_4GP_100MHZ = {
    "frameStructureBW": STR_1116_3MS_4GP_100MHZ,
    "nrRimMitigationScheme": MITIGATION_SCHEME_DL_UL,
    "numRsType1SetId": NUM_RIMRS1_SETID_1116_3MS_4GP,
    "numRbForRs": "96 RBs",
    "repetitionRsType1": "r1",
    "rsPattern1Period": "5ms",
    "rsPattern2Period": None,
    "rsSetId": 65535,
    "rsSetIdAggressor": 11163,
    "startRbForRs": START_RB_FOR_RS_100MHZ,
    "manualFrameTimingAdjustment": 0,
    "manualFrameTimingAdjustmentAggressor": 4280000,
    "nrRiMonitorDownhillEndSymbol": 8,
    "dlMuteSlotsStr": DL_MUTE_SLOTS_SPECIAL_PRECEDING,
    "near_far": NEAR_ONLY,
    "transmission_window": "3min",
    "maxRsDetectDurationWithoutRi": MIN_RS_DETECTION_DURATION_WO_RI,
}

# for 1116_3MS_4GP_100MHZ
MODIFY_SCF_6991_1116_3MS_4GP_100MHZ = get_scf_modify_6991_for_specific_frame_bw(
    DN_NRBTS, DN_MRBTS, DN_TDDCELL, CONFIG_1116_3MS_4GP_100MHZ, False
)
MODIFY_SCF_6991_1116_3MS_4GP_100MHZ_AGGRESSOR = get_scf_modify_6991_for_specific_frame_bw(
    DN_NRBTS_GNB1,
    DN_MRBTS_GNB1,
    DN_TDDCELL_GNB1,
    CONFIG_1116_3MS_4GP_100MHZ,
    True,
)
MODIFY_SCF_DEFAULT_1116_3MS_4GP_100MHZ_GNB0 = (
    MODIFY_SCF_BASE + MODIFY_SCF_6991_1116_3MS_4GP_100MHZ + ACT_PDSCHSchSplSlot
)
MODIFY_SCF_DEFAULT_1116_3MS_4GP_100MHZ_GNB1 = (
    MODIFY_SCF_BASE_AGGRESSOR + MODIFY_SCF_6991_1116_3MS_4GP_100MHZ_AGGRESSOR + ACT_PDSCHSchSplSlot_AGGRESSOR
)

PARAMS_TO_ADD_1116_3MS_4GP_100MHZ_GNB0 = [
    dict(
        dist_name=DN_TDDCELL + "/NRRIM_PROFILE-1",
        list_name="startRbForRs",
        elements=CONFIG_1116_3MS_4GP_100MHZ["startRbForRs"]
    )
]

PARAMS_TO_ADD_1116_3MS_4GP_100MHZ_GNB1 = [
    dict(
        dist_name=DN_TDDCELL_GNB1 + "/NRRIM_PROFILE-1",
        list_name="startRbForRs",
        elements=CONFIG_1116_3MS_4GP_100MHZ["startRbForRs"]
    )
]

PARAMS_TO_DELETE_1116_3MS_4GP_100MHZ_GNB0 = [
    dict(
        dist_name=DN_TDDCELL + "/NRRIM_PROFILE-1",
        list_name='startRbForRs'
    )
]

PARAMS_TO_DELETE_1116_3MS_4GP_100MHZ_GNB1 = [
    dict(
        dist_name=DN_TDDCELL_GNB1 + "/NRRIM_PROFILE-1",
        list_name='startRbForRs'
    )
]

PARAMS_TO_ADD_1116_3MS_4GP_100MHZ_GNB0 = PARAMS_TO_ADD_1116_3MS_4GP_100MHZ_GNB0 + PARAMS_TO_ADD_PCMD
PARAMS_TO_DELETE_1116_3MS_4GP_100MHZ_GNB0 = PARAMS_TO_DELETE_1116_3MS_4GP_100MHZ_GNB0 + PARAMS_TO_DELETE_PCMD
PARAMS_TO_DELETE_DIC = [PARAMS_TO_DELETE_1116_3MS_4GP_100MHZ_GNB0, PARAMS_TO_DELETE_1116_3MS_4GP_100MHZ_GNB1]
PARAMS_TO_MODIFY_DIC = [MODIFY_SCF_DEFAULT_1116_3MS_4GP_100MHZ_GNB0, MODIFY_SCF_DEFAULT_1116_3MS_4GP_100MHZ_GNB1]
PARAMS_TO_ADD_DIC = [PARAMS_TO_ADD_1116_3MS_4GP_100MHZ_GNB0, PARAMS_TO_ADD_1116_3MS_4GP_100MHZ_GNB1]
