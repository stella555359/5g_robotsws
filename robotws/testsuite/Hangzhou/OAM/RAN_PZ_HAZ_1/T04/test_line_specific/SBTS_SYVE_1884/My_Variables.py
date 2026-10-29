MRBTS_DN = "PLMN-PLMN/MRBTS-1884"
WCDMA_DN = "PLMN-PLMN/RNC-511/WBTS-1909"
GSM_DN = "PLMN-PLMN/BSC-210129/BCF-1909"


def get_variables():
    variables = {
        "HW_LOCATION_CODE": "Hangzhou",
        "TESTLINE_NAME": "10_5_UTESRAN1884",
        "TEMP_LOGS_DIR": "/home/ute/logs",
        "BTS_USERNAME": "toor4nsn",
        "BTS_PASSWORD": "oZPS0POrRieRtu",
        "MAX_UDP_SIZE": "104857600",
        "SUBRACK": "1",
        "MRBTS_DN": MRBTS_DN,
        "WCDMA_DN": WCDMA_DN,
        "GSM_DN": GSM_DN,
    }

    return variables
