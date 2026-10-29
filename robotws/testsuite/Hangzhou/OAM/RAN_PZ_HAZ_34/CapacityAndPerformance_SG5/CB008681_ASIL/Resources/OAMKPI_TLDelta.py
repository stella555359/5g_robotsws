#!/usr/bin/env python3

__team__ = "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_05_GMS"
__email__ = "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_05_GMS@internal.nsn.com"

prefix_of_release = "SBTS_"
KPI = {
    "StreamPrefix": "SBTS00_ENB_9999",
    "Stream_Version": "SBTS22R4",
    "CB008457_IA": {
        "OriginalStream": {
            "SBTS00": "SBTS22R4_ENB_0000",
            "SBTS22R4": "SBTS22R3_ENB_0000",
            "SBTS22R3": "SBTS22R4_ENB_0000",
        },
        "OriginalStreamSCF": "OriginalStreamSCF.xml",
    },
    "CB008457_KPI1a": {
        "WebUI_reset_times": 2,
        # CNF_5G_8: single core ASIL
        "CNF_5G_8": {
            "KPI1a_AVG": 600,
            "KPI1a_MAX": 630,
        },
        # CNF_5G_11: Dual core ASIL
        "CNF_5G_11": {
            "KPI1a_AVG": 630,
            "KPI1a_MAX": 700,
        },
        # CNF_5G_16:CPRI config(ASIL+AENB&AZQF)
        "CNF_5G_16": {
            "KPI1a_AVG": 540,
            "KPI1a_MAX": 570,
        },
    },
    "CB008457_KPI3": {  # KPI#3-power reset
        "Power_reset_times": 2,
        "fail_loop_max": 2,
        # CNF_5G_8: single core ASIL
        "CNF_5G_8": {
            "KPI3_AVG": 540,
            "KPI3_MAX": 570,
        },
        # CNF_5G_11: Dual core ASIL
        "CNF_5G_11": {
            "KPI3_AVG": 570,
            "KPI3_MAX": 600,
        },
        # CNF_5G_16:CPRI config(ABIL+AENB&AZQF)
        "CNF_5G_16": {
            "KPI1a_AVG": 540,
            "KPI1a_MAX": 570,
        },
    },
    "CB008457_KPI10": {  # KPI#10-5GRAT reset
        # 270(ABIO reset used instead)
        # 240(if master radios)
        # 90(if cooled SFP used)
        # 240 (if in NSA mode , sctpWaitTimeInitSeqRetryX2 = 240)
        # 60(if actGrflShdn = true)
        # 60(if multi-core config)
        "DualCoreExtend": 60,
        "NSAExtend": 240,
        "KPI10": 270 + 240 + 90,
        "5GRAT_reset_times": 2,
        "CNF_5G_8": {
            "KPI10_AVG": 270 + 240 + 90 + 240,
        },
        "CNF_5G_11": {
            "KPI10_AVG": 270 + 240 + 90 + 60,
        },
        # CNF_5G_16:CPRI config(ABIL+AENB&AZQF)
        "CNF_5G_16": {
            "KPI10_AVG": 270,
            "KPI10_MAX": 270 + 240,
        },
    },
    "CB008457_KPI5": {  # KPI#5-Capacity Module Reset
        "BBMOD_reset_times": 10,
        "KPI5_AVG": 270,
        "KPI5_MAX": 270 + 240,
        "fail_loop_max": 2,
    },
    "CB008457_KPI16a": {  # KPI#16a-Cell lock
        "KPI16a_MAX": 40 + 10,
        "lock_cell_times": 2,
        "fail_times": 2,
    },
    "CB008457_KPI16b": {  # KPI#16b-Cell unlock
        "KPI16b_MAX": 40 + 10,
        "unlock_cell_times": 2,
        "fail_times": 2,
    },
    "CB008457_KPI17a": {  # KPI#17a-Cell block
        "KPI17a_MAX": 10 + 10,
        "cell_block_times": 2,
    },
    "CB008457_KPI17b": {  # KPI#17b-Cell unblock
        "KPI17b_MAX": 10 + 10,
        "cell_unblock_times": 2,
    },
    "CB008457_KPI51": {  # KPI#51-RU Reset
        "KPI51_MAX": 240 + 240,
        "KPI51_AVG": 240,
        "ru_reset_times": 2,
        "fail_loop_max": 2,
    },
    "CB008457_KPI54": {  # KPI#54-RU power Reset
        "KPI54A_MAX": 240 + 240,
        "KPI54A_AVG": 240,
        "ru_reset_times": 2,
        "fail_loop_max": 2,
    },
    'CM_A_01': {
        'Duration_SCFLoad': '10',
        'Duration_ValidationError': '270',
        'Duration_Validation': '140',
        'Duration_Activation': '600',
    },
    'CM_A_02': {
        'Duration_DeltaValidation_succ': 25,
        'Duration_DeltaValidation_error': 60, },
    'CM_A_03': {'SCF_backup_duration': 30, },
    'CM_A_04': {'Duration_DeltaActivation': 600, },
    'CM_A_05': {'Delta_Plan_Provision_Durtion': 110, },
    'CM_A_06': {'Full_Plan_Provision_Durtion': 660, },
    'CM_A_07': {'Delta_Plan_PreProvision_Durtion': 60, },
    'CM_A_08': {'Import_Delta_Plan_Durtion': 20, },
    'CM_A_09': {'Delta_Plan_Provision_Durtion_Reboot': 660, },
    'CM_A_10': {'CMUplod_Durtion': 30, },
    'CM_A_11': {'Duration_ChangeNoti': 30, },
    'CM_A_12': {'DurationOfSwCopyManual': 360, },
    'CM_A_13': {'snapshot_save_time': 7 * 60, },
    'CM_A_14': {'FilePresentTime': 7 * 60, },
}
# #################define search keyword for start time or end time in syslog############################
KEY_TIMESTART_KPI1a = "SiteResetPrepare::PerformReset"
kEY_TIMEEND_KPI1a = "All cells reached OnAirDone state"
KEY_TIMESTART_KPI5 = "from OnAirDone to Validated"
kEY_TIMEEND_KPI5 = "from Validated to OnAirDone"
KEY_TIMESTART_KPI16a = "\\[PlanActivateIndScenario\\] start scenario for"
kEY_TIMEEND_KPI16a = "AntennaCarrierDeactivationResp - OK"
KEY_TIMESTART_KPI16b = "\\[PlanActivateIndScenario\\] start scenario for"
kEY_TIMEEND_KPI16b = "AntennaCarrierActivationResp - OK"
KEY_TIMESTART_KPI17a = "Received BLOCK_IND with NR target"
kEY_TIMEEND_KPI17a = "AntennaCarrierDeactivationResp - OK"
KEY_TIMESTART_KPI17b = "Received UNBLOCK_IND with NR target"
kEY_TIMEEND_KPI17b = "AntennaCarrierActivationResp - OK"
KEY_TIMESTART_KPI51a = "from OnAirDone to Validated"
kEY_TIMEEND_KPI51a = "from Validated to OnAirDone"
KEY_TIMESTART_KPI10 = "from OnAirDone to Validated"
kEY_TIMEEND_KPI10 = "from Validated to OnAirDone"
KEY_TIMESTART_IP_connectivity_test = "Registering indication: /\x4dRBTS-1/RAT-1/URI-[[:digit:]]/SESSION-[[" \
                                     ":digit:]]+/PINGTEST_IND-[[:digit:]]"
KEY_TIMEEND_IP_connectivity_test = "PINGTEST_IND-[[:digit:]]+/PINGTEST_RESULT-[[:digit:]]+"
KEY_TIMESTART_SanityChecker = "Trigger start sanity check call"
KEY_TIMEEND_SanityChecker = "SanityCheckIndHandler\\] Successful result created"
