ONAP_SIMULATOR = {
    "host_ip": "10.5.19.83",
    "user": "ute",
    "pwd": "UTE.debian12",
}

MRBTS_DN = "PLMN-PLMN/MRBTS-621022"
WCDMA_DN = "PLMN-PLMN/RNC-511/WBTS-621022"
GSM_DN = "PLMN-PLMN/BSC-210129/BCF-621022"

PDU1 = {
        "model": "EPC",
        "IP": "10.255.5.215",
        "ports": [1, 4, 7, 8,]
    }
PDU2 = {
        "model": "EPC",
        "IP": "10.255.5.216",
        "ports": [5, 6]
    }


def get_variables():
    variables = {
        "HW_LOCATION_CODE": "Timisoara",
        "TESTLINE_NAME": "10_18_UTESRANRFSMTNRL22",
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
