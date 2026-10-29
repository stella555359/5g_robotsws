# ======================================================================================
# ======================================================================================
# ======================================================================================
# Prepare
SUITE_SETUP_CELL_ADDITION = []
SUITE_SETUP_CELL_DELETION = []


SUITE_SETUP_CELL_RECOMMISSIONING = [{
    "nrCellId": "10",
    "channel_grp_list": ["4TX4RX", "4TX4RX", "4TX", "4TX"],
    "cellBwpList": [{"bwpDN": "8"}, {"bwpDN": "79"}],

    "chBw": "100MHz",
    "physCellId": "845",
    "nrCellType": "16DL8UL",
    "nrarfcn": "517002",
}, {
    "nrCellId": "11",
    "channel_grp_list": ["4TX4RX", "4TX4RX", "4TX", "4TX"],
    "cellBwpList": [{"bwpDN": "7"}, {"bwpDN": "71"}],

    "chBw": "15MHz",
    "physCellId": "846",
    "nrCellType": "16DL8UL",
    "nrarfcn": "502536",
    "actPdcchSharingWithPdsch": "false",
    # "actRat1Alloc": "false",
    "csirsForTracking": [{"rbAllocation": "BWP"}],
}]


# ======================================================================================
# ======================================================================================
# ======================================================================================
# Cell Parameter
Manual_SiSo_CM_Recommissioning = [{
    "nrCellId": "10",
    "channel_grp_list": ["4TX4RX", "4TX4RX", "4TX", "4TX"],
    "cellBwpList": [{"bwpDN": "7"}, {"bwpDN": "71"}],

    "chBw": "15MHz",
    "physCellId": "845",
    "nrCellType": "16DL8UL",
    "nrarfcn": "502536",
}, {
    "nrCellId": "11",
    "channel_grp_list": ["4TX4RX", "4TX4RX", "4TX", "4TX"],
    "cellBwpList": [{"bwpDN": "8"}, {"bwpDN": "75"}],

    "chBw": "50MHz",
    "physCellId": "846",
    "nrCellType": "16DL8UL",
    "nrarfcn": "532008",
}]


General_SiSo_Online_Sector_Addition_Deletion = ["10"]


# ======================================================================================
# ======================================================================================
# ======================================================================================
# L3 CALL CELL Configuration
L3_CALL_CELL_ID_LIST_CONFIGURATION = {
    "Manual_SiSo_CM_Recommissioning": ["11"],
    "General_SiSo_Commissioning_BTS_Template_Commissioning": ["11"],
    "General_SiSo_Auto_Cell_lock_and_unlock_with_L3call": ["11"],
    "General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing": ["11"],
    "General_SiSo_Online_Sector_Addition_Deletion": ["11"],
    "Manual_SiSo_SM_RF_Module_lock_unlock": ["11"],
    "Manual_SiSo_Common_BBMOD_Reset": ["11"],
    "Manual_SiSo_SM_BTS_Site_Reset": ["11"],
    "Manual_SiSo_SM_BTS_Site_Reset_with_HWF": ["11"],
    "OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call": ["11"],
}


L3_CALL_PARAMETER = {
    "10": {
        "ue_index": 0,
        "tput_send_dl": "1500", "tput_expect_dl": "1500", "tput_deviation_dl": "0.98",
        "tput_send_ul": "135", "tput_expect_ul": "135", "tput_deviation_ul": "0.98", "method": "PEAK",
        "min_percent": "0.85", "duration": "30",
    },
    "11": {
        "ue_index": 0,
        "tput_send_dl": "194", "tput_expect_dl": "194", "tput_deviation_dl": "0.98",
        "tput_send_ul": "18.8", "tput_expect_ul": "18.8", "tput_deviation_ul": "0.98", "method": "PEAK",
        "min_percent": "0.85", "duration": "30",
    },
}
