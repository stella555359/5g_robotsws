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


tl_config = sys.modules[__name__]

TESTLINE_TYPE = "FlexibleShare"   # this type is for GG

UE_TYPE = "CPE"
# UE_TYPE = "Real_UE"

UE_INFO = [
           {
            "TYPE": "CPE",
            "MODEL": "Deming",   # Deming/Gemtek
            "BAND": "39",
            "IP": "192.168.1.22",
            "LAN_IP": "192.168.1.2",
            "DMZ": "yes",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G",
            "PA_List": "10.56.7.246"
            },

           {
            "TYPE": "CPE",
            "MODEL": "Deming",   # Deming/Gemtek
            "BAND": "39",
            "IP": "192.168.1.23",
            "LAN_IP": "192.168.1.2",
            "DMZ": "yes",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G",
            "PA_List": "10.56.7.164"
            },

           {
            "TYPE": "CPE",
            "MODEL": "Gemtek",   # Deming/Gemtek
            "BAND": "41",
            "IP": "192.168.1.24",
            "LAN_IP": "192.168.1.2",
            "DMZ": "no",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G",
            "PA_List": "10.56.7.164"
            }
    ]

IPERF_SERVER_INFO = {
                     "IP": "10.69.64.197",
                     "CTRL_IP": "10.69.64.196",
                     "USERNAME": "tdlte-tester",
                     "PASSWORD": "btstest",
                     "PORT": "22",
                     "LOG_PATH": "/home/tdlte-tester/UDP"
            }


FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.56.7.209',
    'USERNAME': 'FZFH001',
    'PASSWORD': 'yss-fsih002',
    "BBU_PORT": "33;35;26",
    }

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME":    "10 min",
    "PACKAGE_TYPE":  "CMCC"
}


SHARE_RRU_INFO = {
     "BBU": {
         "OPTICAL_SWITCH_PORTS": "33:34:35:36:26:38:39:40:41:42:43:44:45:46:47:48:49:50"
     },
     "10.56.7.209_FZFH": {
         "OPTICAL_SWITCH_PORTS": "114"
     }

 }
