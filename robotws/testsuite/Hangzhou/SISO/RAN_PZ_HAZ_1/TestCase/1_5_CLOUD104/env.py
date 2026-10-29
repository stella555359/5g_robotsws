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

TESTLINE_TYPE = "FlexibleShare"  # this type is for GG


UE_TYPE = "CPE"

UE_INFO = [
           {
            "TYPE": "CPE",
            "MODEL": "Gemtek",  # Deming/Gemtek
            "BAND": "38,40,41",
            "IP": "192.168.1.1",
            "LAN_IP": "192.168.1.3",
            "DMZ": "no",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G",
            "PA_List": "10.69.238.68"
            },
           {
                "TYPE": "CPE",
                "MODEL": "Gemtek",  # Deming/Gemtek
                "BAND": "38,40,41",
                "IP": "192.168.1.7",
                "LAN_IP": "192.168.1.3",
                "DMZ": "no",
                "STATUS": "Enabled",
                "NETWORK_TYPE": "4G",
                "PA_List": "10.69.68.98"
            },
           {
                "TYPE": "CPE",
                "MODEL": "Deming",  # Deming/Gemtek
                "BAND": "39",
                "IP": "192.168.1.8",
                "LAN_IP": "192.168.1.3",
                "DMZ": "yes",
                "STATUS": "Enabled",
                "NETWORK_TYPE": "4G",
                "PA_List": "10.69.68.98"
            },
           {
                "TYPE": "CPE",
                "MODEL": "Gemtek",  # Deming/Gemtek
                "BAND": "42",
                "IP": "192.168.1.9",
                "LAN_IP": "192.168.1.3",
                "DMZ": "no",
                "STATUS": "Enabled",
                "NETWORK_TYPE": "4G",
                "PA_List": "10.69.68.98"
            },
           {
                "TYPE": "CPE",
                "MODEL": "ZMTEL_old",  # Deming/Gemtek
                "BAND": "48",
                "IP": "192.168.1.15",
                "LAN_IP": "192.168.1.3",
                "DMZ": "no",
                "STATUS": "Enabled",
                "NETWORK_TYPE": "4G",
                "PA_List": "10.69.68.98"
            }
    ]


FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.69.238.69',
    'USERNAME': 'BTS2512_2274_Share',
    'PASSWORD': 'SISO2_test',
    "BBU_PORT": "37;38;39",
    }


SHARE_RRU_INFO = {
    "BBU": {
        "OPTICAL_SWITCH_PORTS": "37:38:39"
    },
    "10.69.238.69_AZND": {
        "OPTICAL_SWITCH_PORTS": "13:15:17:19:21:23"
    },
    "10.69.238.69_FZFH": {
        "OPTICAL_SWITCH_PORTS": "31:33:35:51"
    }

}

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME":    "20 min",
    "SAS_SIM":    "True"
}
