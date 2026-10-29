# ======================================================================================
# ======================================================================================
# ======================================================================================
# Prepare
SUITE_SETUP_CELL_ADDITION = []
SUITE_SETUP_CELL_DELETION = []


SUITE_SETUP_CELL_RECOMMISSIONING = [{
    "nrCellId": "701",
    "channel_grp_list": ["4TX4RX", "4TX4RX"],
    "cellBwpList": [{"bwpDN": "8"}, {"bwpDN": "79"}],

    "chBw": "100MHz",
    "physCellId": "845",
    "nrCellType": "8DL8UL",
    "nrarfcn": "517002",
}, {
    "nrCellId": "702",
    "channel_grp_list": ["4TX4RX", "4TX4RX"],
    "cellBwpList": [{"bwpDN": "7"}, {"bwpDN": "71"}],

    "chBw": "15MHz",
    "physCellId": "846",
    "nrCellType": "8DL8UL",
    "nrarfcn": "502536",
}, {
    "nrCellId": "703",
    "channel_grp_list": ["4TX4RX", "4TX4RX"],
    "cellBwpList": [{"bwpDN": "7"}, {"bwpDN": "70"}],

    "chBw": "10MHz",
    "physCellId": "847",
    "nrCellType": "8DL8UL",
    "nrarfcn": "536514",
}]


# ======================================================================================
# ======================================================================================
# ======================================================================================
# Cell Parameter
Manual_SiSo_CM_Recommissioning = [{
    "nrCellId": "701",
    "channel_grp_list": ["4TX4RX", "4TX4RX"],
    "cellBwpList": [{"bwpDN": "7"}, {"bwpDN": "71"}],

    "chBw": "15MHz",
    "physCellId": "845",
    "nrCellType": "8DL8UL",
    "nrarfcn": "502536",
}, {
    "nrCellId": "702",
    "channel_grp_list": ["4TX4RX", "4TX4RX"],
    "cellBwpList": [{"bwpDN": "8"}, {"bwpDN": "72"}],

    "chBw": "20MHz",
    "physCellId": "846",
    "nrCellType": "8DL8UL",
    "nrarfcn": "510012",
}, {
    "nrCellId": "703",
    "channel_grp_list": ["4TX4RX", "4TX4RX"],
    "cellBwpList": [{"bwpDN": "7"}, {"bwpDN": "71"}],

    "chBw": "15MHz",
    "physCellId": "847",
    "nrCellType": "8DL8UL",
    "nrarfcn": "501000",
}]


General_SiSo_Online_Sector_Addition_Deletion = ["702"]


# ======================================================================================
# ======================================================================================
# ======================================================================================
# L3 CALL CELL Configuration
L3_CALL_CELL_ID_LIST_CONFIGURATION = {
    "Manual_SiSo_CM_Recommissioning": ["702"],
    "General_SiSo_Commissioning_BTS_Template_Commissioning": ["702"],
    "General_SiSo_Auto_Cell_lock_and_unlock_with_L3call": ["702"],
    "General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing": ["702", "703"],
    "General_SiSo_Online_Sector_Addition_Deletion": ["702"],
    "Manual_SiSo_SM_RF_Module_lock_unlock": ["702"],
    "Manual_SiSo_Common_BBMOD_Reset": ["702"],
    "Manual_SiSo_SM_BTS_Site_Reset": ["702"],
    "Manual_SiSo_SM_BTS_Site_Reset_with_HWF": ["702"],
    "OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call": ["702"],
}


L3_CALL_PARAMETER = {
    "701": {
        "ue_index": 0,
        "tput_send_dl": "1500", "tput_expect_dl": "1500", "tput_deviation_dl": "0.95",
        "tput_send_ul": "135", "tput_expect_ul": "135", "tput_deviation_ul": "0.95", "method": "PEAK",
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
