import sys

REQUIRE_PACKAGES = "Active"

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "UE_ID": "NA",
        "BAND": "39,40,41",
        "NETWORK_TYPE": "4G",
        "IP": "192.168.1.10",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "DMZ": "no",
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
    'IP': '10.56.7.182',
    'USERNAME': 'admin',
    'PASSWORD': 'password',
    'BBU_PORT': "19:36;38;50;20;44;28"
}

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME": "30 min",
    "PACKAGE_TYPE": "CMCC",
}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

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
    'Service account root access is enabled',
    'Ethernet port security is disabled',
    'Sanity Check Error'
                  ]

tl_config = sys.modules[__name__]
