ONAP = {
    "host_ip": "10.110.73.138",
    "user": "ute",
    "pwd": "Ut3pa5s#84b8",
}

ONAP_SIMULATOR = {
    "host_ip": "10.21.41.163",
    "user": "ute",
    "pwd": "UTE.debian12",
}

MRBTS_DN = "PLMN-PLMN/MRBTS-1905"
WCDMA_DN = "PLMN-PLMN/RNC-511/WBTS-1905"
GSM_DN = "PLMN-PLMN/BSC-210129/BCF-2010"


def get_variables():
    variables = {
        "HW_LOCATION_CODE": "Hangzhou",
        "TESTLINE_NAME": "10_5_UTESRAN1905",
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
