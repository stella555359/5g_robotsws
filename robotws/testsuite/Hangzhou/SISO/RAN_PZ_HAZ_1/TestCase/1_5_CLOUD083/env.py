import sys

REQUIRE_PACKAGES = "Active"

UE_INFO = [
    {
            "TYPE": "Dingli",
            "MODEL": "huawei",
            "SUB_MODEL": "Huawei P40",
            "UE_ID":  "0",
            "BAND": "2,4",
            "NETWORK_TYPE": "4G",
            "STATUS": "Enabled",
            "APN": "stdata1",
            "RESET": False
    }
]

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

TESTLINE_TYPE = "Flexible"

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
                  'Service account root access is enabled',
                  'Receiving failure in Optical Interface',
                  'Unsigned software release has been successfully downloaded',
                  'Cell disabled due to unknown problem; logs collected',
                  'Unsigned software release has been successfully downloaded',
                  'BTS Reset Cause',
                  'VSWR major alarm',
                  'Ethernet port security is disabled',
                  'Sanity Check Error'
]

tl_config = sys.modules[__name__]
