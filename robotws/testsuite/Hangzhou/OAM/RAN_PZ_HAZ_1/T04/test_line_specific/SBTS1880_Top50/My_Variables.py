MRBTS_DN = "PLMN-PLMN/MRBTS-1880"
WCDMA_DN = "PLMN-PLMN/RNC-511/WBTS-1890"
GSM_DN = "PLMN-PLMN/BSC-210129/BCF-2010"

SMOD1 = {
    "HW_TYPE": "ASIA",
    "USERNAME": "toor4nsn",
    "PASSWORD": "oZPS0POrRieRtu",
    "UDP_IP": "192.168.255.126",
    "IP": "192.168.255.129",
    "TRS_IP": "192.168.255.129",
    "IM_IP": "192.168.255.129",
}


def get_variables():
    variables = {
        "HW_LOCATION_CODE": "Hangzhou",
        # "TESTLINE_NAME": "10_5_5G-1881-4G-1880_MRBTS-1880",
        "TESTLINE_NAME": "10_5_UTESRAN1880",
        "TEMP_LOGS_DIR": "/home/ute/logs",
        "BTS_USERNAME": "toor4nsn",
        "BTS_PASSWORD": "oZPS0POrRieRtu",
        "MAX_UDP_SIZE": "104857600",
        "SUBRACK": "1",
        "MRBTS_DN": MRBTS_DN,
        "WCDMA_DN": WCDMA_DN,
        "GSM_DN": GSM_DN,
        "SMOD1": SMOD1,
    }

    return variables
