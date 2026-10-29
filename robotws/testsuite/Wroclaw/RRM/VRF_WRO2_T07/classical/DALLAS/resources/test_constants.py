allowed_alarms = ["4655", "4654", "61524", "61652", "61649"]
BTS_ID = 0
CU_ID = 0

UE_ALIAS = 'UE_1'
UE_ALIAS_2 = "UE_2"
ATTENUATOR_ALIAS = "ATTEN_1"
TPUT_DURATION_7145 = "60s"
TPUT_DURATION_8930 = "120s"
EXPECTED_TPUT_8930_UE_1 = "80Mbits/sec"
EXPECTED_TPUT_8930_UE_2 = "10Mbits/sec"
TPUT_DEVIATION = "10%"

# ATTACH_CELL = "MRBTS-55270/NRBTS-55270/NRCELL-32"
ATTACH_CELL = "MRBTS-55270/NRBTS-55270/NRCELL-41"
CELLS_TO_LOCK = {
    "MRBTS-55270/NRBTS-55270/NRCELL-31",
    "MRBTS-55270/NRBTS-55270/NRCELL-51",
}
ATTACH_CELL_8930 = "MRBTS-55270/NRBTS-55270/NRCELL-301"
ATTACH_CELL_ATTENUATION = 0
CELL_ATTENUATION_PORTS = {
    "MRBTS-55270/NRBTS-55270/NRCELL-41": [9, 10, 11, 12],
    "MRBTS-55270/NRBTS-55270/NRCELL-32": [13, 14, 15, 16],
    "MRBTS-55270/NRBTS-55270/NRCELL-301": [17, 18, 19, 20],
}
CELL_30MHZ_GLOBAL_ID = 33

THROUGHPUT_COUNTERS = ["M55349C02001", "M55350C04001"]
FALLBACK_COUNTERS = ["M55124C02501", "M55124C01502"]

MISSING_CONFIG_CHECKPOINT_NAME = "Configuration file presence on the active partition"
INVALID_CONFIG_CHECKPOINT_NAME = "Configuration file validity on the active partition"


FEATURE_8930_DELTA = [
    {
        "distName": ATTACH_CELL_8930,
        "operation": "update",
        "parameters": [{"operation": "update", "parameterName": "actFullPwrMode", "value": "<filled_in_test>"}],
    }
]


REDIR_FALLBACK_DELTA = [
    {
        "distName": "MRBTS-{}/NRBTS-{}",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "actNormVCFallback", "value": "true"},
            {"operation": "update", "parameterName": "actRedirect", "value": "true"},
        ],
    },
    {
        "distName": "MRBTS-{}/NRBTS-{}/NRPMRNL-1",
        "operation": "update",
        "parameters": [{"operation": "update", "parameterName": "miNrRRCC", "value": "5min"}],
    },
    {
        "distName": ATTACH_CELL,
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "voiceFBMode", "value": "redirection"},
        ],
    },
]

FEATURE_5832_DELTA = [
    {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [{"operation": "update", "parameterName": "actLbmOnFronthaul", "value": "true"}],
    },
    {
        "distName": "MRBTS-{}/MNL-1",
        "operation": "update",
        "parameters": [{"operation": "update", "parameterName": "actNcYgMPlane", "value": "false"}],
    },
    {
        "distName": "MRBTS-{}/TNLSVC-1/TNL-2/ETHAPP-1",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "serviceOamEnabled", "value": "true"},
            {"operation": "update", "parameterName": "remoteMepMacAutoLearningEnabled", "value": "false"},
        ],
    },
]

SFP_DELTA = [
    {
        "distName": "MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-4/SFP-1/LANE-1",
        "operation": "update",
        "parameters": [{"operation": "update", "parameterName": "administrativeState", "value": "<filled_in_test>"}],
    }
]
