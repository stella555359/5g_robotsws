from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB009029_CB006991.TestData.NIDD_modify_scf_6991_base import *

CONFIG_1070_2GP_80MHZ = {
    "frameStructureBW": STR_1070_2GP_80MHZ,
    "nrRimMitigationScheme": MITIGATION_SCHEME_DL_UL,
    "numRsType1SetId": NUM_RIMRS1_SETID_1070,
    "numRbForRs": "48 RBs",
    "repetitionRsType1": "r4",
    "rsPattern1Period": "2.5ms",
    "rsPattern2Period": "2.5ms",
    "rsSetId": 524287,
    "rsSetIdAggressor": 1070,
    "startRbForRs": START_RB_FOR_RS_80MHZ,
    "manualFrameTimingAdjustment": 0,
    "manualFrameTimingAdjustmentAggressor": 3920000,
    "nrRiMonitorDownhillEndSymbol": 11,
    "dlMuteSlotsStr": DL_MUTE_SLOTS_SPECIAL,
    "near_far": NEAR_ONLY,
    "transmission_window": "5min",
    "maxRsDetectDurationWithoutRi": DEFAULT_RS_DETECTION_DURATION_WO_RI
}

# for 1070_2GP_80MHZ
MODIFY_SCF_6991_1070_2GP_80MHZ = get_scf_modify_6991_for_specific_frame_bw(
    DN_NRBTS, DN_MRBTS, DN_TDDCELL, CONFIG_1070_2GP_80MHZ, False
)
MODIFY_SCF_6991_1070_2GP_80MHZ_AGGRESSOR = get_scf_modify_6991_for_specific_frame_bw(
    DN_NRBTS_GNB1, DN_MRBTS_GNB1, DN_TDDCELL_GNB1, CONFIG_1070_2GP_80MHZ, True
)
MODIFY_SCF_6991_1070_2GP_80MHZ = MODIFY_SCF_6991_1070_2GP_80MHZ+MODIFY_SCF_NRRIM_24R3 \
    if PROGRAM >= '24R3' else MODIFY_SCF_6991_1070_2GP_80MHZ
MODIFY_SCF_DEFAULT_1070_2GP_80MHZ_GNB0 = MODIFY_SCF_BASE + MODIFY_SCF_6991_1070_2GP_80MHZ + DISABLE_PDSCHSchSplSlot
MODIFY_SCF_DEFAULT_1070_2GP_80MHZ_GNB1 = (
    MODIFY_SCF_BASE_AGGRESSOR + MODIFY_SCF_6991_1070_2GP_80MHZ_AGGRESSOR + DISABLE_PDSCHSchSplSlot_AGGRESSOR
)

PARAMS_TO_ADD_1070_2GP_80MHZ_GNB0 = [
    dict(
        value=CONFIG_1070_2GP_80MHZ["rsPattern2Period"],
        dist_name=DN_TDDCELL + "/NRRIM_PROFILE-1",
        p_name="rsPattern2Period",
    ),
    dict(
        dist_name=DN_TDDCELL + "/NRRIM_PROFILE-1",
        list_name="startRbForRs",
        elements=CONFIG_1070_2GP_80MHZ["startRbForRs"]
    )
]

PARAMS_TO_ADD_1070_2GP_80MHZ_GNB1 = [
    dict(
        value=CONFIG_1070_2GP_80MHZ["rsPattern2Period"],
        dist_name=DN_TDDCELL_GNB1 + "/NRRIM_PROFILE-1",
        p_name="rsPattern2Period",
    ),
    dict(
        dist_name=DN_TDDCELL_GNB1 + "/NRRIM_PROFILE-1",
        list_name="startRbForRs",
        elements=CONFIG_1070_2GP_80MHZ["startRbForRs"]
    )
]

PARAMS_TO_DELETE_1070_2GP_80MHZ_GNB0 = [
    dict(
        dist_name=DN_TDDCELL + "/NRRIM_PROFILE-1",
        list_name='startRbForRs'
    )
]

PARAMS_TO_DELETE_1070_2GP_80MHZ_GNB1 = [
    dict(
        dist_name=DN_TDDCELL_GNB1 + "/NRRIM_PROFILE-1",
        list_name='startRbForRs'
    )
]

PARAMS_TO_DELETE_DIC = [PARAMS_TO_DELETE_1070_2GP_80MHZ_GNB0, PARAMS_TO_DELETE_1070_2GP_80MHZ_GNB1]
PARAMS_TO_MODIFY_DIC = [MODIFY_SCF_DEFAULT_1070_2GP_80MHZ_GNB0, MODIFY_SCF_DEFAULT_1070_2GP_80MHZ_GNB1]
PARAMS_TO_ADD_DIC = [PARAMS_TO_ADD_1070_2GP_80MHZ_GNB0, PARAMS_TO_ADD_1070_2GP_80MHZ_GNB1]
