# BSC = {"ip": "10.107.151.137", "password": "SYSTEM", "user": "SYSTEM"}
# RNC = {
#    "RNC_IP": "10.69.28.173",
#    "RNC_PASSWORD": "root",
#    "RNC_USER": "root",
#    "OMS_IP": "10.68.171.228",
#    "ID": "511",
# }

MRBTS_DN = "PLMN-PLMN/MRBTS-1816"
WCDMA_DN = "PLMN-PLMN/RNC-511/WBTS-1909"
GSM_DN = "PLMN-PLMN/BSC-210129/BCF-1909"

# SMOD1 = {
#    "HW_TYPE": "ASIB",
#   "USERNAME": "toor4nsn",
#    "PASSWORD": "oZPS0POrRieRtu",
#    "UDP_IP": "192.168.255.126",
#    "IP": "192.168.255.129",
#    "TRS_IP": "192.168.255.129",
#    "IM_IP": "192.168.255.129",
# }
# SMOD2 = {
#    "HW_TYPE": "ASIB",
#    "USERNAME": "toor4nsn",
#    "PASSWORD": "oZPS0POrRieRtu",
#    "UDP_IP": "192.168.255.126",
#    "IP": "192.168.255.3",
# }


def get_variables():
    variables = {
        "HW_LOCATION_CODE": "Hangzhou",
        "TESTLINE_NAME": "10_5_UTESRAN1816",
        "TEMP_LOGS_DIR": "/home/ute/logs",
        "BTS_USERNAME": "toor4nsn",
        "BTS_PASSWORD": "oZPS0POrRieRtu",
        # "PC_IP1": "10.97.78.55",
        # "PC_IP2": "10.97.78.56",
        # "MPLANE_IP": "10.68.159.212",
        "MAX_UDP_SIZE": "104857600",
        "SUBRACK": "1",
        # "SMOD1": SMOD1,
        # "SMOD2": SMOD2,
        # "BSC": BSC,
        # "RNC": RNC,
        "MRBTS_DN": MRBTS_DN,
        "WCDMA_DN": WCDMA_DN,
        "GSM_DN": GSM_DN,
    }

    return variables
