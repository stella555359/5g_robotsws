import sys

UE_TYPE = "CPE"

CPE_INFO = [
    {
            "TYPE": "Gemtek",
            "BAND": "42,43",
            "IP": "192.168.1.22",
            "LAN_IP": "192.168.1.2",
            "DMZ": "no",
            "STATUS": "Enabled",
            "PA_List": "10.56.7.191"
    },
    {
            "TYPE": "Gemtek",
            "BAND": "42",
            "IP": "192.168.1.28",
            "LAN_IP": "192.168.1.2",
            "STATUS": "Enabled",
            "DMZ": "no",
            "PA_List": "10.106.211.112"
    },
]
UE_INFO = [
    {
            "TYPE": "CPE",
            "MODEL": "Gemtek",
            "IP": "192.168.1.22",
            "LAN_IP": "192.168.1.2",
            "BAND": "42,43",
            "DMZ": "no",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G"
    },
    {
            "TYPE": "CPE",
            "MODEL": "Gemtek",
            "IP": "192.168.1.28",
            "LAN_IP": "192.168.1.2",
            "BAND": "42",
            "DMZ": "no",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G"
    },
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
    'USERNAME': 'FZQE',
    'PASSWORD': 'SISO2_test',
    'BBU_PORT': "27;28;29;30"
}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

TESTLINE_TYPE = "Flexible"
REQUIRE_PACKAGES = "Active"

ALLOWED_ALARMS = ['Vendor BTS certificate',
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
