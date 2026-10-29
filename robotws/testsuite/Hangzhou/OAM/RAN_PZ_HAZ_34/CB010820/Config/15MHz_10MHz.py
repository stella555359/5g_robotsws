# ======================================================================================
# ======================================================================================
# ======================================================================================
# Prepare
SUITE_SETUP_CELL_ADDITION = []
SUITE_SETUP_CELL_DELETION = []

SUITE_SETUP_CELL_RECOMMISSIONING = []


# ======================================================================================
# ======================================================================================
# ======================================================================================
# L3 CALL CELL Configuration
L3_CALL_CELL_ID_LIST_CONFIGURATION = {
    "General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz": ["702"],
    "General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz": ["703"],
}


L3_CALL_PARAMETER = {
    "701": {
        "ue_index": 0,
        "tput_send_dl": "1500", "tput_expect_dl": "1500", "tput_deviation_dl": "0.98",
        "tput_send_ul": "135", "tput_expect_ul": "135", "tput_deviation_ul": "0.98", "method": "PEAK",
        "min_percent": "0.85", "duration": "30",
    },
    "702": {
        "ue_index": 0,
        "tput_send_dl": "180", "tput_expect_dl": "180", "tput_deviation_dl": "0.98",
        "tput_send_ul": "15", "tput_expect_ul": "15", "tput_deviation_ul": "0.98", "method": "PEAK",
        "min_percent": "0.85", "duration": "30",
    },
    "703": {
        "ue_index": 0,
        "tput_send_dl": "100", "tput_expect_dl": "100", "tput_deviation_dl": "0.98",
        "tput_send_ul": "9", "tput_expect_ul": "9", "tput_deviation_ul": "0.98", "method": "PEAK",
        "min_percent": "0.85", "duration": "30",
    },
}
