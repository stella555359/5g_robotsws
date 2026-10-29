# ======================================================================================
# ======================================================================================
# ======================================================================================
# Prepare
SUITE_SETUP_CELL_ADDITION = []
SUITE_SETUP_CELL_DELETION = ["802"]


SUITE_SETUP_CELL_RECOMMISSIONING = [{
    "nrCellId": "701",
    "channel_grp_list": ["4TX4RX", "4TX4RX", "4TX", "4TX"],
    "cellBwpList": [{"bwpDN": "8"}, {"bwpDN": "79"}],

    "chBw": "100MHz",
    "physCellId": "845",
    "nrCellType": "16DL8UL",
    "nrarfcn": "517002",
}, {
    "nrCellId": "702",
    "channel_grp_list": ["4TX4RX", "4TX"],
    "cellBwpList": [{"bwpDN": "8"}, {"bwpDN": "75"}],

    "chBw": "50MHz",
    "physCellId": "846",
    "nrCellType": "8DL4UL",
    "nrarfcn": "532008",
}, {
    "nrCellId": "703",
    "channel_grp_list": ["4TX4RX", "4TX"],
    "cellBwpList": [{"bwpDN": "7"}, {"bwpDN": "71"}],

    "chBw": "15MHz",
    "physCellId": "847",
    "nrCellType": "8DL4UL",
    "nrarfcn": "502536",
}]


# ======================================================================================
# ======================================================================================
# ======================================================================================
# Cell Parameter
Manual_SiSo_CM_Recommissioning = [{
    "nrCellId": "701",
    "channel_grp_list": ["4TX4RX", "4TX4RX", "4TX", "4TX"],
    "cellBwpList": [{"bwpDN": "8"}, {"bwpDN": "75"}],

    "chBw": "50MHz",
    "physCellId": "845",
    "nrCellType": "16DL8UL",
    "nrarfcn": "532008",
}, {
    "nrCellId": "702",
    "channel_grp_list": ["4TX4RX", "4TX"],
    "cellBwpList": [{"bwpDN": "7"}, {"bwpDN": "71"}],

    "chBw": "15MHz",
    "physCellId": "846",
    "nrCellType": "8DL4UL",
    "nrarfcn": "502536",
}, {
    "nrCellId": "703",
    "channel_grp_list": ["4TX4RX", "4TX"],
    "cellBwpList": [{"bwpDN": "8"}, {"bwpDN": "74"}],

    "chBw": "40MHz",
    "physCellId": "847",
    "nrCellType": "8DL4UL",
    "nrarfcn": "530046",
}]


General_SiSo_Online_Sector_Addition_Deletion = ["702"]


# ======================================================================================
# ======================================================================================
# ======================================================================================
# L3 CALL CELL Configuration
L3_CALL_CELL_ID_LIST_CONFIGURATION = {
    "Manual_SiSo_CM_Recommissioning": ["703"],
    "General_SiSo_Commissioning_BTS_Template_Commissioning": ["703"],
    "General_SiSo_Auto_Cell_lock_and_unlock_with_L3call": ["703"],
    "General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing": ["703"],
    "General_SiSo_Online_Sector_Addition_Deletion": ["703"],
    "Manual_SiSo_SM_RF_Module_lock_unlock": ["703"],
    "Manual_SiSo_Common_BBMOD_Reset": ["703"],
    "Manual_SiSo_SM_BTS_Site_Reset": ["703"],
    "Manual_SiSo_SM_BTS_Site_Reset_with_HWF": ["703"],
    "OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call": ["703"],
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
        "tput_send_dl": "710", "tput_expect_dl": "710", "tput_deviation_dl": "0.98",
        "tput_send_ul": "65", "tput_expect_ul": "65", "tput_deviation_ul": "0.98", "method": "PEAK",
        "min_percent": "0.85", "duration": "30",
    },
    "703": {
        "ue_index": 0,
        "tput_send_dl": "180", "tput_expect_dl": "180", "tput_deviation_dl": "0.98",
        "tput_send_ul": "15", "tput_expect_ul": "15", "tput_deviation_ul": "0.98", "method": "PEAK",
        "min_percent": "0.85", "duration": "30",
    },
}
