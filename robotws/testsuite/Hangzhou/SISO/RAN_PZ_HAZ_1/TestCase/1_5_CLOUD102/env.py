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
    "Unit power reset",
]


tl_config = sys.modules[__name__]

TESTLINE_TYPE = "FlexibleShare"  # this type is for GG


UE_TYPE = "CPE"

UE_INFO = [
           {
                "TYPE": "CPE",
                "MODEL": "Gemtek",    # Deming/Gemtek
                "BAND": "40,41",
                "IP": "192.168.1.5",
                "LAN_IP": "192.168.1.2",
                "DMZ": "no",
                "STATUS": "Enabled",
                "NETWORK_TYPE": "4G",
                "PA_List": "10.69.65.227"
            }
    ]

FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.69.66.67',
    'USERNAME': 'cloud1102',
    'PASSWORD': 'password1*',
    "BBU_PORT": "26;27;28;38;39;40;44;45;46",
    }

# How to define resource_id,
# GGIp+RRUType+self define id(optional)
# 10.56.7.209_FZQE
#
SHARE_RRU_INFO = {
    "BBU": {
        "OPTICAL_SWITCH_PORTS": "26:27:28:38:39:40:44:45:46"
    },
    "10.69.66.67_FZHN": {
        "OPTICAL_SWITCH_PORTS": "96:97"
    },
    "10.69.66.67_FZFI": {
        "OPTICAL_SWITCH_PORTS": "83:84:85:108:109:110:105:106:107"
    },
    "10.69.66.67_AZNA": {
        "OPTICAL_SWITCH_PORTS": "80:81:103:74:104:102:82:90:91:92:93"
    }

}

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME":    "15 min"
}
