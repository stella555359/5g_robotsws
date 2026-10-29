import sys

# UE_INFO = [
#     {
#         "TYPE": "Dingli",
#         "MODEL": "huawei",
#         "SUB_MODEL": "Dingli",
#         "UE_ID": "0",
#         "BAND": "1,3",
#         "NETWORK_TYPE": "4G",
#         "STATUS": "Enabled",
#         "APN": "stdata2",
#         "RESET": False
#     }
# ]

UE_INFO = [
    {
        "TYPE": "SISO_UE",
        "MODEL": "AT_dingli",
        "SUB_MODEL": "dingli",
        "UE_ID": "0",
        "BAND": "1,3",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "APN": "stdata2",
        "ALL_CELL_BARRED": "True",
        "RESET": False,
    },
]

ADDITIONAL_ALLOWED_ALARMS = [
    'Vendor BTS certificate',
    'Synchronization lost',
    'Diagnostic Files collected',
    'BTS booted at .*? due to trs management reset',
    '.*? ToP master service .*? unusable',
    'NTP Server .*? unavailable',
    'SSH enabled',
    'R&D Service Port enabled',
    'LMP access via port.*',
    'Ethernet port security is disabled',
    'Service account root access is enabled',
    'BTS Reset Cause',
    'Beamforming Calibration Detect Continuous Exception',
    'Failure in connection to Real-time PM Collection Entity',
    'Sanity Check Error'
]

FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.56.7.147',
    'USERNAME': 'BTS1786',
    'PASSWORD': 'SISO1_test',
    'BBU_PORT': "98"
}

tl_config = sys.modules[__name__]
