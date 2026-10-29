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
        "IP": "192.168.1.21",
        "LAN_IP": "192.168.1.2",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_List": "10.68.94.73",
    },
]
#
# IPERF_SERVER_INFO = {
#                      "IP" : "10.69.64.197",
#                      "CTRL_IP" : "10.69.64.196",
#                      "USERNAME" : "tdlte-tester",
#                      "PASSWORD" : "btstest",
#                      "PORT"     : "22",
#                      "LOG_PATH"  : "/home/tdlte-tester/UDP"
#             }


FW_INFO = {
    "TYPE": "CALIENT",
    "IP": "10.68.94.20",
    "USERNAME": "admin",
    "PASSWORD": "pxc***",
    "BBU_PORT": "1.1.5;1.1.6;1.1.7;1.1.8;1.5.5;1.2.6;1.5.7;1.2.8;1.3.5;1.3.6;1.3.7;1.3.8",
}


# GGMAP = [
#     # GG INFO .....Connected BBU_PORT INFO.....Connected RRU PORT INFO
#     {"DEVICE": "CALIENT",
#      "IP": "10.68.94.20",
#      "BTS6078":
#          {"USER": "admin",
#           "PSWD": "pxc***",
#           "productName": "AIRSCALE",  # FSMF/FSIH/AIRSCALE
#           "SMOD-1": {'SN': 'L1162013331'},
#           "BBMOD-1": {'SN': 'EA184380766'},
#           "BBMOD-2": {'SN': 'EA184380792'},
#           "BBU_GG_PORT_MAPPING":  # BBU_PORT:GG_PORT
#               {'BBMOD-1(1)': '1.1.1',
#                'BBMOD-1(2)': '1.1.2',
#                'BBMOD-2(1)': '1.1.3',
#                'BBMOD-2(2)': '1.1.4',
#                }
#           },
#
#      "AAHF":
#          {"productName": "AAHF",
#           "SN": "6Q184603086",
#           "RRU_GG_PORT_MAPPING":  # RRU_PORT:GG_PORT
#               {'1': '1.4.5',
#                '2': '1.4.6',
#                '3': '1.4.7',
#                '4': '1.4.8',
#                }
#           }
#
#      }
# ]


SHARE_RRU_INFO = {
    "BBU": {
         "OPTICAL_SWITCH_PORTS": "1.4.5:1.4.6:1.4.7:1.4.8"
     },
    "10.68.94.20_AAHF": {
          "OPTICAL_SWITCH_PORTS": "1.1.1:1.1.2:1.1.3:1.1.4:1.5.1:1.2.2:1.2.3:1.2.4:1.3.1:1.3.2:1.3.3:1.3.4:1.5.3"
     },
    "OTHRES": {
          "OPTICAL_SWITCH_PORTS": ""
     }
}

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME":    "15 min"
}
