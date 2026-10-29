import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "huawei",
        "SUB_MODEL": "Huawei MATE30 PRO",
        "UE_ID": "0",
        "BAND": "1,3",
        "NETWORK_TYPE": "SA",
        # "NETWORK_TYPE": "SA,NSA",
        "STATUS": "Enabled",
    },
    {
        "TYPE": "UE",
        "MODEL": "askey_order",
        "UE_ID": "1",
        "BAND": "66",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        # "INDEX": "0",
        "RESET": "TRUE"
    },
]

ADDITIONAL_ADMIN_ALLOWED_ALARMS = \
    [
        'Vendor BTS certificate',
        'Synchronization lost',
        'Diagnostic Files collected',
        'BTS booted at .*? due to trs management reset',
        '.*? ToP master service .*? unusable',
        'NTP Server .*?',
        'BTS time not corrected',
        'SSH enabled',
        'R&D Service Port enabled',
        'LMP access via port .*?',
        'BTS Reset Cause',
        'Beamforming Calibration Detect Continuous Exception',
        'Service account root access is enabled',
        'Ethernet port security is disabled',
        'Sanity Check Error',
        'Increased BER detected on the optical connection to Radio Module'
    ]

tl_config = sys.modules[__name__]
