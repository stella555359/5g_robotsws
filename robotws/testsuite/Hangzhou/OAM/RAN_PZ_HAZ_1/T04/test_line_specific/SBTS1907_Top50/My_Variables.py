MRBTS_DN = "PLMN-PLMN/MRBTS-1907"
WCDMA_DN = "PLMN-PLMN/RNC-511/WBTS-1890"
GSM_DN = "PLMN-PLMN/BSC-210129/BCF-2010"


def get_variables():
    variables = {
        "HW_LOCATION_CODE": "Hangzhou",
        "TESTLINE_NAME": "10_5_UTE5G-1906-4G-1907_MRBTS-1907",
        "TEMP_LOGS_DIR": "/home/ute/logs",
        "BTS_USERNAME": "toor4nsn",
        "BTS_PASSWORD": "oZPS0POrRieRtu",
        "MAX_UDP_SIZE": "104857600",
        "SUBRACK": "1",
        "MRBTS_DN": MRBTS_DN,
        "WCDMA_DN": WCDMA_DN,
        "GSM_DN": GSM_DN,
        # "INTERFACES": INTERFACES,
        "BTSMED_CONFIG_LIST": [],
    }

    return variables


# __all__ = ['tl', 'INTERFACES', 'NETACT_PLAN']
