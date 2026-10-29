import sys

REQUIRE_PACKAGES = "Active"
UE_INFO = [
   {
        "TYPE": "CPE",
        "MODEL": "Deming",
        "BAND": "39",
        "IP": "192.168.1.5",
        "LAN_IP": "192.168.1.126",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    },
]

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME": "15 min",
    "PACKAGE_TYPE": "CMCC"
}

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
    'Ethernet port security is disabled',
    'Service account root access is enabled',
    'BTS Reset Cause',
    'Beamforming Calibration Detect Continuous Exception',
    'Failure in connection to Real-time PM Collection Entity',
    'Sanity Check Error'
]


tl_config = sys.modules[__name__]
