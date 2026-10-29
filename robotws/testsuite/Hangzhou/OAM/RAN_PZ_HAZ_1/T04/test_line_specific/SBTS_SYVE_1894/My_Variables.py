ONAP_SIMULATOR = {
    "host_ip": "10.21.41.141",
    "user": "ute",
    "pwd": "UTE.debian12",
}

MRBTS_DN = "PLMN-PLMN/MRBTS-1894"
WCDMA_DN = "PLMN-PLMN/RNC-511/WBTS-1909"
GSM_DN = "PLMN-PLMN/BSC-210129/BCF-1909"

PDU1 = {
        "model": "FACOM",
        "IP": "10.70.19.53",
        "ports": [1, 2, 3, 4, 6, 8]
    }
PDU2 = {
        "model": "HBTE",
        "IP": "10.70.14.132",
        "ports": [1]
    }


def get_variables():
    variables = {
        "HW_LOCATION_CODE": "Hangzhou",
        "TESTLINE_NAME": "10_5_UTESRAN1894",
        "TEMP_LOGS_DIR": "/home/ute/logs",
        "BTS_USERNAME": "toor4nsn",
        "BTS_PASSWORD": "oZPS0POrRieRtu",
        "MAX_UDP_SIZE": "104857600",
        "SUBRACK": "1",
        "ONAP": ONAP_SIMULATOR,
        "MRBTS_DN": MRBTS_DN,
        "WCDMA_DN": WCDMA_DN,
        "GSM_DN": GSM_DN,
        "PDU": [PDU1, PDU2]
    }

    return variables
