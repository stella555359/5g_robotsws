import sys

UE_INFO = [
    {
            "TYPE": "UE",
            "MODEL": "huawei",
            "SUB_MODEL": "Huawei P40",
            "UE_ID":  "0",
            "BAND": "78",
            "NETWORK_TYPE": "SA,NSA",
            "STATUS": "Enabled",
    },
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "5",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
    },
]

# SUPPORTED_CALL = False

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

TESTLINE_TYPE = "Flexible"
REQUIRE_PACKAGES = "Active"

ADDITIONAL_ADMIN_ALLOWED_ALARMS = [
                  'Vendor BTS certificate',
                  'Synchronization lost',
                  'Diagnostic Files collected',
                  'BTS booted at .*? due to trs management reset',
                  '.*? ToP master service .*? unusable',
                  'NTP Server .*? unavailable',
                  'SSH enabled',
                  'R&D Service Port enabled',
                  'LMP access via port.*',
                  'BTS internal SW management problem',
                  'Failure in optical interface',
                  'Receiving failure in Optical Interface',
                  'Unsigned software release has been successfully downloaded',
                  'Cell disabled due to unknown problem; logs collected',
                  'Unsigned software release has been successfully downloaded',
                  'BTS Reset Cause',
                  'Service account root access is enable',
                  'Ethernet port security is disabled',
                  'Sanity Check Error'
                  ]


tl_config = sys.modules[__name__]
