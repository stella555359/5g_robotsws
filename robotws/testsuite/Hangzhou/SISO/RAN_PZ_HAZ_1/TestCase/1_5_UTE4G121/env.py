import sys

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

REQUIRE_PACKAGES = "Active"

ALLOWED_ALARMS = [
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

GLO_TL_DESCRIPTOR_FILE_PATH = (
    "/home/ute/testline_configuration/1_5_UTE4G121/TLdescriptor.xml"
)

UE_INFO = [
    {
        "TYPE": "CPE",
        "UE_ID": "0",
        "BAND": "3,38,40,41",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "MODEL": "Gemtek",
        "IP": "192.168.15.4",
        "LAN_IP": "192.168.15.224",
        "DMZ": "no",
        "PA_LIST": '10.108.151.144',
    },
    {
        "TYPE": "CPE",
        "UE_ID": "1",
        "BAND": "3,38,40,41",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "MODEL": "Gemtek",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.224",
        "DMZ": "no",
        "PA_LIST": '10.108.151.98',
    },
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "25",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "MODEL": "askey",
    },
]

FW_INFO = {
    "TYPE": "CALIENT",
    "IP": "10.108.151.115",
    "USERNAME": "admin",
    "PASSWORD": "pxc***",
    "BBU_PORT": "2.6.1;2.6.2;2.6.3;2.6.4;2.6.5;2.6.6;2.6.7",
}

SHARE_RRU_INFO = {
    "BBU": {"OPTICAL_SWITCH_PORTS": "2.6.1:2.6.2:2.6.3:2.6.4:2.6.5:2.6.6:2.6.7"},
    "10.108.151.115_AEHC1": {"OPTICAL_SWITCH_PORTS": "2.2.1"},
    "10.108.151.115_AEHC2": {"OPTICAL_SWITCH_PORTS": "2.2.2"},
    "10.108.151.115_AEHC3": {"OPTICAL_SWITCH_PORTS": "2.2.3"},
    "OTHRES": {"OPTICAL_SWITCH_PORTS": ""},
}

BTS_RELATED_PARAMETER = {"ONAIR_TIME": "20 min"}

UUF_SW_STORAGE = {
    "LOGIN": "siso",
    "PASSWORD": "siso",
    "HOST_IP": "10.106.211.194",
    "SW_PATH": "/home/siso/LTE/UUF/",
}

tl_config = sys.modules[__name__]
