import sys

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
UE_TYPE = "CPE"
REQUIRE_PACKAGES = "Active"

ADDITIONAL_ADMIN_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "Diagnostic Files collected",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "NTP Server .*?",
    "BTS time not corrected",
    "SSH enabled",
    "R&D Service Port enabled",
    "LMP access via port .*?",
    "BTS Reset Cause",
    "Service account root access is enabled",
    "Ethernet port security is disabled",
    "Sanity Check Error",
    "Nokia MN BTS SFP validation failure",
]

UE_INFO = [
    {
        "MODEL": "ZMTEL",  # Deming/Gemtek/ZMTEL
        "TYPE": "CPE",  # Deming/Gemtek/ZMTEL
        "BAND": "38,40,41,42",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "DMZ": "yes",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]

UUF_SW_STORAGE = {
    "LOGIN": "siso",
    "PASSWORD": "siso",
    "HOST_IP": "10.106.211.194",
    "SW_PATH": "/home/siso/LTE/UUF/",
}

SUPPORTED_CALL = True
SAS_SIM = False

tl_config = sys.modules[__name__]
