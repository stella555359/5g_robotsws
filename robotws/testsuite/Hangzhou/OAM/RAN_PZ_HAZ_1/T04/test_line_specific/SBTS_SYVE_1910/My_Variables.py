ONAP_SIMULATOR = {
    "host_ip": "10.106.253.50",
    "user": "ute",
    "pwd": "RAN_pz_HAZ1_SG11",
}

MRBTS_DN = "PLMN-PLMN/MRBTS-1910"
WCDMA_DN = "PLMN-PLMN/RNC-511/WBTS-1910"
GSM_DN = "PLMN-PLMN/BSC-12345/BCF-2010"


def get_variables():
    variables = {
        "HW_LOCATION_CODE": "Hangzhou",
        "TESTLINE_NAME": "10_5_UTESRAN1910",
        "TEMP_LOGS_DIR": "/home/ute/logs",
        "BTS_USERNAME": "toor4nsn",
        "BTS_PASSWORD": "oZPS0POrRieRtu",
        "MAX_UDP_SIZE": "104857600",
        "SUBRACK": "1",
        "ONAP": ONAP_SIMULATOR,
        "MRBTS_DN": MRBTS_DN,
        "WCDMA_DN": WCDMA_DN,
        "GSM_DN": GSM_DN,
    }

    return variables
